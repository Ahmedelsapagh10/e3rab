import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packId = 'e3rab-general-foundations-batch1-ar-v1';
  const assetPath = 'assets/content/e3rab_general_foundations_batch1_v1.json';

  test('general foundations batch is source documented', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final report = const ContentValidationService().validate(pack);
    final lessons = (pack['lessons'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
    final lesson = lessons.singleWhere(
      (item) => item['id'] == 'inflection-building-v1',
    );

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(lesson['topicId'], 'foundations.inflection-building');
    expect(lesson['reviewStatus'], 'sourceDocumented');
    expect((lesson['examples'] as List), hasLength(4));
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
  });

  test('speech terminology is the first foundations lesson', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final lessons = (pack['lessons'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
    final lesson = lessons.singleWhere(
      (item) => item['id'] == 'speech-expression-v1',
    );
    final examples = (lesson['examples'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);

    expect(lesson['topicId'], 'foundations.speech-word-expression');
    expect(lesson['order'], 0);
    expect(lesson['prerequisiteIds'], isEmpty);
    expect(examples, hasLength(6));
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
  });

  test('estimated and local inflection follows the building lesson', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final lessons = (pack['lessons'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
    final lesson = lessons.singleWhere(
      (item) => item['id'] == 'inflection-forms-v1',
    );
    final examples = (lesson['examples'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);

    expect(lesson['topicId'], 'foundations.inflection-forms');
    expect(lesson['order'], 3);
    expect(lesson['prerequisiteIds'], ['inflection-building-v1']);
    expect(examples, hasLength(6));
    expect(
      examples.every((example) => (example['parsedWords'] as List).length >= 2),
      isTrue,
    );
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
  });

  test('governor lesson follows the full parsing decision chain', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final lessons = (pack['lessons'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
    final lesson = lessons.singleWhere(
      (item) => item['id'] == 'grammatical-governance-v1',
    );
    final examples = (lesson['examples'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);

    expect(lesson['topicId'], 'foundations.governor-governed');
    expect(lesson['order'], 4);
    expect(lesson['prerequisiteIds'], ['inflection-forms-v1']);
    expect(examples, hasLength(6));
    expect(
      examples.every((example) => (example['parsedWords'] as List).length >= 2),
      isTrue,
    );
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
  });

  test('sentence types completes the foundations prerequisite chain', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final lessons = (pack['lessons'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);
    final lesson = lessons.singleWhere(
      (item) => item['id'] == 'sentence-types-v1',
    );
    final examples = (lesson['examples'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList(growable: false);

    expect(lesson['topicId'], 'foundations.sentence-types');
    expect(lesson['order'], 5);
    expect(lesson['prerequisiteIds'], ['grammatical-governance-v1']);
    expect(examples, hasLength(6));
    expect(
      examples.every((example) => (example['parsedWords'] as List).length >= 2),
      isTrue,
    );
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
  });

  test('source-documented batch enters the learner curriculum', () async {
    final result = await LocalContentPackCatalogRepository(
      bundle: rootBundle,
    ).getCatalog();
    final catalog = result.getOrElse(
      () => throw StateError('Expected a valid content catalog.'),
    );
    final pack = catalog.packs.singleWhere((item) => item.packId == packId);

    expect(pack.assetPath, assetPath);
    expect(pack.learnerEnabled, isTrue);
    expect(pack.seedEnabled, isTrue);
  });

  test('catalog rejects an in-review pack marked learner enabled', () async {
    final bundle = _UnsafeCatalogBundle();
    final result = await LocalContentPackCatalogRepository(
      bundle: bundle,
    ).getCatalog();

    expect(result.isLeft(), isTrue);
  });
}

class _UnsafeCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '''
  {
    "schemaVersion": 1,
    "catalogVersion": "test",
    "packs": [{
      "packId": "unsafe",
      "assetPath": "assets/content/unsafe.json",
      "contentVersion": "1",
      "curriculumVersion": "1",
      "reviewStatus": "inReview",
      "seedEnabled": true,
      "learnerEnabled": true
    }]
  }
  ''';
}
