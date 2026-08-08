import 'package:equatable/equatable.dart';

import 'content_review_status.dart';
import 'lesson_step_model.dart';

class LessonModel extends Equatable {
  const LessonModel({
    required this.id,
    required this.unitId,
    required this.slug,
    required this.title,
    required this.shortTitle,
    required this.stageIds,
    required this.gradeIds,
    required this.objectives,
    required this.prerequisiteIds,
    required this.sections,
    required this.examples,
    required this.exerciseIds,
    this.masteryExerciseIds = const [],
    required this.referenceIds,
    required this.tags,
    required this.estimatedMinutes,
    required this.contentVersion,
    required this.reviewStatus,
    this.topicId,
    this.order = 0,
    this.steps = const [],
    this.citations = const [],
    this.reviewedBy,
    this.reviewedAt,
  });

  final String id;
  final String unitId;
  final String slug;
  final String title;
  final String shortTitle;
  final List<String> stageIds;
  final List<String> gradeIds;
  final List<String> objectives;
  final List<String> prerequisiteIds;
  final List<LessonSectionModel> sections;
  final List<GrammarExampleModel> examples;
  final List<String> exerciseIds;
  final List<String> masteryExerciseIds;
  final List<String> referenceIds;
  final List<String> tags;
  final int estimatedMinutes;
  final String contentVersion;
  final ContentReviewStatus reviewStatus;
  final String? topicId;
  final int order;
  final List<LessonStepModel> steps;
  final List<CitationModel> citations;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  @override
  List<Object?> get props => [
    id,
    unitId,
    slug,
    title,
    shortTitle,
    stageIds,
    gradeIds,
    objectives,
    prerequisiteIds,
    sections,
    examples,
    exerciseIds,
    masteryExerciseIds,
    referenceIds,
    tags,
    estimatedMinutes,
    contentVersion,
    reviewStatus,
    topicId,
    order,
    steps,
    citations,
    reviewedBy,
    reviewedAt,
  ];
}

class LessonSectionModel extends Equatable {
  const LessonSectionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.order,
    required this.referenceIds,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final int order;
  final List<String> referenceIds;

  @override
  List<Object?> get props => [id, type, title, body, order, referenceIds];
}

class GrammarExampleModel extends Equatable {
  const GrammarExampleModel({
    required this.id,
    required this.sentence,
    required this.fullyDiacritizedSentence,
    required this.parsedWords,
    required this.explanation,
    required this.referenceIds,
  });

  final String id;
  final String sentence;
  final String fullyDiacritizedSentence;
  final List<ParsedWordModel> parsedWords;
  final String explanation;
  final List<String> referenceIds;

  @override
  List<Object?> get props => [
    id,
    sentence,
    fullyDiacritizedSentence,
    parsedWords,
    explanation,
    referenceIds,
  ];
}

class ParsedWordModel extends Equatable {
  const ParsedWordModel({
    required this.word,
    required this.normalizedWord,
    required this.wordType,
    required this.grammaticalRole,
    required this.grammaticalState,
    required this.grammaticalSign,
    required this.signReason,
    required this.explanation,
    required this.startIndex,
    required this.endIndex,
    this.grammaticalAgent = '',
    this.sentencePosition = '',
  });

  final String word;
  final String normalizedWord;
  final String wordType;
  final String grammaticalRole;
  final String grammaticalState;
  final String grammaticalSign;
  final String signReason;
  final String explanation;
  final int startIndex;
  final int endIndex;
  final String grammaticalAgent;
  final String sentencePosition;

  @override
  List<Object?> get props => [
    word,
    normalizedWord,
    wordType,
    grammaticalRole,
    grammaticalState,
    grammaticalSign,
    signReason,
    explanation,
    startIndex,
    endIndex,
    grammaticalAgent,
    sentencePosition,
  ];
}
