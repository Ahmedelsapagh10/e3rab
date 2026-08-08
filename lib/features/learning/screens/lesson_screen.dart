import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../navigation/lesson_phase_navigator.dart';
import '../widgets/lesson_note_dialog.dart';
import '../widgets/lesson_overview_view.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});

  final LessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningCubit, LearningState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(lesson.shortTitle),
          actions: [
            IconButton(
              tooltip: 'ملاحظتي',
              onPressed: () => _editNote(context, state),
              icon: const Icon(Icons.note_alt_outlined),
            ),
            IconButton(
              tooltip: state.isBookmarked(lesson.id)
                  ? 'إزالة الحفظ'
                  : 'حفظ الدرس',
              onPressed: () =>
                  context.read<LearningCubit>().toggleBookmark(lesson),
              icon: Icon(
                state.isBookmarked(lesson.id)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
          ],
        ),
        body: LessonOverviewView(
          lesson: lesson,
          suggestedPhase: _suggestedPhase(state),
          onPhaseSelected: (index) => LessonPhaseNavigator.open(
            context,
            lesson: lesson,
            state: state,
            phase: LearningPhaseType.values[index],
          ),
        ),
      ),
    );
  }

  int _suggestedPhase(LearningState state) {
    final progress = state.progressFor(lesson.id);
    if (progress?.masteryStatus == LessonMasteryStatus.needsRemediation) {
      return LearningPhaseType.workedExamples.index;
    }
    return progress?.currentPhase.index ?? LearningPhaseType.understand.index;
  }

  Future<void> _editNote(BuildContext context, LearningState state) async {
    final text = await showLessonNoteDialog(
      context,
      initialText: state.noteFor(lesson.id)?.text ?? '',
    );
    if (text != null && context.mounted) {
      await context.read<LearningCubit>().saveNote(lesson, text);
    }
  }
}
