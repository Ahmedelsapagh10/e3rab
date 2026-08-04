import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ContentSeedWriteResult { seeded, unchanged }

abstract class ContentSeedDataSource {
  Future<ContentSeedWriteResult> seed(Map<String, dynamic> pack);
}

class FirestoreContentSeedDataSource implements ContentSeedDataSource {
  FirestoreContentSeedDataSource(this._firestore, this._auth);

  static const rootCollection = 'e3rab_content_packs';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<ContentSeedWriteResult> seed(Map<String, dynamic> pack) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('A content admin must be signed in.');
    final manifest = Map<String, dynamic>.from(pack['manifest'] as Map);
    final packId = manifest['packId'] as String;
    final packReference = _firestore.collection(rootCollection).doc(packId);
    final existing = await packReference.get();
    if (existing.data()?['checksum'] == manifest['checksum']) {
      return ContentSeedWriteResult.unchanged;
    }

    final batch = _firestore.batch();
    batch.set(packReference, {
      ...manifest,
      'seededBy': user.uid,
      'seededAt': FieldValue.serverTimestamp(),
    });
    _addEntities(batch, packReference, 'modules', pack['modules']);
    _addEntities(batch, packReference, 'units', pack['units']);
    _addEntities(batch, packReference, 'lessons', pack['lessons']);
    _addEntities(batch, packReference, 'exercises', pack['exercises']);
    _addEntities(batch, packReference, 'references', pack['references']);
    await batch.commit();
    return ContentSeedWriteResult.seeded;
  }

  void _addEntities(
    WriteBatch batch,
    DocumentReference<Map<String, dynamic>> pack,
    String collection,
    Object? values,
  ) {
    for (final value in values as List) {
      final data = Map<String, dynamic>.from(value as Map);
      batch.set(pack.collection(collection).doc(data['id'] as String), data);
    }
  }
}
