import 'package:shared_preferences/shared_preferences.dart';

/// Shared Preferences Helper
class StorageService {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  static late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save token
  static Future<void> saveToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  /// Get token
  static String? getToken() {
    return _prefs.getString(tokenKey);
  }

  /// Save user data
  static Future<void> saveUserData(String userData) async {
    await _prefs.setString(userKey, userData);
  }

  /// Get user data
  static String? getUserData() {
    return _prefs.getString(userKey);
  }

  /// Save user ID
  static Future<void> saveUserId(String userId) async {
    await _prefs.setString(userIdKey, userId);
  }

  /// Get user ID
  static String? getUserId() {
    return _prefs.getString(userIdKey);
  }

  /// Save user role
  static Future<void> saveUserRole(String role) async {
    await _prefs.setString(userRoleKey, role);
  }

  /// Get user role
  static String? getUserRole() {
    return _prefs.getString(userRoleKey);
  }

  /// Clear all data (logout)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return _prefs.containsKey(tokenKey);
  }
}
