import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/parsing_bank_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const assetPath = 'assets/content/e3rab_parsing_bank_chapters_14_18_v1.json';
  const expected = {
    'semi_sentences': (10, 1301, 1310),
    'diptotes': (10, 1401, 1410),
    'numbers': (10, 1501, 1510),
    'special_nouns': (10, 1601, 1610),
    'applied_parsing': (10, 1701, 1710),
  };
  const stepIds = [
    'word-type',
    'role',
    'agent',
    'state',
    'sign',
    'reason',
    'sentence-position',
  ];

  Future<Map<String, dynamic>> loadBank() async => Map<String, dynamic>.from(
    jsonDecode(await rootBundle.loadString(assetPath)) as Map,
  );

  test('chapters 14-18 bank validates with exact ranges', () async {
    final bank = await loadBank();
    final samples = (bank['samples'] as List).cast<Map<String, dynamic>>();

    expect(const ParsingBankValidator().isValid(bank), isTrue);
    expect(bank['schemaVersion'], 1);
    expect(bank['contentVersion'], '1.0.0');
    expect(bank['locale'], 'ar');
    expect(bank['reviewStatus'], 'inReview');
    expect(samples, hasLength(50));
    for (final entry in expected.entries) {
      final track = samples
          .where((sample) => sample['trackId'] == entry.key)
          .toList(growable: false);
      expect(track, hasLength(10));
      expect(
        track.map((sample) => sample['order']),
        orderedEquals(List.generate(10, (i) => entry.value.$2 + i)),
      );
      expect(track.last['order'], entry.value.$3);
    }
  });

  test('samples have unique IDs, sentences, and seven ordered steps', () async {
    final bank = await loadBank();
    final samples = (bank['samples'] as List).cast<Map<String, dynamic>>();

    expect(samples.map((sample) => sample['id']).toSet(), hasLength(50));
    expect(samples.map((sample) => sample['sentence']).toSet(), hasLength(50));
    for (final sample in samples) {
      final steps = (sample['steps'] as List).cast<Map>();
      expect(steps.map((step) => step['id']), stepIds);
      expect(
        steps.every((step) => (step['options'] as List).length >= 2),
        isTrue,
      );
      expect(
        steps.every((step) => '${step['explanation']}'.isNotEmpty),
        isTrue,
      );
      expect(sample['reviewStatus'], 'inReview');
      expect(sample['reviewedBy'], isNull);
      expect((sample['relatedLessonId'] as String), isNotEmpty);
    }
  });

  test('direct loading keeps metadata complete and content gated', () async {
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
      assetPath: assetPath,
    ).loadSamples();

    expect(samples, hasLength(50));
    expect(samples.every((sample) => !sample.isApproved), isTrue);
    for (final sample in samples) {
      for (final word in sample.parsedWords) {
        expect(word.grammaticalAgent, isNotEmpty);
        expect(word.sentencePosition, isNotEmpty);
        expect(
          word.startIndex,
          inInclusiveRange(0, sample.sentence.length - 1),
        );
        expect(
          word.endIndex,
          inInclusiveRange(word.startIndex + 1, sample.sentence.length),
        );
        expect(
          sample.sentence.substring(word.startIndex, word.endIndex),
          word.word,
        );
      }
    }
  });
}
