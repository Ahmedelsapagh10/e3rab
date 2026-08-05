import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<AuthUserModel> signInWithGoogle();

  Future<AuthUserModel> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> reauthenticate(String password);

  Future<void> reauthenticateWithProvider();

  Future<void> deleteCurrentAccount();

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
  Future<AuthUserModel> signInWithGoogle() async {
    UserCredential credential;
    if (kIsWeb) {
      credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
    } else {
      credential = await _firebaseAuth.signInWithCredential(
        await _googleCredential(),
      );
    }
    return _requiredUser(credential.user);
  }

  @override
  Future<AuthUserModel> signInWithApple() async {
    final provider = AppleAuthProvider();
    final credential = kIsWeb
        ? await _firebaseAuth.signInWithPopup(provider)
        : await _firebaseAuth.signInWithProvider(provider);
    return _requiredUser(credential.user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> reauthenticate(String password) async {
    final user = _firebaseAuth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> reauthenticateWithProvider() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');
    final providers = user.providerData.map((item) => item.providerId).toSet();
    if (providers.contains('apple.com')) {
      final provider = AppleAuthProvider();
      if (kIsWeb) {
        await user.reauthenticateWithPopup(provider);
      } else {
        await user.reauthenticateWithProvider(provider);
      }
      return;
    }
    if (providers.contains('google.com')) {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
      } else {
        await user.reauthenticateWithCredential(await _googleCredential());
      }
      return;
    }
    throw FirebaseAuthException(code: 'requires-recent-login');
  }

  @override
  Future<void> deleteCurrentAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'user-not-found');
    await user.delete();
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

  Future<OAuthCredential> _googleCredential() async {
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (error) {
      throw FirebaseAuthException(
        code: error.code == GoogleSignInExceptionCode.canceled
            ? 'sign-in-cancelled'
            : 'network-request-failed',
        message: error.description,
      );
    }
    return GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
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
