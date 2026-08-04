import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/domain/mastery_calculator.dart';

void main() {
  test('requires evidence across two sessions before mastery', () {
    final now = DateTime.utc(2026, 8, 4);
    final attempts = [
      _attempt('one', now.subtract(const Duration(days: 1))),
      _attempt('two', now.subtract(const Duration(days: 1))),
      _attempt('three', now),
      _attempt('four', now),
      _attempt('five', now),
    ];

    final mastery = MasteryCalculator.calculate(
      skillId: 'skill-one',
      attempts: attempts,
      now: now,
    );

    expect(mastery.score, 1);
    expect(mastery.state, MasteryState.mastered);
    expect(mastery.nextReviewAt, now.add(const Duration(days: 1)));
  });

  test('recent meaningful error moves a skill to needs review', () {
    final now = DateTime.utc(2026, 8, 4);
    final attempts = List.generate(
      4,
      (index) => _attempt('$index', now, correct: index != 3),
    );

    final mastery = MasteryCalculator.calculate(
      skillId: 'skill-one',
      attempts: attempts,
      now: now,
    );

    expect(mastery.state, MasteryState.needsReview);
  });

  test('low score remains in learning while review interval is supported', () {
    final now = DateTime.utc(2026, 8, 4);
    final attempts = [
      _attempt('one', now, correct: true),
      _attempt('two', now, correct: false),
      _attempt('three', now, correct: false),
      _attempt('four', now, correct: true),
    ];

    final mastery = MasteryCalculator.calculate(
      skillId: 'skill-one',
      attempts: attempts,
      now: now,
    );

    expect(mastery.score, 0.5);
    expect(mastery.state, MasteryState.learning);
    expect(MasteryCalculator.reviewIntervalLevel(mastery), 0);
  });
}

ExerciseAttemptModel _attempt(String id, DateTime date, {bool correct = true}) {
  return ExerciseAttemptModel(
    attemptId: id,
    exerciseId: 'exercise-$id',
    lessonId: 'lesson-one',
    skillIds: const ['skill-one'],
    contentVersion: '1.0.0',
    selectedAnswer: 'option-one',
    isCorrect: correct,
    scoreWeight: 1,
    hintUsed: false,
    attemptNumber: 1,
    durationMilliseconds: 100,
    clientCreatedAt: date,
    schemaVersion: 1,
  );
}
