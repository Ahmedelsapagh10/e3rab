import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/exercise_model.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/cubit/exercise_cubit.dart';
import 'package:new_strucuture/features/practice/domain/practice_session_config.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('hinted correct answer receives 0.7 and completes lesson', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final progress = LocalFirstProgressRepository(local);
    final owner = LearningDataOwner.guest('guest');
    final cubit = ExerciseCubit(
      progressRepository: progress,
      owner: owner,
      lesson: _lesson,
      exercises: const [_exercise],
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);

    cubit.showHint();
    cubit.selectAnswer('correct');
    await cubit.submit();

    expect(cubit.state.submitted, isTrue);
    expect(local.getAttempts(owner).single.scoreWeight, 0.7);

    await cubit.next();
    expect(cubit.state.completed, isTrue);
    expect(
      local.getProgress(owner).single.status,
      LessonProgressStatus.completed,
    );
    expect(local.getProgress(owner).single.masteryScore, .7);
  });

  test('revealed answer is stored with zero weight', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final owner = LearningDataOwner.guest('guest');
    final cubit = ExerciseCubit(
      progressRepository: LocalFirstProgressRepository(local),
      owner: owner,
      lesson: _lesson,
      exercises: const [_exercise],
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);

    await cubit.revealAnswer();

    expect(cubit.state.revealed, isTrue);
    expect(cubit.state.submitted, isTrue);
    expect(local.getAttempts(owner).single.scoreWeight, 0);
    expect(local.getAttempts(owner).single.selectedAnswer, 'revealed');
  });

  test('timed session records timeout and completes safely', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final owner = LearningDataOwner.guest('guest');
    final cubit = ExerciseCubit(
      progressRepository: LocalFirstProgressRepository(local),
      owner: owner,
      exercises: const [_exercise],
      config: const PracticeSessionConfig.timed(durationSeconds: 1),
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);

    await cubit.tickTimer();

    expect(cubit.state.timedOut, isTrue);
    expect(cubit.state.completed, isTrue);
    expect(local.getAttempts(owner).single.selectedAnswer, 'timeout');
    expect(local.getAttempts(owner).single.isCorrect, isFalse);
  });
}

const _lesson = LessonModel(
  id: 'lesson',
  unitId: 'unit',
  slug: 'lesson',
  title: 'درس',
  shortTitle: 'درس',
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  objectives: ['هدف'],
  prerequisiteIds: [],
  sections: [
    LessonSectionModel(
      id: 'rule',
      type: 'rule',
      title: 'قاعدة',
      body: 'شرح',
      order: 1,
      referenceIds: [],
    ),
  ],
  examples: [],
  exerciseIds: ['exercise'],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 5,
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
);

const _exercise = ExerciseModel(
  id: 'exercise',
  lessonId: 'lesson',
  type: ExerciseType.multipleChoice,
  prompt: 'اختر',
  skillIds: ['skill'],
  stageIds: ['foundation'],
  gradeIds: ['foundation'],
  difficulty: 1,
  options: [
    ExerciseOptionModel(id: 'correct', text: 'صحيح', feedback: 'أحسنت'),
    ExerciseOptionModel(id: 'wrong', text: 'خطأ', feedback: 'راجع القاعدة'),
  ],
  correctAnswerIds: ['correct'],
  explanation: 'تفسير',
  hint: 'تلميح',
  referenceIds: [],
  contentVersion: '1.0.0',
  reviewStatus: ContentReviewStatus.aiAssistedDraft,
  schemaVersion: 1,
);
