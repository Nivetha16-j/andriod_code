import 'dart:convert';
import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class StripeService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<bool> makePayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Junu Bullion",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException {
      return false;
    } catch (e) {
      print(e);

      return false;
    }
  }

  // static Future<bool> confirmCardPayment({required String clientSecret}) async {
  //   try {
  //     await Stripe.instance.confirmPayment(
  //       paymentIntentClientSecret: clientSecret,
  //       data: const PaymentMethodParams.card(
  //         paymentMethodData: PaymentMethodData(),
  //       ),
  //     );

  //     return true;
  //   } on StripeException catch (e) {
  //     print(e.error.localizedMessage);
  //     return false;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  static Future<Map<String, dynamic>> createStripeSession({
    required String shippingAddress,
    required String fulfillmentType,
    required String courierService,
    required String currency,
    String? digitalSubtype,
    required bool terms,
    required String paymentMethod,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final Map<String, dynamic> payload = {
        "shipping_address": shippingAddress,
        "courier_service": courierService.toLowerCase(),
        "currency": currency,
        "terms": terms,
        "fulfillment_type": fulfillmentType.toLowerCase(),
        "payment_method": paymentMethod.toLowerCase(),
      };

      if (fulfillmentType.toLowerCase() == "digital" &&
          digitalSubtype != null &&
          digitalSubtype.isNotEmpty) {
        payload["digital_subtype"] = digitalSubtype.toLowerCase();
      }

      log("Stripe Request => ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse("$baseUrl/checkout/stripe/session"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      log("Stripe Status Code : ${response.statusCode}");
      log("Stripe Response : ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body;
      }

      throw Exception(body["message"] ?? "Failed to create Stripe session.");
    } catch (e) {
      log("Stripe Session Error : $e");
      rethrow;
    }
  }
}
