import 'package:equatable/equatable.dart';

import '../../../curriculum/data/model/content_review_status.dart';
import '../../../curriculum/data/model/lesson_model.dart';

class ParsingOptionModel extends Equatable {
  const ParsingOptionModel({
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

class ParsingStepModel extends Equatable {
  const ParsingStepModel({
    required this.id,
    required this.title,
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });

  final String id;
  final String title;
  final String prompt;
  final List<ParsingOptionModel> options;
  final String correctOptionId;
  final String explanation;

  @override
  List<Object?> get props => [
    id,
    title,
    prompt,
    options,
    correctOptionId,
    explanation,
  ];
}

class ParsingAlternativeModel extends Equatable {
  const ParsingAlternativeModel({
    required this.title,
    required this.explanation,
  });

  final String title;
  final String explanation;

  @override
  List<Object?> get props => [title, explanation];
}

class ParsingSampleModel extends Equatable {
  const ParsingSampleModel({
    required this.id,
    required this.sentence,
    required this.fullyDiacritizedSentence,
    required this.targetText,
    required this.steps,
    required this.parsedWords,
    required this.summary,
    required this.alternatives,
    required this.relatedLessonId,
    required this.referenceIds,
    required this.contentVersion,
    required this.reviewStatus,
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final String sentence;
  final String fullyDiacritizedSentence;
  final String targetText;
  final List<ParsingStepModel> steps;
  final List<ParsedWordModel> parsedWords;
  final String summary;
  final List<ParsingAlternativeModel> alternatives;
  final String relatedLessonId;
  final List<String> referenceIds;
  final String contentVersion;
  final ContentReviewStatus reviewStatus;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  bool get isApproved => reviewStatus == ContentReviewStatus.approved;

  @override
  List<Object?> get props => [
    id,
    sentence,
    fullyDiacritizedSentence,
    targetText,
    steps,
    parsedWords,
    summary,
    alternatives,
    relatedLessonId,
    referenceIds,
    contentVersion,
    reviewStatus,
    reviewedBy,
    reviewedAt,
  ];
}
