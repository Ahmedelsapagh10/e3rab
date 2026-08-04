import 'package:equatable/equatable.dart';

import 'content_review_status.dart';

class ContentPackCatalogEntry extends Equatable {
  const ContentPackCatalogEntry({
    required this.packId,
    required this.assetPath,
    required this.contentVersion,
    required this.curriculumVersion,
    required this.reviewStatus,
    required this.seedEnabled,
    required this.learnerEnabled,
  });

  final String packId;
  final String assetPath;
  final String contentVersion;
  final String curriculumVersion;
  final ContentReviewStatus reviewStatus;
  final bool seedEnabled;
  final bool learnerEnabled;

  @override
  List<Object?> get props => [
    packId,
    assetPath,
    contentVersion,
    curriculumVersion,
    reviewStatus,
    seedEnabled,
    learnerEnabled,
  ];
}

class ContentPackCatalog extends Equatable {
  const ContentPackCatalog({
    required this.schemaVersion,
    required this.catalogVersion,
    required this.packs,
  });

  final int schemaVersion;
  final String catalogVersion;
  final List<ContentPackCatalogEntry> packs;

  @override
  List<Object?> get props => [schemaVersion, catalogVersion, packs];
}
