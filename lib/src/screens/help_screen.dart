/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/material.dart';

/// Explains how to use each part of the app.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<(IconData, String, List<String>)> _sections = [
    (
      Icons.handyman,
      'Setting up',
      [
        'Use a steering wheel prop, such as a dinner plate.',
        'Mount your phone or tablet in front of it so you can see the screen '
            'and the camera can see your hands.',
        'Practise push-pull steering: keep both hands on the wheel and do '
            'not cross your arms.',
      ],
    ),
    (
      Icons.record_voice_over,
      'Voice instructions',
      [
        'The Home screen shows the current instruction and reads it aloud '
            'when you tap Next Instruction.',
        'Start Auto Mode to hear a new instruction every 8 seconds.',
        'Get Feedback shows a tip about your steering.',
        'Speech uses your device\'s text-to-speech engine. If nothing is '
            'read aloud, install one: free engines such as RHVoice and eSpeak '
            'NG are available on F-Droid. Then choose it in your device\'s '
            'text-to-speech settings.',
      ],
    ),
    (
      Icons.videocam,
      'Camera preview',
      [
        'The front camera shows your hand position while you practise. '
            'Nothing is recorded or uploaded.',
        'If your phone faces away from you, tap the switch button in the '
            'corner of the preview to use the rear camera. SteerWise '
            'remembers your choice.',
        'The camera turns off when you switch tab or leave the app, and '
            'turns back on when you return to Home.',
        'If you refused camera access, tap Open settings on the Home screen '
            'to turn it on.',
      ],
    ),
    (
      Icons.traffic,
      'Driving simulation',
      [
        'You drive in the left lane, as in the UK. Oncoming cars use the '
            'right lane and sometimes change lane.',
        'Steer with the arrow buttons or by swiping left or right.',
        'Oncoming cars stop at the line when the traffic light is amber or '
            'red. You score a point for each car you pass safely.',
        'Tap the map button to show the mini map, and use the zoom buttons '
            'to change its scale.',
      ],
    ),
    (
      Icons.question_answer,
      'Show Me/Tell Me',
      [
        'These are the vehicle safety questions from the UK practical '
            'driving test.',
        'Search the questions, or use the filter button to show only Show '
            'or Tell questions.',
        'Tap the eye button to switch between Test Mode (answers hidden) '
            'and Practice Mode (answers shown).',
        'In Test Mode, tap a Tell question to check your answer, or tap the '
            'speaker button to hear the question.',
      ],
    ),
    (
      Icons.settings,
      'Settings',
      ['Choose a light or dark theme, or follow your device setting.'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Help'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          for (final (icon, title, points) in _sections)
            Card(
              child: ExpansionTile(
                leading: Icon(icon),
                title: Text(title, style: theme.textTheme.titleMedium),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $point'),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'SteerWise is a practice aid. It does not replace lessons with '
              'a qualified driving instructor.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
