import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/parsing/cubit/parsing_cubit.dart';
import 'package:new_strucuture/features/parsing/cubit/parsing_state.dart';
import 'package:new_strucuture/features/parsing/data/data_source/local_parsing_data_source.dart';
import 'package:new_strucuture/features/parsing/data/local_grammar_analysis_service.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('production parsing cubit exposes no draft samples', () async {
    final fixture = await _fixture(allowDraftPreview: false);
    addTearDown(fixture.dispose);

    await fixture.cubit.load();

    expect(fixture.cubit.state.status, ParsingLabStatus.empty);
  });

  test(
    'guided preview scores, saves sample, and stores private report',
    () async {
      final fixture = await _fixture(allowDraftPreview: true);
      addTearDown(fixture.dispose);

      await fixture.cubit.load();
      final correctOption = fixture.cubit.state.currentStep.correctOptionId;
      fixture.cubit.selectOption(correctOption);
      fixture.cubit.submit();
      await fixture.cubit.toggleSaved();
      await fixture.cubit.reportError('راجع علامة الإعراب.');

      expect(fixture.cubit.state.status, ParsingLabStatus.ready);
      expect(fixture.cubit.state.previewMode, isTrue);
      expect(fixture.cubit.state.correctCount, 1);
      expect(
        fixture.local.getBookmarks(fixture.owner).single.targetType,
        'parsingSample',
      );
      expect(
        fixture.local.getNotes(fixture.owner).single.targetType,
        'parsingReport',
      );
      expect(
        fixture.local.getNotes(fixture.owner).single.text,
        'راجع علامة الإعراب.',
      );
    },
  );

  test('guided bank filters by grammar track and difficulty', () async {
    final fixture = await _fixture(allowDraftPreview: true);
    addTearDown(fixture.dispose);

    await fixture.cubit.load();
    await fixture.cubit.selectTrack('sentence_positions');
    await fixture.cubit.selectDifficulty(3);

    expect(fixture.cubit.state.samples, hasLength(1));
    expect(fixture.cubit.state.currentSample.trackId, 'sentence_positions');
    expect(fixture.cubit.state.currentSample.difficulty, 3);
  });

  test('foundations filter exposes ordered beginner samples', () async {
    final fixture = await _fixture(allowDraftPreview: true);
    addTearDown(fixture.dispose);

    await fixture.cubit.load();
    await fixture.cubit.selectTrack('foundations');
    await fixture.cubit.selectDifficulty(1);

    expect(fixture.cubit.state.samples, hasLength(5));
    expect(fixture.cubit.state.samples.map((sample) => sample.id), [
      'parse-built-demonstrative-subject',
      'parse-estimated-maqsur-subject',
      'parse-verb-governs-object',
      'parse-preposition-governs-noun',
      'parse-imperative-complete-speech',
    ]);
  });
}

Future<_ParsingFixture> _fixture({required bool allowDraftPreview}) async {
  SharedPreferences.setMockInitialValues({});
  final local = LocalLearningDataSource(await SharedPreferences.getInstance());
  final owner = LearningDataOwner.guest('parsing-guest');
  final cubit = ParsingCubit(
    LocalGrammarAnalysisService(AssetParsingDataSource(bundle: rootBundle)),
    LocalFirstProgressRepository(local),
    owner,
    allowDraftPreview: allowDraftPreview,
    now: () => DateTime.utc(2026, 8, 4),
  );
  return _ParsingFixture(cubit, local, owner);
}

class _ParsingFixture {
  const _ParsingFixture(this.cubit, this.local, this.owner);

  final ParsingCubit cubit;
  final LocalLearningDataSource local;
  final LearningDataOwner owner;

  Future<void> dispose() async {
    await cubit.close();
    await local.dispose();
  }
}
