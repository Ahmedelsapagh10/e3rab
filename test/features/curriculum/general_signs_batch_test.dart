import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packId = 'e3rab-general-signs-batch1-ar-v1';
  const assetPath = 'assets/content/e3rab_general_signs_batch1_v1.json';

  test('original signs lesson is structurally ready for review', () async {
    final raw = await rootBundle.loadString(assetPath);
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final report = const ContentValidationService().validate(pack);
    final lesson = Map<String, dynamic>.from(
      (pack['lessons'] as List).single as Map,
    );

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(lesson['topicId'], 'signs.original-signs');
    expect(lesson['order'], 100);
    expect(lesson['reviewStatus'], 'inReview');
    expect((lesson['examples'] as List), hasLength(4));
    expect((lesson['exerciseIds'] as List), hasLength(10));
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
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
    expect(pack.contentVersion, '1.0.0');
    expect(pack.learnerEnabled, isFalse);
    expect(pack.seedEnabled, isTrue);
  });
}
