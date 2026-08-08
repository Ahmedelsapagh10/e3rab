import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/data/model/exercise_model.dart';
import 'package:new_strucuture/features/learning/domain/remediation_exercise_selector.dart';

void main() {
  const selector = RemediationExerciseSelector();

  test('selects only exercises related to missed skills', () {
    final result = selector.select(
      exercises: const [
        _Exercise('sign', ['sign']),
        _Exercise('agent', ['agent']),
        _Exercise('mixed', ['role', 'sign']),
      ],
      missedSkillIds: const ['sign'],
    );

    expect(result.map((exercise) => exercise.id), ['sign', 'mixed']);
  });

  test('falls back safely when old skill identifiers have no match', () {
    const exercises = [
      _Exercise('role', ['role']),
    ];

    final result = selector.select(
      exercises: exercises,
      missedSkillIds: const ['legacy-skill'],
    );

    expect(result, exercises);
  });
}

class _Exercise extends ExerciseModel {
  const _Exercise(String id, List<String> skills)
    : super(
        id: id,
        lessonId: 'lesson',
        type: ExerciseType.multipleChoice,
        prompt: 'اختر',
        skillIds: skills,
        stageIds: const ['general'],
        gradeIds: const ['general'],
        difficulty: 1,
        options: const [
          ExerciseOptionModel(id: 'a', text: 'أ', feedback: 'صحيح'),
          ExerciseOptionModel(id: 'b', text: 'ب', feedback: 'راجع'),
        ],
        correctAnswerIds: const ['a'],
        explanation: 'تفسير',
        hint: 'تلميح',
        referenceIds: const ['ref'],
        contentVersion: '1',
        reviewStatus: ContentReviewStatus.inReview,
        schemaVersion: 1,
      );
}
