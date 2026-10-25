/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:steer_wise/src/models/driving_question.dart';
import 'package:steer_wise/src/screens/show_me_tell_screen.dart';

const _questions = [
  DrivingQuestion(
    type: DrivingQuestion.show,
    question: 'Show me how you wash the windscreen.',
    answer: '',
  ),
  DrivingQuestion(
    type: DrivingQuestion.tell,
    question: 'Tell me how you check the brakes.',
    answer: 'Brakes should not feel spongy.',
  ),
  DrivingQuestion(
    type: DrivingQuestion.tell,
    question: 'Tell me how you check the tyres.',
    answer: 'At least 1.6mm of tread.',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DrivingQuestion.fromJson', () {
    test('reads all fields and normalises the type', () {
      final question = DrivingQuestion.fromJson({
        'type': ' Tell ',
        'question': 'Tell me how you check the oil.',
        'answer': 'Use the dipstick.',
      });

      expect(question.type, DrivingQuestion.tell);
      expect(question.question, startsWith('Tell me'));
      expect(question.answer, 'Use the dipstick.');
    });

    test('treats a missing answer as empty', () {
      final question = DrivingQuestion.fromJson({
        'type': 'show',
        'question': 'Show me how you use the horn.',
      });

      expect(question.answer, isEmpty);
    });
  });

  group('filterQuestions', () {
    test('returns everything with no search or type', () {
      expect(filterQuestions(_questions), hasLength(3));
    });

    test('filters by type', () {
      final tell = filterQuestions(_questions, type: DrivingQuestion.tell);
      expect(tell.map((q) => q.type), everyElement(DrivingQuestion.tell));
      expect(tell, hasLength(2));
    });

    test('searches the question text, ignoring case', () {
      expect(filterQuestions(_questions, query: 'BRAKES'), hasLength(1));
    });

    test('combines search and type', () {
      expect(
        filterQuestions(_questions, query: 'check', type: DrivingQuestion.tell),
        hasLength(2),
      );
      expect(
        filterQuestions(_questions, query: 'check', type: DrivingQuestion.show),
        isEmpty,
      );
    });
  });

  // "Show me" questions are demonstrated while driving, so only "tell me"
  // questions need a written answer.
  test(
    'bundled question bank contains valid show and tell questions',
    () async {
      final data = await rootBundle.loadString(
        ShowMeTellMeScreen.questionsAsset,
      );
      final questions = (jsonDecode(data) as List)
          .map((q) => DrivingQuestion.fromJson(q as Map<String, dynamic>))
          .toList();

      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect([DrivingQuestion.show, DrivingQuestion.tell], contains(q.type));
        expect(q.question, isNotEmpty);
        if (q.type == DrivingQuestion.tell) expect(q.answer, isNotEmpty);
      }
    },
  );
}
