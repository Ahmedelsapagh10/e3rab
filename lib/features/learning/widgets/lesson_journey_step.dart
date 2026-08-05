import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/content_reference_model.dart';
import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import 'parsed_example_card.dart';
import 'lesson_quick_check.dart';

class LessonJourneyStepData {
  const LessonJourneyStepData({
    required this.id,
    required this.label,
    required this.title,
    required this.children,
  });

  final String id;
  final String label;
  final String title;
  final List<Widget> children;
}

List<LessonJourneyStepData> buildLessonJourney({
  required LessonModel lesson,
  required ExerciseModel? quickCheck,
  required List<ContentReferenceModel> references,
}) {
  final sections = [...lesson.sections]
    ..sort((a, b) => a.order.compareTo(b.order));
  final split = sections.length.clamp(1, 4);
  final ruleSections = sections.take(split).toList();
  final details = sections.skip(split).toList();
  return [
    LessonJourneyStepData(
      id: '${lesson.id}-journey-introduction',
      label: 'تمهيد',
      title: lesson.title,
      children: [
        Text(lesson.objectives.first, style: const TextStyle(height: 1.8)),
        const SizedBox(height: E3rabSpacing.large),
        _ObjectiveCard(objectives: lesson.objectives),
      ],
    ),
    LessonJourneyStepData(
      id: '${lesson.id}-journey-rule',
      label: 'القاعدة ببساطة',
      title: ruleSections.first.title,
      children: ruleSections.map(_SectionBody.new).toList(),
    ),
    LessonJourneyStepData(
      id: '${lesson.id}-journey-example',
      label: 'مثال محلّل',
      title: 'شاهد الإعراب داخل الجملة',
      children: lesson.examples
          .map((example) => ParsedExampleCard(example: example))
          .toList(),
    ),
    LessonJourneyStepData(
      id: '${lesson.id}-journey-attention',
      label: 'انتبه',
      title: details.isEmpty ? 'ثبّت الفكرة' : details.first.title,
      children: details.isEmpty
          ? const [Text('اقرأ المثال مرة أخرى وحدد العلامة وسببها.')]
          : details.map(_SectionBody.new).toList(),
    ),
    if (quickCheck != null)
      LessonJourneyStepData(
        id: '${lesson.id}-journey-check',
        label: 'تحقق سريع',
        title: 'هل وصلت الفكرة؟',
        children: [LessonQuickCheck(exercise: quickCheck)],
      ),
    LessonJourneyStepData(
      id: '${lesson.id}-journey-summary',
      label: 'الخلاصة',
      title: 'أصبحت جاهزًا للتطبيق',
      children: [
        const Text(
          'تذكّر: حدّد نوع الكلمة، ثم موقعها، ثم حالتها وعلامتها وسبب العلامة.',
          style: TextStyle(height: 1.8),
        ),
        const SizedBox(height: E3rabSpacing.large),
        ...references.map(
          (reference) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.verified_outlined),
            title: Text(reference.title),
            subtitle: const Text('مرجع موثّق للمحتوى'),
          ),
        ),
      ],
    ),
  ];
}

class LessonJourneyStep extends StatelessWidget {
  const LessonJourneyStep({
    super.key,
    required this.data,
    required this.onReference,
  });

  final LessonJourneyStepData data;
  final ValueChanged<ContentReferenceModel> onReference;

  @override
  Widget build(BuildContext context) => SelectionArea(
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
                  data.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: E3rabSpacing.large),
                ...data.children,
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionBody extends StatelessWidget {
  const _SectionBody(this.section);

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

class _ObjectiveCard extends StatelessWidget {
  const _ObjectiveCard({required this.objectives});

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
          const SizedBox(height: E3rabSpacing.small),
          ...objectives.map(
            (item) => Text('• $item', style: const TextStyle(height: 1.8)),
          ),
        ],
      ),
    ),
  );
}
