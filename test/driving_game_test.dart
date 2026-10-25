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
