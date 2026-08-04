import 'package:flutter/foundation.dart';

import '../data/content_seed_repository.dart';
import '../data/data_source/firestore_content_seed_data_source.dart';

enum ContentSeedStatus { disabled, seeded, unchanged, failed }

class ContentSeeder {
  const ContentSeeder(
    this._repository, {
    this.enabled = const bool.fromEnvironment(
      'E3RAB_ENABLE_CONTENT_SEED',
      defaultValue: false,
    ),
    this.debugMode = kDebugMode,
  });

  final ContentSeedRepository _repository;
  final bool enabled;
  final bool debugMode;

  Future<ContentSeedStatus> seedIfEnabled() async {
    if (!enabled || !debugMode) return ContentSeedStatus.disabled;
    final result = await _repository.seedConfiguredPacks();
    return result.fold(
      (_) => ContentSeedStatus.failed,
      (values) => values.any((value) => value == ContentSeedWriteResult.seeded)
          ? ContentSeedStatus.seeded
          : ContentSeedStatus.unchanged,
    );
  }
}
