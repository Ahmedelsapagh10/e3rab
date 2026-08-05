import 'validation_report.dart';

part 'content_item_validator.dart';
part 'content_structure_validator.dart';

class ContentValidationService {
  const ContentValidationService();

  static const reviewStatuses = {
    'draft',
    'aiAssistedDraft',
    'inReview',
    'changesRequested',
    'sourceDocumented',
    'humanReviewed',
    'approved',
    'archived',
  };

  ValidationReport validate(Map<String, dynamic> pack) {
    final issues = <ValidationIssue>[];
    final manifest = _mapAt(pack, 'manifest', issues);
    _requireFields(
      manifest,
      const [
        'packId',
        'schemaVersion',
        'contentVersion',
        'curriculumVersion',
        'locale',
        'entityIds',
        'checksum',
        'minimumAppVersion',
        'reviewStatus',
      ],
      'manifest',
      issues,
    );

    final modules = _mapsAt(pack, 'modules', issues);
    final units = _mapsAt(pack, 'units', issues);
    final lessons = _mapsAt(pack, 'lessons', issues);
    final exercises = _mapsAt(pack, 'exercises', issues);
    final references = _mapsAt(pack, 'references', issues);

    final moduleIds = _uniqueIds(modules, 'modules', issues);
    final unitIds = _uniqueIds(units, 'units', issues);
    final lessonIds = _uniqueIds(lessons, 'lessons', issues);
    final exerciseIds = _uniqueIds(exercises, 'exercises', issues);
    final referenceIds = _uniqueIds(references, 'references', issues);
    _checkUniqueSlugs(lessons, issues);

    for (final unit in units) {
      _requireReference(unit, 'moduleId', moduleIds, 'units', issues);
    }
    for (final lesson in lessons) {
      _requireReference(lesson, 'unitId', unitIds, 'lessons', issues);
      _validateReviewStatus(lesson, 'lessons', issues);
      _validateApprovedLesson(lesson, exerciseIds, referenceIds, issues);
      _rejectHtml(lesson, 'title', 'lessons', issues);
    }
    _validatePrerequisiteGraph(lessons, lessonIds, issues);
    for (final exercise in exercises) {
      _requireReference(exercise, 'lessonId', lessonIds, 'exercises', issues);
      _validateReviewStatus(exercise, 'exercises', issues);
      _validateExercise(exercise, issues);
    }

    _validateReviewStatus(manifest, 'manifest', issues);

    final allIds = {...moduleIds, ...unitIds, ...lessonIds, ...exerciseIds};
    if (!_stringList(manifest['entityIds']).toSet().containsAll(allIds)) {
      issues.add(
        const ValidationIssue(
          code: 'manifest_missing_entities',
          message: 'Manifest entityIds must contain every packaged entity ID.',
          path: 'manifest.entityIds',
        ),
      );
    }
    return ValidationReport(List.unmodifiable(issues));
  }
}
