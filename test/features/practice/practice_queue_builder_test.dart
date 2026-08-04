import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/exercise_model.dart';
import 'package:new_strucuture/features/practice/domain/practice_queue_builder.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/data/model/learning_support_models.dart';

void main() {
  const builder = PracticeQueueBuilder();
  final now = DateTime.utc(2026, 8, 4);

  test('prioritizes due skills then weaker skills', () {
    final queue = builder.reviewQueue(
      exercises: [
        _exercise('weak', 'weak-skill', 1),
        _exercise('due', 'due-skill', 3),
      ],
      mastery: [_mastery('weak-skill', MasteryState.learning, now)],
      reviews: [_review('due-skill', now.subtract(const Duration(minutes: 1)))],
      now: now,
    );

    expect(queue.map((item) => item.id), ['due', 'weak']);
  });

  test('builds a cumulative queue interleaved across lessons', () {
    final queue = builder.cumulativeQueue(
      exercisesByLesson: {
        'one': [_exercise('a1', 'a', 1), _exercise('a2', 'a', 2)],
        'two': [_exercise('b1', 'b', 1), _exercise('b2', 'b', 2)],
      },
    );

    expect(queue.map((item) => item.id), ['a1', 'b1', 'a2', 'b2']);
  });
}

ExerciseModel _exercise(String id, String skill, int difficulty) {
  return ExerciseModel(
    id: id,
    lessonId: 'lesson-$skill',
    type: ExerciseType.multipleChoice,
    prompt: 'سؤال',
    skillIds: [skill],
    stageIds: const ['foundation'],
    gradeIds: const ['foundation'],
    difficulty: difficulty,
    options: const [
      ExerciseOptionModel(id: 'correct', text: 'صحيح', feedback: 'أحسنت'),
      ExerciseOptionModel(id: 'wrong', text: 'خطأ', feedback: 'راجع'),
    ],
    correctAnswerIds: const ['correct'],
    explanation: 'شرح',
    hint: 'تلميح',
    referenceIds: const [],
    contentVersion: '1.0.0',
    reviewStatus: ContentReviewStatus.aiAssistedDraft,
    schemaVersion: 1,
  );
}

SkillMasteryModel _mastery(String id, MasteryState state, DateTime now) {
  return SkillMasteryModel(
    skillId: id,
    score: .6,
    state: state,
    scoredAttemptCount: 3,
    unhintedCorrectCount: 1,
    lastPracticedAt: now,
    nextReviewAt: now.add(const Duration(days: 1)),
    algorithmVersion: 1,
    updatedAt: now,
  );
}

ReviewItemModel _review(String id, DateTime dueAt) {
  return ReviewItemModel(
    id: 'skill-$id',
    targetType: 'skill',
    targetId: id,
    dueAt: dueAt,
    intervalLevel: 0,
    lastResult: 'incorrect',
    updatedAt: dueAt,
    algorithmVersion: 1,
  );
}
