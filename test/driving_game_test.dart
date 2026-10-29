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

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/models/manoeuvre.dart';
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/utils/enums.dart';

/// Predictable randomness: oncoming cars stay in the right lane and never
/// change lane.
class _FixedRandom implements Random {
  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

/// After the second car, sends every oncoming car down the player's lane
/// without changing lane. The second car's lane is fixed, so it only asks
/// whether to change lane; later cars ask for a lane, then a lane change.
class _HeadOnRandom implements Random {
  var _calls = 0;

  @override
  bool nextBool() => (_calls++).isOdd;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

/// Advances [game] by [seconds] in 1/60 s frames.
void _run(DrivingGame game, double seconds) {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    game.update(1 / 60);
  }
}

void main() {
  late DrivingGame game;

  setUp(() => game = DrivingGame(random: _FixedRandom()));
  tearDown(() => game.dispose());

  group('steering', () {
    test('starts in the left lane', () {
      expect(game.playerX, DrivingGame.leftLane);
    });

    test('snaps between the two lanes and never leaves the road', () {
      game.moveLeft();
      expect(game.playerX, DrivingGame.leftLane);

      game.moveRight();
      expect(game.playerX, DrivingGame.rightLane);

      game.moveRight();
      expect(game.playerX, DrivingGame.rightLane);

      game.moveLeft();
      expect(game.playerX, DrivingGame.leftLane);
    });
  });

  group('traffic light', () {
    test('cycles green, amber, red and back to green', () {
      expect(game.lightState, TrafficLightState.green);

      _run(game, 4.05);
      expect(game.lightState, TrafficLightState.yellow);

      _run(game, 1.5);
      expect(game.lightState, TrafficLightState.red);

      _run(game, 4);
      expect(game.lightState, TrafficLightState.green);
    });

    test('oncoming cars wait with their front at the stop line', () {
      game.debugSetLight(TrafficLightState.red);
      _run(game, 1.6); // Long enough to reach the line from the spawn point

      expect(game.enemyY, DrivingGame.waitingY);
      expect(
        game.enemyY + DrivingGame.carLength / 2,
        closeTo(DrivingGame.stopLine, 1e-9),
      );

      _run(game, 1);
      expect(game.enemyY, DrivingGame.waitingY);
    });

    test('oncoming cars past the stop line keep going', () {
      _run(game, 1.6); // Green: drive past the line
      final pastLine = game.enemyY;
      expect(pastLine, greaterThan(DrivingGame.waitingY));

      game.debugSetLight(TrafficLightState.red);
      _run(game, 0.2);
      expect(game.enemyY, greaterThan(pastLine));
    });
  });

  group('collisions and score', () {
    test('staying in the left lane scores a point per passing car', () {
      _run(game, 3.5); // Spawn -0.3 to exit 1.2 at 0.5 per second = 3 s

      expect(game.collided, isFalse);
      expect(game.score, 1);
    });

    test('driving into the oncoming lane causes a collision', () {
      game.moveRight();
      _run(game, 3);

      expect(game.collided, isTrue);
    });

    test('the game stops updating after a collision', () {
      game.moveRight();
      _run(game, 3);
      final frozenY = game.enemyY;

      _run(game, 1);
      game.moveLeft();

      expect(game.enemyY, frozenY);
      expect(game.playerX, DrivingGame.rightLane);
    });

    test('reset starts a fresh run', () {
      game.moveRight();
      _run(game, 3);

      game.reset();

      expect(game.collided, isFalse);
      expect(game.score, 0);
      expect(game.playerX, DrivingGame.leftLane);
      expect(game.enemyY, DrivingGame.enemySpawnY);
      expect(game.lightState, TrafficLightState.green);
    });
  });

  group('route', () {
    // Collisions would stop the route, so these tests keep the oncoming
    // traffic away.
    setUp(() => game.debugSetLight(TrafficLightState.red));

    void driveTo(double distance) {
      while (game.roadOffset < distance) {
        game.debugSetLight(TrafficLightState.red);
        game.update(1 / 60);
      }
    }

    test('says follow the road until the first manoeuvre is near', () {
      driveTo(DrivingGame.firstManoeuvreAt - DrivingGame.announceDistance - 10);
      expect(game.instruction.value, Manoeuvre.followRoad);

      driveTo(DrivingGame.firstManoeuvreAt - DrivingGame.announceDistance);
      expect(game.instruction.value, DrivingGame.route.first.instruction);
      expect(game.manoeuvreAt, DrivingGame.firstManoeuvreAt);
    });

    test('marks a correct signal and cancels the indicator', () {
      game.signal(Indicator.left);
      driveTo(DrivingGame.firstManoeuvreAt);

      final result = game.lastResult.value!;
      expect(result.manoeuvre, DrivingGame.route.first);
      expect(result.correct, isTrue);
      expect(game.indicator, Indicator.off);
      expect(game.instruction.value, Manoeuvre.followRoad);
      expect(game.passed?.$2, DrivingGame.firstManoeuvreAt);
      expect(game.nextManoeuvre, DrivingGame.route[1]);
      expect(
        game.manoeuvreAt,
        DrivingGame.firstManoeuvreAt + DrivingGame.manoeuvreSpacing,
      );
    });

    test('marks a missing or wrong signal', () {
      driveTo(DrivingGame.firstManoeuvreAt);
      expect(game.lastResult.value!.correct, isFalse);
      expect(game.lastResult.value!.feedback, 'You forgot to signal left.');

      // The second manoeuvre is the second exit, which needs no signal.
      game.signal(Indicator.right);
      driveTo(game.manoeuvreAt);
      expect(game.lastResult.value!.correct, isFalse);
    });

    test('tapping the lit indicator again turns it off', () {
      game.signal(Indicator.left);
      game.signal(Indicator.left);
      expect(game.indicator, Indicator.off);

      game.signal(Indicator.left);
      game.signal(Indicator.right);
      expect(game.indicator, Indicator.right);
    });

    test('skipping gives the next instruction straight away', () {
      game.skipManoeuvre();
      expect(game.instruction.value, DrivingGame.route[0].instruction);
      expect(game.manoeuvreAt, DrivingGame.announceDistance);

      game.skipManoeuvre();
      expect(game.instruction.value, DrivingGame.route[1].instruction);
      expect(game.lastResult.value, isNull);
    });

    test('reset starts the route again', () {
      driveTo(DrivingGame.firstManoeuvreAt);
      game.reset();

      expect(game.instruction.value, Manoeuvre.followRoad);
      expect(game.lastResult.value, isNull);
      expect(game.nextManoeuvre, DrivingGame.route.first);
      expect(game.passed, isNull);
    });
  });

  group('traffic near a manoeuvre', () {
    late DrivingGame headOn;

    setUp(() => headOn = DrivingGame(random: _HeadOnRandom()));
    tearDown(() => headOn.dispose());

    // Keeps the light green, so cars never wait at the stop line.
    void runGreen(double seconds) {
      for (var t = 0.0; t < seconds; t += 1 / 60) {
        headOn.debugSetLight(TrafficLightState.green);
        headOn.update(1 / 60);
      }
    }

    test('oncoming cars keep to their lane while an instruction is given', () {
      // The first instruction comes at 2.3 s and the first car leaves at
      // 3 s, so the second car arrives while it is being given.
      runGreen(3.1);
      expect(headOn.instruction.value, isNot(Manoeuvre.followRoad));
      expect(headOn.score, 1);
      expect(headOn.enemyX, DrivingGame.rightLane);
    });

    test('between manoeuvres they can use either lane', () {
      // The first manoeuvre is passed at 5.3 s and the third car arrives
      // at 6 s.
      runGreen(6.1);
      expect(headOn.instruction.value, Manoeuvre.followRoad);
      expect(headOn.score, 2);
      expect(headOn.enemyX, DrivingGame.leftLane);
    });

    test('a car in the player\'s lane moves over when one is given', () {
      runGreen(6.1);
      headOn.skipManoeuvre();

      runGreen(1.5); // Past the lane change point, before reaching the car
      expect(headOn.enemyX, DrivingGame.rightLane);
      expect(headOn.collided, isFalse);
    });
  });

  group('manoeuvre signals', () {
    test('follow the Highway Code', () {
      const expected = {
        ManoeuvreType.junctionLeft: Indicator.left,
        ManoeuvreType.junctionRight: Indicator.right,
        ManoeuvreType.pullUpLeft: Indicator.left,
      };
      for (final MapEntry(:key, :value) in expected.entries) {
        expect(Manoeuvre(key).signal, value);
      }
      expect(
        [
          1,
          2,
          3,
        ].map((e) => Manoeuvre(ManoeuvreType.roundabout, exit: e).signal),
        [Indicator.left, Indicator.off, Indicator.right],
      );
    });

    test('roundabout instructions name the exit', () {
      expect(
        const Manoeuvre(ManoeuvreType.roundabout, exit: 2).instruction,
        'At the roundabout, take the second exit',
      );
    });
  });

  test('a long pause is simulated as one short step', () {
    final startY = game.enemyY;
    game.update(5);

    expect(
      game.enemyY,
      closeTo(startY + DrivingGame.enemySpeed * DrivingGame.maxStep, 1e-9),
    );
  });

  test('notifies listeners on every update', () {
    var notifications = 0;
    game.addListener(() => notifications++);

    game.update(1 / 60);
    game.update(1 / 60);

    expect(notifications, 2);
  });
}
