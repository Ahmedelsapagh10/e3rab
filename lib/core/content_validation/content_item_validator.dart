part of 'content_validation_service.dart';

extension _ContentItemValidator on ContentValidationService {
  void _validateApprovedLesson(
    Map<String, dynamic> lesson,
    Set<String> exerciseIds,
    Set<String> referenceIds,
    List<ValidationIssue> issues,
  ) {
    if (!const {
      'sourceDocumented',
      'humanReviewed',
      'approved',
    }.contains(lesson['reviewStatus'])) {
      return;
    }
    final requiredLists = [
      'objectives',
      'examples',
      'exerciseIds',
      'referenceIds',
    ];
    for (final field in requiredLists) {
      if ((lesson[field] as List?)?.isNotEmpty != true) {
        issues.add(
          ValidationIssue(
            code: 'incomplete_approved_lesson',
            message: 'Approved lessons require a non-empty $field.',
            path: 'lessons.${lesson['id']}.$field',
          ),
        );
      }
    }
    if (const {'humanReviewed', 'approved'}.contains(lesson['reviewStatus']) &&
        ((lesson['reviewedBy'] as String?)?.trim().isEmpty != false ||
            lesson['reviewedAt'] == null)) {
      issues.add(
        ValidationIssue(
          code: 'missing_human_review',
          message:
              'Approved lessons require reviewer identity and review date.',
          path: 'lessons.${lesson['id']}.review',
        ),
      );
    }
    _validateIdList(lesson, 'exerciseIds', exerciseIds, issues);
    _validateIdList(lesson, 'referenceIds', referenceIds, issues);
    _validatePrerequisiteShape(lesson, issues);
    _validateLessonSteps(lesson, referenceIds, issues);
  }

  void _validatePrerequisiteShape(
    Map<String, dynamic> lesson,
    List<ValidationIssue> issues,
  ) {
    if (lesson['prerequisiteIds'] is! List) {
      issues.add(
        ValidationIssue(
          code: 'invalid_prerequisites',
          message: 'prerequisiteIds must be a list.',
          path: 'lessons.${lesson['id']}.prerequisiteIds',
        ),
      );
    }
  }

  void _validateLessonSteps(
    Map<String, dynamic> lesson,
    Set<String> referenceIds,
    List<ValidationIssue> issues,
  ) {
    final steps = _stringIdMaps(lesson['steps']);
    if (lesson.containsKey('steps') && steps.isEmpty) {
      issues.add(
        ValidationIssue(
          code: 'empty_lesson_steps',
          message: 'A documented steps field must contain lesson steps.',
          path: 'lessons.${lesson['id']}.steps',
        ),
      );
    }
    final citationIds = _stringIdMaps(
      lesson['citations'],
    ).map((item) => item['id']).whereType<String>().toSet();
    for (final citation in _stringIdMaps(lesson['citations'])) {
      if (!referenceIds.contains(citation['referenceId'])) {
        issues.add(
          ValidationIssue(
            code: 'unknown_citation_reference',
            message: 'Citation must point to a packaged reference.',
            path: 'lessons.${lesson['id']}.citations.${citation['id']}',
          ),
        );
      }
    }
    for (final step in steps) {
      for (final block in _stringIdMaps(step['blocks'])) {
        if (!citationIds.containsAll(_stringList(block['citationIds']))) {
          issues.add(
            ValidationIssue(
              code: 'unknown_block_citation',
              message: 'Content block contains an unknown citation.',
              path: 'lessons.${lesson['id']}.steps.${step['id']}',
            ),
          );
        }
      }
    }
  }

  void _validateExercise(
    Map<String, dynamic> exercise,
    List<ValidationIssue> issues,
  ) {
    final options = _stringIdMaps(exercise['options']);
    final optionIds = options.map((option) => option['id'] as String).toSet();
    final correctIds = _stringList(exercise['correctAnswerIds']);
    if (correctIds.isEmpty || !optionIds.containsAll(correctIds)) {
      issues.add(
        ValidationIssue(
          code: 'invalid_correct_answer',
          message: 'Correct answers must reference existing options.',
          path: 'exercises.${exercise['id']}.correctAnswerIds',
        ),
      );
    }
    for (final option in options) {
      if ((option['feedback'] as String?)?.trim().isEmpty != false) {
        issues.add(
          ValidationIssue(
            code: 'missing_option_feedback',
            message: 'Every option requires useful feedback.',
            path: 'exercises.${exercise['id']}.options.${option['id']}',
          ),
        );
      }
    }
  }

  void _validateReviewStatus(
    Map<String, dynamic> item,
    String path,
    List<ValidationIssue> issues,
  ) {
    if (!ContentValidationService.reviewStatuses.contains(
      item['reviewStatus'],
    )) {
      issues.add(
        ValidationIssue(
          code: 'invalid_review_status',
          message: 'Unsupported content review status.',
          path: '$path.${item['id']}.reviewStatus',
        ),
      );
    }
  }

  void _validateIdList(
    Map<String, dynamic> item,
    String field,
    Set<String> validIds,
    List<ValidationIssue> issues,
  ) {
    if (!validIds.containsAll(_stringList(item[field]))) {
      issues.add(
        ValidationIssue(
          code: 'invalid_reference_list',
          message: '$field contains an unknown ID.',
          path: 'lessons.${item['id']}.$field',
        ),
      );
    }
  }

  List<String> _stringList(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  List<Map<String, dynamic>> _stringIdMaps(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().where((item) {
          return item['id'] is String;
        }).toList()
      : const [];
}
