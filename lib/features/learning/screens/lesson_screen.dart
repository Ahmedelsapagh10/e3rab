import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injector.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../practice/domain/practice_session_config.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../widgets/lesson_note_dialog.dart';
import '../widgets/lesson_overview_view.dart';
import 'exercise_screen.dart';
import 'lesson_examples_screen.dart';
import 'lesson_explanation_screen.dart';

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
          onExplanation: () => _openExplanation(context),
          onExamples: () => _openExamples(context),
          onExercises: () => _openPractice(context, state, exam: false),
          onExam: () => _openPractice(context, state, exam: true),
        ),
      ),
    );
  }

  int _suggestedPhase(LearningState state) {
    final progress = state.progressFor(lesson.id);
    final completed = progress?.completedSectionIds ?? const [];
    if (!completed.contains('${lesson.id}-phase-explanation')) return 0;
    if (!completed.contains('${lesson.id}-phase-examples')) return 1;
    if (progress?.status != LessonProgressStatus.completed) return 2;
    return 3;
  }

  void _openExplanation(BuildContext context) {
    final learning = context.read<LearningCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonExplanationScreen(
          lesson: lesson,
          onCompleted: () =>
              learning.markLessonStep(lesson, '${lesson.id}-phase-explanation'),
        ),
      ),
    );
  }

  void _openExamples(BuildContext context) {
    final learning = context.read<LearningCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LessonExamplesScreen(
          lesson: lesson,
          onCompleted: () =>
              learning.markLessonStep(lesson, '${lesson.id}-phase-examples'),
        ),
      ),
    );
  }

  void _openPractice(
    BuildContext context,
    LearningState state, {
    required bool exam,
  }) {
    final learning = context.read<LearningCubit>();
    final exercises = state.exercises[lesson.id] ?? const [];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ExerciseCubit(
            progressRepository: serviceLocator<ProgressRepository>(),
            owner: learning.owner,
            lesson: exam ? null : lesson,
            exercises: exam ? exercises.take(5).toList() : exercises,
            config: exam
                ? const PracticeSessionConfig.lessonExam()
                : const PracticeSessionConfig.lesson(),
          ),
          child: ExerciseScreen(onFinished: learning.load),
        ),
      ),
    );
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
