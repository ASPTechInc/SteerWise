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
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'package:steer_wise/src/screens/help_screen.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'support/test_app.dart';

const _instructions = AppConstants.instructions;

void main() {
  late FakePlatform platform;

  setUp(() => platform = FakePlatform.install());

  // The driving simulation waits for the user to press play, so its random
  // traffic stays still during these tests.
  Future<void> pumpHome(WidgetTester tester) async {
    await pumpWithProviders(tester, const HomeScreen());
    await tester.pump();
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.widgetWithText(ElevatedButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> openMenuItem(WidgetTester tester, String item) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(ListTile, item));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('shows the camera, first instruction and simulation', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(_instructions.first), findsOneWidget);
    expect(find.text('Camera access is off.'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.text('Tap to start driving'), findsOneWidget);
  });

  testWidgets('Next Instruction moves on and reads it aloud', (tester) async {
    await pumpHome(tester);

    await tapButton(tester, 'Next Instruction');

    expect(find.text(_instructions[1]), findsOneWidget);
    expect(find.text(_instructions.first), findsNothing);
    expect(platform.spoken, [_instructions[1]]);
  });

  testWidgets('instructions start again after the last one', (tester) async {
    await pumpHome(tester);

    for (var i = 0; i < _instructions.length; i++) {
      await tapButton(tester, 'Next Instruction');
    }

    expect(find.text(_instructions.first), findsOneWidget);
    expect(platform.spoken, [..._instructions.skip(1), _instructions.first]);
  });

  testWidgets('auto mode gives a new instruction every 8 seconds', (
    tester,
  ) async {
    await pumpHome(tester);

    await tapButton(tester, 'Start Auto Mode');
    expect(find.text('Stop Auto Mode'), findsOneWidget);
    expect(find.text(_instructions.first), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));
    await tester.pump();
    expect(find.text(_instructions[1]), findsOneWidget);

    await tester.pump(const Duration(seconds: 8));
    await tester.pump();
    expect(find.text(_instructions[2]), findsOneWidget);

    await tapButton(tester, 'Stop Auto Mode');
    expect(find.text('Start Auto Mode'), findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
    expect(find.text(_instructions[2]), findsOneWidget);
    expect(platform.spoken, [_instructions[1], _instructions[2]]);
  });

  testWidgets('Get Feedback shows a tip', (tester) async {
    await pumpHome(tester);

    await tapButton(tester, 'Get Feedback');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Good job!'), findsOneWidget);
  });

  group('menu', () {
    testWidgets('opens Help', (tester) async {
      await pumpHome(tester);

      await openMenuItem(tester, 'Help');

      expect(find.byType(HelpScreen), findsOneWidget);
    });

    testWidgets('opens About', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: AppConstants.appName,
        packageName: 'com.asptechinc.steerwise',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      await pumpHome(tester);

      await openMenuItem(tester, 'About');

      expect(find.byType(AboutScreen), findsOneWidget);
    });

    for (final (item, asset) in [
      ('Licence', 'LICENSE'),
      ('Privacy policy', 'PRIVACY_POLICY.md'),
    ]) {
      testWidgets('opens the $item', (tester) async {
        await pumpHome(tester);

        await openMenuItem(tester, item);

        final page = tester.widget<DocumentScreen>(find.byType(DocumentScreen));
        expect(page.assetPath, asset);
      });
    }

    testWidgets('Feedback opens the issue tracker and closes the menu', (
      tester,
    ) async {
      await pumpHome(tester);

      await openMenuItem(tester, 'Feedback');

      expect(platform.urls.launched, [AppConstants.issuesUrl]);
      expect(find.byType(Drawer), findsNothing);
    });
  });
}
