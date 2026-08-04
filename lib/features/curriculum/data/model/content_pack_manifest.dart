import 'package:equatable/equatable.dart';

import 'content_review_status.dart';

class ContentPackManifest extends Equatable {
  const ContentPackManifest({
    required this.packId,
    required this.schemaVersion,
    required this.contentVersion,
    required this.curriculumVersion,
    required this.locale,
    required this.entityIds,
    required this.checksum,
    required this.minimumAppVersion,
    required this.reviewStatus,
  });

  final String packId;
  final int schemaVersion;
  final String contentVersion;
  final String curriculumVersion;
  final String locale;
  final List<String> entityIds;
  final String checksum;
  final String minimumAppVersion;
  final ContentReviewStatus reviewStatus;

  factory ContentPackManifest.fromJson(Map<String, dynamic> json) {
    return ContentPackManifest(
      packId: json['packId'] as String,
      schemaVersion: json['schemaVersion'] as int,
      contentVersion: json['contentVersion'] as String,
      curriculumVersion: json['curriculumVersion'] as String,
      locale: json['locale'] as String,
      entityIds: List<String>.from(json['entityIds'] as List),
      checksum: json['checksum'] as String,
      minimumAppVersion: json['minimumAppVersion'] as String,
      reviewStatus: contentReviewStatusFromJson(json['reviewStatus'] as String),
    );
  }

  Map<String, Object?> toJson() => {
    'packId': packId,
    'schemaVersion': schemaVersion,
    'contentVersion': contentVersion,
    'curriculumVersion': curriculumVersion,
    'locale': locale,
    'entityIds': entityIds,
    'checksum': checksum,
    'minimumAppVersion': minimumAppVersion,
    'reviewStatus': reviewStatus.name,
  };

  @override
  List<Object?> get props => [
    packId,
    schemaVersion,
    contentVersion,
    curriculumVersion,
    locale,
    entityIds,
    checksum,
    minimumAppVersion,
    reviewStatus,
  ];
}
