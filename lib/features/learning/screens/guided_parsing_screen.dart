import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class GuidedParsingScreen extends StatelessWidget {
  const GuidedParsingScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final LessonModel lesson;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    final example = lesson.examples.first;
    return Scaffold(
      appBar: AppBar(title: const Text('جرّب معي')),
      body: ListView(
        padding: const EdgeInsets.all(E3rabSpacing.large),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: E3rabReadingMetrics.maxContentWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    example.fullyDiacritizedSentence,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: E3rabSpacing.large),
                  Text(
                    'نتبع دائمًا: نوع الكلمة ← موقعها ← حالتها ← علامتها ← سبب العلامة',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: E3rabSpacing.large),
                  for (final word in example.parsedWords)
                    _ParsedWordCard(word: word),
                  FilledButton.icon(
                    onPressed: () async {
                      await onCompleted();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('أكملت الإعراب الموجّه'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParsedWordCard extends StatelessWidget {
  const _ParsedWordCard({required this.word});

  final ParsedWordModel word;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: E3rabSpacing.medium),
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(word.word, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: E3rabSpacing.small),
          Text('نوع الكلمة: ${word.wordType}'),
          Text('الموقع: ${word.grammaticalRole}'),
          if (word.grammaticalAgent.isNotEmpty)
            Text('العامل: ${word.grammaticalAgent}'),
          Text('الحالة: ${word.grammaticalState}'),
          Text('العلامة: ${word.grammaticalSign}'),
          Text('السبب: ${word.signReason}'),
          if (word.sentencePosition.isNotEmpty)
            Text('محل الجملة: ${word.sentencePosition}'),
          const SizedBox(height: E3rabSpacing.small),
          Text(word.explanation, style: const TextStyle(height: 1.7)),
        ],
      ),
    ),
  );
}
