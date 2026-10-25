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
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/screens/show_me_tell_screen.dart';
import 'support/test_app.dart';

// Text from the bundled question bank.
const _headRestraintAnswer = 'The head restraint should be adjusted';

void main() {
  late FakePlatform platform;

  // Each test loads the questions itself; a copy cached by an earlier
  // test belongs to that test's fake clock and never completes here.
  setUp(() {
    platform = FakePlatform.install();
    rootBundle.evict(ShowMeTellMeScreen.questionsAsset);
  });

  Future<void> pumpQuestions(WidgetTester tester) async {
    await pumpWithProviders(tester, const ShowMeTellMeScreen());
    await waitForAssets(tester);
    await tester.pumpAndSettle();
  }

  Finder questionsOfType(String type) => find.byWidgetPredicate(
    (w) => w is Text && (w.textSpan?.toPlainText() ?? '').startsWith(type),
  );

  Finder question(String text) => find.byWidgetPredicate(
    (w) => w is Text && (w.textSpan?.toPlainText() ?? '').contains(text),
  );

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
  }

  Future<void> chooseFilter(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Filter questions'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckedPopupMenuItem<String>, label));
    await tester.pumpAndSettle();
  }

  testWidgets('lists both show and tell questions', (tester) async {
    await pumpQuestions(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(questionsOfType('TELL'), findsWidgets);

    await chooseFilter(tester, 'Show');
    expect(questionsOfType('SHOW'), findsWidgets);
  });

  group('filter', () {
    testWidgets('keeps only the chosen type', (tester) async {
      await pumpQuestions(tester);
      expect(questionsOfType('TELL'), findsWidgets);

      await chooseFilter(tester, 'Show');

      expect(questionsOfType('SHOW'), findsWidgets);
      expect(questionsOfType('TELL'), findsNothing);
    });

    // A regression test: "All" used to be ignored once a type was chosen.
    testWidgets('All shows every type again', (tester) async {
      await pumpQuestions(tester);
      await search(tester, 'dipped');

      await chooseFilter(tester, 'Show');
      expect(questionsOfType('TELL'), findsNothing);

      await chooseFilter(tester, 'All');
      expect(questionsOfType('TELL'), findsWidgets);
      expect(questionsOfType('SHOW'), findsWidgets);
    });

    testWidgets('keeps the search text', (tester) async {
      await pumpQuestions(tester);

      await search(tester, 'brakes');
      await chooseFilter(tester, 'Tell');

      expect(find.text('brakes'), findsOneWidget);
      expect(questionsOfType('TELL'), findsOneWidget);
      expect(questionsOfType('SHOW'), findsNothing);
    });
  });

  testWidgets('explains when nothing matches the search', (tester) async {
    await pumpQuestions(tester);

    await search(tester, 'submarine');

    expect(find.text('No questions match your search.'), findsOneWidget);
  });

  group('practice', () {
    testWidgets('tapping a tell question reveals its answer', (tester) async {
      await pumpQuestions(tester);
      await search(tester, 'head restraint');

      await tester.tap(question('head restraint'));
      await tester.pumpAndSettle();

      expect(find.text('Answer'), findsOneWidget);
      expect(find.textContaining(_headRestraintAnswer), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Answer'), findsNothing);
    });

    testWidgets('show questions have no answer to reveal', (tester) async {
      await pumpQuestions(tester);
      await search(tester, 'horn');

      await tester.tap(question('horn'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('the eye button shows every answer inline', (tester) async {
      await pumpQuestions(tester);
      await search(tester, 'head restraint');
      expect(find.textContaining(_headRestraintAnswer), findsNothing);

      await tester.tap(find.byTooltip('Practice Mode'));
      await tester.pumpAndSettle();
      expect(find.textContaining(_headRestraintAnswer), findsOneWidget);

      // With answers on show, tapping no longer opens a dialog.
      await tester.tap(question('head restraint'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      await tester.tap(find.byTooltip('Test Mode'));
      await tester.pumpAndSettle();
      expect(find.textContaining(_headRestraintAnswer), findsNothing);
    });

    testWidgets('reads a question aloud', (tester) async {
      await pumpQuestions(tester);
      await search(tester, 'horn');

      await tester.tap(find.byTooltip('Read question aloud'));
      await tester.pumpAndSettle();

      expect(platform.spoken, [
        "When it's safe to do so, can you show me how you'd operate the horn?",
      ]);
    });
  });

  // The Open Government Licence requires the source to be credited.
  testWidgets('credits and links to the question source', (tester) async {
    await pumpQuestions(tester);
    await search(tester, 'horn');

    expect(find.text(AppConstants.questionsAttribution), findsOneWidget);

    await tester.tap(find.text('Source: GOV.UK'));
    await tester.tap(find.text('Open Government Licence'));
    await tester.pump();

    expect(platform.urls.launched, [
      AppConstants.questionsSourceUrl,
      AppConstants.oglUrl,
    ]);
  });
}
