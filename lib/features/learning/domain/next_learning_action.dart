import '../../curriculum/data/model/lesson_model.dart';
import '../../progress/data/model/learning_progress_models.dart';

enum NextLearningActionType { phase, remediation, courseComplete }

class NextLearningAction {
  const NextLearningAction({required this.type, this.lesson, this.phase});

  const NextLearningAction.courseComplete()
    : type = NextLearningActionType.courseComplete,
      lesson = null,
      phase = null;

  final NextLearningActionType type;
  final LessonModel? lesson;
  final LearningPhaseType? phase;
}

class NextLearningActionResolver {
  const NextLearningActionResolver();

  NextLearningAction resolve({
    required List<LessonModel> lessons,
    required List<LessonProgressModel> progress,
  }) {
    final progressByLesson = {for (final item in progress) item.lessonId: item};
    for (final lesson in lessons) {
      final lessonProgress = progressByLesson[lesson.id];
      if (lessonProgress?.masteryStatus == LessonMasteryStatus.mastered) {
        continue;
      }
      final prerequisitesMet = lesson.prerequisiteIds.every(
        (id) =>
            progressByLesson[id]?.masteryStatus == LessonMasteryStatus.mastered,
      );
      if (!prerequisitesMet) continue;
      if (lessonProgress?.masteryStatus ==
          LessonMasteryStatus.needsRemediation) {
        return NextLearningAction(
          type: NextLearningActionType.remediation,
          lesson: lesson,
          phase: LearningPhaseType.workedExamples,
        );
      }
      final completed = lessonProgress?.completedPhases.toSet() ?? {};
      final phase = LearningPhaseType.values.firstWhere(
        (item) => !completed.contains(item),
        orElse: () => LearningPhaseType.masteryCheck,
      );
      return NextLearningAction(
        type: NextLearningActionType.phase,
        lesson: lesson,
        phase: phase,
      );
    }
    return const NextLearningAction.courseComplete();
  }
}
