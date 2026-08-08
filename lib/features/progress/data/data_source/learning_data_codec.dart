import '../model/learning_progress_models.dart';

abstract final class LearningDataCodec {
  static Map<String, Object?> progress(LessonProgressModel item) => {
    'lessonId': item.lessonId,
    'contentVersion': item.contentVersion,
    'status': item.status.name,
    'startedAt': _date(item.startedAt),
    'completedAt': _date(item.completedAt),
    'lastOpenedAt': _date(item.lastOpenedAt),
    'completedSectionIds': item.completedSectionIds,
    'attemptCount': item.attemptCount,
    'bestScore': item.bestScore,
    'masteryScore': item.masteryScore,
    'updatedAt': _date(item.updatedAt),
    'schemaVersion': item.schemaVersion,
    'currentPhase': item.currentPhase.name,
    'completedPhases': item.completedPhases.map((item) => item.name).toList(),
    'masteryStatus': item.masteryStatus.name,
    'checkpointScore': item.checkpointScore,
    'missedSkillIds': item.missedSkillIds,
    'masteredAt': _date(item.masteredAt),
  };

  static LessonProgressModel progressFrom(Map<String, dynamic> json) {
    final migration = _migrateProgress(json);
    return LessonProgressModel(
      lessonId: json['lessonId'] as String,
      contentVersion: json['contentVersion'] as String,
      status: LessonProgressStatus.values.byName(json['status'] as String),
      startedAt: _parse(json['startedAt']),
      completedAt: _parse(json['completedAt']),
      lastOpenedAt: _parse(json['lastOpenedAt']),
      completedSectionIds: List<String>.from(
        json['completedSectionIds'] as List,
      ),
      attemptCount: json['attemptCount'] as int,
      bestScore: (json['bestScore'] as num).toDouble(),
      masteryScore: (json['masteryScore'] as num).toDouble(),
      updatedAt: _parse(json['updatedAt'])!,
      schemaVersion: json['schemaVersion'] as int,
      currentPhase: migration.currentPhase,
      completedPhases: migration.completedPhases,
      masteryStatus: migration.masteryStatus,
      checkpointScore: migration.checkpointScore,
      missedSkillIds: List<String>.from(
        json['missedSkillIds'] as List? ?? const [],
      ),
      masteredAt: _parse(json['masteredAt']),
    );
  }

  static _ProgressMigration _migrateProgress(Map<String, dynamic> json) {
    final phases = (json['completedPhases'] as List?)
        ?.whereType<String>()
        .map(LearningPhaseType.values.byName)
        .toSet();
    if (phases != null) {
      final masteryName = json['masteryStatus'] as String?;
      return _ProgressMigration(
        completedPhases: phases.toList(),
        currentPhase: LearningPhaseType.values.byName(
          json['currentPhase'] as String? ?? LearningPhaseType.understand.name,
        ),
        masteryStatus: masteryName == null
            ? LessonMasteryStatus.learning
            : LessonMasteryStatus.values.byName(masteryName),
        checkpointScore: (json['checkpointScore'] as num?)?.toDouble() ?? 0,
      );
    }
    final legacyIds = List<String>.from(
      json['completedSectionIds'] as List? ?? const [],
    );
    final migrated = <LearningPhaseType>{};
    if (legacyIds.any((id) => id.endsWith('-phase-explanation'))) {
      migrated.addAll([LearningPhaseType.understand, LearningPhaseType.detect]);
    }
    if (legacyIds.any((id) => id.endsWith('-phase-examples'))) {
      migrated.add(LearningPhaseType.workedExamples);
    }
    final legacyCompleted =
        json['status'] == LessonProgressStatus.completed.name;
    if (legacyCompleted) {
      migrated.addAll([
        LearningPhaseType.guidedParsing,
        LearningPhaseType.independentPractice,
      ]);
    }
    final bestScore = (json['bestScore'] as num?)?.toDouble() ?? 0;
    final mastered = legacyCompleted && bestScore >= .8;
    if (mastered) migrated.add(LearningPhaseType.masteryCheck);
    return _ProgressMigration(
      completedPhases: migrated.toList(),
      currentPhase: mastered
          ? LearningPhaseType.masteryCheck
          : legacyCompleted
          ? LearningPhaseType.workedExamples
          : _firstIncomplete(migrated),
      masteryStatus: mastered
          ? LessonMasteryStatus.mastered
          : legacyCompleted
          ? LessonMasteryStatus.needsRemediation
          : LessonMasteryStatus.learning,
      checkpointScore: bestScore,
    );
  }

  static LearningPhaseType _firstIncomplete(Set<LearningPhaseType> completed) {
    return LearningPhaseType.values.firstWhere(
      (phase) => !completed.contains(phase),
      orElse: () => LearningPhaseType.masteryCheck,
    );
  }

  static Map<String, Object?> attempt(ExerciseAttemptModel item) => {
    'attemptId': item.attemptId,
    'exerciseId': item.exerciseId,
    'lessonId': item.lessonId,
    'skillIds': item.skillIds,
    'contentVersion': item.contentVersion,
    'selectedAnswer': item.selectedAnswer,
    'isCorrect': item.isCorrect,
    'scoreWeight': item.scoreWeight,
    'hintUsed': item.hintUsed,
    'attemptNumber': item.attemptNumber,
    'durationMilliseconds': item.durationMilliseconds,
    'clientCreatedAt': _date(item.clientCreatedAt),
    'serverCreatedAt': _date(item.serverCreatedAt),
    'schemaVersion': item.schemaVersion,
  };

  static ExerciseAttemptModel attemptFrom(Map<String, dynamic> json) {
    return ExerciseAttemptModel(
      attemptId: json['attemptId'] as String,
      exerciseId: json['exerciseId'] as String,
      lessonId: json['lessonId'] as String,
      skillIds: List<String>.from(json['skillIds'] as List),
      contentVersion: json['contentVersion'] as String,
      selectedAnswer: json['selectedAnswer'],
      isCorrect: json['isCorrect'] as bool,
      scoreWeight: (json['scoreWeight'] as num).toDouble(),
      hintUsed: json['hintUsed'] as bool,
      attemptNumber: json['attemptNumber'] as int,
      durationMilliseconds: json['durationMilliseconds'] as int,
      clientCreatedAt: _parse(json['clientCreatedAt'])!,
      serverCreatedAt: _parse(json['serverCreatedAt']),
      schemaVersion: json['schemaVersion'] as int,
    );
  }

  static String? _date(DateTime? value) => value?.toUtc().toIso8601String();
  static DateTime? _parse(Object? value) =>
      value is String ? DateTime.parse(value) : null;
}

class _ProgressMigration {
  const _ProgressMigration({
    required this.completedPhases,
    required this.currentPhase,
    required this.masteryStatus,
    required this.checkpointScore,
  });

  final List<LearningPhaseType> completedPhases;
  final LearningPhaseType currentPhase;
  final LessonMasteryStatus masteryStatus;
  final double checkpointScore;
}
