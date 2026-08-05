import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/auth_user_model.dart';

class DesktopAuthCache {
  const DesktopAuthCache();

  static const _storage = FlutterSecureStorage();
  static const _refreshKey = 'e3rab_firebase_refresh_token';
  static const _userKey = 'e3rab_firebase_cached_user';

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> writeRefreshToken(String value) =>
      _storage.write(key: _refreshKey, value: value);

  Future<void> writeUser(AuthUserModel user) => _storage.write(
    key: _userKey,
    value: jsonEncode({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'providerIds': user.providerIds,
      'isEmailVerified': user.isEmailVerified,
    }),
  );

  Future<AuthUserModel?> readUser() async {
    final source = await _storage.read(key: _userKey);
    if (source == null) return null;
    final user = Map<String, dynamic>.from(jsonDecode(source) as Map);
    return AuthUserModel(
      uid: user['uid'] as String,
      email: user['email'] as String,
      displayName: user['displayName'] as String?,
      photoUrl: user['photoUrl'] as String?,
      providerIds: List<String>.from(user['providerIds'] as List),
      isEmailVerified: user['isEmailVerified'] as bool,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }
}
