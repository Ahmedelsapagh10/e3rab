class ExerciseScore {
  const ExerciseScore({required this.isCorrect, required this.weight});

  final bool isCorrect;
  final double weight;
}

class ExerciseScoringService {
  const ExerciseScoringService();

  ExerciseScore score({
    required bool isCorrect,
    required bool hintUsed,
    required bool hasPriorError,
    bool revealed = false,
  }) {
    if (revealed) return const ExerciseScore(isCorrect: false, weight: 0);
    if (!isCorrect) return const ExerciseScore(isCorrect: false, weight: 1);
    if (hintUsed) return const ExerciseScore(isCorrect: true, weight: .7);
    if (hasPriorError) {
      return const ExerciseScore(isCorrect: true, weight: .5);
    }
    return const ExerciseScore(isCorrect: true, weight: 1);
  }
}
