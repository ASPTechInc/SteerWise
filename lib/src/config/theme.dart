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
import 'package:steer_wise/src/config/colours.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColorLight: AppColours.primaryLight,
    primaryColor: AppColours.primary,
    scaffoldBackgroundColor: AppColours.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColours.primary,
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColours.primary,
      secondary: AppColours.secondary,
      tertiary: AppColours.tertiary,
      surface: AppColours.background,
      error: AppColours.error,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColours.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: AppColours.textSecondary, fontSize: 14),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColours.primaryDark,
    primaryColorLight: AppColours.primaryLight,
    scaffoldBackgroundColor: AppColours.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColours.primaryDark,
      foregroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme.dark(
      // Navy is kept for the app bar; accents need a lighter blue to stand
      // out on the dark background.
      primary: AppColours.primaryLight,
      secondary: AppColours.secondaryDark,
      tertiary: AppColours.tertiaryDark,
      surface: AppColours.backgroundDark,
      error: AppColours.error,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColours.textPrimaryDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColours.textSecondaryDark, fontSize: 14),
    ),
  );
}
