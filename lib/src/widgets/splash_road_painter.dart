/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

/// Draws the splash screen: a night road with lane markings moving towards
/// the viewer. Drawn in code, so the app carries no third-party artwork.
class SplashRoadPainter extends CustomPainter {
  SplashRoadPainter(this.progress) : super(repaint: progress);

  /// Loops from 0 to 1; one loop moves the markings one dash forward.
  final Animation<double> progress;

  static const Color _skyTop = Color(0xFF020306);
  static const Color _skyHorizon = Color(0xFF0B1418);
  static const Color _road = Color(0xFF1A2326);
  static const Color _verge = Color(0xFF0A1012);
  static const Color _marking = Color(0xFF6FE3E0);
  static const double _horizon = 0.42; // fraction of the height
  static const int _dashes = 8;

  /// Star positions (fractions of the sky) and sizes, fixed so they do not
  /// jump about between frames.
  static final List<(double, double, double)> _stars = () {
    final random = Random(7);
    return List.generate(
      120,
      (_) =>
          (random.nextDouble(), random.nextDouble(), 0.4 + random.nextDouble()),
    );
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * _horizon;
    final centreX = size.width / 2;

    // Sky
    final sky = Rect.fromLTWH(0, 0, size.width, horizonY);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyHorizon],
        ).createShader(sky),
    );
    final starPaint = Paint()..color = Colors.white70;
    for (final (x, y, radius) in _stars) {
      canvas.drawCircle(
        Offset(x * size.width, y * horizonY * 0.9),
        radius,
        starPaint,
      );
    }

    // Ground and road
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      Paint()..color = _verge,
    );
    final roadHalfTop = size.width * 0.02;
    final roadHalfBottom = size.width * 0.75;
    canvas.drawPath(
      Path()
        ..moveTo(centreX - roadHalfTop, horizonY)
        ..lineTo(centreX + roadHalfTop, horizonY)
        ..lineTo(centreX + roadHalfBottom, size.height)
        ..lineTo(centreX - roadHalfBottom, size.height)
        ..close(),
      Paint()..color = _road,
    );

    // Edge lines
    final edgePaint = Paint()
      ..color = _marking.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final side in [-1, 1]) {
      canvas.drawLine(
        Offset(centreX + side * roadHalfTop * 0.8, horizonY),
        Offset(centreX + side * roadHalfBottom * 0.85, size.height),
        edgePaint,
      );
    }

    // Centre dashes, spaced in perspective: depth 0 is the horizon and 1 is
    // the bottom of the screen.
    final dashPaint = Paint()..color = _marking;
    for (var i = 0; i < _dashes; i++) {
      final near = (i + progress.value) / _dashes;
      final far = (i + progress.value + 0.45) / _dashes;
      final top = horizonY + (size.height - horizonY) * near * near;
      final bottom = horizonY + (size.height - horizonY) * min(far * far, 1);
      final halfWidth = 1 + 10 * near;
      canvas.drawPath(
        Path()
          ..moveTo(centreX - halfWidth * 0.8, top)
          ..lineTo(centreX + halfWidth * 0.8, top)
          ..lineTo(centreX + halfWidth, bottom)
          ..lineTo(centreX - halfWidth, bottom)
          ..close(),
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SplashRoadPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
