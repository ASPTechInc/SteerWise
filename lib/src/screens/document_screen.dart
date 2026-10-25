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
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

// Project imports:
import 'package:steer_wise/src/utils/helpers.dart';

/// Shows a Markdown or text file bundled with the app, such as the
/// changelog, licence or privacy policy.
class DocumentScreen extends StatelessWidget {
  const DocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

  Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    // Relative links point at files in the repository, not the app.
    if (uri == null || !uri.hasScheme) return;
    await openExternalUrl(href!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('This document is unavailable.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Markdown(
            data: snapshot.data!,
            selectable: true,
            onTapLink: (text, href, title) => unawaited(_openLink(href)),
          );
        },
      ),
    );
  }
}
