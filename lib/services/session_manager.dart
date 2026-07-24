import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String isLoggedInKey = "isLoggedIn";
  static const String userKey = "user";

  /// Save login state
  static Future<void> saveLogin(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(userKey, jsonEncode(userData));
  }

  /// Check login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(isLoggedInKey) ?? false;
  }

  /// Get user
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final user = prefs.getString(userKey);

    if (user == null) return null;

    return jsonDecode(user);
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(isLoggedInKey);
    await prefs.remove(userKey);
  }
}
