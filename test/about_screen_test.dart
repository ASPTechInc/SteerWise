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
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'support/test_app.dart';

void main() {
  late FakePlatform platform;

  setUp(() {
    platform = FakePlatform.install();
    PackageInfo.setMockInitialValues(
      appName: AppConstants.appName,
      packageName: 'com.asptechinc.steerwise',
      version: '1.2.3',
      buildNumber: '4',
      buildSignature: '',
    );
  });

  group('About', () {
    testWidgets('shows the app version', (tester) async {
      await pumpWithProviders(tester, const AboutScreen());
      await tester.pumpAndSettle();

      expect(find.text('Version 1.2.3'), findsOneWidget);
    });

    for (final (link, title) in [
      ("What's new", "What's new"),
      ('Licence', 'Licence'),
      ('Privacy policy', 'Privacy policy'),
    ]) {
      testWidgets('"$link" opens the bundled document', (tester) async {
        await pumpWithProviders(tester, const AboutScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ListTile, link));
        await tester.pumpAndSettle();

        final page = tester.widget<DocumentScreen>(find.byType(DocumentScreen));
        expect(page.title, title);
        rootBundle.evict(page.assetPath);
      });
    }

    testWidgets('lists the open-source licences', (tester) async {
      await pumpWithProviders(tester, const AboutScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open-source licences'));
      await tester.pumpAndSettle();

      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('opens the source code and question licence links', (
      tester,
    ) async {
      await pumpWithProviders(tester, const AboutScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Source code'));
      await tester.scrollUntilVisible(
        find.text('Show Me/Tell Me questions'),
        100,
      );
      await tester.tap(find.text('Show Me/Tell Me questions'));
      await tester.pump();

      expect(platform.urls.launched, [
        AppConstants.repoUrl,
        AppConstants.oglUrl,
      ]);
    });
  });

  group('DocumentScreen', () {
    testWidgets('renders a bundled Markdown file', (tester) async {
      rootBundle.evict('CHANGELOG.md');
      await pumpWithProviders(
        tester,
        const DocumentScreen(title: "What's new", assetPath: 'CHANGELOG.md'),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await waitForAssets(tester);
      await tester.pumpAndSettle();

      expect(find.text("What's new"), findsOneWidget);
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('explains when the file is missing', (tester) async {
      await pumpWithProviders(
        tester,
        const DocumentScreen(title: 'Missing', assetPath: 'NOT_BUNDLED.md'),
      );
      await waitForAssets(tester);
      await tester.pumpAndSettle();

      expect(find.text('This document is unavailable.'), findsOneWidget);
    });

    // The bundled files must exist, or the About links lead nowhere.
    test('every linked document is bundled with the app', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      for (final asset in ['CHANGELOG.md', 'LICENSE', 'PRIVACY_POLICY.md']) {
        // A copy cached by a widget test above never completes here.
        rootBundle.evict(asset);
        expect(await rootBundle.loadString(asset), isNotEmpty, reason: asset);
      }
    });
  });
}
