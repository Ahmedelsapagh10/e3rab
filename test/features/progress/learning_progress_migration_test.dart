import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/progress/data/data_source/learning_data_codec.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';

void main() {
  test('legacy completed lesson below 80 percent needs remediation', () {
    final progress = LearningDataCodec.progressFrom(
      _legacyProgress(bestScore: .6),
    );

    expect(progress.masteryStatus, LessonMasteryStatus.needsRemediation);
    expect(progress.currentPhase, LearningPhaseType.workedExamples);
    expect(progress.completedPhases, contains(LearningPhaseType.understand));
    expect(
      progress.completedPhases,
      contains(LearningPhaseType.independentPractice),
    );
    expect(
      progress.completedPhases,
      isNot(contains(LearningPhaseType.masteryCheck)),
    );
  });

  test('legacy completed lesson at 80 percent is migrated as mastered', () {
    final progress = LearningDataCodec.progressFrom(
      _legacyProgress(bestScore: .8),
    );

    expect(progress.masteryStatus, LessonMasteryStatus.mastered);
    expect(progress.completedPhases, contains(LearningPhaseType.masteryCheck));
  });
}

Map<String, dynamic> _legacyProgress({required double bestScore}) => {
  'lessonId': 'lesson',
  'contentVersion': '1.0.0',
  'status': 'completed',
  'startedAt': '2026-01-01T00:00:00.000Z',
  'completedAt': '2026-01-02T00:00:00.000Z',
  'lastOpenedAt': '2026-01-02T00:00:00.000Z',
  'completedSectionIds': ['lesson-phase-explanation', 'lesson-phase-examples'],
  'attemptCount': 10,
  'bestScore': bestScore,
  'masteryScore': bestScore,
  'updatedAt': '2026-01-02T00:00:00.000Z',
  'schemaVersion': 2,
};
