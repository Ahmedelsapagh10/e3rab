import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';

abstract final class LearningSupportCodec {
  static Map<String, Object?> mastery(SkillMasteryModel item) => {
    'skillId': item.skillId,
    'score': item.score,
    'state': item.state.name,
    'scoredAttemptCount': item.scoredAttemptCount,
    'unhintedCorrectCount': item.unhintedCorrectCount,
    'lastPracticedAt': _date(item.lastPracticedAt),
    'nextReviewAt': _date(item.nextReviewAt),
    'algorithmVersion': item.algorithmVersion,
    'updatedAt': _date(item.updatedAt),
  };

  static SkillMasteryModel masteryFrom(Map<String, dynamic> json) {
    return SkillMasteryModel(
      skillId: json['skillId'] as String,
      score: (json['score'] as num).toDouble(),
      state: MasteryState.values.byName(json['state'] as String),
      scoredAttemptCount: json['scoredAttemptCount'] as int,
      unhintedCorrectCount: json['unhintedCorrectCount'] as int,
      lastPracticedAt: _parse(json['lastPracticedAt'])!,
      nextReviewAt: _parse(json['nextReviewAt'])!,
      algorithmVersion: json['algorithmVersion'] as int,
      updatedAt: _parse(json['updatedAt'])!,
    );
  }

  static Map<String, Object?> review(ReviewItemModel item) => {
    'id': item.id,
    'targetType': item.targetType,
    'targetId': item.targetId,
    'dueAt': _date(item.dueAt),
    'intervalLevel': item.intervalLevel,
    'lastResult': item.lastResult,
    'updatedAt': _date(item.updatedAt),
    'algorithmVersion': item.algorithmVersion,
  };

  static ReviewItemModel reviewFrom(Map<String, dynamic> json) {
    return ReviewItemModel(
      id: json['id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      dueAt: _parse(json['dueAt'])!,
      intervalLevel: json['intervalLevel'] as int,
      lastResult: json['lastResult'] as String,
      updatedAt: _parse(json['updatedAt'])!,
      algorithmVersion: json['algorithmVersion'] as int,
    );
  }

  static Map<String, Object?> bookmark(BookmarkModel item) => {
    'id': item.id,
    'targetType': item.targetType,
    'targetId': item.targetId,
    'contentVersion': item.contentVersion,
    'createdAt': _date(item.createdAt),
    'updatedAt': _date(item.updatedAt),
    'deletedAt': _date(item.deletedAt),
  };

  static BookmarkModel bookmarkFrom(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      contentVersion: json['contentVersion'] as String,
      createdAt: _parse(json['createdAt'])!,
      updatedAt: _parse(json['updatedAt'])!,
      deletedAt: _parse(json['deletedAt']),
    );
  }

  static Map<String, Object?> note(LearningNoteModel item) => {
    'id': item.id,
    'targetType': item.targetType,
    'targetId': item.targetId,
    'text': item.text,
    'localVersion': item.localVersion,
    'updatedAt': _date(item.updatedAt),
    'deletedAt': _date(item.deletedAt),
    'schemaVersion': item.schemaVersion,
  };

  static LearningNoteModel noteFrom(Map<String, dynamic> json) {
    return LearningNoteModel(
      id: json['id'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      text: json['text'] as String,
      localVersion: json['localVersion'] as int,
      updatedAt: _parse(json['updatedAt'])!,
      deletedAt: _parse(json['deletedAt']),
      schemaVersion: json['schemaVersion'] as int,
    );
  }

  static String? _date(DateTime? value) => value?.toUtc().toIso8601String();
  static DateTime? _parse(Object? value) =>
      value is String ? DateTime.parse(value) : null;
}
