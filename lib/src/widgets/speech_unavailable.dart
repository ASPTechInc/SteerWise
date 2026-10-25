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

// Project imports:
import 'package:steer_wise/src/config/routes.dart';
import 'package:steer_wise/src/services/tts_service.dart';

bool _noticeShown = false;

/// Speaks [text] with the shared [TtsService]. If the device has no speech
/// engine, explains (once per session) how to install a free one.
Future<void> speakOrExplain(
  BuildContext context,
  TtsService tts,
  String text,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context, rootNavigator: true);
  final spoken = await tts.speak(text);
  if (spoken || _noticeShown) return;
  _noticeShown = true;
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 8),
      content: const Text(
        'No text-to-speech engine is installed, so instructions cannot be '
        'read aloud. Free engines such as RHVoice and eSpeak NG are '
        'available on F-Droid.',
      ),
      action: SnackBarAction(
        label: 'Help',
        onPressed: () => unawaited(navigator.pushNamed(AppRoutes.help)),
      ),
    ),
  );
}

@visibleForTesting
void resetSpeechUnavailableNotice() => _noticeShown = false;
