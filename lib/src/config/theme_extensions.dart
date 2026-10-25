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
import 'package:steer_wise/src/config/colours.dart';

extension CustomTileColours on ThemeData {
  Color get showTileColour => brightness == Brightness.dark
      ? AppColours
            .showTileDark // Dark blue
      : AppColours.showTileLight; // Light green

  Color get tellTileColour => brightness == Brightness.dark
      ? AppColours
            .tellTileDark // Brown
      : AppColours.tellTileLight; // Soft orange

  Color get tileTextColour => Colors.white; // or define per theme
}
