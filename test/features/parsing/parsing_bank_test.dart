import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/local_grammar_analysis_service.dart';
import 'package:new_strucuture/features/parsing/data/parsing_bank_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parsing bank is valid and contains three guided drafts', () async {
    final raw = await rootBundle.loadString(
      'assets/content/e3rab_parsing_bank_v1.json',
    );
    final bank = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
    ).loadSamples();

    expect(const ParsingBankValidator().isValid(bank), isTrue);
    expect(samples, hasLength(3));
    expect(samples.every((sample) => sample.steps.length == 7), isTrue);
    expect(samples.every((sample) => !sample.isApproved), isTrue);
    expect(samples.every((sample) => sample.parsedWords.isNotEmpty), isTrue);
  });

  test('student service hides every unapproved parsing sample', () async {
    final service = LocalGrammarAnalysisService(
      AssetParsingDataSource(bundle: rootBundle),
    );

    final studentSamples = await service.getSamples();
    final previewSamples = await service.getSamples(includeDrafts: true);

    expect(studentSamples.getOrElse(() => const []), isEmpty);
    expect(previewSamples.getOrElse(() => const []), hasLength(3));
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
