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

// Project imports:
import 'package:steer_wise/src/config/routes.dart';
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'package:steer_wise/src/screens/help_screen.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'package:steer_wise/src/screens/settings_screen.dart';

/// Builds the page for [name] without showing it.
Widget _pageFor(String name) {
  final route =
      AppRoutes.generateRoute(RouteSettings(name: name))
          as MaterialPageRoute<dynamic>;
  expect(route.settings.name, name);
  return route.builder(_FakeContext());
}

class _FakeContext extends Fake implements BuildContext {}

void main() {
  test('each named route opens its page', () {
    expect(_pageFor(AppRoutes.home), isA<HomeScreen>());
    expect(_pageFor(AppRoutes.settingsPath), isA<SettingsScreen>());
    expect(_pageFor(AppRoutes.help), isA<HelpScreen>());
    expect(_pageFor(AppRoutes.about), isA<AboutScreen>());
  });

  test('document routes show the matching bundled file', () {
    final documents = {
      AppRoutes.changelog: ("What's new", 'CHANGELOG.md'),
      AppRoutes.licence: ('Licence', 'LICENSE'),
      AppRoutes.privacy: ('Privacy policy', 'PRIVACY_POLICY.md'),
    };
    for (final MapEntry(key: name, value: (title, asset))
        in documents.entries) {
      final page = _pageFor(name) as DocumentScreen;
      expect(page.title, title);
      expect(page.assetPath, asset);
    }
  });

  testWidgets('an unknown route explains that it does not exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        initialRoute: '/nowhere',
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );

    expect(find.text('No route defined for /nowhere'), findsOneWidget);
  });
}
