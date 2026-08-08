import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const path = 'assets/content/e3rab_general_styles_batch1_v1.json';
  const topics = [
    'styles.question',
    'styles.negation',
    'styles.exception',
    'styles.vocative',
    'styles.exclamation',
    'styles.praise-blame',
    'styles.oath',
    'styles.condition',
    'styles.encouragement-warning',
    'styles.specialization',
  ];
  test('styles pack is valid, sequential, and reusable', () async {
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
    expect(manifest['externalPrerequisiteIds'], [
      'working-derivatives-verb-noun',
    ]);
    expect(module['order'], 12);
    expect(lessons.map((e) => e['topicId']), topics);
    expect(lessons.map((e) => e['order']), [
      1100,
      1110,
      1120,
      1130,
      1140,
      1150,
      1160,
      1170,
      1180,
      1190,
    ]);
    expect(lessons.first['prerequisiteIds'], ['working-derivatives-verb-noun']);
    for (var i = 1; i < lessons.length; i++) {
      expect(lessons[i]['prerequisiteIds'], [lessons[i - 1]['id']]);
    }
    expect(lessons[8]['id'], 'styles-encouragement-warning');
    expect(lessons[9]['id'], 'styles-specialization');
    final ids = <String>{};
    for (final lesson in lessons) {
      expect(lesson['sections'], hasLength(9));
      expect(lesson['examples'], hasLength(4));
      expect(lesson['exerciseIds'], hasLength(10));
      expect(lesson['masteryExerciseIds'], hasLength(5));
      expect(lesson['reviewStatus'], 'inReview');
      for (final raw in lesson['examples'] as List) {
        final e = Map<String, dynamic>.from(raw as Map);
        expect(ids.add(e['id'] as String), isTrue);
        final s = e['sentence'] as String;
        for (final rw in e['parsedWords'] as List) {
          final w = Map<String, dynamic>.from(rw as Map);
          expect(
            s.substring(w['startIndex'] as int, w['endIndex'] as int),
            w['word'],
          );
        }
      }
    }
  });
}
