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

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/navigation/persistent_nav.dart';
import 'package:steer_wise/src/widgets/splash_road_painter.dart';

/// Full-screen animated splash shown at launch. Tap to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration duration = Duration(seconds: 3);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _road = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _timer;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_road.repeat());
    _timer = Timer(SplashScreen.duration, _continue);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _road.dispose();
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  void _continue() {
    if (_leaving || !mounted) return;
    _leaving = true;
    _timer?.cancel();
    unawaited(
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, _, _) => const BottomNav(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _continue,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: SplashRoadPainter(_road)),
          Align(
            alignment: const Alignment(0, -0.45),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
              child: Text(
                AppConstants.appName,
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
