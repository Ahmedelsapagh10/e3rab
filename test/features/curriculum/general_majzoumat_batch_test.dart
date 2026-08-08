import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const assetPath = 'assets/content/e3rab_general_majzoumat_batch1_v1.json';
  const coveragePath = 'assets/content/e3rab_grammar_coverage_v2.json';
  const expectedTopics = [
    'majzoumat.single-jussive',
    'majzoumat.double-jussive',
    'majzoumat.conditional-tools',
    'majzoumat.conditional-answer-fa',
    'majzoumat.condition-oath',
  ];

  Future<Map<String, dynamic>> load(String path) async =>
      Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(path)) as Map,
      );

  test('majzoumat review pack is valid with explicit dependencies', () async {
    final pack = await load(assetPath);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], [
      'majrourat-genitive-types',
      'jussive-answer-request-v1',
    ]);
    expect(module['order'], 9);
    expect(lessons.map((item) => item['topicId']), expectedTopics);
    expect(lessons.map((item) => item['order']), [800, 810, 820, 830, 850]);
    expect(lessons.first['prerequisiteIds'], ['majrourat-genitive-types']);
    expect(lessons.last['prerequisiteIds'], ['jussive-answer-request-v1']);
    for (var index = 1; index < 4; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect((lesson['sections'] as List), hasLength(9));
      expect((lesson['examples'] as List), hasLength(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
      expect(lesson['reviewStatus'], 'inReview');
    }
  });

  test('new lessons plus shared answer-to-request cover the chapter', () async {
    final pack = await load(assetPath);
    final coverage = await load(coveragePath);
    final track = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'majzoumat');
    final topics =
        (pack['lessons'] as List)
            .map((item) => (item as Map)['topicId'] as String)
            .toSet()
          ..add('majzoumat.answer-to-request');

    expect(topics, track['topicIds'].toSet());
    expect(
      (pack['lessons'] as List).map((item) => (item as Map)['id']),
      isNot(contains('jussive-answer-request-v1')),
    );
  });

  test('parsed words use exact offsets and unique example IDs', () async {
    final pack = await load(assetPath);
    final ids = <String>{};
    for (final lesson in pack['lessons'] as List) {
      for (final rawExample in (lesson as Map)['examples'] as List) {
        final example = Map<String, dynamic>.from(rawExample as Map);
        expect(ids.add(example['id'] as String), isTrue);
        final sentence = example['sentence'] as String;
        for (final rawWord in example['parsedWords'] as List) {
          final word = Map<String, dynamic>.from(rawWord as Map);
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
