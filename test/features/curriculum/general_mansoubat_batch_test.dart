import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packAsset = 'assets/content/e3rab_general_mansoubat_batch1_v1.json';
  const coverageAsset = 'assets/content/e3rab_grammar_coverage_v2.json';
  const expectedTopics = [
    'mansoubat.object',
    'mansoubat.absolute-object',
    'mansoubat.causal-object',
    'mansoubat.adverbial-object',
    'mansoubat.accompaniment-object',
    'mansoubat.circumstantial',
    'mansoubat.specification',
    'mansoubat.exception',
    'mansoubat.vocative',
    'mansoubat.inna-name-kana-predicate',
  ];
  const sharedStyleTopics = [
    'styles.specialization',
    'styles.encouragement-warning',
  ];

  Future<Map<String, dynamic>> load(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  test('mansoubat review pack is valid, complete, and sequential', () async {
    final pack = await load(packAsset);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['reviewStatus'], 'inReview');
    expect(manifest['externalPrerequisiteIds'], [
      'marfouat-present-nominative-positions',
    ]);
    expect(module['order'], 7);
    expect(lessons, hasLength(10));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([600, 610, 620, 630, 640, 650, 660, 670, 680, 690]),
    );
    expect(lessons.first['prerequisiteIds'], [
      'marfouat-present-nominative-positions',
    ]);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'inReview');
      expect(lesson['reviewedBy'], isNull);
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test(
    'ten unique topics are owned here and shared styles stay deferred',
    () async {
      final pack = await load(packAsset);
      final coverage = await load(coverageAsset);
      final lessons = (pack['lessons'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
      final lessonTopics = lessons
          .map((lesson) => lesson['topicId'] as String)
          .toList(growable: false);
      final chapter = (coverage['tracks'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .singleWhere((item) => item['id'] == 'mansoubat');
      final chapterTopics = List<String>.from(chapter['topicIds'] as List);

      expect(lessonTopics, expectedTopics);
      expect(lessonTopics.toSet(), hasLength(expectedTopics.length));
      expect(chapterTopics.take(10), expectedTopics);
      expect(chapterTopics.skip(10), sharedStyleTopics);
      expect(lessonTopics, isNot(containsAll(sharedStyleTopics)));
    },
  );

  test('entity, example, and parsed word ranges are stable', () async {
    final pack = await load(packAsset);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final entityIds = List<String>.from(manifest['entityIds'] as List);
    final examples = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(entityIds.toSet(), hasLength(entityIds.length));
    expect(examples.map((item) => item['id']).toSet(), hasLength(40));
    for (final example in examples) {
      final sentence = example['sentence'] as String;
      for (final value in example['parsedWords'] as List) {
        final word = Map<String, dynamic>.from(value as Map);
        final start = word['startIndex'] as int;
        final end = word['endIndex'] as int;
        expect(sentence.substring(start, end), word['word']);
      }
    }
  });
}
