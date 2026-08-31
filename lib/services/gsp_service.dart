import 'dart:convert';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class GspService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<Map<String, dynamic>> unlockWallet({
    required String unlockPassword,
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/my-account/gsp/wallet/unlock'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'unlock_password': unlockPassword,
        'currency': currency,
      }),
    );

    final data = jsonDecode(response.body);

    log("Unnnn $data......${data['message']}");

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['status'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Unable to unlock balances.');
  }

  static Future<Map<String, dynamic>> fetchWallet({
    required String currency,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-account/gsp/wallet?currency=$currency'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await SessionManager.getToken()}',
        },
      );

      log('Wallet API status: ${response.statusCode}');
      log('Wallet API response: ${response.body}');

      final data = jsonDecode(response.body);

      return data is Map<String, dynamic>
          ? data
          : {'status': false, 'message': 'Invalid wallet response.'};
    } catch (e) {
      log('fetchWallet error: $e');

      return {'status': false, 'message': e.toString()};
    }
  }
}
