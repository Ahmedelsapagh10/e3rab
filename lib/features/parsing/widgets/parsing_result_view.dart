import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../cubit/parsing_state.dart';

class ParsingResultView extends StatelessWidget {
  const ParsingResultView({
    super.key,
    required this.state,
    required this.onNextSample,
  });

  final ParsingState state;
  final VoidCallback onNextSample;

  @override
  Widget build(BuildContext context) {
    final sample = state.currentSample;
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.all(E3rabSpacing.large),
        children: [
          Text(
            'الإعراب المرجعي',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('نتيجتك ${(state.score * 100).round()}٪'),
          const SizedBox(height: E3rabSpacing.medium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(E3rabSpacing.large),
              child: Text(sample.summary, style: const TextStyle(height: 1.8)),
            ),
          ),
          ...sample.parsedWords.map(
            (word) => Card(
              child: Padding(
                padding: const EdgeInsets.all(E3rabSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text('النوع: ${word.wordType}'),
                    Text('الموقع: ${word.grammaticalRole}'),
                    Text('الحالة: ${word.grammaticalState}'),
                    Text('العلامة: ${word.grammaticalSign}'),
                    Text('السبب: ${word.signReason}'),
                    Text(word.explanation),
                  ],
                ),
              ),
            ),
          ),
          if (sample.alternatives.isNotEmpty) ...[
            const SizedBox(height: E3rabSpacing.medium),
            Text(
              'أوجه تعبير صحيحة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...sample.alternatives.map(
              (alternative) => ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: Text(alternative.title),
                subtitle: Text(alternative.explanation),
              ),
            ),
          ],
          const SizedBox(height: E3rabSpacing.medium),
          Text('للمراجعة: ${sample.relatedLessonId}'),
          const SizedBox(height: E3rabSpacing.large),
          FilledButton.icon(
            onPressed: onNextSample,
            icon: const Icon(Icons.arrow_back),
            label: const Text('جملة أخرى'),
          ),
        ],
      ),
    );
  }
}
