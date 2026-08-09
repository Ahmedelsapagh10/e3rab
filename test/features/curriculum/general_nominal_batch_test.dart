import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const nominalAsset = 'assets/content/e3rab_general_nominal_batch1_v1.json';
  const verticalAsset = 'assets/content/e3rab_vertical_slice_v1.json';
  const coverageAsset = 'assets/content/e3rab_grammar_coverage_v2.json';
  const expectedTopics = [
    'nominal.subject-predicate',
    'nominal.subject-forms',
    'nominal.predicate-forms',
    'nominal.predicate-order',
    'nominal.subject-predicate-ellipsis',
    'nominal.multiple-predicates',
    'nominal.descriptive-subject',
  ];

  Future<Map<String, dynamic>> load(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  test('nominal review pack is structurally valid and sequential', () async {
    final pack = await load(nominalAsset);
    final report = const ContentValidationService().validate(pack);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final module = Map<String, dynamic>.from((pack['modules'] as List).single);
    final lessons = (pack['lessons'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(manifest['reviewStatus'], 'sourceDocumented');
    expect(manifest['externalPrerequisiteIds'], ['nominal-sentence']);
    expect(module['order'], 3);
    expect(lessons, hasLength(6));
    expect(
      lessons.map((lesson) => lesson['order']),
      orderedEquals([210, 220, 230, 240, 250, 260]),
    );
    expect(lessons.first['prerequisiteIds'], ['nominal-sentence']);
    for (var index = 1; index < lessons.length; index++) {
      expect(lessons[index]['prerequisiteIds'], [lessons[index - 1]['id']]);
    }
    for (final lesson in lessons) {
      expect(lesson['reviewStatus'], 'sourceDocumented');
      expect(lesson['reviewedBy'], isNull);
      expect((lesson['sections'] as List), hasLength(9));
      expect((lesson['examples'] as List).length, greaterThanOrEqualTo(4));
      expect((lesson['exerciseIds'] as List), hasLength(10));
      expect((lesson['masteryExerciseIds'] as List), hasLength(5));
    }
  });

  test('seven nominal topics are covered once in curriculum order', () async {
    final coverage = await load(coverageAsset);
    final vertical = await load(verticalAsset);
    final nominal = await load(nominalAsset);
    final chapter = (coverage['tracks'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .singleWhere((item) => item['id'] == 'nominal');
    final lessons = [
      ...(vertical['lessons'] as List),
      ...(nominal['lessons'] as List),
    ].map((item) => Map<String, dynamic>.from(item as Map));
    final lessonTopics = lessons.map((lesson) => lesson['topicId']).toList();

    expect(chapter['topics'], [
      'المبتدأ والخبر',
      'صور المبتدأ',
      'صور الخبر',
      'تقديم الخبر وتأخيره',
      'حذف المبتدأ والخبر',
      'تعدد الخبر',
      'المبتدأ الوصف',
    ]);
    expect(chapter['topicIds'], expectedTopics);
    for (final topicId in expectedTopics) {
      expect(
        lessonTopics.where((candidate) => candidate == topicId),
        hasLength(1),
        reason: 'Expected one lesson for $topicId.',
      );
    }
  });

  test('all nominal entity and example IDs are unique', () async {
    final pack = await load(nominalAsset);
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final entityIds = List<String>.from(manifest['entityIds'] as List);
    final exampleIds = (pack['lessons'] as List)
        .expand((lesson) => (lesson as Map)['examples'] as List)
        .map((example) => (example as Map)['id'] as String)
        .toList(growable: false);

    expect(entityIds.toSet(), hasLength(entityIds.length));
    expect(exampleIds.toSet(), hasLength(exampleIds.length));
  });
}
