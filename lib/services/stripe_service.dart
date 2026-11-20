import 'dart:convert';
import 'dart:developer';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class StripeService {
  static const String baseUrl = "https://junubullion.com/api";

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

  static Future<Map<String, dynamic>> createStripeSession({
    required String shippingAddress,
    required String city,
    required String state,
    required String pin,
    required String contactPerson,
    required String contactEmail,
    required String contactPhone,
    required String fulfillmentType,
    String? courierService,
    required String currency,
    String? digitalSubtype,
    required bool terms,
    required String paymentMethod,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final Map<String, dynamic> payload = {
        "street_address": shippingAddress,
        "city": city,
        "state": state,
        "pin": pin,
        "contact_person": contactPerson,
        "contact_email": contactEmail,
        "contact_number": contactPhone,
        "courier_service": courierService?.toLowerCase(),
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

      final errors = body["errors"];
      String details = "";
      if (errors is Map) {
        details = errors.values.expand((v) => v is List ? v : [v]).join("\n");
      }

      throw Exception(
        details.isNotEmpty
            ? details
            : (body["message"] ?? "Failed to create Stripe session."),
      );
    } catch (e) {
      log("Stripe Session Error : $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> stripePaymentSuccess({
    required String paymentIntentId,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final uri = Uri.parse(
        '$baseUrl/checkout/stripe/success',
      ).replace(queryParameters: {'payment_intent_id': paymentIntentId});

      log('STRIPE SUCCESS API URL -> $uri');

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      log(
        'STRIPE SUCCESS API -> '
        '${response.statusCode} ${response.body}',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Map<String, dynamic>.from(data);
      }

      return {
        'status': false,
        'message': data['message'] ?? 'Stripe success API failed',
      };
    } catch (e, stackTrace) {
      log('STRIPE SUCCESS API ERROR -> $e', stackTrace: stackTrace);

      return {'status': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    log("STRIPE $path -> ${response.statusCode} ${response.body}");

    final dynamic body = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(body);
    }

    throw Exception(
      (body is Map ? body["message"] : null)?.toString() ??
          "Request failed (${response.statusCode})",
    );
  }

  static Future<Map<String, dynamic>> sendPaymentOtp({
    required String paymentIntentId,
    required String email,
  }) => _postJson("/checkout/stripe/payment-otp/send", {
    "payment_intent_id": paymentIntentId,
    "payment_email": email,
  });

  static Future<Map<String, dynamic>> paymentOtpStatus({
    required String paymentIntentId,
  }) => _postJson("/checkout/stripe/payment-otp/status", {
    "payment_intent_id": paymentIntentId,
  });

  static Future<Map<String, dynamic>> resendPaymentOtp({
    required String paymentIntentId,
    required String email,
  }) => _postJson("/checkout/stripe/payment-otp/resend", {
    "payment_intent_id": paymentIntentId,
    "payment_email": email,
  });

  /// Returns the client_secret once the code is correct.
  static Future<String> verifyPaymentOtp({
    required String paymentIntentId,
    required String otp,
  }) async {
    final res = await _postJson("/checkout/stripe/payment-otp/verify", {
      "payment_intent_id": paymentIntentId,
      "otp": otp,
    });

    final secret =
        (res["data"] is Map ? res["data"]["client_secret"] : null) ??
        res["client_secret"];

    if (secret == null || secret.toString().trim().isEmpty) {
      throw Exception(
        "Verification succeeded but no client secret was returned",
      );
    }
    log("PAYMENT OTP VERIFIED, CLIENT SECRET: $secret");
    return secret.toString();
  }

  static Future<String> verifyPhoneOtp({
    required String paymentIntentId,
    required String token,
  }) async {
    final res = await _postJson(
      "/checkout/stripe/payment-otp/verify-phone", // path only
      {"payment_intent_id": paymentIntentId, "firebase_id_token": token},
    );

    final secret =
        (res["data"] is Map ? res["data"]["client_secret"] : null) ??
        res["client_secret"];

    if (secret == null || secret.toString().trim().isEmpty) {
      throw Exception(
        "Verification succeeded but no client secret was returned",
      );
    }
    log("PHONE OTP VERIFIED, CLIENT SECRET: $secret");
    return secret.toString();
  }

  /// Stripe sheet FIRST (collects details), then [otpStep] runs, then the
  /// payment is confirmed with the client_secret that [otpStep] returns.
  static Future<bool> payWithDeferredIntent({
    required String currency,
    required int amountMinor,
    required String email,
    required Future<String?> Function() otpStep,
  }) async {
    String? secret;
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: "Junu Bullion",
          customFlow: true,
          returnURL: 'junubullion://stripe-redirect', // NEW
          billingDetails: BillingDetails(email: email),
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                email: CollectionMode.always,
              ),
          intentConfiguration: IntentConfiguration(
            mode: IntentMode.paymentMode(
              currencyCode: currency.toUpperCase(),
              amount: amountMinor,
            ),
            paymentMethodTypes: ['card', 'link'],
            confirmHandler: (paymentMethod, shouldSavePaymentMethod) async {
              Stripe.instance.intentCreationCallback(
                secret != null
                    ? IntentCreationCallbackParams(clientSecret: secret!)
                    : IntentCreationCallbackParams(
                        error: StripeException(
                          error: LocalizedErrorMessage(
                            code: FailureCode.Failed,
                            localizedMessage: "Payment not verified",
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      secret = await otpStep();
      log("STRIPE DEFERRED OTP STEP RETURNED SECRET -> $secret");
      if (secret == null || secret.isEmpty) return false;

      await Stripe.instance.confirmPaymentSheetPayment();
      return true;
    } on StripeException catch (e) {
      log(
        "STRIPE DEFERRED StripeException -> "
        "code=${e.error.code} type=${e.error.type} "
        "message=${e.error.message} "
        "localized=${e.error.localizedMessage} "
        "decline=${e.error.declineCode}",
      );
      return await _intentSucceeded(secret);
    } catch (e, st) {
      log("STRIPE DEFERRED ERROR -> $e", stackTrace: st);
      return await _intentSucceeded(secret);
    }
  }

  /// The SDK can throw after 3DS even though the payment went through.
  static Future<bool> _intentSucceeded(String? secret) async {
    if (secret == null || secret.isEmpty) return false;
    try {
      final pi = await Stripe.instance.retrievePaymentIntent(secret);
      log("STRIPE PI STATUS AFTER ERROR -> ${pi.status}");
      return pi.status == PaymentIntentsStatus.Succeeded;
    } catch (e) {
      log("STRIPE PI RETRIEVE ERROR -> $e");
      return false;
    }
  }
}
