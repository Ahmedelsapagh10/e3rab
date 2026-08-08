import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/practice/domain/lesson_completion_service.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('repeating practice never removes achieved mastery', () async {
    final setup = await _setupMasteredProgress();
    addTearDown(setup.local.dispose);

    await const LessonCompletionService().completePractice(
      repository: setup.repository,
      owner: setup.owner,
      lesson: _lesson,
      correctCount: 0,
      earnedWeight: 0,
      exerciseCount: 10,
      now: DateTime.utc(2026, 8, 9),
    );

    final saved = setup.local.getProgress(setup.owner).single;
    expect(saved.status, LessonProgressStatus.completed);
    expect(saved.masteryStatus, LessonMasteryStatus.mastered);
    expect(saved.masteredAt, DateTime.utc(2026, 8, 1));
  });

  test('a later failed checkpoint never erases prior mastery', () async {
    final setup = await _setupMasteredProgress();
    addTearDown(setup.local.dispose);

    await const LessonCompletionService().completeMasteryCheck(
      repository: setup.repository,
      owner: setup.owner,
      lesson: _lesson,
      correctCount: 0,
      exerciseCount: 5,
      missedSkillIds: const ['skill'],
      now: DateTime.utc(2026, 8, 9),
    );

    final saved = setup.local.getProgress(setup.owner).single;
    expect(saved.masteryStatus, LessonMasteryStatus.mastered);
    expect(saved.checkpointScore, .8);
    expect(saved.missedSkillIds, isEmpty);
  });
}

Future<_Setup> _setupMasteredProgress() async {
  SharedPreferences.setMockInitialValues({});
  final local = LocalLearningDataSource(await SharedPreferences.getInstance());
  final owner = LearningDataOwner.guest('mastered');
  await local.saveProgress(
    owner,
    LessonProgressModel(
      lessonId: _lesson.id,
      contentVersion: _lesson.contentVersion,
      status: LessonProgressStatus.completed,
      completedSectionIds: const [],
      attemptCount: 5,
      bestScore: .8,
      masteryScore: .8,
      updatedAt: DateTime.utc(2026, 8, 1),
      schemaVersion: 3,
      currentPhase: LearningPhaseType.masteryCheck,
      completedPhases: LearningPhaseType.values,
      masteryStatus: LessonMasteryStatus.mastered,
      checkpointScore: .8,
      masteredAt: DateTime.utc(2026, 8, 1),
      completedAt: DateTime.utc(2026, 8, 1),
    ),
  );
  return _Setup(local, LocalFirstProgressRepository(local), owner);
}

class _Setup {
  const _Setup(this.local, this.repository, this.owner);

  final LocalLearningDataSource local;
  final LocalFirstProgressRepository repository;
  final LearningDataOwner owner;
}

const _lesson = LessonModel(
  id: 'lesson',
  unitId: 'unit',
  slug: 'lesson',
  title: 'درس',
  shortTitle: 'درس',
  stageIds: [],
  gradeIds: [],
  objectives: ['هدف'],
  prerequisiteIds: [],
  sections: [],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 10,
  contentVersion: '1',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);
