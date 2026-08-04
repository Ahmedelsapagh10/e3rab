import 'package:equatable/equatable.dart';

import 'content_review_status.dart';

enum ExerciseType {
  multipleChoice,
  trueFalse,
  targetWord,
  matching,
  ordering,
  missingWord,
  missingSign,
  correctEnding,
  classification,
  sentenceBuilding,
  guidedParsing,
  errorCorrection,
  comparison,
  timedTest,
}

class ExerciseModel extends Equatable {
  const ExerciseModel({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.skillIds,
    required this.stageIds,
    required this.gradeIds,
    required this.difficulty,
    required this.options,
    required this.correctAnswerIds,
    required this.explanation,
    required this.hint,
    required this.referenceIds,
    required this.contentVersion,
    required this.reviewStatus,
    required this.schemaVersion,
  });

  final String id;
  final String lessonId;
  final ExerciseType type;
  final String prompt;
  final List<String> skillIds;
  final List<String> stageIds;
  final List<String> gradeIds;
  final int difficulty;
  final List<ExerciseOptionModel> options;
  final List<String> correctAnswerIds;
  final String explanation;
  final String hint;
  final List<String> referenceIds;
  final String contentVersion;
  final ContentReviewStatus reviewStatus;
  final int schemaVersion;

  @override
  List<Object?> get props => [
    id,
    lessonId,
    type,
    prompt,
    skillIds,
    stageIds,
    gradeIds,
    difficulty,
    options,
    correctAnswerIds,
    explanation,
    hint,
    referenceIds,
    contentVersion,
    reviewStatus,
    schemaVersion,
  ];
}

class ExerciseOptionModel extends Equatable {
  const ExerciseOptionModel({
    required this.id,
    required this.text,
    required this.feedback,
  });

  final String id;
  final String text;
  final String feedback;

  @override
  List<Object?> get props => [id, text, feedback];
}
