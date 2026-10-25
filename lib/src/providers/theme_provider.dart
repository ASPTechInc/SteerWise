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
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the chosen theme (system, light or dark) and saves it on the device.
///
/// The preferences are loaded before the app starts (see main.dart), so the
/// saved theme is used from the first frame.
class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._prefs) : _themeMode = _parse(_prefs.getString(_key));

  static const String _key = 'themeMode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_key, mode.name);
  }

  static ThemeMode _parse(String? value) => ThemeMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => ThemeMode.system,
  );
}
