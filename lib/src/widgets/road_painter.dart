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
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/utils/enums.dart';

/// Draws the road, road features, traffic light and both cars.
///
/// Repaints whenever [game] notifies, so the widget tree does not need to
/// rebuild on every frame.
class RoadPainter extends CustomPainter {
  RoadPainter(this.game) : super(repaint: game);

  final DrivingGame game;

  static const Color playerColour = Colors.blueAccent;

  /// How long (in pixels of road travelled) each road feature stays visible.
  static const double featureWindow = 120;

  /// Converts a game x position (-1 to 1) to a canvas x position. The road
  /// is 60% of the width, so the lanes at -0.4 and 0.4 sit in the middle of
  /// each half of the road.
  static double laneToCanvasX(double x, Size size) =>
      size.width / 2 + x * size.width * 0.375;

  @override
  void paint(Canvas canvas, Size size) {
    final roadWidth = size.width * 0.6;
    final roadLeft = (size.width - roadWidth) / 2;
    final offset = game.roadOffset;

    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.green[900]!);
    canvas.drawRect(
      Rect.fromLTWH(roadLeft, 0, roadWidth, size.height),
      Paint()..color = Colors.grey[800]!,
    );

    // Centre line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    for (double y = -40 + offset % 40; y < size.height; y += 40) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + 20),
        linePaint,
      );
    }

    if (offset % 1300 < featureWindow) {
      final arrowY = size.height * 0.12;
      final arrowPath = Path()
        ..moveTo(size.width / 2, arrowY)
        ..lineTo(size.width / 2 - 10, arrowY + 20)
        ..lineTo(size.width / 2 + 10, arrowY + 20)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = Colors.orange);
    }

    if (offset % 800 < featureWindow) {
      canvas.drawRect(
        Rect.fromLTWH(
          roadLeft,
          size.height * 0.2,
          roadWidth * 0.5,
          size.height * 0.1,
        ),
        Paint()..color = Colors.grey[700]!,
      );
    }

    if (offset % 1500 < featureWindow) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.55),
        size.height * 0.08,
        Paint()..color = Colors.yellow[700]!,
      );
    }

    if (offset % 1000 < featureWindow) {
      final stripeWidth = roadWidth / 12;
      final crossingPaint = Paint()..color = Colors.white;
      for (int i = 0; i < 6; i++) {
        canvas.drawRect(
          Rect.fromLTWH(
            roadLeft + stripeWidth * (2 * i + 0.5),
            size.height * 0.68,
            stripeWidth,
            size.height * 0.04,
          ),
          crossingPaint,
        );
      }
    }

    _paintTrafficLight(canvas, size, roadLeft + roadWidth);

    _paintCar(canvas, size, game.enemyX, game.enemyY, game.enemyColour);
    _paintCar(canvas, size, game.playerX, DrivingGame.playerY, playerColour);
  }

  void _paintTrafficLight(Canvas canvas, Size size, double roadRight) {
    final stopY = size.height * DrivingGame.stopLine;

    // Stop line across the oncoming (right-hand) lane
    canvas.drawLine(
      Offset(size.width / 2, stopY),
      Offset(roadRight, stopY),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );

    const lampRadius = 4.0;
    final housing = Rect.fromLTWH(roadRight + 4, stopY - 30, 14, 34);
    canvas.drawRRect(
      RRect.fromRectAndRadius(housing, const Radius.circular(3)),
      Paint()..color = Colors.black,
    );
    const lamps = [
      (TrafficLightState.red, Colors.red),
      (TrafficLightState.yellow, Colors.amber),
      (TrafficLightState.green, Colors.green),
    ];
    for (final (index, (state, colour)) in lamps.indexed) {
      canvas.drawCircle(
        Offset(housing.center.dx, housing.top + 6 + index * 11),
        lampRadius,
        Paint()
          ..color = game.lightState == state
              ? colour
              : colour.withValues(alpha: 0.25),
      );
    }
  }

  void _paintCar(Canvas canvas, Size size, double x, double y, Color colour) {
    final height = size.height * DrivingGame.carLength;
    final rect = Rect.fromCenter(
      center: Offset(laneToCanvasX(x, size), size.height * y),
      width: height * 0.57,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = colour,
    );
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) => oldDelegate.game != game;
}
