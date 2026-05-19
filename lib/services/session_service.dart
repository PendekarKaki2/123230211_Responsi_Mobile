import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService(this._preferences);

  static const _isLoggedInKey = 'is_logged_in';
  static const _usernameKey = 'username';

  final SharedPreferences _preferences;

  Future<void> saveLogin(String username) async {
    await _preferences.setBool(_isLoggedInKey, true);
    await _preferences.setString(_usernameKey, username);
  }

  Future<bool> isLoggedIn() async {
    return _preferences.getBool(_isLoggedInKey) ?? false;
  }

  Future<String> getUsername() async {
    return _preferences.getString(_usernameKey) ?? '';
  }

  Future<void> logout() async {
    await _preferences.remove(_isLoggedInKey);
    await _preferences.remove(_usernameKey);
  }
}
