import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/curriculum/data/data_source/local_curriculum_data_source.dart';
import 'package:new_strucuture/features/curriculum/data/local_curriculum_repository.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/teacher/cubit/teacher_cubit.dart';
import 'package:new_strucuture/features/teacher/cubit/teacher_state.dart';
import 'package:new_strucuture/features/teacher/data/progress_teacher_workspace_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'creates lesson collections, revision sets, and private notes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalLearningDataSource(
        await SharedPreferences.getInstance(),
      );
      final progress = LocalFirstProgressRepository(local);
      final now = DateTime.utc(2026, 8, 4);
      final cubit = TeacherCubit(
        LocalCurriculumRepository(
          AssetCurriculumDataSource(bundle: rootBundle),
        ),
        ProgressTeacherWorkspaceRepository(progress, now: () => now),
        LearningDataOwner.guest('teacher'),
        now: () => now,
      );
      addTearDown(cubit.close);
      addTearDown(local.dispose);

      await cubit.load();
      final lessonId = cubit.state.lessons.first.id;
      await cubit.createCollection('مجموعة تأسيس', [lessonId]);
      await cubit.createRevisionSet('مراجعة تأسيس', [lessonId]);
      await cubit.savePrivateNote(lessonId, 'ابدأ بالسؤال التمهيدي.');

      expect(cubit.state.status, TeacherStatus.ready);
      expect(cubit.state.workspace.collections.single.title, 'مجموعة تأسيس');
      expect(
        cubit.state.workspace.revisionSets.single.exerciseIds,
        hasLength(10),
      );
      expect(cubit.state.noteFor(lessonId)?.text, 'ابدأ بالسؤال التمهيدي.');
    },
  );

  test('deletes only the selected workspace item', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final now = DateTime.utc(2026, 8, 4);
    final cubit = TeacherCubit(
      LocalCurriculumRepository(AssetCurriculumDataSource(bundle: rootBundle)),
      ProgressTeacherWorkspaceRepository(
        LocalFirstProgressRepository(local),
        now: () => now,
      ),
      LearningDataOwner.guest('teacher'),
      now: () => now,
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);

    await cubit.load();
    await cubit.createCollection('مجموعة', [cubit.state.lessons.first.id]);
    final id = cubit.state.workspace.collections.single.id;
    await cubit.deleteCollection(id);

    expect(cubit.state.workspace.collections, isEmpty);
  });

  test('rejects an oversized collection without truncating it', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final now = DateTime.utc(2026, 8, 4);
    final cubit = TeacherCubit(
      LocalCurriculumRepository(AssetCurriculumDataSource(bundle: rootBundle)),
      ProgressTeacherWorkspaceRepository(
        LocalFirstProgressRepository(local),
        now: () => now,
      ),
      LearningDataOwner.guest('teacher'),
      now: () => now,
    );
    addTearDown(cubit.close);
    addTearDown(local.dispose);
    await cubit.load();

    await cubit.createCollection(
      'مجموعة كبيرة',
      List.generate(51, (index) => 'lesson-$index'),
    );

    expect(cubit.state.workspace.collections, isEmpty);
    expect(cubit.state.message, contains('50 درسًا'));
  });
}
