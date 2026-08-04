import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/learning_progress_models.dart';
import '../model/learning_support_models.dart';
import 'firestore_learning_mapper.dart';
import 'local_learning_data_source.dart';

class FirestoreLearningDataSource {
  FirestoreLearningDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<LearningSnapshot> fetch(String uid) async {
    final results = await Future.wait([
      _collection(uid, 'lesson_progress').get(),
      _collection(uid, 'exercise_attempts').get(),
      _collection(uid, 'skill_mastery').get(),
      _collection(uid, 'review_items').get(),
      _collection(uid, 'bookmarks').get(),
      _collection(uid, 'notes').get(),
    ]);
    return LearningSnapshot(
      progress: results[0].docs
          .map((doc) => FirestoreLearningMapper.progress(doc.data()))
          .toList(),
      attempts: results[1].docs
          .map((doc) => FirestoreLearningMapper.attempt(doc.data()))
          .toList(),
      mastery: results[2].docs
          .map((doc) => FirestoreLearningMapper.mastery(doc.data()))
          .toList(),
      reviews: results[3].docs
          .map((doc) => FirestoreLearningMapper.review(doc.id, doc.data()))
          .toList(),
      bookmarks: results[4].docs
          .map((doc) => FirestoreLearningMapper.bookmark(doc.id, doc.data()))
          .toList(),
      notes: results[5].docs
          .map((doc) => FirestoreLearningMapper.note(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<void> saveProgress(String uid, LessonProgressModel item) {
    return _doc(uid, 'lesson_progress', item.lessonId).set({
      'lessonId': item.lessonId,
      'contentVersion': item.contentVersion,
      'status': item.status.name,
      'startedAt': _timestamp(item.startedAt),
      'completedAt': _timestamp(item.completedAt),
      'lastOpenedAt': _timestamp(item.lastOpenedAt),
      'completedSectionIds': item.completedSectionIds,
      'attemptCount': item.attemptCount,
      'bestScore': item.bestScore,
      'masteryScore': item.masteryScore,
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': item.schemaVersion,
    });
  }

  Future<void> appendAttempt(String uid, ExerciseAttemptModel item) async {
    final reference = _doc(uid, 'exercise_attempts', item.attemptId);
    if ((await reference.get()).exists) return;
    await reference.set({
      'attemptId': item.attemptId,
      'exerciseId': item.exerciseId,
      'lessonId': item.lessonId,
      'skillIds': item.skillIds,
      'contentVersion': item.contentVersion,
      'selectedAnswer': item.selectedAnswer,
      'isCorrect': item.isCorrect,
      'scoreWeight': item.scoreWeight,
      'hintUsed': item.hintUsed,
      'attemptNumber': item.attemptNumber,
      'durationMilliseconds': item.durationMilliseconds,
      'clientCreatedAt': Timestamp.fromDate(item.clientCreatedAt),
      'serverCreatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': item.schemaVersion,
    });
  }

  Future<void> saveMastery(String uid, SkillMasteryModel item) {
    return _doc(uid, 'skill_mastery', item.skillId).set({
      'skillId': item.skillId,
      'score': item.score,
      'state': item.state.name,
      'scoredAttemptCount': item.scoredAttemptCount,
      'unhintedCorrectCount': item.unhintedCorrectCount,
      'lastPracticedAt': Timestamp.fromDate(item.lastPracticedAt),
      'nextReviewAt': Timestamp.fromDate(item.nextReviewAt),
      'algorithmVersion': item.algorithmVersion,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveReview(String uid, ReviewItemModel item) {
    return _doc(uid, 'review_items', item.id).set({
      'targetType': item.targetType,
      'targetId': item.targetId,
      'dueAt': Timestamp.fromDate(item.dueAt),
      'intervalLevel': item.intervalLevel,
      'lastResult': item.lastResult,
      'updatedAt': FieldValue.serverTimestamp(),
      'algorithmVersion': item.algorithmVersion,
    });
  }

  Future<void> saveBookmark(String uid, BookmarkModel item) {
    return _doc(uid, 'bookmarks', item.id).set({
      'bookmarkId': item.id,
      'targetType': item.targetType,
      'targetId': item.targetId,
      'contentVersion': item.contentVersion,
      'createdAt': Timestamp.fromDate(item.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': _timestamp(item.deletedAt),
    });
  }

  Future<void> saveNote(String uid, LearningNoteModel item) {
    return _doc(uid, 'notes', item.id).set({
      'noteId': item.id,
      'targetType': item.targetType,
      'targetId': item.targetId,
      'text': item.text,
      'localVersion': item.localVersion,
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': _timestamp(item.deletedAt),
      'schemaVersion': item.schemaVersion,
    });
  }

  Future<void> resetProgress(String uid) async {
    for (final collection in const [
      'lesson_progress',
      'exercise_attempts',
      'skill_mastery',
      'review_items',
    ]) {
      await _deleteCollection(uid, collection);
    }
  }

  Future<void> _deleteCollection(String uid, String collection) async {
    while (true) {
      final snapshot = await _collection(uid, collection).limit(400).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  DocumentReference<Map<String, dynamic>> _doc(
    String uid,
    String collection,
    String id,
  ) {
    return _firestore
        .collection('e3rab_users')
        .doc(uid)
        .collection(collection)
        .doc(id);
  }

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String collection,
  ) {
    return _firestore.collection('e3rab_users').doc(uid).collection(collection);
  }

  Object? _timestamp(DateTime? date) {
    return date == null ? null : Timestamp.fromDate(date);
  }
}
