import '../../curriculum/data/model/exercise_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';

class PracticeQueueBuilder {
  const PracticeQueueBuilder();

  List<ExerciseModel> reviewQueue({
    required List<ExerciseModel> exercises,
    required List<SkillMasteryModel> mastery,
    required List<ReviewItemModel> reviews,
    required DateTime now,
    int limit = 10,
  }) {
    final dueSkills = reviews
        .where((item) => item.targetType == 'skill' && !item.dueAt.isAfter(now))
        .map((item) => item.targetId)
        .toSet();
    final weakSkills = mastery
        .where(
          (item) =>
              item.state == MasteryState.needsReview ||
              item.state == MasteryState.learning,
        )
        .map((item) => item.skillId)
        .toSet();
    final targets = {...dueSkills, ...weakSkills};
    if (targets.isEmpty) return const [];
    final candidates =
        exercises.where((item) => item.skillIds.any(targets.contains)).toList()
          ..sort((a, b) {
            final aDue = a.skillIds.any(dueSkills.contains) ? 0 : 1;
            final bDue = b.skillIds.any(dueSkills.contains) ? 0 : 1;
            final byDue = aDue.compareTo(bDue);
            return byDue != 0 ? byDue : a.difficulty.compareTo(b.difficulty);
          });
    return candidates.take(limit).toList(growable: false);
  }

  List<ExerciseModel> cumulativeQueue({
    required Map<String, List<ExerciseModel>> exercisesByLesson,
    int limit = 15,
  }) {
    final queues = exercisesByLesson.values
        .map((items) => List<ExerciseModel>.from(items))
        .toList();
    final result = <ExerciseModel>[];
    for (var index = 0; result.length < limit; index++) {
      var added = false;
      for (final queue in queues) {
        if (index < queue.length && result.length < limit) {
          result.add(queue[index]);
          added = true;
        }
      }
      if (!added) break;
    }
    return result;
  }
}
