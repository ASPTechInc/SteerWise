/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:developer' as developer;
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

/// Logs an error to the debug console and the Dart DevTools logging view.
///
/// Works on every platform, unlike a shell script, which cannot run inside
/// an installed app.
void logError(String message, [Object? error, StackTrace? stackTrace]) {
  developer.log(
    message,
    name: 'SteerWise',
    level: 1000, // SEVERE
    error: error,
    stackTrace: stackTrace,
  );
}

/// Opens [url] in the browser or the app that handles it.
Future<void> openExternalUrl(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e, stackTrace) {
    logError('Could not open $url', e, stackTrace);
  }
}

/// Colours used for the oncoming cars in the driving simulation.
const List<Color> carColours = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.purple,
  Colors.teal,
  Colors.pink,
  Colors.brown,
];

Color getRandomCarColour([Random? random]) {
  return carColours[(random ?? Random()).nextInt(carColours.length)];
}

/// Route shown on the mini map, from the player (bottom) to the destination
/// (top). x is -1 to 1 across the road and y is 0 (top) to 1 (bottom).
const List<Offset> pathPoints = [
  Offset(0, 0.9), // Start (player)
  Offset(0, 0.6),
  Offset(0.1, 0.3),
  Offset(0, 0.1), // Near roundabout/destination
];
