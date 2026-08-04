import 'package:shared_preferences/shared_preferences.dart';

import '../exports.dart';

late SharedPreferences prefs;

class Preferences {
  static final Preferences instance = Preferences._internal();

  Preferences._internal();

  factory Preferences() => instance;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Save app language using SharedPreferences
  Future<void> savedLang(String local) async {
    await prefs.setString(AppStrings.locale, local);
  }

  /// Get app language using SharedPreferences
  Future<String> getSavedLang() async {
    return prefs.getString(AppStrings.locale) ?? 'ar'; // Default to 'ar'
  }

  /// Save app language using SharedPreferences

  Future<void> setDeviceToken(String token) async {
    await prefs.setString('device_token', token);
  }

  /// Get app language using SharedPreferences
  Future<String> getDeviceToken() async {
    return prefs.getString('device_token') ?? 'device_token';
  }
}
