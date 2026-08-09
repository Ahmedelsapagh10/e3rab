import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/parsing_bank_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const assetPath = 'assets/content/e3rab_parsing_bank_chapters_8_13_v1.json';
  const expected = {
    'majrourat': (10, 701, 710),
    'majzoumat': (9, 801, 809),
    'followers': (10, 901, 910),
    'working_derivatives': (10, 1001, 1010),
    'styles': (10, 1101, 1110),
    'sentence_positions': (9, 1201, 1209),
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

  test('chapters 8-13 bank validates with exact track ranges', () async {
    final raw = await rootBundle.loadString(assetPath);
    final bank = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final samples = (bank['samples'] as List).cast<Map<String, dynamic>>();

    expect(const ParsingBankValidator().isValid(bank), isTrue);
    expect(bank['schemaVersion'], 1);
    expect(bank['contentVersion'], '1.0.0');
    expect(bank['locale'], 'ar');
    expect(bank['reviewStatus'], 'sourceDocumented');
    expect(samples, hasLength(58));
    for (final entry in expected.entries) {
      final track = samples
          .where((sample) => sample['trackId'] == entry.key)
          .toList(growable: false);
      expect(track, hasLength(entry.value.$1));
      expect(
        track.map((sample) => sample['order']),
        orderedEquals(List.generate(entry.value.$1, (i) => entry.value.$2 + i)),
      );
      expect(track.last['order'], entry.value.$3);
    }
  });

  test(
    'all samples use the seven-step decision chain and unique text',
    () async {
      final bank = Map<String, dynamic>.from(
        jsonDecode(await rootBundle.loadString(assetPath)) as Map,
      );
      final samples = (bank['samples'] as List).cast<Map<String, dynamic>>();
      final ids = samples.map((sample) => sample['id']).toSet();
      final sentences = samples.map((sample) => sample['sentence']).toSet();

      expect(ids, hasLength(58));
      expect(sentences, hasLength(58));
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
        expect(sample['reviewStatus'], 'sourceDocumented');
        expect(sample['reviewedBy'], isNull);
        expect((sample['relatedLessonId'] as String), isNotEmpty);
      }
    },
  );

  test('metadata offsets are complete and content is learner ready', () async {
    final samples = await AssetParsingDataSource(
      bundle: rootBundle,
      assetPath: assetPath,
    ).loadSamples();

    expect(samples, hasLength(58));
    expect(samples.every((sample) => !sample.isApproved), isTrue);
    expect(samples.every((sample) => sample.isLearnerReady), isTrue);
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
