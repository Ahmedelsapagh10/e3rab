import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class LessonExplanationScreen extends StatelessWidget {
  const LessonExplanationScreen({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final LessonModel lesson;
  final Future<void> Function() onCompleted;

  @override
  Widget build(BuildContext context) {
    final sections = [...lesson.sections]
      ..sort((a, b) => a.order.compareTo(b.order));
    return Scaffold(
      appBar: AppBar(title: const Text('الشرح')),
      body: SelectionArea(
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
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.4),
                    ),
                    const SizedBox(height: E3rabSpacing.large),
                    _ObjectivesCard(objectives: lesson.objectives),
                    const SizedBox(height: E3rabSpacing.large),
                    ...sections.map(_ExplanationSection.new),
                    FilledButton.icon(
                      onPressed: () async {
                        await onCompleted();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('فهمت الشرح'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectivesCard extends StatelessWidget {
  const _ObjectivesCard({required this.objectives});

  final List<String> objectives;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ماذا ستتعلم؟', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: E3rabSpacing.small),
          ...objectives.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: E3rabSpacing.small),
              child: Text('• $item', style: const TextStyle(height: 1.7)),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection(this.section);

  final LessonSectionModel section;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: E3rabSpacing.large),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: E3rabSpacing.small),
        Text(section.body, style: const TextStyle(height: 1.85)),
      ],
    ),
  );
}
