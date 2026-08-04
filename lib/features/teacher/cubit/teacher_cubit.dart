import 'package:flutter_bloc/flutter_bloc.dart';

import '../../curriculum/data/curriculum_repository.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../data/model/teacher_workspace_models.dart';
import '../data/teacher_workspace_repository.dart';
import 'teacher_state.dart';

class TeacherCubit extends Cubit<TeacherState> {
  TeacherCubit(
    this._curriculum,
    this._workspaceRepository,
    this.owner, {
    DateTime Function()? now,
  }) : _now = now ?? _utcNow,
       super(const TeacherState());

  static DateTime _utcNow() => DateTime.now().toUtc();

  final CurriculumRepository _curriculum;
  final TeacherWorkspaceRepository _workspaceRepository;
  final LearningDataOwner owner;
  final DateTime Function() _now;

  Future<void> load() async {
    emit(state.copyWith(status: TeacherStatus.loading, clearMessage: true));
    final lessonsResult = await _curriculum.getAllLessons();
    final workspaceResult = await _workspaceRepository.getWorkspace(owner);
    final notesResult = await _workspaceRepository.getPrivateNotes(owner);
    if (lessonsResult.isLeft() ||
        workspaceResult.isLeft() ||
        notesResult.isLeft()) {
      emit(
        state.copyWith(
          status: TeacherStatus.failure,
          message: 'تعذّر فتح مساحة المعلم المحلية.',
        ),
      );
      return;
    }
    emit(
      TeacherState(
        status: TeacherStatus.ready,
        lessons: lessonsResult.getOrElse(() => const []),
        workspace: workspaceResult.getOrElse(
          () => const TeacherWorkspaceModel(),
        ),
        privateNotes: notesResult.getOrElse(() => const []),
      ),
    );
  }

  Future<void> createCollection(String title, List<String> lessonIds) async {
    final value = title.trim();
    if (value.isEmpty || lessonIds.isEmpty || _busy) return;
    if (value.length > 80 || lessonIds.length > 50) {
      emit(state.copyWith(message: 'الحد الأقصى 80 حرفًا و50 درسًا للمجموعة.'));
      return;
    }
    final now = _now();
    final collection = TeacherCollectionModel(
      id: 'collection-${now.microsecondsSinceEpoch}',
      title: value,
      lessonIds: List.unmodifiable(lessonIds),
      createdAt: now,
      updatedAt: now,
    );
    await _saveWorkspace(
      state.workspace.copyWith(
        collections: [...state.workspace.collections, collection],
      ),
      'حُفظت مجموعة الدروس.',
    );
  }

  Future<void> createRevisionSet(String title, List<String> lessonIds) async {
    final value = title.trim();
    if (value.isEmpty || lessonIds.isEmpty || _busy) return;
    if (value.length > 80 || lessonIds.length > 20) {
      emit(
        state.copyWith(
          message: 'الحد الأقصى 80 حرفًا و20 درسًا لحزمة المراجعة.',
        ),
      );
      return;
    }
    final exerciseIds = <String>[];
    for (final lessonId in lessonIds) {
      final exercises = (await _curriculum.getLessonExercises(
        lessonId,
      )).getOrElse(() => const []);
      exerciseIds.addAll(exercises.map((exercise) => exercise.id));
    }
    if (exerciseIds.length > 200) {
      emit(
        state.copyWith(
          message: 'الحزمة أكبر من 200 تمرين؛ اختر عددًا أقل من الدروس.',
        ),
      );
      return;
    }
    final now = _now();
    final revisionSet = TeacherRevisionSetModel(
      id: 'revision-${now.microsecondsSinceEpoch}',
      title: value,
      lessonIds: List.unmodifiable(lessonIds),
      exerciseIds: List.unmodifiable(exerciseIds),
      createdAt: now,
    );
    await _saveWorkspace(
      state.workspace.copyWith(
        revisionSets: [...state.workspace.revisionSets, revisionSet],
      ),
      'حُفظت حزمة المراجعة.',
    );
  }

  Future<void> deleteCollection(String id) => _saveWorkspace(
    state.workspace.copyWith(
      collections: state.workspace.collections
          .where((item) => item.id != id)
          .toList(),
    ),
    'حُذفت المجموعة.',
  );

  Future<void> deleteRevisionSet(String id) => _saveWorkspace(
    state.workspace.copyWith(
      revisionSets: state.workspace.revisionSets
          .where((item) => item.id != id)
          .toList(),
    ),
    'حُذفت حزمة المراجعة.',
  );

  Future<void> savePrivateNote(String lessonId, String text) async {
    if (_busy) return;
    emit(state.copyWith(status: TeacherStatus.saving, clearMessage: true));
    final result = await _workspaceRepository.savePrivateNote(
      owner,
      lessonId,
      text,
    );
    if (result.isLeft()) {
      emit(
        state.copyWith(
          status: TeacherStatus.ready,
          message: 'تعذّر حفظ الملاحظة الخاصة.',
        ),
      );
      return;
    }
    final notes = (await _workspaceRepository.getPrivateNotes(
      owner,
    )).getOrElse(() => state.privateNotes);
    emit(
      state.copyWith(
        status: TeacherStatus.ready,
        privateNotes: notes,
        message: 'حُفظت الملاحظة الخاصة.',
      ),
    );
  }

  bool get _busy => state.status == TeacherStatus.saving;

  Future<void> _saveWorkspace(
    TeacherWorkspaceModel workspace,
    String successMessage,
  ) async {
    if (_busy) return;
    emit(state.copyWith(status: TeacherStatus.saving, clearMessage: true));
    final result = await _workspaceRepository.saveWorkspace(owner, workspace);
    emit(
      state.copyWith(
        status: TeacherStatus.ready,
        workspace: result.isRight() ? workspace : state.workspace,
        message: result.isRight() ? successMessage : 'تعذّر حفظ مساحة المعلم.',
      ),
    );
  }
}
