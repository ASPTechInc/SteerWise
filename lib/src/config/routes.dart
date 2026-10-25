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

// Project imports:
import 'package:steer_wise/src/screens/about_screen.dart';
import 'package:steer_wise/src/screens/document_screen.dart';
import 'package:steer_wise/src/screens/help_screen.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'package:steer_wise/src/screens/settings_screen.dart';

/// Named routes. The tabs live in the bottom navigation bar; these routes
/// open full-screen pages on the root navigator.
class AppRoutes {
  static const String home = '/';
  static const String settingsPath = '/settings';
  static const String help = '/help';
  static const String about = '/about';
  static const String changelog = '/changelog';
  static const String licence = '/licence';
  static const String privacy = '/privacy';

  /// Reserved for the planned map view (see docs/md/planned-features.md).
  static const String mapView = '/map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      home => const HomeScreen(),
      settingsPath => const SettingsScreen(),
      help => const HelpScreen(),
      about => const AboutScreen(),
      changelog => const DocumentScreen(
        title: "What's new",
        assetPath: 'CHANGELOG.md',
      ),
      licence => const DocumentScreen(title: 'Licence', assetPath: 'LICENSE'),
      privacy => const DocumentScreen(
        title: 'Privacy policy',
        assetPath: 'PRIVACY_POLICY.md',
      ),
      _ => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
