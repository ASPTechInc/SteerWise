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

// Package imports:
import 'package:package_info_plus/package_info_plus.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/config/routes.dart';
import 'package:steer_wise/src/utils/helpers.dart';

/// App version, description and links to the bundled documents.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          final version = snapshot.data?.version;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Image.asset('assets/images/app_logo.png', height: 96),
              const SizedBox(height: 12),
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (version != null)
                Text(
                  'Version $version',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 12),
              const Text(
                'A free and open-source, voice-guided driving practice app '
                'for learner drivers. No accounts, analytics or adverts.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.new_releases),
                title: const Text("What's new"),
                onTap: () =>
                    unawaited(navigator.pushNamed(AppRoutes.changelog)),
              ),
              ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('Licence'),
                onTap: () => unawaited(navigator.pushNamed(AppRoutes.licence)),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Open-source licences'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: version,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy policy'),
                onTap: () => unawaited(navigator.pushNamed(AppRoutes.privacy)),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Source code'),
                subtitle: const Text(AppConstants.repoUrl),
                onTap: () => unawaited(openExternalUrl(AppConstants.repoUrl)),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Show Me/Tell Me questions'),
                subtitle: const Text(
                  'Contains public sector information licensed under the '
                  'Open Government Licence v3.0 (DVSA, Crown copyright).',
                ),
                onTap: () => unawaited(openExternalUrl(AppConstants.oglUrl)),
              ),
            ],
          );
        },
      ),
    );
  }
}
