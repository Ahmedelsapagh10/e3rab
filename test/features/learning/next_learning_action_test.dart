import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/lesson_model.dart';
import 'package:new_strucuture/features/learning/domain/next_learning_action.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';

void main() {
  const resolver = NextLearningActionResolver();

  test('continues at first incomplete phase', () {
    final action = resolver.resolve(
      lessons: const [_lesson],
      progress: [
        _progress(completed: const [LearningPhaseType.understand]),
      ],
    );

    expect(action.lesson, _lesson);
    expect(action.phase, LearningPhaseType.detect);
  });

  test('failed checkpoint returns to worked examples', () {
    final action = resolver.resolve(
      lessons: const [_lesson],
      progress: [
        _progress(masteryStatus: LessonMasteryStatus.needsRemediation),
      ],
    );

    expect(action.type, NextLearningActionType.remediation);
    expect(action.phase, LearningPhaseType.workedExamples);
  });

  test('opens the next lesson only after prerequisite mastery', () {
    final action = resolver.resolve(
      lessons: const [_lesson, _advancedLesson],
      progress: [_progress(masteryStatus: LessonMasteryStatus.mastered)],
    );

    expect(action.lesson, _advancedLesson);
    expect(action.phase, LearningPhaseType.understand);
  });

  test('never recommends a lesson whose prerequisite is incomplete', () {
    final action = resolver.resolve(
      lessons: const [_advancedLesson, _lesson],
      progress: const [],
    );

    expect(action.lesson, _lesson);
  });
}

LessonProgressModel _progress({
  List<LearningPhaseType> completed = const [],
  LessonMasteryStatus masteryStatus = LessonMasteryStatus.learning,
}) => LessonProgressModel(
  lessonId: 'lesson',
  contentVersion: '1',
  status: LessonProgressStatus.inProgress,
  completedSectionIds: const [],
  attemptCount: 0,
  bestScore: 0,
  masteryScore: 0,
  updatedAt: DateTime.utc(2026),
  schemaVersion: 3,
  completedPhases: completed,
  masteryStatus: masteryStatus,
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
  reviewStatus: ContentReviewStatus.sourceDocumented,
);

const _advancedLesson = LessonModel(
  id: 'advanced',
  unitId: 'unit',
  slug: 'advanced',
  title: 'درس متقدم',
  shortTitle: 'درس متقدم',
  stageIds: [],
  gradeIds: [],
  objectives: ['هدف'],
  prerequisiteIds: ['lesson'],
  sections: [],
  examples: [],
  exerciseIds: [],
  referenceIds: [],
  tags: [],
  estimatedMinutes: 10,
  contentVersion: '1',
  reviewStatus: ContentReviewStatus.sourceDocumented,
);
