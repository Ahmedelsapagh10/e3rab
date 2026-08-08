import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const assetPath = 'assets/content/e3rab_general_nawasekh_batch1_v1.json';
  const coveragePath = 'assets/content/e3rab_grammar_coverage_v2.json';
  const topics = [
    'nawasekh.kana',
    'nawasekh.kada',
    'nawasekh.inna',
    'nawasekh.la-gender-negation',
    'nawasekh.zanna',
    'nawasekh.transformation-verbs',
    'nawasekh.ma-la-lata',
  ];

  Future<Map<String, dynamic>> load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('nawasekh pack is valid, reviewed safely, and sequential', () async {
    final pack = await load(assetPath);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], ['verbal-hidden-subject']);
    expect(manifest['reviewStatus'], 'inReview');
    expect(module['order'], 5);
    expect(lessons, hasLength(7));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([400, 410, 420, 430, 440, 450, 460]),
    );
    expect(lessons.first['prerequisiteIds'], ['verbal-hidden-subject']);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['id'], startsWith('nawasekh-'));
      expect(lesson['reviewStatus'], 'inReview');
      expect(lesson['reviewedBy'], isNull);
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
    expect(lessons.last['id'], 'nawasekh-ma-la-lata');
  });

  test('nawasekh lesson topics match coverage order', () async {
    final pack = await load(assetPath);
    final coverage = await load(coveragePath);
    final track = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'nawasekh');
    final lessonTopics = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toList(growable: false);

    expect(track['order'], 5);
    expect(track['topicIds'], topics);
    expect(lessonTopics, topics);
  });

  test('nawasekh entity and example IDs are unique', () async {
    final pack = await load(assetPath);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final entityIds = List<String>.from(manifest['entityIds'] as List);
    final examples = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .map((example) => Map<String, dynamic>.from(example as Map))
        .toList(growable: false);
    final exampleIds = examples.map((example) => example['id']).toList();

    expect(entityIds.toSet(), hasLength(entityIds.length));
    expect(exampleIds.toSet(), hasLength(exampleIds.length));
    expect(
      examples.every((item) => (item['parsedWords'] as List).isNotEmpty),
      isTrue,
    );
  });
}
