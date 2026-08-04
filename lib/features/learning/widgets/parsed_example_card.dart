import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class ParsedExampleCard extends StatelessWidget {
  const ParsedExampleCard({super.key, required this.example});

  final GrammarExampleModel example;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(
          example.fullyDiacritizedSentence,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 2),
        ),
        subtitle: Text(example.explanation),
        children: example.parsedWords
            .map(
              (word) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  E3rabSpacing.medium,
                  E3rabSpacing.small,
                  E3rabSpacing.medium,
                  E3rabSpacing.medium,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(E3rabSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: E3rabSpacing.small),
                        Wrap(
                          spacing: E3rabSpacing.small,
                          runSpacing: E3rabSpacing.small,
                          children: [
                            Chip(label: Text('النوع: ${word.wordType}')),
                            Chip(
                              label: Text('الموقع: ${word.grammaticalRole}'),
                            ),
                            Chip(
                              label: Text('الحالة: ${word.grammaticalState}'),
                            ),
                            Chip(
                              label: Text('العلامة: ${word.grammaticalSign}'),
                            ),
                          ],
                        ),
                        Text('السبب: ${word.signReason}'),
                        Text(word.explanation),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
