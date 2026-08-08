import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/local_grammar_analysis_service.dart';
import 'package:new_strucuture/features/parsing/data/parsing_bank_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parsing bank contains sixteen gated guided samples', () async {
    final raw = await rootBundle.loadString(
      'assets/content/e3rab_parsing_bank_v1.json',
    );
    final bank = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
    ).loadSamples();

    expect(const ParsingBankValidator().isValid(bank), isTrue);
    expect(samples, hasLength(16));
    expect(samples.every((sample) => sample.steps.length == 7), isTrue);
    expect(samples.every((sample) => !sample.isApproved), isTrue);
    expect(samples.every((sample) => sample.parsedWords.isNotEmpty), isTrue);
    expect(samples.every((sample) => sample.trackId.isNotEmpty), isTrue);
    expect(samples.every((sample) => sample.difficulty > 0), isTrue);
    final foundationSamples = samples
        .where((sample) => sample.trackId == 'foundations')
        .toList(growable: false);
    expect(foundationSamples, hasLength(12));
    expect(
      foundationSamples.map((sample) => sample.order),
      orderedEquals([5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
    );
    final inflectionSamples = samples
        .where((sample) => sample.relatedLessonId == 'inflection-forms-v1')
        .toList(growable: false);
    const decisionStepIds = [
      'word-type',
      'role',
      'agent',
      'state',
      'sign',
      'reason',
      'sentence-position',
    ];
    expect(inflectionSamples, hasLength(3));
    expect(
      inflectionSamples.every((sample) {
        final ids = sample.steps.map((step) => step.id).toList();
        return ids.length == decisionStepIds.length &&
            Iterable<int>.generate(
              ids.length,
            ).every((index) => ids[index] == decisionStepIds[index]);
      }),
      isTrue,
    );
    expect(
      inflectionSamples.every(
        (sample) => sample.parsedWords.every(
          (word) =>
              word.grammaticalAgent.isNotEmpty &&
              word.sentencePosition.isNotEmpty,
        ),
      ),
      isTrue,
    );
    final governanceSamples = samples
        .where(
          (sample) => sample.relatedLessonId == 'grammatical-governance-v1',
        )
        .toList(growable: false);
    expect(governanceSamples, hasLength(3));
    expect(
      governanceSamples.every((sample) {
        final ids = sample.steps.map((step) => step.id).toList();
        return ids.length == decisionStepIds.length &&
            Iterable<int>.generate(
              ids.length,
            ).every((index) => ids[index] == decisionStepIds[index]);
      }),
      isTrue,
    );
    final sentenceTypeSamples = samples
        .where((sample) => sample.relatedLessonId == 'sentence-types-v1')
        .toList(growable: false);
    expect(sentenceTypeSamples, hasLength(3));
    expect(
      sentenceTypeSamples.every((sample) {
        final ids = sample.steps.map((step) => step.id).toList();
        return ids.length == decisionStepIds.length &&
            Iterable<int>.generate(
              ids.length,
            ).every((index) => ids[index] == decisionStepIds[index]);
      }),
      isTrue,
    );
    final speechSamples = samples
        .where((sample) => sample.relatedLessonId == 'speech-expression-v1')
        .toList(growable: false);
    expect(speechSamples, hasLength(2));
    expect(
      speechSamples.every((sample) {
        final ids = sample.steps.map((step) => step.id).toList();
        return ids.length == decisionStepIds.length &&
            Iterable<int>.generate(
              ids.length,
            ).every((index) => ids[index] == decisionStepIds[index]);
      }),
      isTrue,
    );
  });

  test('student service hides every unapproved parsing sample', () async {
    final service = LocalGrammarAnalysisService(
      AssetParsingDataSource(bundle: rootBundle),
    );

    final studentSamples = await service.getSamples();
    final previewSamples = await service.getSamples(includeDrafts: true);

    expect(studentSamples.getOrElse(() => const []), isEmpty);
    expect(previewSamples.getOrElse(() => const []), hasLength(16));
  });

  test('approved samples require reviewer identity and review date', () {
    final invalidBank = <String, dynamic>{
      'schemaVersion': 1,
      'samples': [
        {
          'id': 'sample',
          'reviewStatus': 'approved',
          'reviewedBy': null,
          'reviewedAt': null,
          'steps': [
            {
              'options': [
                {'id': 'a'},
                {'id': 'b'},
              ],
              'correctOptionId': 'a',
            },
          ],
        },
      ],
    };

    expect(const ParsingBankValidator().isValid(invalidBank), isFalse);
  });
}
