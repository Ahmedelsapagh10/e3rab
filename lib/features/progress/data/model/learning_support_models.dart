import 'package:equatable/equatable.dart';

import 'learning_progress_models.dart';

class SkillMasteryModel extends Equatable {
  const SkillMasteryModel({
    required this.skillId,
    required this.score,
    required this.state,
    required this.scoredAttemptCount,
    required this.unhintedCorrectCount,
    required this.lastPracticedAt,
    required this.nextReviewAt,
    required this.algorithmVersion,
    required this.updatedAt,
  });

  final String skillId;
  final double score;
  final MasteryState state;
  final int scoredAttemptCount;
  final int unhintedCorrectCount;
  final DateTime lastPracticedAt;
  final DateTime nextReviewAt;
  final int algorithmVersion;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    skillId,
    score,
    state,
    scoredAttemptCount,
    unhintedCorrectCount,
    lastPracticedAt,
    nextReviewAt,
    algorithmVersion,
    updatedAt,
  ];
}

class ReviewItemModel extends Equatable {
  const ReviewItemModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.dueAt,
    required this.intervalLevel,
    required this.lastResult,
    required this.updatedAt,
    required this.algorithmVersion,
  });

  final String id;
  final String targetType;
  final String targetId;
  final DateTime dueAt;
  final int intervalLevel;
  final String lastResult;
  final DateTime updatedAt;
  final int algorithmVersion;

  @override
  List<Object?> get props => [
    id,
    targetType,
    targetId,
    dueAt,
    intervalLevel,
    lastResult,
    updatedAt,
    algorithmVersion,
  ];
}

class BookmarkModel extends Equatable {
  const BookmarkModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.contentVersion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String contentVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  @override
  List<Object?> get props => [
    id,
    targetType,
    targetId,
    contentVersion,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

class LearningNoteModel extends Equatable {
  const LearningNoteModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.text,
    required this.localVersion,
    required this.updatedAt,
    required this.schemaVersion,
    this.deletedAt,
  });

  final String id;
  final String targetType;
  final String targetId;
  final String text;
  final int localVersion;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int schemaVersion;

  @override
  List<Object?> get props => [
    id,
    targetType,
    targetId,
    text,
    localVersion,
    updatedAt,
    deletedAt,
    schemaVersion,
  ];
}
