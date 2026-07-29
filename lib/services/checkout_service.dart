import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> placeOrder({
    required String shippingAddress,
    required String deliveryOption,
    required String courierService,
    required bool terms,
    required String paymentType,
  }) async {
    try {
      final token = await SessionManager.getToken();

      log(
        "Request => "
        "${token}"
        "shippingAddress: $shippingAddress, "
        "deliveryOption: $deliveryOption, "
        "courierService: $courierService, "
        "terms: $terms, "
        "paymentType: $paymentType",
      );

      final response = await http
          .post(
            Uri.parse("https://staging.junubullion.com/api/checkout/place"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              "shipping_address": shippingAddress,
              "delivery_option": deliveryOption.toLowerCase(),
              "courier_service": courierService.toLowerCase(),
              "terms": terms,
              "payment_type": paymentType,
            }),
          )
          .timeout(const Duration(seconds: 30));

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
}
