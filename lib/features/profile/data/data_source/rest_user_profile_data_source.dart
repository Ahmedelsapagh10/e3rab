import '../../../../core/firebase/firestore_rest_client.dart';
import '../../../auth/data/model/auth_user_model.dart';
import '../model/e3rab_user_profile.dart';
import 'firestore_user_data_source.dart';

class RestUserProfileDataSource implements FirestoreUserDataSource {
  RestUserProfileDataSource(this._client);

  final FirestoreRestClient _client;

  @override
  Stream<E3rabUserProfile?> watchProfile(String uid) =>
      Stream.fromFuture(getProfile(uid));

  @override
  Future<E3rabUserProfile?> getProfile(String uid) async {
    final data = await _client.getDocument(_path(uid));
    return data == null ? null : E3rabUserProfile.fromLocalJson(data);
  }

  @override
  Future<E3rabUserProfile> createOrRepairProfile(AuthUserModel user) async {
    final existing = await getProfile(user.uid);
    if (existing != null) return existing;
    final now = DateTime.now().toUtc();
    final profile = E3rabUserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      authProviders: user.providerIds,
      learningRole: LearningRole.independentLearner,
      countryCode: 'GLOBAL',
      preferredLocale: 'ar',
      onboardingCompleted: true,
      profileSchemaVersion: 1,
      createdAt: now,
      updatedAt: now,
    );
    await _client.setDocument(
      _path(profile.uid),
      profile.toLocalJson(),
      serverTimestampFields: const ['createdAt', 'updatedAt'],
    );
    return profile;
  }

  @override
  Future<void> upsertProfile(E3rabUserProfile profile) {
    return _client.setDocument(
      _path(profile.uid),
      profile.toLocalJson(),
      serverTimestampFields: const ['updatedAt'],
    );
  }

  @override
  Future<void> deleteProfile(String uid) async {
    for (final collection in const [
      'lesson_progress',
      'exercise_attempts',
      'skill_mastery',
      'review_items',
      'bookmarks',
      'notes',
    ]) {
      final documents = await _client.listDocuments(
        'e3rab_users/$uid/$collection',
      );
      for (final document in documents) {
        await _client.deleteDocument(
          'e3rab_users/$uid/$collection/${document['_documentId']}',
        );
      }
    }
    await _client.deleteDocument(_path(uid));
  }

  String _path(String uid) => 'e3rab_users/$uid';
}
