import 'package:equatable/equatable.dart';

import 'content_review_status.dart';

class CurriculumVersionModel extends Equatable {
  const CurriculumVersionModel({
    required this.id,
    required this.countryCode,
    required this.authority,
    required this.academicYear,
    required this.version,
    required this.reviewStatus,
    required this.sourceIds,
  });

  final String id;
  final String countryCode;
  final String authority;
  final String academicYear;
  final String version;
  final ContentReviewStatus reviewStatus;
  final List<String> sourceIds;

  @override
  List<Object?> get props => [
    id,
    countryCode,
    authority,
    academicYear,
    version,
    reviewStatus,
    sourceIds,
  ];
}

class LearningPathModel extends Equatable {
  const LearningPathModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.moduleIds,
    required this.isFreeOrder,
  });

  final String id;
  final String slug;
  final String title;
  final List<String> moduleIds;
  final bool isFreeOrder;

  @override
  List<Object?> get props => [id, slug, title, moduleIds, isFreeOrder];
}

class GrammarModuleModel extends Equatable {
  const GrammarModuleModel({
    required this.id,
    required this.slug,
    required this.title,
    required this.unitIds,
    required this.order,
  });

  final String id;
  final String slug;
  final String title;
  final List<String> unitIds;
  final int order;

  @override
  List<Object?> get props => [id, slug, title, unitIds, order];
}

class GrammarUnitModel extends Equatable {
  const GrammarUnitModel({
    required this.id,
    required this.moduleId,
    required this.slug,
    required this.title,
    required this.lessonIds,
    required this.order,
  });

  final String id;
  final String moduleId;
  final String slug;
  final String title;
  final List<String> lessonIds;
  final int order;

  @override
  List<Object?> get props => [id, moduleId, slug, title, lessonIds, order];
}
