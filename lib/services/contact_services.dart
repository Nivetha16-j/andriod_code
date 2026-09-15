import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class ContactService {
  // Use your existing API base URL here
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<Map<String, dynamic>> submitContact({
    required String firstName,
    required String lastName,
    required String email,
    required String description,
  }) async {
    final token = await SessionManager.getToken();
    try {
      final url = Uri.parse('$baseUrl/contact-us');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "description": description,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      }

      throw Exception(responseData['message'] ?? 'Something went wrong');
    } catch (e) {
      rethrow;
    }
  }
}
