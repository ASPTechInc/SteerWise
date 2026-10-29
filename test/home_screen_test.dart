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
import 'package:steer_wise/src/models/manoeuvre.dart';
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'package:steer_wise/src/screens/help_screen.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'support/test_app.dart';

final _route = DrivingGame.route.map((m) => m.instruction).toList();

void main() {
  late FakePlatform platform;

  setUp(() => platform = FakePlatform.install());

  // The driving simulation waits for the user to press play, so its random
  // traffic stays still during these tests.
  Future<void> pumpHome(WidgetTester tester) async {
    await pumpWithProviders(tester, const HomeScreen());
    await tester.pump();
  }

  /// Taps an icon button by its tooltip.
  Future<void> tapButton(WidgetTester tester, String label) async {
    final button = find.byTooltip(label);
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

  testWidgets('shows the camera, instruction and simulation', (tester) async {
    await pumpHome(tester);

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(Manoeuvre.followRoad), findsOneWidget);
    expect(find.text('Camera access is off.'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    expect(find.text('Tap to start driving'), findsOneWidget);
  });

  testWidgets('Next Instruction gives the next manoeuvre and reads it aloud', (
    tester,
  ) async {
    await pumpHome(tester);

    await tapButton(tester, 'Next Instruction');
    expect(find.text(_route[0]), findsOneWidget);
    expect(find.text(Manoeuvre.followRoad), findsNothing);

    await tapButton(tester, 'Next Instruction');
    expect(find.text(_route[1]), findsOneWidget);
    expect(platform.spoken, [_route[0], _route[1]]);
  });

  testWidgets('the route starts again after the last manoeuvre', (
    tester,
  ) async {
    await pumpHome(tester);

    for (var i = 0; i <= _route.length; i++) {
      await tapButton(tester, 'Next Instruction');
    }

    expect(find.text(_route.first), findsOneWidget);
    expect(platform.spoken, [..._route, _route.first]);
  });

  testWidgets('driving gives the instruction, then feedback on signalling', (
    tester,
  ) async {
    await pumpHome(tester);
    await tapButton(tester, 'Start driving');

    // Frames have to be pumped by hand while the simulation runs.
    Future<void> drive(double seconds) async {
      for (var t = 0.0; t < seconds; t += 0.05) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    const announceAt =
        (DrivingGame.firstManoeuvreAt - DrivingGame.announceDistance) /
        DrivingGame.roadSpeed;
    await drive(announceAt + 0.1);
    expect(find.text(_route.first), findsOneWidget);
    expect(platform.spoken, [_route.first]);

    await tapButton(tester, 'Signal left');
    await drive(DrivingGame.announceDistance / DrivingGame.roadSpeed);

    expect(find.text(Manoeuvre.followRoad), findsOneWidget);
    expect(find.textContaining('Well done'), findsOneWidget);
  });

  testWidgets('Get Feedback explains there is nothing to report yet', (
    tester,
  ) async {
    await pumpHome(tester);

    await tapButton(tester, 'Get Feedback');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Drive up to a junction'), findsOneWidget);
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
