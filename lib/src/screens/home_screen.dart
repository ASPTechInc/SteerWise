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

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/models/manoeuvre.dart';
import 'package:steer_wise/src/screens/driving_simulator.dart';
import 'package:steer_wise/src/services/tts_service.dart';
import 'package:steer_wise/src/simulation/driving_game.dart';
import 'package:steer_wise/src/widgets/app_sidebar.dart';
import 'package:steer_wise/src/widgets/camera_preview_box.dart';
import 'package:steer_wise/src/widgets/speech_unavailable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Shared with the simulation, which drives the route. The instruction
  /// shown here is whatever the road is about to show.
  final DrivingGame _game = DrivingGame();

  String get _currentInstruction => _game.instruction.value;

  @override
  void initState() {
    super.initState();
    _game.instruction.addListener(_onInstructionChanged);
    _game.lastResult.addListener(_onManoeuvreDone);
  }

  @override
  void dispose() {
    _game.instruction.removeListener(_onInstructionChanged);
    _game.lastResult.removeListener(_onManoeuvreDone);
    _game.dispose();
    super.dispose();
  }

  void _onInstructionChanged() {
    setState(() {});
    // Only manoeuvres are read aloud, not the reminder between them.
    if (_currentInstruction == Manoeuvre.followRoad) return;
    unawaited(
      speakOrExplain(context, context.read<TtsService>(), _currentInstruction),
    );
  }

  void _onManoeuvreDone() {
    if (_game.lastResult.value != null) _giveFeedback();
  }

  void _nextInstruction() => _game.skipManoeuvre();

  void _giveFeedback() {
    final result = _game.lastResult.value;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            result?.feedback ??
                'Drive up to a junction or roundabout to get feedback on '
                    'your signals.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
      ),
      drawer: const AppSidebar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 200,
              width: double.infinity,
              child: CameraPreviewBox(),
            ),
            const SizedBox(height: 10),
            const Text('Current Instruction:', style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _currentInstruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: SizedBox(
                height: 280,
                width: double.infinity,
                child: ClipRect(child: DrivingSimulationScreen(game: _game)),
              ),
            ),
            const SizedBox(height: 8),
            // Icons only; the tooltips also name the buttons for screen
            // readers.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                IconButton.filledTonal(
                  onPressed: _nextInstruction,
                  tooltip: 'Next Instruction',
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_forward),
                ),
                IconButton.filledTonal(
                  onPressed: _giveFeedback,
                  tooltip: 'Get Feedback',
                  iconSize: 32,
                  icon: const Icon(Icons.lightbulb_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
