import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/practice/domain/lesson_completion_service.dart';
import 'package:new_strucuture/features/practice/domain/practice_session_config.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('journey exposes six ordered phases and a feedback-free exam', () {
    expect(LearningPhaseType.values, [
      LearningPhaseType.understand,
      LearningPhaseType.detect,
      LearningPhaseType.workedExamples,
      LearningPhaseType.guidedParsing,
      LearningPhaseType.independentPractice,
      LearningPhaseType.masteryCheck,
    ]);
    const exam = PracticeSessionConfig.lessonExam();
    expect(exam.mode, PracticeMode.lessonExam);
    expect(exam.isTimed, isFalse);
    expect(exam.allowHint, isFalse);
    expect(exam.allowReveal, isFalse);
    expect(exam.showImmediateFeedback, isFalse);
  });

  test(
    'every seeded lesson has five deterministic mastery exercises',
    () async {
      final catalog = await _load(
        'assets/content/e3rab_content_catalog_v1.json',
      );
      var lessonCount = 0;
      for (final rawEntry in (catalog['packs'] as List).cast<Map>()) {
        final entry = Map<String, dynamic>.from(rawEntry);
        if (entry['seedEnabled'] != true) continue;
        final pack = await _load(entry['assetPath'] as String);
        final exerciseIds = (pack['exercises'] as List)
            .map((exercise) => (exercise as Map)['id'] as String)
            .toSet();
        for (final rawLesson in (pack['lessons'] as List).cast<Map>()) {
          final lesson = Map<String, dynamic>.from(rawLesson);
          final masteryIds = List<String>.from(
            lesson['masteryExerciseIds'] as List,
          );
          lessonCount++;
          expect(masteryIds, hasLength(5), reason: '${lesson['id']}');
          expect(masteryIds.toSet(), hasLength(5), reason: '${lesson['id']}');
          expect(
            exerciseIds.containsAll(masteryIds),
            isTrue,
            reason: '${lesson['id']}',
          );
          expect(
            List<String>.from(lesson['masteryExerciseIds'] as List),
            masteryIds,
          );
        }
      }
      expect(lessonCount, greaterThan(100));
    },
  );

  test('mastery requires exactly four correct answers out of five', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final repository = LocalFirstProgressRepository(local);
    addTearDown(local.dispose);

    await _complete(repository, LearningDataOwner.guest('failed'), 3);
    await _complete(repository, LearningDataOwner.guest('passed'), 4);
    final failed = local.getProgress(LearningDataOwner.guest('failed')).single;
    final passed = local.getProgress(LearningDataOwner.guest('passed')).single;

    expect(failed.masteryStatus, LessonMasteryStatus.needsRemediation);
    expect(failed.currentPhase, LearningPhaseType.workedExamples);
    expect(failed.missedSkillIds, ['skill']);
    expect(passed.masteryStatus, LessonMasteryStatus.mastered);
    expect(passed.completedPhases, contains(LearningPhaseType.masteryCheck));
  });
}

Future<Map<String, dynamic>> _load(String path) async =>
    Map<String, dynamic>.from(
      jsonDecode(await rootBundle.loadString(path)) as Map,
    );

Future<void> _complete(
  LocalFirstProgressRepository repository,
  LearningDataOwner owner,
  int correct,
) => const LessonCompletionService().completeMasteryCheck(
  repository: repository,
  owner: owner,
  lesson: _lesson,
  correctCount: correct,
  exerciseCount: 5,
  missedSkillIds: const ['skill'],
  now: DateTime.utc(2026, 8, 9),
);

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
  reviewStatus: ContentReviewStatus.inReview,
);
