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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:steer_wise/src/app.dart';
import 'package:steer_wise/src/providers/theme_provider.dart';
import 'package:steer_wise/src/services/tts_service.dart';

Future<void> main() async {
  // Plugins (shared_preferences here) need the engine to be initialised.
  WidgetsFlutterBinding.ensureInitialized();
  // Load preferences before the first frame so the saved theme is used
  // straight away, with no flash of the system theme.
  final prefs = await SharedPreferences.getInstance();
  runApp(SteerWiseRoot(prefs: prefs));
}

class SteerWiseRoot extends StatelessWidget {
  const SteerWiseRoot({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        Provider(create: (_) => TtsService(), dispose: (_, tts) => tts.stop()),
      ],
      child: const SteerWiseApp(),
    );
  }
}
