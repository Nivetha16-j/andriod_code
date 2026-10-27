import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> placeOrder({
    required String shippingAddress,
    required String city,
    required String state,
    required String pin,
    required String contactPerson,
    required String contactEmail,
    required String contactPhone,
    required String deliveryOption,
    String? digitalType,
    String? courierService,
    required bool terms,
    required String paymentType,
    required String currency,
    String? customerBank,
  }) async {
    try {
      final token = await SessionManager.getToken();

      // Build payload
      final Map<String, dynamic> payload = {
        "street_address": shippingAddress,
        "city": city,
        "state": state,
        "pin": pin,
        "contact_person": contactPerson,
        "contact_email": contactEmail,
        "contact_number": contactPhone,
        // "shipping_address": shippingAddress,
        "delivery_option": deliveryOption.toLowerCase(),
        "courier_service": courierService,
        "terms": terms,
        "payment_type": paymentType,
        "customer_bank": customerBank,
        "currency": currency,
      };

      log("ccccc $courierService");

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

  static Future<Map<String, dynamic>> placePhysicalOrder({
    required String shippingAddress,
    required String city,
    required String state,
    required String pin,
    required String contactPerson,
    required String contactEmail,
    required String contactPhone,
    required bool terms,
    required String digitalType,
  }) async {
    final token = await SessionManager.getToken();

    final normalizedDigitalType = digitalType.trim().toLowerCase();

    if (normalizedDigitalType != 'jsc' && normalizedDigitalType != 'gsp') {
      return {"status": false, "message": "Invalid digital type."};
    }

    final uri = Uri.parse('https://staging.junubullion.com/api/checkout/place');

    final body = {
      "delivery_option": "physical",
      "digital_type": normalizedDigitalType,
      "terms": terms,
      "payment_type": "wallet",
      "payment_method": "wallet",
      "courier_service": "",
      "shipping_address": shippingAddress,
      "city": city,
      "state": state,
      "pin": pin,
      "contact_person": contactPerson,
      "contact_email": contactEmail,
      "contact_number": contactPhone,
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);

    log(
      "PHYSICAL CHECKOUT API -> "
      "statusCode=${response.statusCode}, "
      "response=$responseData",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(responseData);
    }

    throw Exception(
      responseData["message"]?.toString() ?? "Unable to place physical order",
    );
  }

  static Future<Map<String, dynamic>> generateUpiQr({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse("$baseUrl/checkout/upi/preview"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      log("UPI QR STATUS => ${response.statusCode}");
      log("UPI QR RESPONSE => ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(body);
      }

      throw Exception(
        body["message"]?.toString() ?? "Failed to generate UPI QR",
      );
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response from server");
    } catch (e) {
      throw Exception("Failed to generate UPI QR: $e");
    }
  }

  static Future<Map<String, dynamic>> placeOrderUpi({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse("https://staging.junubullion.com/api/checkout/upi/pay"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      log("UPI QR STATUS => ${response.statusCode}");
      log("UPI QR RESPONSE => ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(body);
      }

      throw Exception(
        body["message"]?.toString() ?? "Failed to generate UPI QR",
      );
    } on SocketException {
      throw Exception("No internet connection");
    } on FormatException {
      throw Exception("Invalid response from server");
    } catch (e) {
      throw Exception("Failed to generate UPI QR: $e");
    }
  }
}
