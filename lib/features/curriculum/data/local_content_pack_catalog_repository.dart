import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import 'content_pack_catalog_repository.dart';
import 'model/content_pack_catalog_models.dart';
import 'model/content_review_status.dart';

class LocalContentPackCatalogRepository
    implements ContentPackCatalogRepository {
  LocalContentPackCatalogRepository({
    required AssetBundle bundle,
    this.assetPath = 'assets/content/e3rab_content_catalog_v1.json',
  }) : _bundle = bundle;

  final AssetBundle _bundle;
  final String assetPath;

  @override
  Future<Either<Failure, ContentPackCatalog>> getCatalog() async {
    try {
      final json = Map<String, dynamic>.from(
        jsonDecode(await _bundle.loadString(assetPath)) as Map,
      );
      final packs = (json['packs'] as List)
          .map((value) => Map<String, dynamic>.from(value as Map))
          .map(_entry)
          .toList(growable: false);
      if (!_isValid(json, packs)) {
        return Left(CacheFailure());
      }
      return Right(
        ContentPackCatalog(
          schemaVersion: json['schemaVersion'] as int,
          catalogVersion: json['catalogVersion'] as String,
          packs: packs,
        ),
      );
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  ContentPackCatalogEntry _entry(Map<String, dynamic> json) {
    return ContentPackCatalogEntry(
      packId: json['packId'] as String,
      assetPath: json['assetPath'] as String,
      contentVersion: json['contentVersion'] as String,
      curriculumVersion: json['curriculumVersion'] as String,
      reviewStatus: contentReviewStatusFromJson(json['reviewStatus'] as String),
      seedEnabled: json['seedEnabled'] as bool,
      learnerEnabled: json['learnerEnabled'] as bool,
    );
  }

  bool _isValid(
    Map<String, dynamic> json,
    List<ContentPackCatalogEntry> packs,
  ) {
    final schemaVersion = json['schemaVersion'];
    final ids = packs.map((entry) => entry.packId).toSet();
    return schemaVersion is int &&
        schemaVersion > 0 &&
        _hasText(json['catalogVersion']) &&
        packs.isNotEmpty &&
        ids.length == packs.length &&
        packs.every(
          (entry) =>
              _hasText(entry.packId) &&
              entry.assetPath.startsWith('assets/content/') &&
              entry.assetPath.endsWith('.json') &&
              _hasText(entry.contentVersion) &&
              _hasText(entry.curriculumVersion) &&
              _isSafeForLearners(entry),
        );
  }

  bool _isSafeForLearners(ContentPackCatalogEntry entry) {
    if (!entry.learnerEnabled) return true;
    return entry.reviewStatus.isLearnerReady;
  }

  bool _hasText(Object? value) => value is String && value.trim().isNotEmpty;
}
