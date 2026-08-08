class ParsingBankValidator {
  const ParsingBankValidator();

  static const _decisionStepIds = [
    'word-type',
    'role',
    'agent',
    'state',
    'sign',
    'reason',
    'sentence-position',
  ];

  bool isValid(Map<String, dynamic> bank) {
    final samples = bank['samples'];
    if (bank['schemaVersion'] is! int || samples is! List || samples.isEmpty) {
      return false;
    }
    final ids = <String>{};
    for (final value in samples) {
      if (value is! Map<String, dynamic> || !_validSample(value, ids)) {
        return false;
      }
    }
    return true;
  }

  bool _validSample(Map<String, dynamic> sample, Set<String> ids) {
    final id = sample['id'];
    final status = sample['reviewStatus'];
    final steps = sample['steps'];
    if (!_hasText(id) || !ids.add(id as String) || !_hasSampleText(sample)) {
      return false;
    }
    if (!_hasText(sample['trackId']) ||
        sample['difficulty'] is! int ||
        sample['order'] is! int) {
      return false;
    }
    if (steps is! List ||
        steps.length != _decisionStepIds.length ||
        !Iterable<int>.generate(steps.length).every(
          (index) =>
              steps[index] is Map<String, dynamic> &&
              (steps[index] as Map<String, dynamic>)['id'] ==
                  _decisionStepIds[index],
        ) ||
        !steps.every(_validStep)) {
      return false;
    }
    if (!const {
      'draft',
      'aiAssistedDraft',
      'inReview',
      'changesRequested',
      'approved',
      'archived',
    }.contains(status)) {
      return false;
    }
    if (status == 'approved' && !_validApproval(sample)) {
      return false;
    }
    final parsedWords = sample['parsedWords'];
    final alternatives = sample['alternatives'];
    final references = sample['referenceIds'];
    return parsedWords is List &&
        parsedWords.isNotEmpty &&
        parsedWords.every(_validParsedWord) &&
        alternatives is List &&
        alternatives.every(_validAlternative) &&
        references is List &&
        references.every(_hasText);
  }

  bool _validStep(Object? value) {
    if (value is! Map<String, dynamic>) return false;
    final options = value['options'];
    final correctId = value['correctOptionId'];
    if (!_hasText(value['id']) ||
        !_hasText(value['title']) ||
        !_hasText(value['prompt']) ||
        !_hasText(value['explanation']) ||
        options is! List ||
        options.length < 2 ||
        !_hasText(correctId)) {
      return false;
    }
    final optionIds = <String>{};
    return options.every(
          (option) =>
              option is Map<String, dynamic> &&
              _hasText(option['id']) &&
              optionIds.add(option['id'] as String) &&
              _hasText(option['text']) &&
              _hasText(option['feedback']),
        ) &&
        optionIds.contains(correctId);
  }

  bool _hasSampleText(Map<String, dynamic> sample) => const [
    'sentence',
    'fullyDiacritizedSentence',
    'targetText',
    'summary',
    'relatedLessonId',
    'contentVersion',
  ].every((key) => _hasText(sample[key]));

  bool _validApproval(Map<String, dynamic> sample) {
    if (!_hasText(sample['reviewedBy']) || !_hasText(sample['reviewedAt'])) {
      return false;
    }
    return DateTime.tryParse(sample['reviewedAt'] as String) != null;
  }

  bool _validParsedWord(Object? value) {
    if (value is! Map<String, dynamic>) return false;
    final hasText = const [
      'word',
      'normalizedWord',
      'wordType',
      'grammaticalRole',
      'grammaticalState',
      'grammaticalSign',
      'signReason',
      'grammaticalAgent',
      'sentencePosition',
      'explanation',
    ].every((key) => _hasText(value[key]));
    return hasText &&
        value['startIndex'] is int &&
        value['endIndex'] is int &&
        (value['endIndex'] as int) > (value['startIndex'] as int);
  }

  bool _validAlternative(Object? value) =>
      value is Map<String, dynamic> &&
      _hasText(value['title']) &&
      _hasText(value['explanation']);

  bool _hasText(Object? value) => value is String && value.trim().isNotEmpty;
}
