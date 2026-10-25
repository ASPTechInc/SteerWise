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
import 'package:steer_wise/src/screens/driving_simulator.dart';
import 'package:steer_wise/src/services/tts_service.dart';
import 'package:steer_wise/src/widgets/app_sidebar.dart';
import 'package:steer_wise/src/widgets/camera_preview_box.dart';
import 'package:steer_wise/src/widgets/speech_unavailable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Duration autoModeInterval = Duration(seconds: 8);

  int _currentIndex = 0;
  Timer? _instructionTimer;

  bool get _autoMode => _instructionTimer?.isActive ?? false;

  String get _currentInstruction => AppConstants.instructions[_currentIndex];

  @override
  void dispose() {
    _instructionTimer?.cancel();
    super.dispose();
  }

  void _nextInstruction() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % AppConstants.instructions.length;
    });
    unawaited(
      speakOrExplain(context, context.read<TtsService>(), _currentInstruction),
    );
  }

  void _toggleAutoMode() {
    setState(() {
      if (_autoMode) {
        _instructionTimer?.cancel();
      } else {
        _instructionTimer = Timer.periodic(
          autoModeInterval,
          (_) => _nextInstruction(),
        );
      }
    });
  }

  void _giveFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback: Good job! Try to turn smoother next time.'),
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
              child: const SizedBox(
                height: 280,
                width: double.infinity,
                child: ClipRect(child: DrivingSimulationScreen()),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _nextInstruction,
              child: const Text('Next Instruction'),
            ),
            ElevatedButton(
              onPressed: _toggleAutoMode,
              child: Text(_autoMode ? 'Stop Auto Mode' : 'Start Auto Mode'),
            ),
            ElevatedButton(
              onPressed: _giveFeedback,
              child: const Text('Get Feedback'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
