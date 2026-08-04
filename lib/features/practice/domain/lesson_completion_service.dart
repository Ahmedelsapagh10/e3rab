import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/progress_repository.dart';

class LessonCompletionService {
  const LessonCompletionService();

  Future<void> complete({
    required ProgressRepository repository,
    required LearningDataOwner owner,
    required LessonModel lesson,
    required int correctCount,
    required double earnedWeight,
    required int exerciseCount,
    required DateTime now,
  }) async {
    final existing = (await repository.getLessonProgress(owner))
        .getOrElse(() => const [])
        .where((item) => item.lessonId == lesson.id)
        .firstOrNull;
    final score = correctCount / exerciseCount;
    await repository.saveLessonProgress(
      owner,
      LessonProgressModel(
        lessonId: lesson.id,
        contentVersion: lesson.contentVersion,
        status: LessonProgressStatus.completed,
        startedAt: existing?.startedAt ?? now,
        completedAt: now,
        lastOpenedAt: now,
        completedSectionIds: lesson.sections.map((item) => item.id).toList(),
        attemptCount: (existing?.attemptCount ?? 0) + exerciseCount,
        bestScore: existing == null || score > existing.bestScore
            ? score
            : existing.bestScore,
        masteryScore: earnedWeight / exerciseCount,
        updatedAt: now,
        schemaVersion: 1,
      ),
    );
  }
}
