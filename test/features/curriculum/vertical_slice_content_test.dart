import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'vertical slice pack is valid and contains three complete lessons',
    () async {
      final raw = await rootBundle.loadString(
        'assets/content/e3rab_vertical_slice_v1.json',
      );
      final pack = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final report = const ContentValidationService().validate(pack);
      final lessons = (pack['lessons'] as List).cast<Map<String, dynamic>>();
      final exercises = (pack['exercises'] as List)
          .cast<Map<String, dynamic>>();

      expect(report.isValid, isTrue, reason: report.errors.toString());
      expect(lessons, hasLength(3));
      expect(exercises, hasLength(30));
      expect(
        lessons.every((lesson) => (lesson['exerciseIds'] as List).length == 10),
        isTrue,
      );
      expect(
        lessons.every((lesson) => (lesson['examples'] as List).length >= 3),
        isTrue,
      );
      expect(
        lessons.every((lesson) => lesson['reviewStatus'] == 'sourceDocumented'),
        isTrue,
      );
      expect(
        exercises.every(
          (exercise) => (exercise['options'] as List).every(
            (option) => (option as Map)['feedback'].toString().isNotEmpty,
          ),
        ),
        isTrue,
      );
    },
  );

  test('local repository searches normalized Arabic lesson content', () async {
    final repository = LocalCurriculumRepository(
      AssetCurriculumDataSource(bundle: rootBundle),
    );

    final result = await repository.search('المبتدأ');
    final lessons = result.getOrElse(() => const []);

    expect(lessons, isNotEmpty);
    expect(lessons.first.lesson.id, 'nominal-sentence');
  });
}
