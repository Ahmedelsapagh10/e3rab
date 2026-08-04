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
  };

  static LessonProgressModel progressFrom(Map<String, dynamic> json) {
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
