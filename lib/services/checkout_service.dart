import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> placeOrder({
    required String shippingAddress,
    required String deliveryOption,
    String? digitalType,
    required String courierService,
    required bool terms,
    required String paymentType,
    required String currency,
  }) async {
    try {
      final token = await SessionManager.getToken();

      // Build payload
      final Map<String, dynamic> payload = {
        "shipping_address": shippingAddress,
        "delivery_option": deliveryOption.toLowerCase(),
        "courier_service": courierService.toLowerCase(),
        "terms": terms,
        "payment_type": paymentType,
        "currency": currency,
      };

      // Add digital_type only for Digital delivery
      if (deliveryOption.toLowerCase() == "digital" &&
          digitalType != null &&
          digitalType.isNotEmpty) {
        payload["digital_type"] = digitalType.toLowerCase();
      }

      log("Request => Token: $token");
      log("Payload => ${jsonEncode(payload)}");

      final response = await http
          .post(
            Uri.parse("https://staging.junubullion.com/api/checkout/place"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      log("Status Code : ${response.statusCode}");
      log("Response Body : ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return body;
      } else {
        throw Exception(body["message"] ?? "Failed to place order.");
      }
    } on SocketException {
      throw Exception("No internet connection.");
    } on FormatException {
      throw Exception("Invalid response received from server.");
    } on http.ClientException catch (e) {
      throw Exception("HTTP Error: ${e.message}");
    } on Exception catch (e) {
      log("Checkout Exception: $e");
      rethrow;
    } catch (e, stackTrace) {
      log("Unexpected Error: $e");
      log(stackTrace.toString());
      throw Exception("Something went wrong.");
    }
  }

  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<List<String>> fetchPaymentMethods() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/my-account/payment-methods"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("Status: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return (json["data"] as List)
          .map((e) => e["payment_method"].toString())
          .toList();
    } else {
      throw Exception("Failed to fetch payment methods");
    }
  }
}
