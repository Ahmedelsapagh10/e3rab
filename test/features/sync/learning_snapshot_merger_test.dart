import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/progress/data/data_source/local_learning_data_source.dart';
import 'package:new_strucuture/features/progress/data/model/learning_progress_models.dart';
import 'package:new_strucuture/features/progress/data/model/learning_support_models.dart';
import 'package:new_strucuture/features/sync/data/learning_snapshot_merger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'cloud merge keeps newest tombstone and preserves note conflicts',
    () async {
      SharedPreferences.setMockInitialValues({});
      final local = LocalLearningDataSource(
        await SharedPreferences.getInstance(),
      );
      final owner = LearningDataOwner.account('account');
      final older = DateTime.utc(2026, 8, 3);
      final newer = DateTime.utc(2026, 8, 4);
      await local.saveBookmark(owner, _bookmark(older));
      await local.saveNote(owner, _note('نسخة محلية', newer));

      final conflicts = await LearningSnapshotMerger.mergeCloud(
        local: local,
        owner: owner,
        cloud: LearningSnapshot(
          progress: const [],
          attempts: const [],
          mastery: const [],
          reviews: const [],
          bookmarks: [_bookmark(newer, deleted: true)],
          notes: [_note('نسخة سحابية', older)],
        ),
      );

      expect(local.getBookmarks(owner).single.isDeleted, isTrue);
      expect(local.getNotes(owner), hasLength(2));
      expect(
        local.getNotes(owner).map((note) => note.text),
        containsAll(['نسخة محلية', 'نسخة سحابية']),
      );
      expect(conflicts, ['lesson-one']);
      await local.dispose();
    },
  );
}

BookmarkModel _bookmark(DateTime updatedAt, {bool deleted = false}) {
  return BookmarkModel(
    id: 'lesson-one',
    targetType: 'lesson',
    targetId: 'lesson-one',
    contentVersion: '1.0.0',
    createdAt: DateTime.utc(2026, 8, 1),
    updatedAt: updatedAt,
    deletedAt: deleted ? updatedAt : null,
  );
}

LearningNoteModel _note(String text, DateTime updatedAt) {
  return LearningNoteModel(
    id: 'lesson-one',
    targetType: 'lesson',
    targetId: 'lesson-one',
    text: text,
    localVersion: 1,
    updatedAt: updatedAt,
    schemaVersion: 1,
  );
}
