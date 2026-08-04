part of 'content_validation_service.dart';

extension _ContentItemValidator on ContentValidationService {
  void _validateApprovedLesson(
    Map<String, dynamic> lesson,
    Set<String> exerciseIds,
    Set<String> referenceIds,
    List<ValidationIssue> issues,
  ) {
    if (lesson['reviewStatus'] != 'approved') return;
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
    if ((lesson['reviewedBy'] as String?)?.trim().isEmpty != false ||
        lesson['reviewedAt'] == null) {
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
