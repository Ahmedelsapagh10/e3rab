import '../../progress/data/data_source/local_learning_data_source.dart';
import '../../progress/data/model/learning_progress_models.dart';
import '../../progress/data/model/learning_support_models.dart';

abstract final class LearningSnapshotMerger {
  static Future<List<String>> mergeCloud({
    required LocalLearningDataSource local,
    required LearningDataOwner owner,
    required LearningSnapshot cloud,
  }) async {
    final current = local.snapshot(owner);
    final conflicts = <String>[];
    for (final attempt in cloud.attempts) {
      if (!current.attempts.any(
        (item) => item.attemptId == attempt.attemptId,
      )) {
        await local.appendAttempt(owner, attempt);
      }
    }
    for (final item in cloud.progress) {
      final existing = current.progress
          .where((value) => value.lessonId == item.lessonId)
          .firstOrNull;
      if (existing == null || item.updatedAt.isAfter(existing.updatedAt)) {
        await local.saveProgress(owner, item);
      }
    }
    for (final item in cloud.mastery) {
      final existing = current.mastery
          .where((value) => value.skillId == item.skillId)
          .firstOrNull;
      if (existing == null || item.updatedAt.isAfter(existing.updatedAt)) {
        await local.saveMastery(owner, item);
      }
    }
    for (final item in cloud.reviews) {
      final existing = current.reviews
          .where((value) => value.id == item.id)
          .firstOrNull;
      if (existing == null || item.updatedAt.isAfter(existing.updatedAt)) {
        await local.saveReview(owner, item);
      }
    }
    await _mergeBookmarks(local, owner, current.bookmarks, cloud.bookmarks);
    await _mergeNotes(local, owner, current.notes, cloud.notes, conflicts);
    return conflicts;
  }

  static Future<void> _mergeBookmarks(
    LocalLearningDataSource local,
    LearningDataOwner owner,
    List<BookmarkModel> current,
    List<BookmarkModel> cloud,
  ) async {
    for (final item in cloud) {
      final existing = current
          .where((value) => value.id == item.id)
          .firstOrNull;
      if (existing == null || item.updatedAt.isAfter(existing.updatedAt)) {
        await local.saveBookmark(owner, item);
      }
    }
  }

  static Future<void> _mergeNotes(
    LocalLearningDataSource local,
    LearningDataOwner owner,
    List<LearningNoteModel> current,
    List<LearningNoteModel> cloud,
    List<String> conflicts,
  ) async {
    for (final item in cloud) {
      final existing = current
          .where((value) => value.id == item.id)
          .firstOrNull;
      if (existing == null) {
        await local.saveNote(owner, item);
      } else if (existing.text != item.text) {
        final latest = item.updatedAt.isAfter(existing.updatedAt)
            ? item
            : existing;
        final other = identical(latest, item) ? existing : item;
        await local.saveNote(owner, latest);
        await local.saveNote(owner, _conflictCopy(other));
        conflicts.add(item.id);
      } else if (item.updatedAt.isAfter(existing.updatedAt)) {
        await local.saveNote(owner, item);
      }
    }
  }

  static LearningNoteModel _conflictCopy(LearningNoteModel source) {
    return LearningNoteModel(
      id: '${source.id}-conflict-${source.updatedAt.millisecondsSinceEpoch}',
      targetType: source.targetType,
      targetId: source.targetId,
      text: source.text,
      localVersion: source.localVersion,
      updatedAt: source.updatedAt,
      deletedAt: source.deletedAt,
      schemaVersion: source.schemaVersion,
    );
  }
}
