import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/model/auth_user_model.dart';
import '../model/e3rab_user_profile.dart';
import 'firestore_user_data_purger.dart';

abstract class FirestoreUserDataSource {
  Stream<E3rabUserProfile?> watchProfile(String uid);

  Future<E3rabUserProfile?> getProfile(String uid);

  Future<E3rabUserProfile> createOrRepairProfile(AuthUserModel user);

  Future<void> upsertProfile(E3rabUserProfile profile);

  Future<void> deleteProfile(String uid);
}

class FirestoreUserDataSourceImpl implements FirestoreUserDataSource {
  FirestoreUserDataSourceImpl(this._firestore)
    : _purger = FirestoreUserDataPurger(_firestore);

  static const _collection = 'e3rab_users';
  final FirebaseFirestore _firestore;
  final FirestoreUserDataPurger _purger;

  @override
  Stream<E3rabUserProfile?> watchProfile(String uid) {
    return _reference(uid).snapshots().map(_profileFromSnapshot);
  }

  @override
  Future<E3rabUserProfile?> getProfile(String uid) async {
    return _profileFromSnapshot(await _reference(uid).get());
  }

  @override
  Future<E3rabUserProfile> createOrRepairProfile(AuthUserModel user) async {
    final reference = _reference(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (snapshot.exists) {
        transaction.set(reference, _repairedProfileData(snapshot.data(), user));
        return;
      }
      transaction.set(reference, _newProfileData(user));
    });
    return (await getProfile(user.uid))!;
  }

  @override
  Future<void> upsertProfile(E3rabUserProfile profile) async {
    final reference = _reference(profile.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final data = _profileData(profile);
      if (snapshot.exists) {
        transaction.update(reference, data);
      } else {
        transaction.set(reference, {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> deleteProfile(String uid) async {
    await _purger.purgeSubcollections(uid);
    await _reference(uid).delete();
  }

  DocumentReference<Map<String, dynamic>> _reference(String uid) {
    return _firestore.collection(_collection).doc(uid);
  }

  Map<String, Object?> _newProfileData(AuthUserModel user) => {
    'uid': user.uid,
    'email': user.email,
    'displayName': user.displayName,
    'photoUrl': user.photoUrl,
    'authProviders': user.providerIds,
    'learningRole': LearningRole.student.name,
    'countryCode': 'EG',
    'preferredLocale': 'ar',
    'onboardingCompleted': false,
    'profileSchemaVersion': 1,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, Object?> _repairedProfileData(
    Map<String, dynamic>? existing,
    AuthUserModel user,
  ) {
    final data = existing ?? const <String, dynamic>{};
    final roles = LearningRole.values.map((role) => role.name).toSet();
    final role = data['learningRole'];
    final repaired = <String, Object?>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'authProviders': user.providerIds,
      'learningRole': role is String && roles.contains(role)
          ? role
          : LearningRole.student.name,
      'countryCode': data['countryCode'] is String ? data['countryCode'] : 'EG',
      'preferredLocale': data['preferredLocale'] is String
          ? data['preferredLocale']
          : 'ar',
      'onboardingCompleted': data['onboardingCompleted'] is bool
          ? data['onboardingCompleted']
          : false,
      'profileSchemaVersion': data['profileSchemaVersion'] is int
          ? data['profileSchemaVersion']
          : 1,
      'createdAt': data['createdAt'] is Timestamp
          ? data['createdAt']
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    for (final key in const [
      'curriculumId',
      'curriculumVersionId',
      'stageId',
      'gradeId',
      'grammarLevel',
      'learningGoal',
    ]) {
      if (data[key] == null || data[key] is String) repaired[key] = data[key];
    }
    if (data['dailyGoalMinutes'] is int) {
      repaired['dailyGoalMinutes'] = data['dailyGoalMinutes'];
    }
    return repaired;
  }

  Map<String, Object?> _profileData(E3rabUserProfile profile) => {
    'uid': profile.uid,
    'email': profile.email,
    'displayName': profile.displayName,
    'photoUrl': profile.photoUrl,
    'authProviders': profile.authProviders,
    'learningRole': profile.learningRole.name,
    'countryCode': profile.countryCode,
    'curriculumId': profile.curriculumId,
    'curriculumVersionId': profile.curriculumVersionId,
    'stageId': profile.stageId,
    'gradeId': profile.gradeId,
    'grammarLevel': profile.grammarLevel,
    'learningGoal': profile.learningGoal,
    'dailyGoalMinutes': profile.dailyGoalMinutes,
    'preferredLocale': profile.preferredLocale,
    'onboardingCompleted': profile.onboardingCompleted,
    'profileSchemaVersion': profile.profileSchemaVersion,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  E3rabUserProfile? _profileFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return E3rabUserProfile(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      authProviders: List<String>.from(data['authProviders'] as List? ?? []),
      learningRole: LearningRole.values.byName(data['learningRole'] as String),
      countryCode: data['countryCode'] as String,
      curriculumId: data['curriculumId'] as String?,
      curriculumVersionId: data['curriculumVersionId'] as String?,
      stageId: data['stageId'] as String?,
      gradeId: data['gradeId'] as String?,
      grammarLevel: data['grammarLevel'] as String?,
      learningGoal: data['learningGoal'] as String?,
      dailyGoalMinutes: data['dailyGoalMinutes'] as int?,
      preferredLocale: data['preferredLocale'] as String,
      onboardingCompleted: data['onboardingCompleted'] as bool,
      profileSchemaVersion: data['profileSchemaVersion'] as int,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
    );
  }

  DateTime _date(Object? value) {
    return value is Timestamp ? value.toDate() : DateTime.now().toUtc();
  }
}
