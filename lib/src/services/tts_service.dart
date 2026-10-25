/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_tts/flutter_tts.dart';

// Project imports:
import 'package:steer_wise/src/utils/helpers.dart';

/// The single text-to-speech engine shared by the whole app, so screens
/// never talk over each other.
///
/// Speech uses the device's own text-to-speech engine. Phones without
/// Google services may have none installed; [speak] then returns false so
/// the screen can explain how to install a free engine.
class TtsService {
  TtsService({FlutterTts? tts}) : _tts = tts;

  FlutterTts? _tts;
  bool _configured = false;
  bool? _available;

  /// Whether a speech engine is installed. Only Android reports this;
  /// other platforms always have one.
  Future<bool> isAvailable() async {
    final known = _available;
    if (known != null) return known;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return _available = true;
    }
    try {
      final engines = await (_tts ??= FlutterTts()).getEngines;
      return _available = engines is List && engines.isNotEmpty;
    } catch (e, stackTrace) {
      logError('Could not list text-to-speech engines', e, stackTrace);
      // Unknown: try to speak anyway rather than block speech.
      return _available = true;
    }
  }

  Future<FlutterTts> _engine() async {
    final tts = _tts ??= FlutterTts();
    if (!_configured) {
      await tts.setLanguage('en-GB');
      await tts.setSpeechRate(0.5);
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);
      _configured = true;
    }
    return tts;
  }

  /// Speaks [text], interrupting anything that is already being spoken.
  ///
  /// Returns false if the device has no speech engine.
  Future<bool> speak(String text) async {
    if (!await isAvailable()) return false;
    try {
      final tts = await _engine();
      await tts.stop();
      await tts.speak(text);
    } catch (e, stackTrace) {
      logError('Text-to-speech failed', e, stackTrace);
    }
    return true;
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (e, stackTrace) {
      logError('Stopping text-to-speech failed', e, stackTrace);
    }
  }
}
