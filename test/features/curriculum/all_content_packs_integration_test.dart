import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/grammar_coverage_repository.dart';
import 'package:new_strucuture/features/curriculum/data/local_content_pack_catalog_repository.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/curriculum/data/model/content_review_status.dart';
import 'package:new_strucuture/features/curriculum/services/curriculum_coverage_auditor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all catalog packs combine with safe prerequisites and topic ids',
    () async {
      final catalogResult = await LocalContentPackCatalogRepository(
        bundle: rootBundle,
      ).getCatalog();
      final catalog = catalogResult.getOrElse(
        () => throw StateError('Expected content catalog.'),
      );
      final source = AssetCurriculumDataSource(
        bundle: rootBundle,
        assetPaths: catalog.packs
            .where((pack) => pack.reviewStatus.isLearnerReady)
            .map((pack) => pack.assetPath)
            .toList(growable: false),
      );

      await source.load();
      final lessonsResult = await LocalCurriculumRepository(
        source,
      ).getAllLessons();
      final lessons = lessonsResult.getOrElse(
        () => throw StateError('Expected combined lessons.'),
      );
      final tracks = await LocalGrammarCoverageRepository(
        bundle: rootBundle,
      ).getTracks();
      final report = const CurriculumCoverageAuditor().audit(
        tracks: tracks,
        lessonTopicIds: lessons.map((lesson) => lesson.topicId),
      );

      expect(report.isComplete, isTrue);
      expect(catalog.packs, hasLength(20));
      expect(
        catalog.packs.every((pack) => pack.reviewStatus.isLearnerReady),
        isTrue,
      );
      expect(report.expectedTopicIds, hasLength(125));
      expect(report.coveredTopicIds, hasLength(125));
      expect(lessons, hasLength(125));
      expect(report.unknownTopicIds, isEmpty);
      expect(report.duplicateTopicIds, isEmpty);
      expect(lessons.map((lesson) => lesson.topicId).toSet(), hasLength(125));
      expect(lessons.map((lesson) => lesson.order).toSet(), hasLength(125));
      expect(
        lessons.map((lesson) => lesson.order),
        orderedEquals(lessons.map((lesson) => lesson.order).toList()..sort()),
      );

      const requiredSectionTypes = {
        'explanation',
        'rule',
        'detection',
        'misconceptions',
        'summary',
      };
      const requiredWordFields = {
        'word',
        'normalizedWord',
        'wordType',
        'grammaticalRole',
        'grammaticalState',
        'grammaticalSign',
        'signReason',
        'grammaticalAgent',
        'sentencePosition',
        'explanation',
      };
      final globalExampleIds = <String>{};
      for (final entry in catalog.packs.where((pack) => pack.seedEnabled)) {
        final raw = await rootBundle.loadString(entry.assetPath);
        final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
        final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
        final exercises = (pack['exercises'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false);
        final exerciseIds = exercises
            .map((exercise) => exercise['id'] as String)
            .toSet();

        expect(manifest['contentVersion'], entry.contentVersion);
        for (final exercise in exercises) {
          expect(exercise['contentVersion'], entry.contentVersion);
        }
        for (final rawLesson in pack['lessons'] as List) {
          final lesson = Map<String, dynamic>.from(rawLesson as Map);
          final examples = (lesson['examples'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(growable: false);
          final lessonExerciseIds = List<String>.from(
            lesson['exerciseIds'] as List,
          );
          final masteryIds = List<String>.from(
            lesson['masteryExerciseIds'] as List,
          );
          final sectionTypes = (lesson['sections'] as List)
              .map((section) => (section as Map)['type'])
              .whereType<String>()
              .toSet();

          expect(lesson['contentVersion'], entry.contentVersion);
          expect(examples.length, greaterThanOrEqualTo(4));
          expect(lessonExerciseIds.length, greaterThanOrEqualTo(10));
          expect(masteryIds, hasLength(5));
          expect(exerciseIds.containsAll(lessonExerciseIds), isTrue);
          expect(lessonExerciseIds.toSet().containsAll(masteryIds), isTrue);
          expect((lesson['referenceIds'] as List), isNotEmpty);
          expect(sectionTypes.containsAll(requiredSectionTypes), isTrue);

          for (final example in examples) {
            expect(globalExampleIds.add(example['id'] as String), isTrue);
            expect((example['referenceIds'] as List), isNotEmpty);
            final sentence = example['sentence'] as String;
            for (final rawWord in example['parsedWords'] as List) {
              final word = Map<String, dynamic>.from(rawWord as Map);
              for (final field in requiredWordFields) {
                expect((word[field] as String).trim(), isNotEmpty);
              }
              final start = word['startIndex'] as int;
              final end = word['endIndex'] as int;
              expect(start, greaterThanOrEqualTo(0));
              expect(end, greaterThan(start));
              expect(end, lessThanOrEqualTo(sentence.length));
              expect(sentence.substring(start, end), word['word']);
            }
          }
        }
      }
    },
  );

  test('catalog versions match every pack manifest', () async {
    final result = await LocalContentPackCatalogRepository(
      bundle: rootBundle,
    ).getCatalog();
    final catalog = result.getOrElse(
      () => throw StateError('Expected content catalog.'),
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
