import 'package:equatable/equatable.dart';

enum LessonStepType {
  introduction,
  simpleRule,
  interactiveExample,
  commonMistake,
  exceptionRule,
  comparison,
  quickCheck,
  summary,
}

enum ContentBlockType { paragraph, highlightedRule, example, warning, list }

class ContentBlockModel extends Equatable {
  const ContentBlockModel({
    required this.id,
    required this.type,
    required this.body,
    this.title,
    this.citationIds = const [],
  });

  final String id;
  final ContentBlockType type;
  final String? title;
  final String body;
  final List<String> citationIds;

  @override
  List<Object?> get props => [id, type, title, body, citationIds];
}

class QuickCheckModel extends Equatable {
  const QuickCheckModel({
    required this.prompt,
    required this.options,
    required this.correctOptionId,
    required this.explanation,
  });

  final String prompt;
  final Map<String, String> options;
  final String correctOptionId;
  final String explanation;

  @override
  List<Object?> get props => [prompt, options, correctOptionId, explanation];
}

class LessonStepModel extends Equatable {
  const LessonStepModel({
    required this.id,
    required this.type,
    required this.title,
    required this.order,
    required this.blocks,
    this.quickCheck,
  });

  final String id;
  final LessonStepType type;
  final String title;
  final int order;
  final List<ContentBlockModel> blocks;
  final QuickCheckModel? quickCheck;

  @override
  List<Object?> get props => [id, type, title, order, blocks, quickCheck];
}

class CitationModel extends Equatable {
  const CitationModel({
    required this.id,
    required this.title,
    required this.locator,
    required this.referenceId,
  });

  final String id;
  final String title;
  final String locator;
  final String referenceId;

  @override
  List<Object?> get props => [id, title, locator, referenceId];
}
