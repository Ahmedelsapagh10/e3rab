import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class MySecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _languageKey = 'language';
  static const _darkModeKey = 'isDark';

  static Future<String> getLanguage() async {
    return await _storage.read(key: _languageKey) ?? 'ar';
  }

  static Future<void> setLanguage(String value) {
    return _storage.write(key: _languageKey, value: value);
  }

  static Future<bool> getIsDark() async {
    return await _storage.read(key: _darkModeKey) == 'true';
  }

  static Future<void> setIsDark(bool value) {
    return _storage.write(key: _darkModeKey, value: value.toString());
  }
}
