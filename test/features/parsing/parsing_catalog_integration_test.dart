import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const trackIds = {
    'foundations',
    'signs',
    'nominal',
    'verbal',
    'nawasekh',
    'marfouat',
    'mansoubat',
    'majrourat',
    'majzoumat',
    'followers',
    'working_derivatives',
    'styles',
    'sentence_positions',
    'semi_sentences',
    'diptotes',
    'numbers',
    'special_nouns',
    'applied_parsing',
  };

  Future<Map<String, dynamic>> loadMap(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('default parsing catalog exposes the complete gated lab', () async {
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
    ).loadSamples();
    final actualTracks = samples.map((sample) => sample.trackId).toSet();

    expect(samples.length, greaterThanOrEqualTo(180));
    expect(samples, hasLength(182));
    expect(actualTracks, trackIds);
    for (final trackId in trackIds) {
      expect(
        samples.where((sample) => sample.trackId == trackId).length,
        greaterThanOrEqualTo(10),
        reason: '$trackId must contain at least ten lab sentences.',
      );
    }
    expect(samples.every((sample) => !sample.isApproved), isTrue);
    expect(
      samples.map((sample) => sample.id).toSet(),
      hasLength(samples.length),
    );
    expect(
      samples.map((sample) => sample.order).toSet(),
      hasLength(samples.length),
    );
    expect(
      samples.map((sample) => sample.sentence).toSet(),
      hasLength(samples.length),
    );
  });

  test('every sample points to a lesson in a seeded curriculum pack', () async {
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
    ).loadSamples();
    final catalog = await loadMap(
      'assets/content/e3rab_content_catalog_v1.json',
    );
    final lessonIds = <String>{};

    for (final value in (catalog['packs'] as List).cast<Map>()) {
      final entry = Map<String, dynamic>.from(value);
      if (entry['seedEnabled'] != true) continue;
      final pack = await loadMap(entry['assetPath'] as String);
      lessonIds.addAll(
        (pack['lessons'] as List).map(
          (lesson) => (lesson as Map)['id'] as String,
        ),
      );
    }

    final missing = samples
        .where((sample) => !lessonIds.contains(sample.relatedLessonId))
        .map((sample) => '${sample.id}: ${sample.relatedLessonId}')
        .toList(growable: false);
    expect(missing, isEmpty, reason: 'Unknown related lessons: $missing');
  });

  test('parsing catalog versions match every bank manifest', () async {
    final catalog = await loadMap(
      'assets/content/e3rab_parsing_catalog_v1.json',
    );

    for (final value in (catalog['banks'] as List).cast<Map>()) {
      final entry = Map<String, dynamic>.from(value);
      final bank = await loadMap(entry['assetPath'] as String);
      expect(
        entry['contentVersion'],
        bank['contentVersion'],
        reason: 'Version mismatch for ${entry['id']}.',
      );
    }
  });
}
