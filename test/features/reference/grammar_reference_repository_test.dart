import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/reference/data/local_grammar_reference_repository.dart';
import 'package:new_strucuture/features/reference/data/model/grammar_reference_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalGrammarReferenceRepository repository;

  setUp(() {
    repository = LocalGrammarReferenceRepository(
      LocalCurriculumRepository(AssetCurriculumDataSource(bundle: rootBundle)),
    );
  });

  test(
    'builds four reference categories for every vertical-slice lesson',
    () async {
      final entries = (await repository.getEntries()).getOrElse(() => const []);

      expect(entries, hasLength(12));
      for (final type in GrammarReferenceType.values) {
        expect(entries.where((entry) => entry.type == type), hasLength(3));
      }
    },
  );

  test('ranked search handles diacritics, grammar roles, and stages', () async {
    final titleResults = (await repository.search(
      'الْمُبْتَدَأ',
    )).getOrElse(() => const []);
    final roleResults = (await repository.search(
      'مرفوع',
    )).getOrElse(() => const []);
    final stageResults = (await repository.search(
      'الثانوية',
    )).getOrElse(() => const []);

    expect(titleResults, isNotEmpty);
    expect(titleResults.first.entry.lesson.id, 'nominal-sentence');
    expect(roleResults, isNotEmpty);
    expect(
      stageResults.every(
        (result) =>
            result.entry.lesson.id == 'sentences-with-syntactic-position',
      ),
      isTrue,
    );
  });
}
