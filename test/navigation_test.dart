/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/main.dart';
import 'package:steer_wise/src/navigation/persistent_nav.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'package:steer_wise/src/screens/show_me_tell_screen.dart';
import 'package:steer_wise/src/screens/splash_screen.dart';
import 'support/test_app.dart';

// Pumps long enough for page and tab transitions to finish. Once started,
// the driving simulation never settles, so pumpAndSettle is not used.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _openTab(WidgetTester tester, String title) async {
  await tester.tap(
    find.descendant(
      of: find.byType(Style4BottomNavBar),
      matching: find.text(title),
    ),
  );
  await _settle(tester);
}

/// Whether [screen]'s tickers (animations, simulation, camera) are running.
bool _isActive(WidgetTester tester, Type screen) => TickerMode.valuesOf(
  tester.element(find.byType(screen, skipOffstage: false)),
).enabled;

void main() {
  setUp(FakePlatform.install);

  group('splash screen', () {
    testWidgets('moves on to the app after a few seconds', (tester) async {
      await pumpWithProviders(tester, const SplashScreen());
      expect(find.text('SteerWise'), findsOneWidget);

      await tester.pump(SplashScreen.duration);
      await _settle(tester);

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BottomNav), findsOneWidget);
    });

    testWidgets('can be skipped with a tap', (tester) async {
      await pumpWithProviders(tester, const SplashScreen());

      await tester.tap(find.byType(SplashScreen));
      await _settle(tester);

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BottomNav), findsOneWidget);
    });
  });

  group('bottom navigation', () {
    testWidgets('opens on Home and switches between tabs', (tester) async {
      await pumpWithProviders(tester, const BottomNav());
      await _settle(tester);
      expect(_isActive(tester, HomeScreen), isTrue);

      await _openTab(tester, 'Show Me/Tell Me');
      expect(find.text('Show Me & Tell Me'), findsOneWidget);
      expect(_isActive(tester, ShowMeTellMeScreen), isTrue);

      expect(_isActive(tester, HomeScreen), isFalse);

      await _openTab(tester, 'Home');
      expect(_isActive(tester, HomeScreen), isTrue);
    });

    // Otherwise the camera and simulation would keep running out of sight.
    testWidgets('pauses the Home tab while another tab is open', (
      tester,
    ) async {
      await pumpWithProviders(tester, const BottomNav());
      await _settle(tester);

      await _openTab(tester, 'Show Me/Tell Me');

      expect(_isActive(tester, HomeScreen), isFalse);
    });
  });

  group('whole app', () {
    Future<SharedPreferences> launchApp(
      WidgetTester tester, [
      Map<String, Object> saved = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(saved);
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(SteerWiseRoot(prefs: prefs));
      await tester.tap(find.byType(SplashScreen));
      await _settle(tester);
      return prefs;
    }

    Brightness brightness(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(BottomNav))).brightness;

    testWidgets('starts with the saved theme', (tester) async {
      await launchApp(tester, {'themeMode': 'dark'});

      expect(brightness(tester), Brightness.dark);
    });

    testWidgets('changing the theme in the menu saves it', (tester) async {
      final prefs = await launchApp(tester, {'themeMode': 'light'});
      expect(brightness(tester), Brightness.light);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await _settle(tester);
      await tester.tap(find.text('Dark'));
      await _settle(tester);

      expect(brightness(tester), Brightness.dark);
      expect(prefs.getString('themeMode'), 'dark');
      // The menu stays open so the choice can be changed again.
      expect(find.byType(Drawer), findsOneWidget);
    });
  });
}
