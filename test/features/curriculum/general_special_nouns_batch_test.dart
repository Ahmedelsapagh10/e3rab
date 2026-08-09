import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asset = 'assets/content/e3rab_general_special_nouns_batch1_v1.json';
  const coverage = 'assets/content/e3rab_grammar_coverage_v2.json';
  const topics = [
    'special-nouns.relative',
    'special-nouns.demonstrative',
    'special-nouns.pronouns',
    'special-nouns.conditional',
    'special-nouns.interrogative',
    'special-nouns.built-adverbs',
    'special-nouns.kam-kayyin-kadha',
  ];

  Future<Map<String, dynamic>> load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('special nouns pack validates with ordered dependencies', () async {
    final pack = await load(asset);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], ['numbers-euphemisms']);
    expect(module['order'], 17);
    expect(lessons, hasLength(7));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([1600, 1610, 1620, 1630, 1640, 1650, 1660]),
    );
    expect(lessons.first['prerequisiteIds'], ['numbers-euphemisms']);
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

  test('special noun topics match coverage order', () async {
    final pack = await load(asset);
    final map = await load(coverage);
    final track = (map['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'special_nouns');
    final actual = (pack['lessons'] as List)
        .map((lesson) => (lesson as Map)['topicId'])
        .toList(growable: false);
    expect(track['order'], 17);
    expect(track['topicIds'], topics);
    expect(actual, topics);
  });

  test('all parsed-word offsets are inside their sentence', () async {
    final pack = await load(asset);
    final examples = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .cast<Map>();
    final ids = <Object?>{};
    for (final example in examples) {
      expect(ids.add(example['id']), isTrue);
      final sentence = example['sentence'] as String;
      for (final word in (example['parsedWords'] as List).cast<Map>()) {
        final start = word['startIndex'] as int;
        final end = word['endIndex'] as int;
        expect(start, inInclusiveRange(0, sentence.length - 1));
        expect(end, inInclusiveRange(start + 1, sentence.length));
        expect(sentence.substring(start, end), word['word']);
      }
    }
    expect(ids, hasLength(28));
  });
}
