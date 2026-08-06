import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class TestimonialService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<List<dynamic>> fetchTestimonials() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/testimonials"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return body["data"];
    }

    throw Exception("Failed to load testimonials");
  }

  Future<Map<String, dynamic>> submitTestimonial({
    required String name,
    required String email,
    required int rating,
    required String description,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/testimonials"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "rating": rating,
        "description": description,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(data["message"] ?? "Failed to submit testimonial");
  }
}
