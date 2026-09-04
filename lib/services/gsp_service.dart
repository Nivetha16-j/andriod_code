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

  static Future<Map<String, dynamic>> getSellBackDetails({
    required String currency,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final uri = Uri.parse(
        '$baseUrl/my-account/gsp/sell-backs',
      ).replace(queryParameters: {'currency': currency});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      log('Sell Back API Response: ${response.statusCode} ${response.body}');

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      log('Sell Back API error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchConvertPhysicalDetails({
    required String currency,
  }) async {
    final token = await SessionManager.getToken();
    final uri = Uri.parse(
      '$baseUrl/my-account/gsp/convert-physical',
    ).replace(queryParameters: {'currency': currency});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    log("ressssssss-- ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to fetch convert physical data: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> convertToPhysical({
    required String metal,
    required double amount,
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final url = Uri.parse(
      'https://staging.junubullion.com/api/my-account/gsp/wallet/convert',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'metal': metal.toLowerCase(),
        'amount': amount,
        'currency': currency,
      }),
    );

    log('CONVERT API STATUS: ${response.statusCode}');
    log('CONVERT API BODY: ${response.body}');

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {'status': false, 'message': 'Invalid response from server.'};
    } catch (e) {
      log('Convert API JSON error: $e');

      return {'status': false, 'message': 'Invalid response from server.'};
    }
  }

  static Future<Map<String, dynamic>> fetchMonthlyPlan(String currency) async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse(
          '$baseUrl/my-account/gsp/monthly-plan',
        ).replace(queryParameters: {'currency': currency}),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('GSP MONTHLY PLAN STATUS: ${response.statusCode}');

      log('GSP MONTHLY PLAN RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'status': false,
        'message': 'Failed to fetch GSP monthly plan (${response.statusCode})',
      };
    } catch (e) {
      log('GSP MONTHLY PLAN ERROR: $e');

      return {'status': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createMonthlyPayment({
    required double amount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/my-account/gsp/monthly-plan/pay'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'amount': amount,
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['status'] == true) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Unable to create Stripe payment session.',
    );
  }
}
