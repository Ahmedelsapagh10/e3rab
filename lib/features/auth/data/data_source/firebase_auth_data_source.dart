import 'package:firebase_auth/firebase_auth.dart';

import '../model/auth_user_model.dart';

abstract class FirebaseAuthDataSource {
  Stream<AuthUserModel?> authStateChanges();

  AuthUserModel? get currentUser;

  Future<AuthUserModel> createAccount({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthUserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapUser);
  }

  @override
  AuthUserModel? get currentUser => _mapUser(_firebaseAuth.currentUser);

  @override
  Future<AuthUserModel> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName?.trim().isNotEmpty == true) {
      await credential.user?.updateDisplayName(displayName!.trim());
      await credential.user?.reload();
    }
    return _requiredUser(_firebaseAuth.currentUser ?? credential.user);
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _requiredUser(credential.user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  AuthUserModel _requiredUser(User? user) {
    final mapped = _mapUser(user);
    if (mapped == null) {
      throw StateError('Firebase did not return an authenticated user.');
    }
    return mapped;
  }

  AuthUserModel? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      providerIds: user.providerData.map((item) => item.providerId).toList(),
      isEmailVerified: user.emailVerified,
    );
  }
}
