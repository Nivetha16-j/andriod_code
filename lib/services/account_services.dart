import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class AccountService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<Map<String, dynamic>> fetchAccountDetails() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/my-account/account-details"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("Fetch Account Details Status : ${response.statusCode}");
    log("Fetch Account Details Response : ${response.body}");

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateAccountDetails({
    required String name,
    required String email,
    required String phone,
  }) async {
    final token = await SessionManager.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/my-account/account-details"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "email": email, "phone_number": phone}),
    );

    log("Update Account Status : ${response.statusCode}");
    log(response.body);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final token = await SessionManager.getToken();

    log(
      "Update Password Request : $token $currentPassword $password $passwordConfirmation",
    );

    final response = await http.put(
      Uri.parse("$baseUrl/my-account/password"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "current_password": currentPassword.toString(),
        "password": password.toString(),
        "password_confirmation": passwordConfirmation.toString(),
      }),
    );

    log("Update Password Status : ${response.statusCode}");
    log(response.body);

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyPassword(String currentPassword) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/my-account/verify-password"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"current_password": currentPassword}),
    );

    return jsonDecode(response.body);
  }
}
