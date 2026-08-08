import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../widgets/parsed_example_card.dart';

class LessonExamplesScreen extends StatelessWidget {
  const LessonExamplesScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final LessonModel lesson;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الأمثلة')),
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
                  'اختر مثالًا لترى إعرابه',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: E3rabSpacing.small),
                const Text('كل مثال مشروح كلمةً كلمة بوضوح.'),
                const SizedBox(height: E3rabSpacing.large),
                ...lesson.examples.indexed.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: E3rabSpacing.small),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        minTileHeight: 72,
                        leading: CircleAvatar(child: Text('${entry.$1 + 1}')),
                        title: Text(
                          entry.$2.fullyDiacritizedSentence,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        trailing: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                        ),
                        onTap: () => _openExample(context, entry.$2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: E3rabSpacing.medium),
                FilledButton.icon(
                  onPressed: () async {
                    await onCompleted();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('شاهدت الأمثلة'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  void _openExample(BuildContext context, GrammarExampleModel example) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ExampleDetailsScreen(example: example),
      ),
    );
  }
}

class _ExampleDetailsScreen extends StatelessWidget {
  const _ExampleDetailsScreen({required this.example});

  final GrammarExampleModel example;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('شرح المثال')),
    body: ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: E3rabReadingMetrics.maxContentWidth,
            ),
            child: ParsedExampleCard(example: example, initiallyExpanded: true),
          ),
        ),
      ],
    ),
  );
}
