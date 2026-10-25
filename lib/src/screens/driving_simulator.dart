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
import 'package:steer_wise/src/widgets/map_view_painter.dart';
import 'package:steer_wise/src/widgets/road_painter.dart';

/// The driving simulation shown on the Home screen.
///
/// A [Ticker] advances the [DrivingGame] once per frame. The painters listen
/// to the game directly, so only the canvas repaints each frame.
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

  bool _showMiniMap = false;
  double _mapZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _game.addListener(_onGameChanged);
    unawaited(_ticker.start());
  }

  @override
  void dispose() {
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

  void _restart() {
    _game.reset();
    _lastTick = Duration.zero;
    unawaited(_ticker.start());
  }

  Future<void> _showCollisionDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Collision detected'),
        content: Text(
          'You collided with an oncoming car!\nScore: ${_game.score}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    if (mounted) _restart();
  }

  void _zoomMap(double change) {
    setState(() => _mapZoom = (_mapZoom + change).clamp(0.6, 2.0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
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
                  onPressed: _game.moveLeft,
                  tooltip: 'Steer left',
                  icon: const Icon(
                    Icons.arrow_circle_left,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: _game.moveRight,
                  tooltip: 'Steer right',
                  icon: const Icon(
                    Icons.arrow_circle_right,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
