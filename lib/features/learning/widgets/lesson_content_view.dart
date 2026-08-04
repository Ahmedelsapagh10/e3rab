import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/content_reference_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'parsed_example_card.dart';

class LessonContentView extends StatelessWidget {
  const LessonContentView({
    super.key,
    required this.lesson,
    required this.references,
    required this.onReference,
  });

  final LessonModel lesson;
  final List<ContentReferenceModel> references;
  final ValueChanged<ContentReferenceModel> onReference;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView(
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
                    lesson.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: E3rabSpacing.small),
                  Wrap(
                    spacing: E3rabSpacing.small,
                    children: [
                      Chip(label: Text('${lesson.estimatedMinutes} دقيقة')),
                      const Chip(label: Text('مسودة قيد المراجعة')),
                    ],
                  ),
                  const SizedBox(height: E3rabSpacing.large),
                  _Objectives(objectives: lesson.objectives),
                  ...lesson.sections.map(
                    (section) => _Section(section: section),
                  ),
                  Text(
                    'أمثلة معرَبة',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: E3rabSpacing.small),
                  ...lesson.examples.map(
                    (example) => ParsedExampleCard(example: example),
                  ),
                  const SizedBox(height: E3rabSpacing.large),
                  Text(
                    'المراجع',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ...references.map(
                    (reference) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.open_in_new),
                      title: Text(reference.title),
                      subtitle: Text(reference.publisher),
                      onTap: () => onReference(reference),
                    ),
                  ),
                  const SizedBox(height: 112),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Objectives extends StatelessWidget {
  const _Objectives({required this.objectives});

  final List<String> objectives;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بعد هذا الدرس ستستطيع:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          ...objectives.map(
            (objective) =>
                Text('• $objective', style: const TextStyle(height: 1.8)),
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final LessonSectionModel section;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: E3rabSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: E3rabSpacing.small),
        Text(
          section.body,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: E3rabReadingMetrics.paragraphHeight,
          ),
        ),
      ],
    ),
  );
}
