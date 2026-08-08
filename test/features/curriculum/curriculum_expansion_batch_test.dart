import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_matrix_repository.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const batchPackId = 'egypt-secondary2-term1-batch1-ar-v1';
  const officialSourceUrl =
      'https://elearnningcontent.blob.core.windows.net/'
      'elearnningcontent/content/2026/Secondry/Secondry2/Term1/'
      'ClassrHomeAssessmentsTest/'
      'Arabic_language_Secondary2_TR1_C-W6.pdf';

  test(
    'matrix exposes one dated draft mapping backed by the official source',
    () async {
      final result = await LocalCurriculumMatrixRepository(
        bundle: rootBundle,
      ).getCurrentMatrix();
      final matrix = result.getOrElse(
        () => throw StateError('Expected a valid curriculum matrix.'),
      );

      expect(matrix.curriculum.id, 'egypt-national-2025-2026');
      expect(matrix.curriculum.academicYear, '2025-2026');
      expect(
        matrix.curriculum.reviewStatus,
        ContentReviewStatus.aiAssistedDraft,
      );
      expect(matrix.mappings, hasLength(1));

      final mapping = matrix.mappings.single;
      expect(mapping.stageId, 'secondary');
      expect(mapping.gradeId, 'grade-11');
      expect(mapping.termId, 'term-1');
      expect(mapping.officialOutcome, 'جزم المضارع في جواب الطلب');
      expect(mapping.source.url, officialSourceUrl);
      expect(mapping.source.checkedAt, DateTime(2026, 8, 4));
      expect(mapping.reviewStatus, ContentReviewStatus.aiAssistedDraft);
      expect(mapping.reviewer, isNull);
    },
  );

  test(
    'catalog marks the reviewed batch learner-disabled but seed-enabled',
    () async {
      final result = await LocalContentPackCatalogRepository(
        bundle: rootBundle,
      ).getCatalog();
      final catalog = result.getOrElse(
        () => throw StateError('Expected a valid content catalog.'),
      );

      expect(catalog.packs.map((pack) => pack.packId), contains(batchPackId));
      final batch = catalog.packs.singleWhere(
        (pack) => pack.packId == batchPackId,
      );
      expect(batch.reviewStatus, ContentReviewStatus.inReview);
      expect(batch.seedEnabled, isTrue);
      expect(batch.learnerEnabled, isFalse);

      final learnerSource = AssetCurriculumDataSource(
        bundle: rootBundle,
        assetPaths: catalog.packs
            .where((pack) => pack.learnerEnabled)
            .map((pack) => pack.assetPath)
            .toList(),
      );
      await learnerSource.load();
      expect(learnerSource.lessons, hasLength(3));
      expect(
        learnerSource.lessons.map((lesson) => lesson.id),
        isNot(contains('jussive-answer-request-v1')),
      );
    },
  );

  test('secondary batch is structurally ready for specialist review', () async {
    final raw = await rootBundle.loadString(
      'assets/content/e3rab_egypt_secondary2_term1_batch1_v1.json',
    );
    final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final report = const ContentValidationService().validate(pack);

    expect(report.issues, isEmpty, reason: report.issues.join('\n'));
    expect((pack['manifest'] as Map)['packId'], batchPackId);
    expect((pack['modules'] as List), hasLength(1));
    expect((pack['units'] as List), hasLength(1));
    expect((pack['lessons'] as List), hasLength(1));

    final lesson = Map<String, dynamic>.from(
      (pack['lessons'] as List).single as Map,
    );
    final exercises = (pack['exercises'] as List)
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    expect(exercises, hasLength(10));
    expect(lesson['reviewStatus'], 'inReview');
    expect(lesson['reviewedBy'], isNull);
    expect(lesson['reviewedAt'], isNull);
    expect((lesson['examples'] as List), hasLength(4));
    expect(
      (lesson['examples'] as List).every(
        (example) => ((example as Map)['parsedWords'] as List).every(
          (word) =>
              ((word as Map)['grammaticalAgent'] as String).isNotEmpty &&
              (word['sentencePosition'] as String).isNotEmpty,
        ),
      ),
      isTrue,
    );
    expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    expect(lesson['topicId'], 'majzoumat.answer-to-request');
    expect(
      exercises.every(
        (exercise) => exercise['reviewStatus'] == 'aiAssistedDraft',
      ),
      isTrue,
    );
    expect(
      exercises.every(
        (exercise) => (exercise['options'] as List).every(
          (option) => ((option as Map)['feedback'] as String).trim().isNotEmpty,
        ),
      ),
      isTrue,
    );

    final reference = Map<String, dynamic>.from(
      (pack['references'] as List).single as Map,
    );
    expect(reference['url'], officialSourceUrl);
    expect(reference['checkedAt'], '2026-08-04');
  });
}
