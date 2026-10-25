/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// End-to-end tests of the real app on a device or emulator, with real
// plugins (preferences, camera, speech).
//
// Run on any connected device:
//   flutter test integration_test
// Run as Android instrumentation tests (grants camera access first):
//   make android-test

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/main.dart';
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/navigation/persistent_nav.dart';
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'package:steer_wise/src/screens/home_screen.dart';

/// Pumps frames until [finder] matches, failing after [timeout].
///
/// The driving simulation animates for as long as it runs, so
/// pumpAndSettle cannot be used while it is driving.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      fail('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps frames for [duration], for animations to finish.
Future<void> _pumpFor(
  WidgetTester tester, [
  Duration duration = const Duration(milliseconds: 800),
]) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await _pumpFor(tester);
}

Future<void> _openTab(WidgetTester tester, String title) => _tapAndWait(
  tester,
  find.descendant(
    of: find.byType(Style4BottomNavBar),
    matching: find.text(title),
  ),
);

/// Types [text] into the question search box.
Future<void> _search(WidgetTester tester, String text) async {
  // Tap first: on a device the box loses its input connection whenever a
  // dialog opens over it.
  await tester.tap(find.byType(TextField));
  await tester.pump();
  await tester.enterText(find.byType(TextField), text);
  await _pumpFor(tester);
}

Finder _questionContaining(String text) => find.byWidgetPredicate(
  (w) => w is Text && (w.textSpan?.toPlainText() ?? '').contains(text),
);

Brightness _brightness(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(BottomNav))).brightness;

/// Starts the app as main() does and waits for the splash screen to hand
/// over to the Home tab.
Future<SharedPreferences> _launchApp(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(SteerWiseRoot(prefs: prefs));
  expect(find.text(AppConstants.appName), findsOneWidget);
  await _pumpUntil(tester, find.byType(HomeScreen));
  await _pumpFor(tester);
  return prefs;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  testWidgets('start, crash, retry, pause and stop driving', (tester) async {
    await _launchApp(tester);
    expect(find.text(AppConstants.instructions.first), findsOneWidget);

    await _tapAndWait(
      tester,
      find.widgetWithText(ElevatedButton, 'Next Instruction'),
    );
    expect(find.text(AppConstants.instructions[1]), findsOneWidget);

    // Nothing moves until the user starts driving.
    expect(find.text('Tap to start driving'), findsOneWidget);
    await _tapAndWait(tester, find.byTooltip('Start driving'));
    expect(find.byTooltip('Pause'), findsOneWidget);

    // The first oncoming car always uses the right lane.
    await tester.tap(find.byTooltip('Steer right'));
    await _pumpUntil(tester, find.text('Collision detected'));

    await _tapAndWait(tester, find.text('Retry'));
    expect(find.text('Collision detected'), findsNothing);
    expect(find.text('Score: 0'), findsOneWidget);

    // Pause and stop before the random traffic that follows can arrive.
    await _tapAndWait(tester, find.byTooltip('Pause'));
    expect(find.text('Paused: tap to resume'), findsOneWidget);
    await _tapAndWait(tester, find.byTooltip('Stop'));
    expect(find.text('Tap to start driving'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
  });

  testWidgets('practise Show Me/Tell Me questions', (tester) async {
    await _launchApp(tester);
    await _openTab(tester, 'Show Me/Tell Me');
    await _pumpUntil(tester, _questionContaining('TELL'));

    await _search(tester, 'head restraint');
    await _tapAndWait(tester, _questionContaining('head restraint'));
    expect(find.text('Answer'), findsOneWidget);
    await _tapAndWait(tester, find.text('Close'));
    expect(find.text('Answer'), findsNothing);

    await _search(tester, 'dipped');
    await _tapAndWait(tester, find.byTooltip('Filter questions'));
    await _tapAndWait(
      tester,
      find.widgetWithText(CheckedPopupMenuItem<String>, 'Show'),
    );
    expect(_questionContaining('TELL'), findsNothing);
    await _tapAndWait(tester, find.byTooltip('Filter questions'));
    await _tapAndWait(
      tester,
      find.widgetWithText(CheckedPopupMenuItem<String>, 'All'),
    );
    expect(_questionContaining('TELL'), findsOneWidget);
    expect(_questionContaining('SHOW'), findsOneWidget);

    await _search(tester, 'submarine');
    expect(find.text('No questions match your search.'), findsOneWidget);
  });

  testWidgets('the chosen theme is saved and restored', (tester) async {
    final prefs = await _launchApp(tester);
    await _openTab(tester, 'Settings');

    await _tapAndWait(tester, find.text('Dark'));
    expect(_brightness(tester), Brightness.dark);
    expect(prefs.getString('themeMode'), 'dark');

    await _tapAndWait(tester, find.text('Light'));
    expect(_brightness(tester), Brightness.light);

    // Start the app again: the saved theme is used straight away.
    await tester.pumpWidget(const SizedBox());
    await _launchApp(tester);
    expect(_brightness(tester), Brightness.light);
    await _openTab(tester, 'Settings');
  });

  testWidgets('menu opens About and the bundled documents', (tester) async {
    await _launchApp(tester);
    await _openTab(tester, 'Settings');

    await _tapAndWait(tester, find.byTooltip('Open navigation menu'));
    await _tapAndWait(tester, find.widgetWithText(ListTile, 'About'));
    expect(find.byType(AboutScreen), findsOneWidget);
    await _pumpUntil(tester, find.textContaining('Version '));

    await _tapAndWait(tester, find.widgetWithText(ListTile, 'Licence'));
    expect(find.byType(DocumentScreen), findsOneWidget);
    await _pumpUntil(tester, find.textContaining('MIT License'));

    await _tapAndWait(tester, find.byTooltip('Back'));
    await _tapAndWait(tester, find.byTooltip('Back'));
    expect(find.byType(AboutScreen), findsNothing);
    expect(find.byType(BottomNav), findsOneWidget);
  });
}
