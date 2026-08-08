import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injector.dart';
import '../../curriculum/data/model/exercise_model.dart';
import '../../curriculum/data/model/lesson_model.dart';
import '../../practice/domain/practice_session_config.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';
import '../cubit/exercise_cubit.dart';
import '../cubit/learning_cubit.dart';
import '../cubit/learning_state.dart';
import '../domain/remediation_exercise_selector.dart';
import '../screens/exercise_screen.dart';
import '../screens/guided_parsing_screen.dart';
import '../screens/lesson_detection_screen.dart';
import '../screens/lesson_examples_screen.dart';
import '../screens/lesson_explanation_screen.dart';

abstract final class LessonPhaseNavigator {
  static void open(
    BuildContext context, {
    required LessonModel lesson,
    required LearningState state,
    required LearningPhaseType phase,
  }) {
    final learning = context.read<LearningCubit>();
    final screen = switch (phase) {
      LearningPhaseType.understand => LessonExplanationScreen(
        lesson: lesson,
        onCompleted: () =>
            learning.markPhase(lesson, LearningPhaseType.understand),
      ),
      LearningPhaseType.detect => LessonDetectionScreen(
        lesson: lesson,
        onCompleted: () => learning.markPhase(lesson, LearningPhaseType.detect),
      ),
      LearningPhaseType.workedExamples => LessonExamplesScreen(
        lesson: lesson,
        onCompleted: () =>
            learning.markPhase(lesson, LearningPhaseType.workedExamples),
      ),
      LearningPhaseType.guidedParsing => GuidedParsingScreen(
        lesson: lesson,
        onCompleted: () =>
            learning.markPhase(lesson, LearningPhaseType.guidedParsing),
      ),
      LearningPhaseType.independentPractice => _practice(
        learning,
        lesson,
        state,
        exam: false,
      ),
      LearningPhaseType.masteryCheck => _practice(
        learning,
        lesson,
        state,
        exam: true,
      ),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  static Widget _practice(
    LearningCubit learning,
    LessonModel lesson,
    LearningState state, {
    required bool exam,
  }) {
    final exercises = state.exercises[lesson.id] ?? const [];
    final progress = state.progressFor(lesson.id);
    final practiceExercises =
        !exam && progress?.masteryStatus == LessonMasteryStatus.needsRemediation
        ? const RemediationExerciseSelector().select(
            exercises: exercises,
            missedSkillIds: progress?.missedSkillIds ?? const [],
          )
        : exercises;
    return BlocProvider(
      create: (_) => ExerciseCubit(
        progressRepository: serviceLocator<ProgressRepository>(),
        owner: learning.owner,
        lesson: lesson,
        exercises: exam
            ? _masteryExercises(lesson, exercises)
            : practiceExercises,
        config: exam
            ? const PracticeSessionConfig.lessonExam()
            : const PracticeSessionConfig.lesson(),
      ),
      child: ExerciseScreen(onFinished: learning.load),
    );
  }

  static List<ExerciseModel> _masteryExercises(
    LessonModel lesson,
    List<ExerciseModel> exercises,
  ) {
    if (lesson.masteryExerciseIds.isEmpty) return exercises.take(5).toList();
    final byId = {for (final exercise in exercises) exercise.id: exercise};
    return lesson.masteryExerciseIds
        .map((id) => byId[id])
        .whereType<ExerciseModel>()
        .toList(growable: false);
  }
}
