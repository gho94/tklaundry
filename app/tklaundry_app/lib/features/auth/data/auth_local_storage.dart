import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _keyAutoLogin = 'auth_auto_login';
  static const _keyUserId = 'auth_user_id';
  static const _keyPassword = 'auth_password';

  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLogin) ?? false;
  }

  Future<({String userId, String password})?> readCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyAutoLogin) != true) return null;

    final userId = prefs.getString(_keyUserId);
    final password = prefs.getString(_keyPassword);
    if (userId == null ||
        userId.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }

    return (userId: userId, password: password);
  }

  Future<void> save({
    required String userId,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyPassword, password);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAutoLogin);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPassword);
  }
}
