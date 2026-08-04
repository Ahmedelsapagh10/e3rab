import 'package:flutter/material.dart';

import '../../../core/design_system/e3rab_design_tokens.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_support_models.dart';
import 'teacher_lesson_card.dart';

class TeacherLessonsView extends StatelessWidget {
  const TeacherLessonsView({
    super.key,
    required this.lessons,
    required this.privateNotes,
    required this.onPresent,
    required this.onNote,
  });

  final List<LessonModel> lessons;
  final List<LearningNoteModel> privateNotes;
  final ValueChanged<LessonModel> onPresent;
  final ValueChanged<LessonModel> onNote;

  @override
  Widget build(BuildContext context) {
    final names = {for (final lesson in lessons) lesson.id: lesson.title};
    return ListView(
      padding: const EdgeInsets.all(E3rabSpacing.large),
      children: [
        Text('دليل المعلم', style: Theme.of(context).textTheme.headlineSmall),
        const Text(
          'راجع الهدف والمتطلبات والأخطاء الشائعة، ثم افتح العرض الصفي.',
          style: TextStyle(height: 1.7),
        ),
        const SizedBox(height: E3rabSpacing.medium),
        ...lessons.map(
          (lesson) => TeacherLessonCard(
            lesson: lesson,
            prerequisites: lesson.prerequisiteIds
                .map((id) => names[id] ?? id)
                .toList(),
            hasPrivateNote: privateNotes.any(
              (note) => note.targetId == lesson.id && note.deletedAt == null,
            ),
            onPresent: () => onPresent(lesson),
            onNote: () => onNote(lesson),
          ),
        ),
      ],
    );
  }
}
