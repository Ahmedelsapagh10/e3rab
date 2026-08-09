import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/parsing_bank_validator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const path = 'assets/content/e3rab_parsing_bank_chapters_2_7_v1.json';
  const sequence = [
    'word-type',
    'role',
    'agent',
    'state',
    'sign',
    'reason',
    'sentence-position',
  ];
  test('chapters 2 to 7 bank is valid and source documented', () async {
    final bank = Map<String, dynamic>.from(
      jsonDecode(await rootBundle.loadString(path)) as Map,
    );
    expect(const ParsingBankValidator().isValid(bank), isTrue);
    expect(bank['schemaVersion'], 1);
    expect(bank['contentVersion'], '1.1.0');
    expect(bank['locale'], 'ar');
    expect(bank['reviewStatus'], 'sourceDocumented');
    final samples = (bank['samples'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    expect(samples, hasLength(52));
    const counts = {
      'signs': 4,
      'nominal': 8,
      'verbal': 10,
      'nawasekh': 10,
      'marfouat': 10,
      'mansoubat': 10,
    };
    const starts = {
      'signs': 101,
      'nominal': 201,
      'verbal': 301,
      'nawasekh': 401,
      'marfouat': 501,
      'mansoubat': 601,
    };
    final ids = <String>{}, sentences = <String>{};
    for (final entry in counts.entries) {
      final group = samples.where((e) => e['trackId'] == entry.key).toList();
      expect(group, hasLength(entry.value));
      expect(
        group.map((e) => e['order']),
        List.generate(entry.value, (i) => starts[entry.key]! + i),
      );
    }
    for (final sample in samples) {
      expect(ids.add(sample['id'] as String), isTrue);
      expect(sentences.add(sample['sentence'] as String), isTrue);
      expect(sample['difficulty'], inInclusiveRange(1, 3));
      expect((sample['steps'] as List).map((e) => (e as Map)['id']), sequence);
      expect(sample['reviewStatus'], 'sourceDocumented');
      expect(sample['reviewedBy'], isNull);
      expect(sample['reviewedAt'], isNull);
      final sentence = sample['sentence'] as String;
      for (final raw in sample['parsedWords'] as List) {
        final word = Map<String, dynamic>.from(raw as Map);
        for (final key in ['grammaticalAgent', 'sentencePosition']) {
          expect((word[key] as String).trim(), isNotEmpty);
        }
        expect(
          sentence.substring(
            word['startIndex'] as int,
            word['endIndex'] as int,
          ),
          word['word'],
        );
      }
    }
    final loaded = await AssetParsingDataSource(
      bundle: rootBundle,
      assetPath: path,
    ).loadSamples();
    expect(loaded, hasLength(52));
    expect(loaded.every((sample) => !sample.isApproved), isTrue);
    expect(loaded.every((sample) => sample.isLearnerReady), isTrue);
  });
}
