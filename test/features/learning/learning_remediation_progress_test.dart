import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/learning/cubit/learning_cubit.dart';
import 'package:new_strucuture/features/learning/domain/next_learning_action.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reviewed examples lead to practice without deleting phases', () async {
    SharedPreferences.setMockInitialValues({});
    final curriculum = LocalCurriculumRepository(
      AssetCurriculumDataSource(bundle: rootBundle),
    );
    final lesson = (await curriculum.getAllLessons())
        .getOrElse(() => throw StateError('Expected a local lesson'))
        .first;
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final owner = LearningDataOwner.guest('remediation');
    final completed = LearningPhaseType.values
        .where((phase) => phase != LearningPhaseType.masteryCheck)
        .toList();
    await local.saveProgress(
      owner,
      LessonProgressModel(
        lessonId: lesson.id,
        contentVersion: lesson.contentVersion,
        status: LessonProgressStatus.inProgress,
        completedSectionIds: const [],
        attemptCount: 15,
        bestScore: .6,
        masteryScore: .6,
        updatedAt: DateTime.utc(2026, 8, 9),
        schemaVersion: 3,
        currentPhase: LearningPhaseType.workedExamples,
        completedPhases: completed,
        masteryStatus: LessonMasteryStatus.needsRemediation,
        checkpointScore: .6,
        missedSkillIds: const ['skill'],
      ),
    );
    final cubit = LearningCubit(
      curriculum,
      LocalFirstProgressRepository(local),
      owner,
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);
    await cubit.load();

    await cubit.markPhase(lesson, LearningPhaseType.workedExamples);

    final saved = local.getProgress(owner).single;
    expect(saved.completedPhases, containsAll(completed));
    expect(saved.masteryStatus, LessonMasteryStatus.needsRemediation);
    expect(saved.currentPhase, LearningPhaseType.independentPractice);
    expect(cubit.nextLearningAction().type, NextLearningActionType.remediation);
    expect(
      cubit.nextLearningAction().phase,
      LearningPhaseType.independentPractice,
    );
  });
}
