import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/reference/cubit/reference_cubit.dart';
import 'package:new_strucuture/features/reference/cubit/reference_state.dart';
import 'package:new_strucuture/features/reference/data/local_grammar_reference_repository.dart';
import 'package:new_strucuture/features/reference/data/model/grammar_reference_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'filters categories and persists owner-scoped saved references',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalLearningDataSource(
        await SharedPreferences.getInstance(),
      );
      final owner = LearningDataOwner.guest('reference-guest');
      final cubit = ReferenceCubit(
        LocalGrammarReferenceRepository(
          LocalCurriculumRepository(
            AssetCurriculumDataSource(bundle: rootBundle),
          ),
        ),
        LocalFirstProgressRepository(local),
        owner,
      );
      addTearDown(cubit.close);
      addTearDown(local.dispose);

      await cubit.load();
      cubit.selectType(GrammarReferenceType.quickRule);
      final entry = cubit.state.visibleEntries.first;
      await cubit.toggleSaved(entry);
      cubit.toggleSavedOnly();

      expect(cubit.state.status, ReferenceStatus.ready);
      expect(cubit.state.visibleEntries, [entry]);
      expect(local.getBookmarks(owner).single.targetType, 'referenceEntry');
    },
  );

  test('query searches indexed examples and grammatical signs', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final cubit = ReferenceCubit(
      LocalGrammarReferenceRepository(
        LocalCurriculumRepository(
          AssetCurriculumDataSource(bundle: rootBundle),
        ),
      ),
      LocalFirstProgressRepository(local),
      LearningDataOwner.guest('search-guest'),
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);

    await cubit.load();
    await cubit.search('الضمة الظاهرة');

    expect(cubit.state.visibleEntries, isNotEmpty);
    expect(cubit.state.query, 'الضمة الظاهرة');
  });
}
