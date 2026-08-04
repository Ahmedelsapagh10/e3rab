import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';

class TeacherLessonCard extends StatelessWidget {
  const TeacherLessonCard({
    super.key,
    required this.lesson,
    required this.prerequisites,
    required this.hasPrivateNote,
    required this.onPresent,
    required this.onNote,
  });

  final LessonModel lesson;
  final List<String> prerequisites;
  final bool hasPrivateNote;
  final VoidCallback onPresent;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    final misconception = lesson.sections
        .where((section) => section.type == 'misconceptions')
        .firstOrNull;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.co_present_outlined),
        title: Text(lesson.title),
        subtitle: Text(
          '${lesson.objectives.length} أهداف • '
          '${prerequisites.length} متطلبات • ${lesson.estimatedMinutes} دقيقة',
        ),
        childrenPadding: const EdgeInsets.all(E3rabSpacing.medium),
        children: [
          _Section(title: 'الأهداف', lines: lesson.objectives),
          _Section(
            title: 'المتطلبات السابقة',
            lines: prerequisites.isEmpty
                ? const ['لا توجد متطلبات مسجلة.']
                : prerequisites,
          ),
          _Section(
            title: 'خطأ شائع ينبغي مناقشته',
            lines: [misconception?.body ?? 'لا يوجد خطأ شائع مسجل.'],
          ),
          Wrap(
            spacing: E3rabSpacing.small,
            runSpacing: E3rabSpacing.small,
            children: [
              FilledButton.icon(
                onPressed: onPresent,
                icon: const Icon(Icons.slideshow),
                label: const Text('عرض صفي'),
              ),
              OutlinedButton.icon(
                onPressed: onNote,
                icon: Icon(
                  hasPrivateNote ? Icons.note_alt : Icons.note_add_outlined,
                ),
                label: Text(
                  hasPrivateNote ? 'تعديل الملاحظة الخاصة' : 'ملاحظة خاصة',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: E3rabSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        ...lines.map((line) => Text('• $line')),
      ],
    ),
  );
}
