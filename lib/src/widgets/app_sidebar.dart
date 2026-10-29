/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/config/routes.dart';
import 'package:steer_wise/src/utils/helpers.dart';
import 'package:steer_wise/src/providers/theme_provider.dart';

// Package imports:

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  /// Pages open on the root navigator, which knows the app's named routes
  /// (each bottom navigation tab has its own navigator).
  void _open(BuildContext context, String route) {
    final navigator = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    unawaited(navigator.pushNamed(route));
  }

  void _sendFeedback(BuildContext context) {
    Navigator.pop(context);
    unawaited(openExternalUrl(AppConstants.issuesUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: theme.primaryColor),
            child: const Text(
              AppConstants.appName,
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (selection) =>
                    unawaited(themeProvider.setThemeMode(selection.first)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () => _open(context, AppRoutes.help),
          ),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Licence'),
            onTap: () => _open(context, AppRoutes.licence),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy policy'),
            onTap: () => _open(context, AppRoutes.privacy),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () => _open(context, AppRoutes.about),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            subtitle: const Text('Report a problem or suggest an idea'),
            onTap: () => _sendFeedback(context),
          ),
        ],
      ),
    );
  }
}
