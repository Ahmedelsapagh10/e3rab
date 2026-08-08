import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';

class LessonCompletionService {
  const LessonCompletionService();

  static const masteryThreshold = .8;

  Future<void> completePractice({
    required ProgressRepository repository,
    required LearningDataOwner owner,
    required LessonModel lesson,
    required int correctCount,
    required double earnedWeight,
    required int exerciseCount,
    required DateTime now,
  }) async {
    final existing = await _progress(repository, owner, lesson.id);
    final score = exerciseCount == 0 ? 0.0 : correctCount / exerciseCount;
    final completed = {
      ...?existing?.completedPhases,
      LearningPhaseType.independentPractice,
    };
    final nextPhase = LearningPhaseType.values.firstWhere(
      (phase) => !completed.contains(phase),
      orElse: () => LearningPhaseType.masteryCheck,
    );
    await repository.saveLessonProgress(
      owner,
      _updated(
        lesson: lesson,
        existing: existing,
        now: now,
        completedPhases: completed,
        currentPhase: nextPhase,
        masteryStatus: LessonMasteryStatus.learning,
        attemptCount: (existing?.attemptCount ?? 0) + exerciseCount,
        bestScore: _best(existing?.bestScore ?? 0, score),
        masteryScore: exerciseCount == 0 ? 0 : earnedWeight / exerciseCount,
      ),
    );
  }

  Future<void> completeMasteryCheck({
    required ProgressRepository repository,
    required LearningDataOwner owner,
    required LessonModel lesson,
    required int correctCount,
    required int exerciseCount,
    required List<String> missedSkillIds,
    required DateTime now,
  }) async {
    final existing = await _progress(repository, owner, lesson.id);
    final score = exerciseCount == 0 ? 0.0 : correctCount / exerciseCount;
    final mastered = score >= masteryThreshold;
    final completed = {...?existing?.completedPhases};
    if (mastered) completed.add(LearningPhaseType.masteryCheck);
    await repository.saveLessonProgress(
      owner,
      _updated(
        lesson: lesson,
        existing: existing,
        now: now,
        completedPhases: completed,
        currentPhase: mastered
            ? LearningPhaseType.masteryCheck
            : LearningPhaseType.workedExamples,
        masteryStatus: mastered
            ? LessonMasteryStatus.mastered
            : LessonMasteryStatus.needsRemediation,
        status: mastered
            ? LessonProgressStatus.completed
            : LessonProgressStatus.inProgress,
        checkpointScore: score,
        missedSkillIds: mastered ? const [] : missedSkillIds,
        masteredAt: mastered ? now : null,
        completedAt: mastered ? now : null,
        bestScore: _best(existing?.bestScore ?? 0, score),
      ),
    );
  }

  Future<LessonProgressModel?> _progress(
    ProgressRepository repository,
    LearningDataOwner owner,
    String lessonId,
  ) async {
    return (await repository.getLessonProgress(owner))
        .getOrElse(() => const [])
        .where((item) => item.lessonId == lessonId)
        .firstOrNull;
  }

  LessonProgressModel _updated({
    required LessonModel lesson,
    required LessonProgressModel? existing,
    required DateTime now,
    required Set<LearningPhaseType> completedPhases,
    required LearningPhaseType currentPhase,
    required LessonMasteryStatus masteryStatus,
    LessonProgressStatus status = LessonProgressStatus.inProgress,
    int? attemptCount,
    double? bestScore,
    double? masteryScore,
    double checkpointScore = 0,
    List<String> missedSkillIds = const [],
    DateTime? masteredAt,
    DateTime? completedAt,
  }) {
    return LessonProgressModel(
      lessonId: lesson.id,
      contentVersion: lesson.contentVersion,
      status: status,
      startedAt: existing?.startedAt ?? now,
      completedAt: completedAt ?? existing?.completedAt,
      lastOpenedAt: now,
      completedSectionIds: existing?.completedSectionIds ?? const [],
      attemptCount: attemptCount ?? existing?.attemptCount ?? 0,
      bestScore: bestScore ?? existing?.bestScore ?? 0,
      masteryScore: masteryScore ?? existing?.masteryScore ?? 0,
      currentPhase: currentPhase,
      completedPhases: completedPhases.toList(),
      masteryStatus: masteryStatus,
      checkpointScore: checkpointScore,
      missedSkillIds: missedSkillIds,
      masteredAt: masteredAt ?? existing?.masteredAt,
      updatedAt: now,
      schemaVersion: 3,
    );
  }

  double _best(double previous, double current) =>
      current > previous ? current : previous;
}
