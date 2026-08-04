import '../../curriculum/data/model/exercise_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import 'exercise_scoring_service.dart';

class PreparedAttempt {
  const PreparedAttempt({required this.attempt, required this.score});

  final ExerciseAttemptModel attempt;
  final ExerciseScore score;
}

class ExerciseAttemptFactory {
  const ExerciseAttemptFactory({
    this.scoringService = const ExerciseScoringService(),
  });

  final ExerciseScoringService scoringService;

  PreparedAttempt create({
    required ExerciseModel exercise,
    required List<ExerciseAttemptModel> history,
    required Object selectedAnswer,
    required bool isCorrect,
    required bool hintUsed,
    required bool revealed,
    required DateTime startedAt,
    required DateTime now,
  }) {
    final prior = history
        .where((item) => item.exerciseId == exercise.id)
        .toList();
    final score = scoringService.score(
      isCorrect: isCorrect,
      hintUsed: hintUsed,
      hasPriorError: prior.any((item) => !item.isCorrect),
      revealed: revealed,
    );
    return PreparedAttempt(
      score: score,
      attempt: ExerciseAttemptModel(
        attemptId:
            '${exercise.id}-${prior.length + 1}-${now.microsecondsSinceEpoch}',
        exerciseId: exercise.id,
        lessonId: exercise.lessonId,
        skillIds: exercise.skillIds,
        contentVersion: exercise.contentVersion,
        selectedAnswer: selectedAnswer,
        isCorrect: score.isCorrect,
        scoreWeight: score.weight,
        hintUsed: hintUsed,
        attemptNumber: prior.length + 1,
        durationMilliseconds: now.difference(startedAt).inMilliseconds,
        clientCreatedAt: now,
        schemaVersion: 1,
      ),
    );
  }
}
