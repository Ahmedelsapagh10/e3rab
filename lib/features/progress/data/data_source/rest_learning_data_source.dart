import '../../../../core/firebase/firestore_rest_client.dart';
import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';
import 'cloud_learning_data_source.dart';
import 'learning_data_codec.dart';
import 'learning_support_codec.dart';
import 'local_learning_data_source.dart';

class RestLearningDataSource implements CloudLearningDataSource {
  RestLearningDataSource(this._client);

  final FirestoreRestClient _client;

  @override
  Future<LearningSnapshot> fetch(String uid) async {
    final collections = await Future.wait([
      _list(uid, 'lesson_progress'),
      _list(uid, 'exercise_attempts'),
      _list(uid, 'skill_mastery'),
      _list(uid, 'review_items'),
      _list(uid, 'bookmarks'),
      _list(uid, 'notes'),
    ]);
    return LearningSnapshot(
      progress: collections[0].map(LearningDataCodec.progressFrom).toList(),
      attempts: collections[1].map(LearningDataCodec.attemptFrom).toList(),
      mastery: collections[2].map(LearningSupportCodec.masteryFrom).toList(),
      reviews: collections[3]
          .map((item) => LearningSupportCodec.reviewFrom(_withId(item)))
          .toList(),
      bookmarks: collections[4]
          .map((item) => LearningSupportCodec.bookmarkFrom(_withId(item)))
          .toList(),
      notes: collections[5]
          .map((item) => LearningSupportCodec.noteFrom(_withId(item)))
          .toList(),
    );
  }

  @override
  Future<void> saveProgress(String uid, LessonProgressModel item) => _set(
    uid,
    'lesson_progress',
    item.lessonId,
    LearningDataCodec.progress(item),
  );

  @override
  Future<void> appendAttempt(String uid, ExerciseAttemptModel item) async {
    final path = _document(uid, 'exercise_attempts', item.attemptId);
    if (await _client.getDocument(path) != null) return;
    await _client.setDocument(
      path,
      LearningDataCodec.attempt(item),
      serverTimestampFields: const ['serverCreatedAt'],
    );
  }

  @override
  Future<void> saveMastery(String uid, SkillMasteryModel item) => _set(
    uid,
    'skill_mastery',
    item.skillId,
    LearningSupportCodec.mastery(item),
  );

  @override
  Future<void> saveReview(String uid, ReviewItemModel item) => _set(
    uid,
    'review_items',
    item.id,
    Map<String, Object?>.from(LearningSupportCodec.review(item))..remove('id'),
  );

  @override
  Future<void> saveBookmark(String uid, BookmarkModel item) => _set(
    uid,
    'bookmarks',
    item.id,
    _renameId(LearningSupportCodec.bookmark(item), 'bookmarkId'),
  );

  @override
  Future<void> saveNote(String uid, LearningNoteModel item) => _set(
    uid,
    'notes',
    item.id,
    _renameId(LearningSupportCodec.note(item), 'noteId'),
  );

  @override
  Future<void> resetProgress(String uid) async {
    for (final collection in const [
      'lesson_progress',
      'exercise_attempts',
      'skill_mastery',
      'review_items',
    ]) {
      final items = await _list(uid, collection);
      for (final item in items) {
        await _client.deleteDocument(
          _document(uid, collection, item['_documentId'] as String),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _list(String uid, String collection) {
    return _client.listDocuments('e3rab_users/$uid/$collection');
  }

  Future<void> _set(
    String uid,
    String collection,
    String id,
    Map<String, Object?> data,
  ) {
    return _client.setDocument(
      _document(uid, collection, id),
      data,
      serverTimestampFields: const ['updatedAt'],
    );
  }

  String _document(String uid, String collection, String id) =>
      'e3rab_users/$uid/$collection/$id';

  Map<String, Object?> _renameId(Map<String, Object?> source, String target) {
    final result = Map<String, Object?>.from(source);
    result[target] = result.remove('id');
    return result;
  }

  static Map<String, dynamic> _withId(Map<String, dynamic> source) => {
    ...source,
    'id': source['_documentId'],
  };
}
