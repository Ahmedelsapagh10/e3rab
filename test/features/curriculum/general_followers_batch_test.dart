import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const assetPath = 'assets/content/e3rab_general_followers_batch1_v1.json';
  const coveragePath = 'assets/content/e3rab_grammar_coverage_v2.json';
  const topics = [
    'followers.adjective',
    'followers.conjunction',
    'followers.explanatory-apposition',
    'followers.emphasis',
    'followers.apposition',
  ];

  Future<Map<String, dynamic>> load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('followers pack is valid and sequential', () async {
    final pack = await load(assetPath);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], ['majzoumat-condition-oath']);
    expect(manifest['reviewStatus'], 'inReview');
    expect(module['order'], 10);
    expect(lessons, hasLength(5));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([900, 910, 920, 930, 940]),
    );
    expect(lessons.first['prerequisiteIds'], ['majzoumat-condition-oath']);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['id'], startsWith('followers-'));
      expect(lesson['reviewStatus'], 'inReview');
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('followers topic IDs match comprehensive coverage', () async {
    final pack = await load(assetPath);
    final coverage = await load(coveragePath);
    final track = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'followers');
    final lessonTopics = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toList(growable: false);

    expect(track['order'], 10);
    expect(track['topicIds'], topics);
    expect(lessonTopics, topics);
  });

  test('followers entity and parsed example IDs are unique', () async {
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
      examples.every((example) => (example['parsedWords'] as List).isNotEmpty),
      isTrue,
    );
  });
}
