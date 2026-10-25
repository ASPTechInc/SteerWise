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
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/src/providers/theme_provider.dart';

Future<ThemeProvider> _providerWith(Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  return ThemeProvider(await SharedPreferences.getInstance());
}

void main() {
  test('defaults to the system theme when nothing is saved', () async {
    final provider = await _providerWith({});
    expect(provider.themeMode, ThemeMode.system);
  });

  test('loads the saved theme straight away', () async {
    final provider = await _providerWith({'themeMode': 'dark'});
    expect(provider.themeMode, ThemeMode.dark);
  });

  test('falls back to the system theme for an unknown value', () async {
    final provider = await _providerWith({'themeMode': 'sepia'});
    expect(provider.themeMode, ThemeMode.system);
  });

  test('saves the chosen theme and can return to system', () async {
    final provider = await _providerWith({});
    final prefs = await SharedPreferences.getInstance();

    await provider.setThemeMode(ThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);
    expect(prefs.getString('themeMode'), 'dark');

    await provider.setThemeMode(ThemeMode.system);
    expect(provider.themeMode, ThemeMode.system);
    expect(prefs.getString('themeMode'), 'system');
  });

  test('notifies listeners only when the theme changes', () async {
    final provider = await _providerWith({'themeMode': 'light'});
    var notifications = 0;
    provider.addListener(() => notifications++);

    await provider.setThemeMode(ThemeMode.light);
    await provider.setThemeMode(ThemeMode.dark);

    expect(notifications, 1);
  });
}
