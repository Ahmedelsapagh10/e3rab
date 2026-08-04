import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  OnboardingRepository(this._preferences);

  static const _completionKey = 'e3rab_intro_completed';
  final SharedPreferences _preferences;

  bool get isCompleted => _preferences.getBool(_completionKey) ?? false;

  Future<void> complete() => _preferences.setBool(_completionKey, true);
}
