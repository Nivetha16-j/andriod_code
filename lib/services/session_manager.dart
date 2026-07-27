import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String isLoggedInKey = "isLoggedIn";
  static const String userKey = "user";
  static const String tokenKey = "token";

  static Future<void> saveLogin({
    required Map<String, dynamic> user,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    log("Saving Login...");
    log("uuuuuuuu ${user}");
    log("tttttttt ${token}");

    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(userKey, jsonEncode(user));
    await prefs.setString(tokenKey, token);

    log("isloginkey ${await prefs.getBool(isLoggedInKey)}");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final user = prefs.getString(userKey);

    if (user == null) return null;

    return jsonDecode(user);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
