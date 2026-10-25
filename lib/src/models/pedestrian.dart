/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:ui';

/// A pedestrian crossing back and forth in the driving simulation.
/// [position] uses the same coordinates as DrivingGame.
class Pedestrian {
  Pedestrian({required this.position, this.movingRight = true});

  Offset position;
  bool movingRight;
}
