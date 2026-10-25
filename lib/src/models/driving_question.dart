/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

/// A Show Me/Tell Me question from the UK practical driving test.
class DrivingQuestion {
  const DrivingQuestion({
    required this.type,
    required this.question,
    required this.answer,
  });

  /// Reads a question from the bundled JSON. [type] is normalised to
  /// lower case, so the data can use "Show", "show " and so on.
  factory DrivingQuestion.fromJson(Map<String, dynamic> json) {
    return DrivingQuestion(
      type: (json['type'] as String).trim().toLowerCase(),
      question: json['question'] as String,
      answer: json['answer'] as String? ?? '',
    );
  }

  static const String show = 'show';
  static const String tell = 'tell';

  /// Either [show] or [tell].
  final String type;
  final String question;

  /// Written answer. Empty for "show me" questions, which are demonstrated
  /// while driving.
  final String answer;
}

/// Returns the [questions] whose text contains [query] (ignoring case) and,
/// when [type] is given, that are of that type.
List<DrivingQuestion> filterQuestions(
  Iterable<DrivingQuestion> questions, {
  String query = '',
  String? type,
}) {
  final search = query.trim().toLowerCase();
  return questions
      .where(
        (q) =>
            (type == null || q.type == type) &&
            q.question.toLowerCase().contains(search),
      )
      .toList();
}
