import 'package:equatable/equatable.dart';

import 'content_review_status.dart';
import 'curriculum_models.dart';

class OfficialCurriculumSourceModel extends Equatable {
  const OfficialCurriculumSourceModel({
    required this.id,
    required this.title,
    required this.url,
    required this.checkedAt,
  });

  final String id;
  final String title;
  final String url;
  final DateTime checkedAt;

  @override
  List<Object?> get props => [id, title, url, checkedAt];
}

class CurriculumMappingModel extends Equatable {
  const CurriculumMappingModel({
    required this.id,
    required this.stageId,
    required this.gradeId,
    required this.termId,
    required this.officialUnit,
    required this.officialOutcome,
    required this.grammarConceptIds,
    required this.source,
    required this.version,
    required this.reviewStatus,
    this.reviewer,
  });

  final String id;
  final String stageId;
  final String gradeId;
  final String termId;
  final String officialUnit;
  final String officialOutcome;
  final List<String> grammarConceptIds;
  final OfficialCurriculumSourceModel source;
  final String version;
  final ContentReviewStatus reviewStatus;
  final String? reviewer;

  @override
  List<Object?> get props => [
    id,
    stageId,
    gradeId,
    termId,
    officialUnit,
    officialOutcome,
    grammarConceptIds,
    source,
    version,
    reviewStatus,
    reviewer,
  ];
}

class CurriculumMatrixModel extends Equatable {
  const CurriculumMatrixModel({
    required this.schemaVersion,
    required this.curriculum,
    required this.mappings,
  });

  final int schemaVersion;
  final CurriculumVersionModel curriculum;
  final List<CurriculumMappingModel> mappings;

  @override
  List<Object?> get props => [schemaVersion, curriculum, mappings];
}
