import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // ✅ Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ✅ Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    return token;
  }

  // ✅ Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ✅ Save user data
  Future<void> saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = user.toJson();
      final userJsonString = jsonEncode(userJson);
      await prefs.setString(_userDataKey, userJsonString);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ Get user data
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userDataKey);

      if (userJsonString != null) {
        try {
          final userJson = jsonDecode(userJsonString);
          final user = UserModel.fromJson(userJson);

          return user;
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ Clear user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_tokenKey); // Also clear token
    } catch (e) {}
  }

  // ✅ Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final userData = await getUserData();
    return userData != null;
  }

  // ✅ Clear all stored data (for testing)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {}
  }

  // ✅ Get all stored keys (for debugging)
  Future<List<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys().toList();
    } catch (e) {
      return [];
    }
  }
}
