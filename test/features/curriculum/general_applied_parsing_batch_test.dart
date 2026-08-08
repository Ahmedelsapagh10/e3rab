import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const asset = 'assets/content/e3rab_general_applied_parsing_batch1_v1.json';
  const expectedIds = [
    'applied-parsing-word-type',
    'applied-parsing-role-governor',
    'applied-parsing-state-sign',
    'applied-parsing-sign-reason',
    'applied-parsing-nominal-sentence',
    'applied-parsing-verbal-sentence',
    'applied-parsing-texts',
    'applied-parsing-error-correction',
  ];
  const expectedTopics = [
    'applied-parsing.word-type',
    'applied-parsing.role-governor',
    'applied-parsing.state-sign',
    'applied-parsing.sign-reason',
    'applied-parsing.nominal-sentence',
    'applied-parsing.verbal-sentence',
    'applied-parsing.texts',
    'applied-parsing.error-correction',
  ];

  Future<Map<String, dynamic>> load() async {
    final raw = await rootBundle.loadString(asset);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  test('applied parsing review pack is valid and complete', () async {
    final pack = await load();
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['reviewStatus'], 'inReview');
    expect(manifest['externalPrerequisiteIds'], [
      'special-nouns-kam-kayyin-kadha',
    ]);
    expect(module['order'], 18);
    expect((pack['units'] as List), hasLength(8));
    expect(lessons, hasLength(8));
    expect((pack['exercises'] as List), hasLength(80));
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'inReview');
      expect(lesson['reviewedBy'], isNull);
      expect((lesson['sections'] as List), hasLength(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
      expect((lesson['referenceIds'] as List), hasLength(2));
    }
  });

  test('ids, topics, orders, and dependencies follow final chapter', () async {
    final pack = await load();
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(lessons.map((lesson) => lesson['id']), expectedIds);
    expect(lessons.map((lesson) => lesson['topicId']), expectedTopics);
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([1700, 1710, 1720, 1730, 1740, 1750, 1760, 1770]),
    );
    expect(lessons.first['prerequisiteIds'], [
      'special-nouns-kam-kayyin-kadha',
    ]);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
  });

  test('entity IDs, examples, and every word offset are stable', () async {
    final pack = await load();
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final entityIds = List<String>.from(manifest['entityIds'] as List);
    final examples = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(entityIds.toSet(), hasLength(entityIds.length));
    expect(examples.map((item) => item['id']).toSet(), hasLength(32));
    for (final example in examples) {
      final sentence = example['sentence'] as String;
      for (final value in example['parsedWords'] as List) {
        final parsedWord = Map<String, dynamic>.from(value as Map);
        final start = parsedWord['startIndex'] as int;
        final end = parsedWord['endIndex'] as int;
        expect(sentence.substring(start, end), parsedWord['word']);
        for (final field in const [
          'wordType',
          'grammaticalRole',
          'grammaticalAgent',
          'grammaticalState',
          'grammaticalSign',
          'signReason',
        ]) {
          expect((parsedWord[field] as String).trim(), isNotEmpty);
        }
      }
    }
  });
}
