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
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:steer_wise/src/config/constants.dart';
import 'package:steer_wise/src/config/theme_extensions.dart';
import 'package:steer_wise/src/models/driving_question.dart';
import 'package:steer_wise/src/services/tts_service.dart';
import 'package:steer_wise/src/utils/helpers.dart';
import 'package:steer_wise/src/widgets/app_sidebar.dart';
import 'package:steer_wise/src/widgets/speech_unavailable.dart';

class ShowMeTellMeScreen extends StatefulWidget {
  const ShowMeTellMeScreen({super.key});

  static const String questionsAsset =
      'assets/data/show_me_tell_me_questions.json';

  @override
  State<ShowMeTellMeScreen> createState() => _ShowMeTellMeScreenState();
}

class _ShowMeTellMeScreenState extends State<ShowMeTellMeScreen> {
  List<DrivingQuestion> _allQuestions = [];
  bool _loading = true;
  String _searchQuery = '';

  /// [DrivingQuestion.show], [DrivingQuestion.tell] or null for all.
  String? _typeFilter;
  bool _showAnswers = false;

  List<DrivingQuestion> get _visibleQuestions =>
      filterQuestions(_allQuestions, query: _searchQuery, type: _typeFilter);

  @override
  void initState() {
    super.initState();
    unawaited(_loadQuestions());
  }

  Future<void> _loadQuestions() async {
    try {
      final data = await rootBundle.loadString(
        ShowMeTellMeScreen.questionsAsset,
      );
      final questions = (jsonDecode(data) as List)
          .map((q) => DrivingQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _allQuestions = questions;
        _loading = false;
      });
    } catch (e, stackTrace) {
      logError('Could not load Show Me/Tell Me questions', e, stackTrace);
      if (mounted) setState(() => _loading = false);
    }
  }

  void _speak(String text) {
    unawaited(speakOrExplain(context, context.read<TtsService>(), text));
  }

  Future<void> _showAnswer(DrivingQuestion question) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Answer'),
        content: Text(question.answer),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu() {
    // PopupMenuButton treats a null value as the menu being dismissed, so
    // "All" uses an empty string instead.
    const all = '';
    const options = {
      all: 'All',
      DrivingQuestion.show: 'Show',
      DrivingQuestion.tell: 'Tell',
    };
    final selected = _typeFilter ?? all;
    return PopupMenuButton<String>(
      icon: Icon(
        _typeFilter == null ? Icons.filter_alt_outlined : Icons.filter_alt,
      ),
      tooltip: 'Filter questions',
      initialValue: selected,
      onSelected: (value) =>
          setState(() => _typeFilter = value == all ? null : value),
      itemBuilder: (_) => [
        for (final MapEntry(key: value, value: label) in options.entries)
          CheckedPopupMenuItem<String>(
            value: value,
            checked: selected == value,
            child: Text(label),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = _visibleQuestions;

    return Scaffold(
      drawer: const AppSidebar(),
      appBar: AppBar(
        title: const Text('Show Me & Tell Me'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showAnswers ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showAnswers = !_showAnswers),
            tooltip: _showAnswers ? 'Test Mode' : 'Practice Mode',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buildFilterMenu(),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.colorScheme.tertiary,
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
          ? const Center(child: Text('No questions match your search.'))
          : ListView.builder(
              // The last item credits the source, as the OGL requires.
              itemCount: questions.length + 1,
              itemBuilder: (_, i) => i < questions.length
                  ? _buildQuestion(theme, questions[i])
                  : _buildAttribution(theme),
            ),
    );
  }

  Widget _buildAttribution(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Text(
            AppConstants.questionsAttribution,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              TextButton(
                onPressed: () =>
                    unawaited(openExternalUrl(AppConstants.questionsSourceUrl)),
                child: const Text('Source: GOV.UK'),
              ),
              TextButton(
                onPressed: () =>
                    unawaited(openExternalUrl(AppConstants.oglUrl)),
                child: const Text('Open Government Licence'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(ThemeData theme, DrivingQuestion q) {
    final isShow = q.type == DrivingQuestion.show;
    return Card(
      child: ListTile(
        tileColor: isShow ? theme.showTileColour : theme.tellTileColour,
        title: Text.rich(
          TextSpan(
            style: theme.textTheme.bodyLarge,
            children: [
              TextSpan(
                text: q.type.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(text: ': ${q.question}'),
            ],
          ),
        ),
        subtitle: _showAnswers && q.answer.isNotEmpty ? Text(q.answer) : null,
        trailing: IconButton(
          icon: const Icon(Icons.volume_up),
          tooltip: 'Read question aloud',
          onPressed: () => _speak(q.question),
        ),
        onTap: !_showAnswers && q.type == DrivingQuestion.tell
            ? () => unawaited(_showAnswer(q))
            : null,
      ),
    );
  }
}
