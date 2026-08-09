import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asset =
      'assets/content/e3rab_general_sentence_positions_batch1_v1.json';
  const coverage = 'assets/content/e3rab_grammar_coverage_v2.json';
  const vertical = 'assets/content/e3rab_vertical_slice_v1.json';
  const newTopics = [
    'sentence-positions.without-position',
    'sentence-positions.predicate-clause',
    'sentence-positions.circumstantial-clause',
    'sentence-positions.adjective-clause',
    'sentence-positions.genitive-clause',
    'sentence-positions.conditional-answer',
    'sentence-positions.subordinate-clause',
  ];

  Future<Map<String, dynamic>> load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('sentence positions pack validates with ordered dependencies', () async {
    final pack = await load(asset);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], [
      'sentences-with-syntactic-position',
    ]);
    expect(module['order'], 13);
    expect(lessons, hasLength(7));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([1210, 1220, 1230, 1240, 1250, 1260, 1270]),
    );
    expect(lessons.first['prerequisiteIds'], [
      'sentences-with-syntactic-position',
    ]);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'sourceDocumented');
      expect((lesson['sections'] as List), hasLength(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('existing and new lessons cover all sentence position topics', () async {
    final pack = await load(asset);
    final map = await load(coverage);
    final existing = await load(vertical);
    final track = (map['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'sentence_positions');
    final existingTopics = (existing['lessons'] as List).map(
      (lesson) => (lesson as Map)['topicId'],
    );
    final lessonTopics = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toList(growable: false);

    expect(lessonTopics, newTopics);
    expect(existingTopics, contains('sentence-positions.with-position'));
    expect(track['topicIds'], [
      'sentence-positions.with-position',
      ...newTopics,
    ]);
  });

  test('example IDs and sentence positions are complete', () async {
    final pack = await load(asset);
    final examples = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .map((example) => Map<String, dynamic>.from(example as Map))
        .toList(growable: false);
    final ids = examples.map((example) => example['id']).toSet();

    expect(ids, hasLength(28));
    for (final example in examples) {
      final words = (example['parsedWords'] as List).cast<Map>();
      expect(words, isNotEmpty);
      expect(
        words.every((word) => '${word['sentencePosition']}'.isNotEmpty),
        isTrue,
      );
    }
  });
}
