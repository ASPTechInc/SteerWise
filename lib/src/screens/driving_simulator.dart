/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Project imports:
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/utils/enums.dart';
import 'package:steer_wise/src/widgets/map_view_painter.dart';
import 'package:steer_wise/src/widgets/road_painter.dart';

/// The driving simulation shown on the Home screen.
///
/// A [Ticker] advances the [DrivingGame] once per frame. The painters listen
/// to the game directly, so only the canvas repaints each frame.
///
/// The simulation starts stopped and only runs once the user taps play. It
/// pauses itself when its tab is hidden or the app is put away.
class DrivingSimulationScreen extends StatefulWidget {
  const DrivingSimulationScreen({super.key});

  @override
  State<DrivingSimulationScreen> createState() =>
      _DrivingSimulationScreenState();
}

class _DrivingSimulationScreenState extends State<DrivingSimulationScreen>
    with SingleTickerProviderStateMixin {
  final DrivingGame _game = DrivingGame();
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  late final AppLifecycleListener _lifecycle;
  SimulationState _state = SimulationState.stopped;

  bool _showMiniMap = false;
  double _mapZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _game.addListener(_onGameChanged);
    _lifecycle = AppLifecycleListener(onHide: _pause);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The bottom navigation mutes tickers on hidden tabs (see TickerMode).
    if (!TickerMode.valuesOf(context).enabled &&
        _state == SimulationState.running) {
      _ticker.stop();
      _state = SimulationState.paused;
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _ticker.dispose();
    _game
      ..removeListener(_onGameChanged)
      ..dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final seconds = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _game.update(seconds);
  }

  void _onGameChanged() {
    if (_game.collided && _ticker.isActive) {
      _ticker.stop();
      unawaited(_showCollisionDialog());
    }
  }

  /// Starts driving, or carries on after a pause.
  void _play() {
    if (_ticker.isActive) return;
    // A restarted ticker counts from zero again.
    _lastTick = Duration.zero;
    unawaited(_ticker.start());
    setState(() => _state = SimulationState.running);
  }

  void _pause() {
    if (_state != SimulationState.running) return;
    _ticker.stop();
    setState(() => _state = SimulationState.paused);
  }

  /// Stops driving and puts everything back to the start.
  void _stop() {
    _ticker.stop();
    _game.reset();
    setState(() => _state = SimulationState.stopped);
  }

  void _restart() {
    _game.reset();
    _play();
  }

  Future<void> _showCollisionDialog() async {
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Collision detected'),
        content: Text(
          'You collided with an oncoming car!\nScore: ${_game.score}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stop'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (retry ?? false) {
      _restart();
    } else {
      _stop();
    }
  }

  void _zoomMap(double change) {
    setState(() => _mapZoom = (_mapZoom + change).clamp(0.6, 2.0));
  }

  @override
  Widget build(BuildContext context) {
    final running = _state == SimulationState.running;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (!running) return;
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 0) {
          _game.moveRight();
        } else if (velocity < 0) {
          _game.moveLeft();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: RoadPainter(_game)),
            ),
          ),
          if (!running) _buildStartOverlay(),
          Positioned(
            top: 10,
            right: 10,
            child: ListenableBuilder(
              listenable: _game,
              builder: (context, _) => Text(
                'Score: ${_game.score}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.map, color: Colors.white, size: 30),
              tooltip: _showMiniMap ? 'Hide mini map' : 'Show mini map',
              onPressed: () => setState(() => _showMiniMap = !_showMiniMap),
            ),
          ),
          if (_showMiniMap) _buildMiniMap(),
          Positioned(
            bottom: 4,
            left: 2,
            right: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: running ? _game.moveLeft : null,
                  tooltip: 'Steer left',
                  icon: const Icon(Icons.arrow_circle_left, size: 40),
                  color: Colors.white,
                  disabledColor: Colors.white38,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: running ? _pause : _play,
                      tooltip: switch (_state) {
                        SimulationState.stopped => 'Start driving',
                        SimulationState.running => 'Pause',
                        SimulationState.paused => 'Resume',
                      },
                      icon: Icon(
                        running ? Icons.pause_circle : Icons.play_circle,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _state == SimulationState.stopped
                          ? null
                          : _stop,
                      tooltip: 'Stop',
                      icon: const Icon(Icons.stop_circle, size: 40),
                      color: Colors.white,
                      disabledColor: Colors.white38,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: running ? _game.moveRight : null,
                  tooltip: 'Steer right',
                  icon: const Icon(Icons.arrow_circle_right, size: 40),
                  color: Colors.white,
                  disabledColor: Colors.white38,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dims the road while the simulation is stopped or paused. Tapping it
  /// starts driving.
  Widget _buildStartOverlay() {
    final paused = _state == SimulationState.paused;
    final label = paused ? 'Paused: tap to resume' : 'Tap to start driving';
    return Positioned.fill(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: _play,
          child: ColoredBox(
            color: Colors.black54,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return Positioned(
      top: 50,
      left: 20,
      child: Column(
        children: [
          Container(
            width: 160,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RepaintBoundary(
              child: CustomPaint(
                painter: MapViewPainter(game: _game, zoom: _mapZoom),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                tooltip: 'Zoom in',
                onPressed: () => _zoomMap(0.2),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                tooltip: 'Zoom out',
                onPressed: () => _zoomMap(-0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
