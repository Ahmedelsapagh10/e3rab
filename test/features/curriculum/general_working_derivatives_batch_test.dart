import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const path =
      'assets/content/e3rab_general_working_derivatives_batch1_v1.json';
  const topics = [
    'working-derivatives.active-participle',
    'working-derivatives.intensive-forms',
    'working-derivatives.passive-participle',
    'working-derivatives.resembling-adjective',
    'working-derivatives.comparative',
    'working-derivatives.governing-verbal-noun',
    'working-derivatives.verb-noun',
  ];
  test('working derivatives pack is valid, complete, and sequential', () async {
    final pack = Map<String, dynamic>.from(
      jsonDecode(await rootBundle.loadString(path)) as Map,
    );
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['externalPrerequisiteIds'], ['followers-apposition']);
    expect(module['order'], 11);
    expect(lessons.map((e) => e['topicId']), topics);
    expect(lessons.map((e) => e['order']), [
      1000,
      1010,
      1020,
      1030,
      1040,
      1050,
      1060,
    ]);
    expect(lessons.first['prerequisiteIds'], ['followers-apposition']);
    for (var i = 1; i < lessons.length; i++) {
      expect(lessons[i]['prerequisiteIds'], [lessons[i - 1]['id']]);
    }
    final exampleIds = <String>{};
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'sourceDocumented');
      expect(lesson['sections'], hasLength(9));
      expect(lesson['examples'], hasLength(4));
      expect(lesson['exerciseIds'], hasLength(10));
      expect(lesson['masteryExerciseIds'], hasLength(5));
      for (final raw in lesson['examples'] as List) {
        final example = Map<String, dynamic>.from(raw as Map);
        expect(exampleIds.add(example['id'] as String), isTrue);
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
