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

  test('accepts source-documented content without claiming human review', () {
    final pack = _validPack();
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    final exercises = pack['exercises'] as List;
    final entityIds = (pack['manifest'] as Map)['entityIds'] as List;
    for (var index = 2; index <= 10; index++) {
      final exercise = Map<String, dynamic>.from(
        exercises.first as Map<String, dynamic>,
      )..['id'] = 'exercise-$index';
      exercises.add(exercise);
      entityIds.add('exercise-$index');
    }
    lesson.addAll({
      'reviewStatus': 'sourceDocumented',
      'topicId': 'foundations.parts-of-speech',
      'order': 1,
      'objectives': ['تمييز أقسام الكلمة.'],
      'sections': _documentedSections,
      'examples': List.generate(4, _documentedExample),
      'exerciseIds': List.generate(10, (index) => 'exercise-${index + 1}'),
      'masteryExerciseIds': List.generate(
        5,
        (index) => 'exercise-${index + 1}',
      ),
      'referenceIds': ['reference-1'],
      'prerequisiteIds': <String>[],
    });

    final report = validator.validate(pack);

    expect(
      report.errors.map((issue) => issue.code),
      isNot(contains('missing_human_review')),
    );
    expect(report.isValid, isTrue, reason: report.errors.toString());
  });

  test('reviewed content requires stable topic identity and order', () {
    final pack = _validPack();
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    lesson.addAll({
      'reviewStatus': 'inReview',
      'objectives': ['تمييز أقسام الكلمة.'],
      'sections': _documentedSections,
      'examples': List.generate(4, _documentedExample),
      'exerciseIds': List.filled(10, 'exercise-1'),
      'masteryExerciseIds': List.filled(5, 'exercise-1'),
      'referenceIds': ['reference-1'],
      'prerequisiteIds': <String>[],
    });

    final report = validator.validate(pack);
    final codes = report.errors.map((issue) => issue.code);

    expect(codes, contains('missing_topic_id'));
    expect(codes, contains('invalid_lesson_order'));
  });

  test('rejects cyclic lesson prerequisites', () {
    final pack = _validPack();
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    lesson['prerequisiteIds'] = ['lesson-1'];

    final report = validator.validate(pack);

    expect(
      report.errors.map((issue) => issue.code),
      contains('cyclic_prerequisite'),
    );
  });

  test('accepts a declared cross-pack prerequisite', () {
    final pack = _validPack();
    final manifest = pack['manifest'] as Map<String, dynamic>;
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    manifest['externalPrerequisiteIds'] = ['published-lesson'];
    lesson['prerequisiteIds'] = ['published-lesson'];

    final report = validator.validate(pack);

    expect(report.errors, isEmpty);
  });

  test('rejects an undeclared cross-pack prerequisite', () {
    final pack = _validPack();
    final lesson = (pack['lessons'] as List).first as Map<String, dynamic>;
    lesson['prerequisiteIds'] = ['missing-lesson'];

    final report = validator.validate(pack);

    expect(
      report.errors.map((issue) => issue.code),
      contains('unknown_prerequisite'),
    );
  });
}

const _documentedSections = [
  {'id': 'section-1', 'type': 'explanation'},
  {'id': 'section-2', 'type': 'rule'},
  {'id': 'section-3', 'type': 'detection'},
  {'id': 'section-4', 'type': 'misconceptions'},
  {'id': 'section-5', 'type': 'summary'},
];

Map<String, dynamic> _documentedExample(int index) => {
  'id': 'example-${index + 1}',
  'sentence': 'العلم نور',
  'fullyDiacritizedSentence': 'العِلْمُ نُورٌ',
  'referenceIds': ['reference-1'],
  'parsedWords': [
    <String, dynamic>{
      'word': 'العلم',
      'normalizedWord': 'العلم',
      'wordType': 'اسم',
      'grammaticalRole': 'مبتدأ',
      'grammaticalState': 'مرفوع',
      'grammaticalSign': 'الضمة',
      'signReason': 'مفرد',
      'grammaticalAgent': 'الابتداء',
      'sentencePosition': 'طرف الإسناد الأول',
      'explanation': 'مبتدأ مرفوع.',
      'startIndex': 0,
      'endIndex': 5,
    },
  ],
};

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
