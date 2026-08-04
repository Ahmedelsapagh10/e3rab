import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/local_first_progress_repository.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/data/model/learning_support_models.dart';
import 'package:new_strucuture/features/teacher/data/model/teacher_workspace_models.dart';
import 'package:new_strucuture/features/teacher/data/progress_teacher_workspace_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('workspace round-trips as a private owner-scoped note', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final progress = LocalFirstProgressRepository(local);
    final now = DateTime.utc(2026, 8, 4);
    final repository = ProgressTeacherWorkspaceRepository(
      progress,
      now: () => now,
    );
    final owner = LearningDataOwner.guest('teacher');
    final other = LearningDataOwner.guest('other');
    final workspace = TeacherWorkspaceModel(
      collections: [
        TeacherCollectionModel(
          id: 'collection',
          title: 'الصف الأول',
          lessonIds: const ['lesson'],
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    addTearDown(local.dispose);

    await repository.saveWorkspace(owner, workspace);

    expect(
      (await repository.getWorkspace(
        owner,
      )).getOrElse(() => const TeacherWorkspaceModel()),
      workspace,
    );
    expect(
      (await repository.getWorkspace(
        other,
      )).getOrElse(() => const TeacherWorkspaceModel()).collections,
      isEmpty,
    );
    expect(local.getNotes(owner).single.targetType, 'teacherCollection');
  });

  test('private teacher notes can be saved and tombstoned', () async {
    SharedPreferences.setMockInitialValues({});
    final local = LocalLearningDataSource(
      await SharedPreferences.getInstance(),
    );
    final repository = ProgressTeacherWorkspaceRepository(
      LocalFirstProgressRepository(local),
      now: () => DateTime.utc(2026, 8, 4),
    );
    final owner = LearningDataOwner.guest('teacher');
    addTearDown(local.dispose);

    await repository.savePrivateNote(owner, 'lesson', 'اسأل عن المثال.');
    expect(
      (await repository.getPrivateNotes(
        owner,
      )).getOrElse(() => const []).single.text,
      'اسأل عن المثال.',
    );

    await repository.savePrivateNote(owner, 'lesson', '');
    expect(
      (await repository.getPrivateNotes(owner)).getOrElse(() => const []),
      isEmpty,
    );
    expect(local.getNotes(owner).single.deletedAt, isNotNull);
  });

  test(
    'preserves a synchronized workspace conflict as a visible copy',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalLearningDataSource(
        await SharedPreferences.getInstance(),
      );
      final progress = LocalFirstProgressRepository(local);
      final repository = ProgressTeacherWorkspaceRepository(progress);
      final owner = LearningDataOwner.guest('teacher');
      final now = DateTime.utc(2026, 8, 4);
      final item = TeacherCollectionModel(
        id: 'collection',
        title: 'الفصل',
        lessonIds: const ['lesson'],
        createdAt: now,
        updatedAt: now,
      );
      addTearDown(local.dispose);

      await repository.saveWorkspace(
        owner,
        TeacherWorkspaceModel(collections: [item]),
      );
      await progress.saveNote(
        owner,
        LearningNoteModel(
          id: 'collection-conflict-1',
          targetType: 'teacherCollection',
          targetId: 'collection',
          text: local.getNotes(owner).single.text,
          localVersion: 1,
          updatedAt: now,
          schemaVersion: 1,
        ),
      );

      final workspace = (await repository.getWorkspace(
        owner,
      )).getOrElse(() => const TeacherWorkspaceModel());
      expect(workspace.collections, hasLength(2));
      expect(
        workspace.collections.any(
          (value) => value.title.contains('نسخة تعارض'),
        ),
        isTrue,
      );
    },
  );
}
