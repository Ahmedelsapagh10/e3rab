class CurriculumMatrixValidator {
  const CurriculumMatrixValidator();

  static const _statuses = {
    'draft',
    'aiAssistedDraft',
    'inReview',
    'changesRequested',
    'approved',
    'archived',
  };

  bool isValid(Map<String, dynamic> matrix) {
    final curriculum = matrix['curriculum'];
    final mappings = matrix['mappings'];
    if (matrix['schemaVersion'] is! int ||
        curriculum is! Map<String, dynamic> ||
        mappings is! List ||
        mappings.isEmpty) {
      return false;
    }
    if (!_requiredText(curriculum, const [
          'id',
          'countryCode',
          'authority',
          'academicYear',
          'version',
          'reviewStatus',
        ]) ||
        !_statuses.contains(curriculum['reviewStatus']) ||
        curriculum['sourceIds'] is! List) {
      return false;
    }
    final ids = <String>{};
    return mappings.every(
      (value) => value is Map<String, dynamic> && _validMapping(value, ids),
    );
  }

  bool _validMapping(Map<String, dynamic> mapping, Set<String> ids) {
    if (!_requiredText(mapping, const [
          'id',
          'stageId',
          'gradeId',
          'termId',
          'officialUnit',
          'officialOutcome',
          'version',
          'reviewStatus',
        ]) ||
        !ids.add(mapping['id'] as String) ||
        !_statuses.contains(mapping['reviewStatus'])) {
      return false;
    }
    final concepts = mapping['grammarConceptIds'];
    final source = mapping['source'];
    if (concepts is! List || concepts.isEmpty || !concepts.every(_hasText)) {
      return false;
    }
    if (source is! Map<String, dynamic> ||
        !_requiredText(source, const ['id', 'title', 'url', 'checkedAt']) ||
        DateTime.tryParse(source['checkedAt'] as String) == null) {
      return false;
    }
    return mapping['reviewStatus'] != 'approved' ||
        _hasText(mapping['reviewer']);
  }

  bool _requiredText(Map<String, dynamic> value, List<String> keys) =>
      keys.every((key) => _hasText(value[key]));

  bool _hasText(Object? value) => value is String && value.trim().isNotEmpty;
}
