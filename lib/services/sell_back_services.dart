import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class SellBackServices {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<Map<String, dynamic>> submitSellBack({
    required String plan,
    required String metal,
    required double amount,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    String? ifscCode,
    String? swiftCode,
    required String bankBranch,
    required String currency,
  }) async {
    try {
      final token = await SessionManager.getToken();
      final String endpoint;

      if (plan.toLowerCase() == 'gsp') {
        endpoint = '$baseUrl/my-account/gsp/wallet/sell-back';
      } else {
        // KEEP YOUR EXISTING JSC ENDPOINT HERE
        endpoint = '$baseUrl/my-account/wallet/sell-back';
      }

      final payload = {
        'metal': metal,
        'amount': amount,
        'account_holder_name': accountHolderName,
        'bank_name': bankName,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
        'swift_code': swiftCode,
        'bank_branch': bankBranch,
        'currency': currency,
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      log('SELL BACK STATUS: ${response.statusCode}');
      log('SELL BACK RESPONSE: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      }

      throw Exception(
        responseData['message'] ?? 'Failed to submit sell back request',
      );
    } catch (e) {
      log('SELL BACK API ERROR: $e');
      rethrow;
    }
  }
}
