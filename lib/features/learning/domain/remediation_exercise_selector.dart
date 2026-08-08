import '../../curriculum/data/model/exercise_model.dart';

class RemediationExerciseSelector {
  const RemediationExerciseSelector();

  List<ExerciseModel> select({
    required List<ExerciseModel> exercises,
    required List<String> missedSkillIds,
  }) {
    if (missedSkillIds.isEmpty) return exercises;
    final missed = missedSkillIds.toSet();
    final targeted = exercises.where(
      (exercise) => exercise.skillIds.any(missed.contains),
    );
    final selected = targeted.toList(growable: false);
    return selected.isEmpty ? exercises : selected;
  }
}
