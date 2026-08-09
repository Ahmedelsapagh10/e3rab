import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assetPath = 'assets/content/e3rab_general_marfouat_batch1_v1.json';
  const coveragePath = 'assets/content/e3rab_grammar_coverage_v2.json';
  const sharedPath = 'assets/content/e3rab_vertical_slice_v1.json';
  const expectedTopics = [
    'nominal.subject-predicate',
    'marfouat.kana-name-inna-predicate',
    'marfouat.subject-passive-subject',
    'marfouat.nominative-follower',
    'marfouat.present-nominative-positions',
  ];

  Future<Map<String, dynamic>> load(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  test('marfouat review pack is valid and sequential', () async {
    final pack = await load(assetPath);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], ['nawasekh-ma-la-lata']);
    expect(module['order'], 6);
    expect(lessons, hasLength(4));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([510, 520, 530, 540]),
    );
    expect(lessons.first['prerequisiteIds'], ['nawasekh-ma-la-lata']);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'sourceDocumented');
      expect((lesson['sections'] as List).length, greaterThanOrEqualTo(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('marfouat coverage reuses the shared nominal lesson', () async {
    final pack = await load(assetPath);
    final shared = await load(sharedPath);
    final coverage = await load(coveragePath);
    final track = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'marfouat');
    final localTopics = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'] as String)
        .toList(growable: false);
    final sharedTopics = (shared['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toSet();

    expect(track['topicIds'], expectedTopics);
    expect(sharedTopics, contains(expectedTopics.first));
    expect(localTopics, expectedTopics.skip(1));
    expect(localTopics, isNot(contains(expectedTopics.first)));
  });

  test('marfouat examples have unique IDs and exact word offsets', () async {
    final pack = await load(assetPath);
    final ids = <String>{};
    for (final rawLesson in pack['lessons'] as List) {
      final lesson = Map<String, dynamic>.from(rawLesson as Map);
      for (final rawExample in lesson['examples'] as List) {
        final example = Map<String, dynamic>.from(rawExample as Map);
        expect(ids.add(example['id'] as String), isTrue);
        final sentence = example['sentence'] as String;
        for (final rawWord in example['parsedWords'] as List) {
          final word = Map<String, dynamic>.from(rawWord as Map);
          expect((word['grammaticalAgent'] as String).trim(), isNotEmpty);
          expect((word['sentencePosition'] as String).trim(), isNotEmpty);
          expect(
            sentence.substring(
              word['startIndex'] as int,
              word['endIndex'] as int,
            ),
            word['word'],
          );
        }
      }
    }
  });
}
