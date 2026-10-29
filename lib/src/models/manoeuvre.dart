/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Project imports:
import 'package:steer_wise/src/utils/enums.dart';

/// One manoeuvre on the simulated route, and the signal it needs on the
/// approach.
class Manoeuvre {
  const Manoeuvre(this.type, {this.exit = 0});

  final ManoeuvreType type;

  /// For roundabouts, the exit to take counting clockwise from the entry:
  /// 1 is left, 2 is straight ahead and 3 is right.
  final int exit;

  /// What the examiner says between manoeuvres.
  static const String followRoad = 'Follow the road ahead';

  static const List<String> _ordinals = ['first', 'second', 'third'];

  String get _exitName => _ordinals[exit - 1];

  String get instruction => switch (type) {
    ManoeuvreType.junctionLeft => 'Turn left at the next junction',
    ManoeuvreType.junctionRight => 'Turn right at the next junction',
    ManoeuvreType.roundabout => 'At the roundabout, take the $_exitName exit',
    ManoeuvreType.pullUpLeft => 'Pull up on the left in a safe place',
  };

  /// The signal to give on the approach. Going ahead at a roundabout needs
  /// none until you pass the exit before yours (Highway Code rule 186).
  Indicator get signal => switch (type) {
    ManoeuvreType.junctionLeft || ManoeuvreType.pullUpLeft => Indicator.left,
    ManoeuvreType.junctionRight => Indicator.right,
    ManoeuvreType.roundabout => switch (exit) {
      1 => Indicator.left,
      2 => Indicator.off,
      _ => Indicator.right,
    },
  };
}

/// How the player signalled for a manoeuvre they have just reached.
class ManoeuvreResult {
  const ManoeuvreResult(this.manoeuvre, this.signalled);

  final Manoeuvre manoeuvre;
  final Indicator signalled;

  bool get correct => signalled == manoeuvre.signal;

  String get feedback {
    final expected = manoeuvre.signal;
    if (expected == Indicator.off) {
      final advice =
          'Signal left after you pass the '
          '${Manoeuvre._ordinals[manoeuvre.exit - 2]} exit.';
      return correct
          ? 'Well done: no signal on the approach for the '
                '${manoeuvre._exitName} exit. $advice'
          : 'No signal was needed on the approach for the '
                '${manoeuvre._exitName} exit. $advice';
    }
    if (correct) return 'Well done: you signalled ${expected.name} in time.';
    if (signalled == Indicator.off) {
      return 'You forgot to signal ${expected.name}.';
    }
    return 'You signalled ${signalled.name}, but this needed a '
        '${expected.name} signal.';
  }
}
