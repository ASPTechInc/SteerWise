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

// Project imports:
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/utils/enums.dart';
import 'package:steer_wise/src/utils/helpers.dart';

/// Draws the mini map for [game]. Repaints whenever the game notifies.
class MapViewPainter extends CustomPainter {
  MapViewPainter({required this.game, this.zoom = 1.0}) : super(repaint: game);

  final DrivingGame game;
  final double zoom;

  static final TextPainter _legend = TextPainter(
    text: const TextSpan(
      style: TextStyle(color: Colors.white, fontSize: 8),
      children: [
        TextSpan(text: '● Blue: You\n'),
        TextSpan(text: '● Red: Oncoming car\n'),
        TextSpan(text: '● Green: Target\n'),
        TextSpan(text: '● White dots: Pedestrians\n'),
        TextSpan(text: '● Traffic light\n'),
      ],
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// Converts a game position (x -1 to 1, y 0 to 1) to the map.
  static Offset _toMap(double x, double y, Size size) =>
      Offset(size.width / 2 + x * size.width * 0.375, y * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Road
    paint.color = Colors.grey[800]!;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height),
      paint,
    );

    // Centre line
    paint
      ..color = Colors.white
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 10) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 5),
        paint,
      );
    }

    _paintTrafficLight(canvas, size);

    // Pedestrians
    paint.color = Colors.white;
    for (final pedestrian in game.pedestrians) {
      canvas.drawCircle(
        _toMap(pedestrian.position.dx, pedestrian.position.dy, size),
        5 * zoom,
        paint,
      );
    }

    _paintCar(canvas, size, game.playerX, DrivingGame.playerY, Colors.blue);
    _paintCar(canvas, size, game.enemyX, game.enemyY, Colors.red);

    _paintRoute(canvas, size);

    // Destination marker
    canvas.drawCircle(
      Offset(size.width / 2, 20),
      4,
      Paint()..color = Colors.greenAccent,
    );

    // Top-left corner: clear of the player's car and the route.
    _legend.paint(canvas, const Offset(5, 2));
  }

  void _paintTrafficLight(Canvas canvas, Size size) {
    final lightX = size.width * 0.8;
    final lightY = size.height * 0.1;
    const lightRadius = 8.0;

    canvas.drawRect(
      Rect.fromLTWH(lightX - 20, lightY - 20, 40, 80),
      Paint()..color = Colors.black,
    );
    const lamps = [
      (TrafficLightState.red, Colors.red),
      (TrafficLightState.yellow, Colors.yellow),
      (TrafficLightState.green, Colors.green),
    ];
    for (final (index, (state, colour)) in lamps.indexed) {
      canvas.drawCircle(
        Offset(lightX, lightY + index * 30),
        lightRadius,
        Paint()
          ..color = game.lightState == state
              ? colour
              : colour.withValues(alpha: 0.3),
      );
    }
  }

  void _paintCar(Canvas canvas, Size size, double x, double y, Color colour) {
    canvas.drawRect(
      Rect.fromCenter(
        center: _toMap(x, y, size),
        width: 10 * zoom,
        height: 16 * zoom,
      ),
      Paint()..color = colour,
    );
  }

  void _paintRoute(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2;
    const arrowSize = 8.0;

    for (int i = 0; i < pathPoints.length - 1; i++) {
      final start = _toMap(pathPoints[i].dx, pathPoints[i].dy, size);
      final end = _toMap(pathPoints[i + 1].dx, pathPoints[i + 1].dy, size);
      canvas.drawLine(start, end, paint);

      final angle = atan2(end.dy - start.dy, end.dx - start.dx);
      final arrowHead = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6),
        )
        ..lineTo(
          end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6),
        )
        ..close();
      canvas.drawPath(arrowHead, paint);
    }
  }

  @override
  bool shouldRepaint(MapViewPainter oldDelegate) =>
      oldDelegate.game != game || oldDelegate.zoom != zoom;
}
