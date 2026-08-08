part of 'content_validation_service.dart';

extension _ContentReadinessValidator on ContentValidationService {
  void _validateLearnerReadyLesson(
    Map<String, dynamic> lesson,
    Set<String> exerciseIds,
    Set<String> referenceIds,
    List<ValidationIssue> issues,
  ) {
    final id = lesson['id'];
    final examples = _stringIdMaps(lesson['examples']);
    final practiceIds = _stringList(lesson['exerciseIds']);
    final masteryIds = _stringList(lesson['masteryExerciseIds']);
    if (examples.length < 4) {
      _readinessIssue(
        issues,
        'insufficient_worked_examples',
        'Learner-ready lessons require at least four parsed examples.',
        'lessons.$id.examples',
      );
    }
    if (practiceIds.length < 10) {
      _readinessIssue(
        issues,
        'insufficient_independent_practice',
        'Learner-ready lessons require at least ten practice exercises.',
        'lessons.$id.exerciseIds',
      );
    }
    if (masteryIds.length != 5 ||
        !exerciseIds.containsAll(masteryIds) ||
        !practiceIds.toSet().containsAll(masteryIds)) {
      _readinessIssue(
        issues,
        'invalid_mastery_check',
        'A mastery check requires five valid deterministic exercise IDs.',
        'lessons.$id.masteryExerciseIds',
      );
    }
    _validateRequiredSections(lesson, issues);
    _validateExamples(lesson, examples, referenceIds, issues);
  }

  void _validateRequiredSections(
    Map<String, dynamic> lesson,
    List<ValidationIssue> issues,
  ) {
    final types = _stringIdMaps(
      lesson['sections'],
    ).map((item) => item['type']).whereType<String>().toSet();
    const required = {
      'explanation',
      'rule',
      'detection',
      'misconceptions',
      'summary',
    };
    if (!types.containsAll(required)) {
      _readinessIssue(
        issues,
        'missing_lesson_sections',
        'Learner-ready lessons require rule, detection, mistakes, and summary.',
        'lessons.${lesson['id']}.sections',
      );
    }
  }

  void _validateExamples(
    Map<String, dynamic> lesson,
    List<Map<String, dynamic>> examples,
    Set<String> referenceIds,
    List<ValidationIssue> issues,
  ) {
    final ids = <String>{};
    for (final example in examples) {
      final id = example['id'] as String;
      final refs = _stringList(example['referenceIds']);
      final parsedWords = _stringIdMapsWithWord(example['parsedWords']);
      if (!ids.add(id)) {
        _readinessIssue(
          issues,
          'duplicate_example_id',
          'Every parsed example requires a unique stable ID.',
          'lessons.${lesson['id']}.examples.$id',
        );
      }
      if (refs.isEmpty || !referenceIds.containsAll(refs)) {
        _readinessIssue(
          issues,
          'invalid_example_references',
          'Every parsed example requires packaged references.',
          'lessons.${lesson['id']}.examples.$id.referenceIds',
        );
      }
      if (parsedWords.isEmpty ||
          parsedWords.any((word) => !_isCompleteParsedWord(word))) {
        _readinessIssue(
          issues,
          'incomplete_parsed_example',
          'Every example requires complete word parsing metadata.',
          'lessons.${lesson['id']}.examples.$id.parsedWords',
        );
      }
    }
  }

  List<Map<String, dynamic>> _stringIdMapsWithWord(Object? value) =>
      value is List
      ? value.whereType<Map<String, dynamic>>().where((item) {
          return (item['word'] as String?)?.trim().isNotEmpty == true;
        }).toList()
      : const [];

  bool _isCompleteParsedWord(Map<String, dynamic> word) {
    const fields = {
      'word',
      'normalizedWord',
      'wordType',
      'grammaticalRole',
      'grammaticalState',
      'grammaticalSign',
      'signReason',
      'explanation',
    };
    return fields.every(
          (field) => (word[field] as String?)?.trim().isNotEmpty == true,
        ) &&
        word['startIndex'] is int &&
        word['endIndex'] is int &&
        (word['endIndex'] as int) > (word['startIndex'] as int);
  }

  void _readinessIssue(
    List<ValidationIssue> issues,
    String code,
    String message,
    String path,
  ) {
    issues.add(ValidationIssue(code: code, message: message, path: path));
  }
}
