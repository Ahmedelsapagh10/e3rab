import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserDataPurger {
  FirestoreUserDataPurger(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> purgeSubcollections(String uid) async {
    for (final collection in const [
      'lesson_progress',
      'exercise_attempts',
      'skill_mastery',
      'review_items',
      'bookmarks',
      'notes',
    ]) {
      await _deleteCollection(uid, collection);
    }
  }

  Future<void> _deleteCollection(String uid, String collection) async {
    final reference = _firestore.collection('e3rab_users').doc(uid);
    while (true) {
      final snapshot = await reference.collection(collection).limit(400).get();
      if (snapshot.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }
}
