import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../progress/data/data_source/cloud_learning_data_source.dart';
import '../../progress/data/data_source/local_learning_data_source.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';
import '../../progress/data/progress_repository.dart';
import 'model/sync_models.dart';
import 'learning_snapshot_merger.dart';
import 'sync_repository.dart';

class LocalFirstSyncRepository implements SyncRepository {
  LocalFirstSyncRepository(
    this._local,
    this._progress, {
    CloudLearningDataSource? cloud,
  }) : _cloud = cloud;

  final LocalLearningDataSource _local;
  final ProgressRepository _progress;
  final CloudLearningDataSource? _cloud;
  final StreamController<SyncStatus> _status = StreamController.broadcast();

  @override
  Stream<SyncStatus> watchStatus() => _status.stream;

  @override
  Future<bool> hasGuestData(LearningDataOwner guestOwner) async {
    return !_local.snapshot(guestOwner).isEmpty;
  }

  @override
  Future<Either<Failure, SyncResult>> mergeGuestIntoAccount({
    required LearningDataOwner guestOwner,
    required LearningDataOwner accountOwner,
  }) async {
    _status.add(SyncStatus.syncing);
    try {
      final guest = _local.snapshot(guestOwner);
      final account = _local.snapshot(accountOwner);
      var uploaded = 0;
      var skipped = 0;
      final conflicts = <String>[];

      for (final attempt in guest.attempts) {
        if (account.attempts.any(
          (item) => item.attemptId == attempt.attemptId,
        )) {
          skipped++;
        } else {
          await _progress.appendExerciseAttempt(accountOwner, attempt);
          uploaded++;
        }
      }
      for (final item in guest.progress) {
        final cloudItem = account.progress
            .where((value) => value.lessonId == item.lessonId)
            .firstOrNull;
        final selected =
            cloudItem == null || item.updatedAt.isAfter(cloudItem.updatedAt)
            ? item
            : cloudItem;
        await _progress.saveLessonProgress(accountOwner, selected);
        uploaded++;
      }
      for (final bookmark in guest.bookmarks) {
        final accountItem = account.bookmarks
            .where((item) => item.id == bookmark.id)
            .firstOrNull;
        final selected =
            accountItem == null ||
                bookmark.updatedAt.isAfter(accountItem.updatedAt)
            ? bookmark
            : accountItem;
        await _progress.saveBookmark(accountOwner, selected);
        uploaded++;
      }
      for (final note in guest.notes) {
        final accountNote = account.notes
            .where((item) => item.id == note.id)
            .firstOrNull;
        if (accountNote != null && accountNote.text != note.text) {
          final preserved = LearningNoteModel(
            id: '${note.id}-guest-conflict-${note.updatedAt.millisecondsSinceEpoch}',
            targetType: note.targetType,
            targetId: note.targetId,
            text: note.text,
            localVersion: note.localVersion,
            updatedAt: note.updatedAt,
            schemaVersion: note.schemaVersion,
          );
          await _progress.saveNote(accountOwner, preserved);
          conflicts.add(note.id);
        } else {
          await _progress.saveNote(accountOwner, note);
        }
        uploaded++;
      }
      if (_cloud != null) {
        final confirmation = await syncPending(accountOwner);
        if (confirmation.isLeft()) {
          _status.add(SyncStatus.failed);
          return Left(ServerFailure());
        }
        await _local.clear(guestOwner);
      }
      final status = conflicts.isEmpty
          ? SyncStatus.completed
          : SyncStatus.partiallyCompleted;
      _status.add(status);
      return Right(
        SyncResult(
          status: status,
          uploadedOperationCount: uploaded,
          skippedOperationCount: skipped,
          conflictIds: conflicts,
        ),
      );
    } catch (_) {
      _status.add(SyncStatus.failed);
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, SyncResult>> syncPending(
    LearningDataOwner accountOwner,
  ) async {
    if (_cloud == null || accountOwner.type != LearningDataOwnerType.account) {
      return const Right(
        SyncResult(
          status: SyncStatus.idle,
          uploadedOperationCount: 0,
          skippedOperationCount: 0,
          conflictIds: [],
        ),
      );
    }
    _status.add(SyncStatus.syncing);
    try {
      final cloud = await _cloud.fetch(accountOwner.id);
      final conflicts = await LearningSnapshotMerger.mergeCloud(
        local: _local,
        owner: accountOwner,
        cloud: cloud,
      );
      final data = _local.snapshot(accountOwner);
      var count = 0;
      for (final item in data.progress) {
        await _cloud.saveProgress(accountOwner.id, item);
        count++;
      }
      for (final item in data.attempts) {
        await _cloud.appendAttempt(accountOwner.id, item);
        count++;
      }
      for (final item in data.mastery) {
        await _cloud.saveMastery(accountOwner.id, item);
        count++;
      }
      for (final item in data.reviews) {
        await _cloud.saveReview(accountOwner.id, item);
        count++;
      }
      for (final item in data.bookmarks) {
        await _cloud.saveBookmark(accountOwner.id, item);
        count++;
      }
      for (final item in data.notes) {
        await _cloud.saveNote(accountOwner.id, item);
        count++;
      }
      final status = conflicts.isEmpty
          ? SyncStatus.completed
          : SyncStatus.partiallyCompleted;
      _status.add(status);
      return Right(
        SyncResult(
          status: status,
          uploadedOperationCount: count,
          skippedOperationCount: 0,
          conflictIds: conflicts,
        ),
      );
    } catch (_) {
      _status.add(SyncStatus.failed);
      return Left(ServerFailure());
    }
  }
}
