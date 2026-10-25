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
import 'dart:ui';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:steer_wise/src/models/pedestrian.dart';
import 'package:steer_wise/src/utils/enums.dart';
import 'package:steer_wise/src/utils/helpers.dart';

/// The rules of the driving simulation, kept apart from the widgets so they
/// can be unit tested.
///
/// Positions are relative to the simulation area, so the game behaves the
/// same at any size: x runs from -1 (left edge) to 1 (right edge) and y from
/// 0 (top) to 1 (bottom). Movement is scaled by elapsed time, so speeds are
/// the same at 60 Hz and 120 Hz.
class DrivingGame extends ChangeNotifier {
  DrivingGame({Random? random}) : _random = random ?? Random() {
    reset();
  }

  /// UK traffic drives on the left, so oncoming cars use the right lane.
  static const double leftLane = -0.4;
  static const double rightLane = 0.4;

  /// Vertical centre of the player's car.
  static const double playerY = 0.82;

  /// Car length as a fraction of the simulation height.
  static const double carLength = 0.28;

  /// The stop line for oncoming cars.
  static const double stopLine = 0.35;

  /// Where an oncoming car's centre is when it waits at the stop line.
  /// Oncoming cars drive down the screen, so their front is the lower edge.
  static const double waitingY = stopLine - carLength / 2;

  /// Oncoming cars start above the visible area and leave below it.
  static const double enemySpawnY = -0.3;
  static const double enemyExitY = 1.2;

  /// Oncoming cars change lane once they pass this point.
  static const double laneChangeY = 0.4;

  /// Speeds, per second.
  static const double enemySpeed = 0.5;
  static const double roadSpeed = 170; // logical pixels
  static const double pedestrianSpeed = 0.07;

  /// Longest step simulated in one update, so a stalled frame (for
  /// example after the app is resumed) cannot teleport the cars.
  static const double maxStep = 0.05;

  static const Map<TrafficLightState, double> lightDurations = {
    TrafficLightState.green: 4,
    TrafficLightState.yellow: 1.5,
    TrafficLightState.red: 4,
  };

  final Random _random;

  late double _playerX;
  late double _enemyX;
  late double _enemyY;
  late Color _enemyColour;
  late bool _enemyWillChangeLane;
  late bool _firstSpawn;
  late double _roadOffset;
  late TrafficLightState _lightState;
  late double _lightTimer;
  late List<Pedestrian> _pedestrians;
  late int _score;
  late bool _collided;

  double get playerX => _playerX;
  double get enemyX => _enemyX;
  double get enemyY => _enemyY;
  Color get enemyColour => _enemyColour;
  double get roadOffset => _roadOffset;
  TrafficLightState get lightState => _lightState;
  List<Pedestrian> get pedestrians => List.unmodifiable(_pedestrians);
  int get score => _score;
  bool get collided => _collided;

  /// Starts a new run.
  void reset() {
    _playerX = leftLane;
    _enemyX = rightLane;
    _enemyY = enemySpawnY;
    _enemyColour = carColours.first;
    _enemyWillChangeLane = false;
    _firstSpawn = true;
    _roadOffset = 0;
    _lightState = TrafficLightState.green;
    _lightTimer = 0;
    _pedestrians = List.generate(
      5,
      (index) => Pedestrian(
        position: Offset(-0.4 + 0.2 * index, 0.5 + 0.1 * index),
        movingRight: index.isEven,
      ),
    );
    _score = 0;
    _collided = false;
    notifyListeners();
  }

  void moveLeft() => _setPlayerLane(leftLane);

  void moveRight() => _setPlayerLane(rightLane);

  void _setPlayerLane(double lane) {
    if (_collided || _playerX == lane) return;
    _playerX = lane;
    notifyListeners();
  }

  /// Advances the simulation by [seconds].
  void update(double seconds) {
    if (_collided || seconds <= 0) return;
    final dt = min(seconds, maxStep);

    _roadOffset += roadSpeed * dt;
    _updateTrafficLight(dt);
    _updateEnemy(dt);
    _updatePedestrians(dt);

    if (_enemyX == _playerX && (_enemyY - playerY).abs() < carLength) {
      _collided = true;
    }
    notifyListeners();
  }

  void _updateTrafficLight(double dt) {
    _lightTimer += dt;
    final duration = lightDurations[_lightState]!;
    if (_lightTimer < duration) return;
    _lightTimer -= duration;
    _lightState = switch (_lightState) {
      TrafficLightState.green => TrafficLightState.yellow,
      TrafficLightState.yellow => TrafficLightState.red,
      TrafficLightState.red => TrafficLightState.green,
    };
  }

  void _updateEnemy(double dt) {
    final nextY = _enemyY + enemySpeed * dt;
    final mustStop = _lightState != TrafficLightState.green;
    if (mustStop && _enemyY <= waitingY && nextY > waitingY) {
      _enemyY = waitingY;
    } else {
      _enemyY = nextY;
    }

    if (_enemyWillChangeLane && _enemyY > laneChangeY) {
      _enemyX = _enemyX == rightLane ? leftLane : rightLane;
      _enemyWillChangeLane = false;
    }

    if (_enemyY > enemyExitY) {
      _score++;
      _spawnEnemy();
    }
  }

  void _spawnEnemy() {
    _enemyY = enemySpawnY;
    if (_firstSpawn) {
      _enemyX = rightLane;
      _firstSpawn = false;
    } else {
      _enemyX = _random.nextBool() ? leftLane : rightLane;
    }
    _enemyColour = getRandomCarColour(_random);
    _enemyWillChangeLane = _random.nextBool();
  }

  void _updatePedestrians(double dt) {
    for (final p in _pedestrians) {
      final step = pedestrianSpeed * dt;
      var newX = p.position.dx + (p.movingRight ? step : -step);
      if (newX > 0.6) {
        p.movingRight = false;
        newX = 0.6;
      } else if (newX < -0.6) {
        p.movingRight = true;
        newX = -0.6;
      }
      p.position = Offset(newX, p.position.dy);
    }
  }

  @visibleForTesting
  void debugSetLight(TrafficLightState state) {
    _lightState = state;
    _lightTimer = 0;
  }
}
