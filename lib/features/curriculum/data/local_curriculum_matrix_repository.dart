import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import 'curriculum_matrix_repository.dart';
import 'curriculum_matrix_validator.dart';
import 'model/content_review_status.dart';
import 'model/curriculum_mapping_models.dart';
import 'model/curriculum_models.dart';

class LocalCurriculumMatrixRepository implements CurriculumMatrixRepository {
  LocalCurriculumMatrixRepository({
    required AssetBundle bundle,
    CurriculumMatrixValidator validator = const CurriculumMatrixValidator(),
    this.assetPath =
        'assets/content/e3rab_curriculum_matrix_egypt_2025_2026_v1.json',
  }) : _bundle = bundle,
       _validator = validator;

  final AssetBundle _bundle;
  final CurriculumMatrixValidator _validator;
  final String assetPath;

  @override
  Future<Either<Failure, CurriculumMatrixModel>> getCurrentMatrix() async {
    try {
      final value = Map<String, dynamic>.from(
        jsonDecode(await _bundle.loadString(assetPath)) as Map,
      );
      if (!_validator.isValid(value)) return Left(CacheFailure());
      return Right(_map(value));
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  CurriculumMatrixModel _map(Map<String, dynamic> json) {
    final curriculum = Map<String, dynamic>.from(json['curriculum'] as Map);
    return CurriculumMatrixModel(
      schemaVersion: json['schemaVersion'] as int,
      curriculum: CurriculumVersionModel(
        id: curriculum['id'] as String,
        countryCode: curriculum['countryCode'] as String,
        authority: curriculum['authority'] as String,
        academicYear: curriculum['academicYear'] as String,
        version: curriculum['version'] as String,
        reviewStatus: contentReviewStatusFromJson(
          curriculum['reviewStatus'] as String,
        ),
        sourceIds: List<String>.from(curriculum['sourceIds'] as List),
      ),
      mappings: (json['mappings'] as List).map((value) {
        final mapping = Map<String, dynamic>.from(value as Map);
        final source = Map<String, dynamic>.from(mapping['source'] as Map);
        return CurriculumMappingModel(
          id: mapping['id'] as String,
          stageId: mapping['stageId'] as String,
          gradeId: mapping['gradeId'] as String,
          termId: mapping['termId'] as String,
          officialUnit: mapping['officialUnit'] as String,
          officialOutcome: mapping['officialOutcome'] as String,
          grammarConceptIds: List<String>.from(
            mapping['grammarConceptIds'] as List,
          ),
          source: OfficialCurriculumSourceModel(
            id: source['id'] as String,
            title: source['title'] as String,
            url: source['url'] as String,
            checkedAt: DateTime.parse(source['checkedAt'] as String),
          ),
          version: mapping['version'] as String,
          reviewStatus: contentReviewStatusFromJson(
            mapping['reviewStatus'] as String,
          ),
          reviewer: mapping['reviewer'] as String?,
        );
      }).toList(),
    );
  }
}
