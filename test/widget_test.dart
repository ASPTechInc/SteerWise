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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/src/providers/theme_provider.dart';
import 'package:steer_wise/src/screens/help_screen.dart';
import 'package:steer_wise/src/screens/settings_screen.dart';
import 'package:steer_wise/src/services/tts_service.dart';

/// Wraps [child] in the providers and MaterialApp the screens expect.
Future<ThemeProvider> _pumpScreen(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({});
  final themeProvider = ThemeProvider(await SharedPreferences.getInstance());
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider(create: (_) => TtsService()),
      ],
      child: MaterialApp(home: child),
    ),
  );
  // Let real asset loading (such as the question bank) finish; it runs
  // outside the test's fake clock.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
  return themeProvider;
}

void main() {
  testWidgets('Settings switches theme and can return to System', (
    tester,
  ) async {
    final themeProvider = await _pumpScreen(tester, const SettingsScreen());
    expect(themeProvider.themeMode, ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(themeProvider.themeMode, ThemeMode.dark);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(themeProvider.themeMode, ThemeMode.system);
  });

  testWidgets('Help lists every section', (tester) async {
    await _pumpScreen(tester, const HelpScreen());

    for (final title in [
      'Setting up',
      'Voice instructions',
      'Driving simulation',
      'Show Me/Tell Me',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
  });
}
