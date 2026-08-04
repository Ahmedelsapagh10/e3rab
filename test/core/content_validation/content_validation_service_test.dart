import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/content_validation/content_validation_service.dart';

void main() {
  const validator = ContentValidationService();

  test('accepts a structurally valid draft content pack', () {
    final report = validator.validate(_validPack());

    expect(report.isValid, isTrue, reason: report.errors.toString());
    expect(report.errors, isEmpty);
  });

  test('rejects incomplete approved content and invalid answers', () {
    final pack = _validPack();
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    lesson['reviewStatus'] = 'approved';
    lesson['objectives'] = <String>[];
    lesson['examples'] = <Object>[];
    lesson['exerciseIds'] = <String>[];
    lesson['referenceIds'] = <String>[];
    final exercise = (pack['exercises'] as List).first as Map<String, dynamic>;
    exercise['correctAnswerIds'] = ['missing-option'];

    final report = validator.validate(pack);
    final codes = report.errors.map((issue) => issue.code).toSet();

    expect(report.isValid, isFalse);
    expect(codes, contains('incomplete_approved_lesson'));
    expect(codes, contains('missing_human_review'));
    expect(codes, contains('invalid_correct_answer'));
  });
}

Map<String, dynamic> _validPack() => {
  'manifest': <String, dynamic>{
    'packId': 'foundation-ar-v1',
    'schemaVersion': 1,
    'contentVersion': '1.0.0',
    'curriculumVersion': 'egypt-general-v1',
    'locale': 'ar',
    'entityIds': ['module-1', 'unit-1', 'lesson-1', 'exercise-1'],
    'checksum': 'test-checksum',
    'minimumAppVersion': '1.0.0',
    'reviewStatus': 'draft',
  },
  'modules': [
    <String, dynamic>{
      'id': 'module-1',
      'slug': 'foundation',
      'title': 'التأسيس',
    },
  ],
  'units': [
    <String, dynamic>{
      'id': 'unit-1',
      'moduleId': 'module-1',
      'slug': 'word-basics',
      'title': 'أساسيات الكلمة',
    },
  ],
  'lessons': [
    <String, dynamic>{
      'id': 'lesson-1',
      'unitId': 'unit-1',
      'slug': 'parts-of-speech',
      'title': 'أقسام الكلمة',
      'reviewStatus': 'draft',
    },
  ],
  'exercises': [
    <String, dynamic>{
      'id': 'exercise-1',
      'lessonId': 'lesson-1',
      'reviewStatus': 'draft',
      'options': [
        <String, dynamic>{
          'id': 'option-1',
          'text': 'اسم',
          'feedback': 'إجابة صحيحة.',
        },
        <String, dynamic>{
          'id': 'option-2',
          'text': 'فعل',
          'feedback': 'راجع علامات الاسم.',
        },
      ],
      'correctAnswerIds': ['option-1'],
    },
  ],
  'references': [
    <String, dynamic>{'id': 'reference-1', 'title': 'مرجع تجريبي'},
  ],
};
