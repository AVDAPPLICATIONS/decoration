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
    print('✅ Token saved to shared preferences');
  }

  // ✅ Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('🔍 Token retrieved: ${token != null ? 'Found' : 'Not found'}');
    return token;
  }

  // ✅ Clear token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('🗑️ Token cleared from shared preferences');
  }

  // ✅ Save user data
  Future<void> saveUserData(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = user.toJson();
      final userJsonString = jsonEncode(userJson);
      await prefs.setString(_userDataKey, userJsonString);
      print('✅ User data saved to shared preferences: ${user.username}');
      print('📝 Saved data: $userJsonString');
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  // ✅ Get user data
  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userDataKey);
      
      print('🔍 Checking for saved user data: ${userJsonString != null ? 'Found' : 'Not found'}');
      
      if (userJsonString != null) {
        try {
          final userJson = jsonDecode(userJsonString);
          final user = UserModel.fromJson(userJson);
          print('✅ User data restored: ${user.username} (${user.role})');
          return user;
        } catch (e) {
          print('❌ Error parsing saved user data: $e');
          print('📝 Raw data: $userJsonString');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // ✅ Clear user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_tokenKey); // Also clear token
      print('🗑️ All user data cleared from shared preferences');
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
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
      print('🗑️ All shared preferences data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
    }
  }

  // ✅ Get all stored keys (for debugging)
  Future<List<String>> getAllKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getKeys().toList();
    } catch (e) {
      print('❌ Error getting keys: $e');
      return [];
    }
  }
}
