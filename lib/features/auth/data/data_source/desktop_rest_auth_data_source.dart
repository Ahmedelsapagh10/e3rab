import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/auth_user_model.dart';
import 'desktop_auth_cache.dart';
import 'desktop_auth_rest_client.dart';
import 'firebase_auth_data_source.dart';

class DesktopRestAuthDataSource implements FirebaseAuthDataSource {
  DesktopRestAuthDataSource._(this._rest, this._cache);

  final DesktopAuthRestClient _rest;
  final DesktopAuthCache _cache;
  final StreamController<AuthUserModel?> _controller =
      StreamController<AuthUserModel?>.broadcast();
  AuthUserModel? _currentUser;
  String? _idToken;
  DateTime? _expiresAt;

  static Future<DesktopRestAuthDataSource> create({
    required Dio client,
    required String apiKey,
  }) async {
    final source = DesktopRestAuthDataSource._(
      DesktopAuthRestClient(client, apiKey),
      const DesktopAuthCache(),
    );
    await source._restore();
    return source;
  }

  String? get idToken => _idToken;

  Future<String> getValidIdToken() async {
    if (_idToken == null ||
        _expiresAt == null ||
        DateTime.now().toUtc().isAfter(
          _expiresAt!.subtract(const Duration(minutes: 2)),
        )) {
      await _refreshSession();
    }
    if (_idToken == null) {
      throw FirebaseAuthException(code: 'user-token-expired');
    }
    return _idToken!;
  }

  @override
  AuthUserModel? get currentUser => _currentUser;

  @override
  Stream<AuthUserModel?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUserModel> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final data = await _rest.post('accounts:signUp', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    await _acceptSession(data);
    if (displayName?.trim().isNotEmpty == true) {
      await _rest.post('accounts:update', {
        'idToken': _idToken,
        'displayName': displayName!.trim(),
        'returnSecureToken': true,
      });
      await _lookup();
    }
    return _currentUser!;
  }

  @override
  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final data = await _rest.post('accounts:signInWithPassword', {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });
    await _acceptSession(data);
    return _currentUser!;
  }

  @override
  Future<AuthUserModel> signInWithGoogle() => _unsupported('google');

  @override
  Future<AuthUserModel> signInWithApple() => _unsupported('apple');

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _rest.post('accounts:sendOobCode', {
      'requestType': 'PASSWORD_RESET',
      'email': email,
    });
  }

  @override
  Future<void> reauthenticate(String password) async {
    final email = _currentUser?.email;
    if (email == null) throw FirebaseAuthException(code: 'user-not-found');
    await signIn(email: email, password: password);
  }

  @override
  Future<void> reauthenticateWithProvider() {
    throw FirebaseAuthException(code: 'operation-not-supported');
  }

  @override
  Future<void> deleteCurrentAccount() async {
    await _rest.post('accounts:delete', {'idToken': _idToken});
    await signOut();
  }

  @override
  Future<void> signOut() async {
    _idToken = null;
    _expiresAt = null;
    _currentUser = null;
    await _cache.clear();
    _controller.add(null);
  }

  Future<void> _restore() async {
    final refreshToken = await _cache.readRefreshToken();
    if (refreshToken == null) return;
    try {
      await _refreshSession(refreshToken: refreshToken);
      await _lookup();
    } catch (_) {
      _currentUser = await _cache.readUser();
    }
  }

  Future<void> _acceptSession(Map<String, dynamic> data) async {
    _idToken = data['idToken'] as String;
    _expiresAt = DateTime.now().toUtc().add(
      Duration(seconds: int.tryParse(data['expiresIn'].toString()) ?? 3600),
    );
    await _cache.writeRefreshToken(data['refreshToken'] as String);
    await _lookup();
    _controller.add(_currentUser);
  }

  Future<void> _refreshSession({String? refreshToken}) async {
    final token = refreshToken ?? await _cache.readRefreshToken();
    if (token == null) throw FirebaseAuthException(code: 'user-token-expired');
    final data = await _rest.refresh(token);
    _idToken = data['id_token'] as String;
    _expiresAt = DateTime.now().toUtc().add(
      Duration(seconds: int.tryParse(data['expires_in'].toString()) ?? 3600),
    );
    await _cache.writeRefreshToken(data['refresh_token'] as String);
  }

  Future<void> _lookup() async {
    final data = await _rest.post('accounts:lookup', {'idToken': _idToken});
    final user = Map<String, dynamic>.from(
      (data['users'] as List).first as Map,
    );
    _currentUser = AuthUserModel(
      uid: user['localId'] as String,
      email: user['email'] as String? ?? '',
      displayName: user['displayName'] as String?,
      photoUrl: user['photoUrl'] as String?,
      providerIds: const ['password'],
      isEmailVerified: user['emailVerified'] as bool? ?? false,
    );
    await _cache.writeUser(_currentUser!);
  }

  Future<AuthUserModel> _unsupported(String provider) {
    throw FirebaseAuthException(
      code: 'operation-not-supported',
      message: '$provider is not supported on this desktop platform.',
    );
  }
}
