import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packId = 'e3rab-general-signs-batch1-ar-v1';
  const assetPath = 'assets/content/e3rab_general_signs_batch1_v1.json';

  test('signs lessons are structurally ready in prerequisite order', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final report = const ContentValidationService().validate(pack);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
    const expectedTopics = [
      'signs.original-signs',
      'signs.secondary-signs',
      'signs.five-nouns',
      'signs.dual',
      'signs.sound-masculine-plural',
      'signs.sound-feminine-plural',
      'signs.five-verbs',
      'signs.weak-ending',
    ];
    const expectedPrerequisites = [
      <String>[],
      ['original-signs-v1'],
      ['secondary-signs-v1'],
      ['five-nouns-v1'],
      ['dual-v1'],
      ['sound-masculine-plural-v1'],
      ['sound-feminine-plural-v1'],
      ['five-verbs-v1'],
    ];

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(lessons, hasLength(expectedTopics.length));
    final exampleIds = <String>{};
    for (var index = 0; index < lessons.length; index++) {
      final lesson = lessons[index];
      expect(lesson['topicId'], expectedTopics[index]);
      expect(lesson['order'], 100 + (index * 10));
      expect(lesson['prerequisiteIds'], expectedPrerequisites[index]);
      expect(lesson['reviewStatus'], 'inReview');
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(7));
      final examples = (lesson['examples'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
      expect(examples.length, greaterThanOrEqualTo(4));
      for (final example in examples) {
        expect(exampleIds.add(example['id'] as String), isTrue);
        final sentence = example['sentence'] as String;
        for (final rawWord in example['parsedWords'] as List) {
          final word = Map<String, dynamic>.from(rawWord as Map);
          expect(
            sentence.substring(
              word['startIndex'] as int,
              word['endIndex'] as int,
            ),
            word['word'],
          );
        }
      }
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('signs review pack stays outside learner curriculum', () async {
    final result = await LocalContentPackCatalogRepository(
      bundle: rootBundle,
    ).getCatalog();
    final catalog = result.getOrElse(
      () => throw StateError('Expected a valid content catalog.'),
    );
    final pack = catalog.packs.singleWhere((item) => item.packId == packId);

    expect(pack.assetPath, assetPath);
    expect(pack.contentVersion, '1.7.0');
    expect(pack.learnerEnabled, isFalse);
    expect(pack.seedEnabled, isTrue);
  });

  test('catalog versions match every content pack manifest', () async {
    final result = await LocalContentPackCatalogRepository(
      bundle: rootBundle,
    ).getCatalog();
    final catalog = result.getOrElse(
      () => throw StateError('Expected a valid content catalog.'),
    );

    for (final entry in catalog.packs) {
      final raw = await rootBundle.loadString(entry.assetPath);
      final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
      expect(
        entry.contentVersion,
        manifest['contentVersion'],
        reason: 'Catalog version differs for ${entry.packId}.',
      );
    }
  });
}
