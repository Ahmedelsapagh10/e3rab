import '../data/model/learning_progress_models.dart';
import '../data/model/learning_support_models.dart';

abstract final class MasteryCalculator {
  static const intervals = [1, 3, 7, 14, 30, 60];

  static int reviewIntervalLevel(SkillMasteryModel mastery) {
    final days = mastery.nextReviewAt.difference(mastery.updatedAt).inDays;
    final index = intervals.indexOf(days);
    return index < 0 ? 0 : index;
  }

  static SkillMasteryModel calculate({
    required String skillId,
    required List<ExerciseAttemptModel> attempts,
    required DateTime now,
    SkillMasteryModel? previous,
  }) {
    final scored = attempts.where((attempt) {
      return attempt.skillIds.contains(skillId) && attempt.scoreWeight > 0;
    }).toList();
    final totalWeight = scored.fold<double>(
      0,
      (sum, item) => sum + item.scoreWeight,
    );
    final earned = scored.fold<double>(0, (sum, item) {
      return sum + (item.isCorrect ? item.scoreWeight : 0);
    });
    final score = totalWeight == 0 ? 0.0 : earned / totalWeight;
    final unhinted = scored
        .where((item) => item.isCorrect && !item.hintUsed)
        .length;
    final sessions = scored
        .map(
          (item) => DateTime(
            item.clientCreatedAt.year,
            item.clientCreatedAt.month,
            item.clientCreatedAt.day,
          ),
        )
        .toSet()
        .length;
    final recentError = scored.isNotEmpty && !scored.last.isCorrect;
    final overdue = previous != null && previous.nextReviewAt.isBefore(now);
    final state = _state(
      score,
      scored.length,
      unhinted,
      sessions,
      recentError,
      overdue,
    );
    final intervalLevel = state == MasteryState.mastered
        ? ((previous?.scoredAttemptCount ?? 0) ~/ 2).clamp(
            0,
            intervals.length - 1,
          )
        : 0;
    final last = scored.isEmpty ? now : scored.last.clientCreatedAt;
    return SkillMasteryModel(
      skillId: skillId,
      score: score,
      state: state,
      scoredAttemptCount: scored.length,
      unhintedCorrectCount: unhinted,
      lastPracticedAt: last,
      nextReviewAt: now.add(Duration(days: intervals[intervalLevel])),
      algorithmVersion: 1,
      updatedAt: now,
    );
  }

  static MasteryState _state(
    double score,
    int count,
    int unhinted,
    int sessions,
    bool recentError,
    bool overdue,
  ) {
    if (count < 3) return MasteryState.newSkill;
    if (recentError || overdue) return MasteryState.needsReview;
    if (score < .75) return MasteryState.learning;
    if (score < .85) return MasteryState.needsReview;
    if (score >= .85 &&
        count >= 5 &&
        sessions >= 2 &&
        unhinted >= 2 &&
        !recentError &&
        !overdue) {
      return MasteryState.mastered;
    }
    return MasteryState.learning;
  }
}
