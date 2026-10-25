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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/services/tts_service.dart';
import 'package:steer_wise/src/widgets/speech_unavailable.dart';

const _ttsChannel = MethodChannel('flutter_tts');

void main() {
  late List<String> spoken;

  void mockEngines(List<String> engines) {
    spoken = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, (call) async {
          switch (call.method) {
            case 'getEngines':
              return engines;
            case 'speak':
              spoken.add(call.arguments as String);
              return 1;
            default:
              return 1;
          }
        });
  }

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    resetSpeechUnavailableNotice();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_ttsChannel, null);
  });

  test('speaks when an engine is installed', () async {
    mockEngines(['org.nobody.multitts']);
    final tts = TtsService();

    expect(await tts.speak('Turn left'), isTrue);
    expect(spoken, ['Turn left']);
  });

  test('reports when no engine is installed', () async {
    mockEngines([]);
    final tts = TtsService();

    expect(await tts.isAvailable(), isFalse);
    expect(await tts.speak('Turn left'), isFalse);
    expect(spoken, isEmpty);
  });

  testWidgets('explains a missing engine once per session', (tester) async {
    mockEngines([]);
    final tts = TtsService();
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    await speakOrExplain(context, tts, 'Turn left');
    await tester.pump();
    expect(find.textContaining('RHVoice'), findsOneWidget);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await speakOrExplain(context, tts, 'Turn right');
    await tester.pump();
    expect(find.textContaining('RHVoice'), findsNothing);

    // Reset the platform before the test framework checks it.
    debugDefaultTargetPlatformOverride = null;
  });
}
