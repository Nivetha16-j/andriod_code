import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class GspService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  /// Unlock GSP wallet.
  ///
  /// This API BOTH:
  /// 1. Unlocks the wallet
  /// 2. Returns gold/silver wallet values
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

    log('GSP UNLOCK STATUS CODE -> ${response.statusCode}');

    log('GSP UNLOCK RAW RESPONSE -> ${response.body}');

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Invalid response from server.');
    }

    if (decoded is! Map) {
      throw Exception('Invalid response from server.');
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

    log('GSP UNLOCK RESPONSE -> $data');

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['status'] == true) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ?? 'Unable to unlock balances.',
    );
  }

  static Future<Map<String, dynamic>> fetchWallet({
    required String currency,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-account/gsp/my-wallet?currency=$currency'),
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

  static Future<Map<String, dynamic>> getPurchases({
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/my-account/gsp/purchases?currency=${currency}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message']?.toString() ?? 'Failed to fetch purchases');
  }
}
