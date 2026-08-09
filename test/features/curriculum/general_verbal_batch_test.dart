import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetPath = 'assets/content/e3rab_general_verbal_batch1_v1.json';
  const coveragePath = 'assets/content/e3rab_grammar_coverage_v2.json';
  const expectedTopics = [
    'verbal.past-verb',
    'verbal.present-verb',
    'verbal.imperative-verb',
    'verbal.subject',
    'verbal.passive-subject',
    'verbal.gender-agreement',
    'verbal.subject-order',
    'verbal.hidden-subject',
  ];

  Future<Map<String, dynamic>> load(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  test('verbal review pack is structurally valid and sequential', () async {
    final pack = await load(assetPath);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final units = (pack['units'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['reviewStatus'], 'sourceDocumented');
    expect(manifest['externalPrerequisiteIds'], [
      'nominal-descriptive-subject',
    ]);
    expect(module['order'], 4);
    expect(units, hasLength(8));
    expect(lessons, hasLength(8));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([300, 310, 320, 330, 340, 350, 360, 370]),
    );
    expect(lessons.first['prerequisiteIds'], ['nominal-descriptive-subject']);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'sourceDocumented');
      expect(lesson['reviewedBy'], isNull);
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(9));
      expect((lesson['examples'] as List).length, greaterThanOrEqualTo(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('verbal topics match comprehensive coverage order', () async {
    final pack = await load(assetPath);
    final coverage = await load(coveragePath);
    final track = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'verbal');
    final lessonTopics = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toList(growable: false);

    expect(track['order'], 4);
    expect(track['topicIds'], expectedTopics);
    expect(lessonTopics, expectedTopics);
  });

  test('verbal entity and parsed example IDs are unique', () async {
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
    for (final example in examples) {
      expect((example['parsedWords'] as List), isNotEmpty);
    }
  });
}
