import 'package:equatable/equatable.dart';

enum LearningDataOwnerType { guest, account }

enum LessonProgressStatus { notStarted, inProgress, completed }

enum MasteryState { newSkill, learning, needsReview, mastered }

class LearningDataOwner extends Equatable {
  const LearningDataOwner._({required this.id, required this.type});

  factory LearningDataOwner.guest(String guestId) =>
      LearningDataOwner._(id: guestId, type: LearningDataOwnerType.guest);

  factory LearningDataOwner.account(String uid) =>
      LearningDataOwner._(id: uid, type: LearningDataOwnerType.account);

  final String id;
  final LearningDataOwnerType type;

  @override
  List<Object?> get props => [id, type];
}

class LessonProgressModel extends Equatable {
  const LessonProgressModel({
    required this.lessonId,
    required this.contentVersion,
    required this.status,
    required this.completedSectionIds,
    required this.attemptCount,
    required this.bestScore,
    required this.masteryScore,
    required this.updatedAt,
    required this.schemaVersion,
    this.startedAt,
    this.completedAt,
    this.lastOpenedAt,
  });

  final String lessonId;
  final String contentVersion;
  final LessonProgressStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? lastOpenedAt;
  final List<String> completedSectionIds;
  final int attemptCount;
  final double bestScore;
  final double masteryScore;
  final DateTime updatedAt;
  final int schemaVersion;

  @override
  List<Object?> get props => [
    lessonId,
    contentVersion,
    status,
    startedAt,
    completedAt,
    lastOpenedAt,
    completedSectionIds,
    attemptCount,
    bestScore,
    masteryScore,
    updatedAt,
    schemaVersion,
  ];
}

class ExerciseAttemptModel extends Equatable {
  const ExerciseAttemptModel({
    required this.attemptId,
    required this.exerciseId,
    required this.lessonId,
    required this.skillIds,
    required this.contentVersion,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.scoreWeight,
    required this.hintUsed,
    required this.attemptNumber,
    required this.durationMilliseconds,
    required this.clientCreatedAt,
    required this.schemaVersion,
    this.serverCreatedAt,
  });

  final String attemptId;
  final String exerciseId;
  final String lessonId;
  final List<String> skillIds;
  final String contentVersion;
  final Object? selectedAnswer;
  final bool isCorrect;
  final double scoreWeight;
  final bool hintUsed;
  final int attemptNumber;
  final int durationMilliseconds;
  final DateTime clientCreatedAt;
  final DateTime? serverCreatedAt;
  final int schemaVersion;

  @override
  List<Object?> get props => [
    attemptId,
    exerciseId,
    lessonId,
    skillIds,
    contentVersion,
    selectedAnswer,
    isCorrect,
    scoreWeight,
    hintUsed,
    attemptNumber,
    durationMilliseconds,
    clientCreatedAt,
    serverCreatedAt,
    schemaVersion,
  ];
}
