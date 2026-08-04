import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../../progress/data/progress_repository.dart';
import 'model/teacher_workspace_models.dart';
import 'teacher_workspace_repository.dart';

class ProgressTeacherWorkspaceRepository implements TeacherWorkspaceRepository {
  ProgressTeacherWorkspaceRepository(this._progress, {DateTime Function()? now})
    : _now = now ?? _utcNow;

  static DateTime _utcNow() => DateTime.now().toUtc();

  final ProgressRepository _progress;
  final DateTime Function() _now;

  @override
  Future<Either<Failure, TeacherWorkspaceModel>> getWorkspace(
    LearningDataOwner owner,
  ) async {
    final result = await _progress.getNotes(owner);
    return result.bind((notes) {
      try {
        final active = notes.where((note) => note.deletedAt == null);
        return Right(
          TeacherWorkspaceModel(
            collections: active
                .where((note) => note.targetType == 'teacherCollection')
                .map(_collectionFromNote)
                .toList(),
            revisionSets: active
                .where((note) => note.targetType == 'teacherRevisionSet')
                .map(_revisionFromNote)
                .toList(),
          ),
        );
      } catch (_) {
        return Left(CacheFailure());
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> saveWorkspace(
    LearningDataOwner owner,
    TeacherWorkspaceModel workspace,
  ) async {
    final notes = (await _progress.getNotes(owner)).getOrElse(() => const []);
    final desired = <String, ({String type, String text})>{
      for (final item in workspace.collections)
        item.id: (type: 'teacherCollection', text: jsonEncode(item.toJson())),
      for (final item in workspace.revisionSets)
        item.id: (type: 'teacherRevisionSet', text: jsonEncode(item.toJson())),
    };
    for (final item in desired.entries) {
      final existing = notes.where((note) => note.id == item.key).firstOrNull;
      if (existing != null &&
          existing.deletedAt == null &&
          existing.targetType == item.value.type &&
          existing.text == item.value.text) {
        continue;
      }
      final result = await _saveStructuredNote(
        owner,
        id: item.key,
        type: item.value.type,
        text: item.value.text,
        localVersion: (existing?.localVersion ?? 0) + 1,
      );
      if (result.isLeft()) return result;
    }
    final removed = notes.where(
      (note) =>
          note.deletedAt == null &&
          const {
            'teacherCollection',
            'teacherRevisionSet',
          }.contains(note.targetType) &&
          !desired.containsKey(note.id),
    );
    for (final note in removed) {
      final result = await _saveStructuredNote(
        owner,
        id: note.id,
        type: note.targetType,
        text: note.text,
        localVersion: note.localVersion + 1,
        deleted: true,
      );
      if (result.isLeft()) return result;
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, List<LearningNoteModel>>> getPrivateNotes(
    LearningDataOwner owner,
  ) async {
    return (await _progress.getNotes(owner)).map(
      (notes) => notes
          .where(
            (note) =>
                note.targetType == 'teacherPrivateNote' &&
                note.deletedAt == null,
          )
          .toList(growable: false),
    );
  }

  @override
  Future<Either<Failure, Unit>> savePrivateNote(
    LearningDataOwner owner,
    String lessonId,
    String text,
  ) async {
    final notes = (await _progress.getNotes(owner)).getOrElse(() => const []);
    final id = 'teacher-note-$lessonId';
    final existing = notes.where((item) => item.id == id).firstOrNull;
    final value = text.trim();
    final now = _now();
    return _progress.saveNote(
      owner,
      LearningNoteModel(
        id: id,
        targetType: 'teacherPrivateNote',
        targetId: lessonId,
        text: value,
        localVersion: (existing?.localVersion ?? 0) + 1,
        updatedAt: now,
        deletedAt: value.isEmpty ? now : null,
        schemaVersion: 1,
      ),
    );
  }

  TeacherCollectionModel _collectionFromNote(LearningNoteModel note) {
    final item = TeacherCollectionModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(note.text) as Map),
    );
    return item.id == note.id ? item : item.asConflictCopy(note.id);
  }

  TeacherRevisionSetModel _revisionFromNote(LearningNoteModel note) {
    final item = TeacherRevisionSetModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(note.text) as Map),
    );
    return item.id == note.id ? item : item.asConflictCopy(note.id);
  }

  Future<Either<Failure, Unit>> _saveStructuredNote(
    LearningDataOwner owner, {
    required String id,
    required String type,
    required String text,
    required int localVersion,
    bool deleted = false,
  }) {
    final now = _now();
    return _progress.saveNote(
      owner,
      LearningNoteModel(
        id: id,
        targetType: type,
        targetId: id,
        text: text,
        localVersion: localVersion,
        updatedAt: now,
        deletedAt: deleted ? now : null,
        schemaVersion: 1,
      ),
    );
  }
}
