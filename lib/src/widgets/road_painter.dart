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
import 'package:steer_wise/src/models/manoeuvre.dart';
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/utils/enums.dart';

/// Draws the road, the route's junctions and roundabouts, the traffic light
/// and both cars.
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

    // A manoeuvre is level with the player's car when the road has
    // scrolled to its distance.
    final playerCanvasY = size.height * DrivingGame.playerY;
    final passed = game.passed;
    if (passed != null) {
      _paintManoeuvre(
        canvas,
        size,
        passed.$1,
        playerCanvasY - (passed.$2 - offset),
        roadLeft,
        roadWidth,
      );
    }
    _paintManoeuvre(
      canvas,
      size,
      game.nextManoeuvre,
      playerCanvasY - (game.manoeuvreAt - offset),
      roadLeft,
      roadWidth,
    );

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
    _paintIndicator(canvas, size);
  }

  /// Draws [manoeuvre] centred on canvas height [y], if any of it shows.
  void _paintManoeuvre(
    Canvas canvas,
    Size size,
    Manoeuvre manoeuvre,
    double y,
    double roadLeft,
    double roadWidth,
  ) {
    final reach = roadWidth * 0.6;
    if (y < -reach || y > size.height + reach) return;

    final roadPaint = Paint()..color = Colors.grey[800]!;
    final roadRight = roadLeft + roadWidth;
    final sideRoadHeight = roadWidth * 0.45;
    Rect sideRoad(double left, double right) => Rect.fromLTRB(
      left,
      y - sideRoadHeight / 2,
      right,
      y + sideRoadHeight / 2,
    );
    final giveWayPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    switch (manoeuvre.type) {
      case ManoeuvreType.junctionLeft:
        canvas.drawRect(sideRoad(0, roadLeft + 1), roadPaint);
        canvas.drawLine(
          Offset(roadLeft - 4, y - sideRoadHeight / 2),
          Offset(roadLeft - 4, y + sideRoadHeight / 2),
          giveWayPaint,
        );
      case ManoeuvreType.junctionRight:
        canvas.drawRect(sideRoad(roadRight - 1, size.width), roadPaint);
        canvas.drawLine(
          Offset(roadRight + 4, y - sideRoadHeight / 2),
          Offset(roadRight + 4, y + sideRoadHeight / 2),
          giveWayPaint,
        );
      case ManoeuvreType.roundabout:
        // Exits to the left, ahead (the main road) and right.
        canvas.drawRect(sideRoad(0, size.width), roadPaint);
        canvas.drawCircle(Offset(size.width / 2, y), reach, roadPaint);
        canvas.drawCircle(
          Offset(size.width / 2, y),
          size.width * 0.06,
          Paint()..color = Colors.white,
        );
      case ManoeuvreType.pullUpLeft:
        // A lay-by on the left verge.
        final layBy = Rect.fromLTWH(
          roadLeft - roadWidth * 0.12,
          y - roadWidth * 0.4,
          roadWidth * 0.12 + 1,
          roadWidth * 0.8,
        );
        canvas.drawRect(layBy, roadPaint);
        canvas.drawRect(
          layBy.deflate(2),
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
    }
  }

  /// Flashes amber lights on the signalled side of the player's car.
  void _paintIndicator(Canvas canvas, Size size) {
    if (game.indicator == Indicator.off) return;
    // Flash with distance driven, so the lights stay on while paused.
    if ((game.roadOffset ~/ 60).isOdd) return;
    final length = size.height * DrivingGame.carLength;
    final halfWidth = length * 0.57 / 2;
    final centreX = laneToCanvasX(game.playerX, size);
    final x = game.indicator == Indicator.left
        ? centreX - halfWidth
        : centreX + halfWidth;
    final centreY = size.height * DrivingGame.playerY;
    final paint = Paint()..color = Colors.amber;
    for (final dy in [-length / 2 + 6, length / 2 - 6]) {
      canvas.drawCircle(Offset(x, centreY + dy), 4, paint);
    }
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
