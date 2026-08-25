import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class CartService {
  static const String _baseUrl = "https://staging.junubullion.com/api";

  // ============================================================
  // FETCH CART
  // ============================================================

  static Future<Map<String, dynamic>> fetchCart({
    required String currency,
    required String unit,
    required String courierService,
  }) async {
    final token = await SessionManager.getToken();

    final uri = Uri.parse("$_baseUrl/cart").replace(
      queryParameters: {
        "currency": currency,
        "unit": unit.toLowerCase() == "ounce"
            ? "toz"
            : unit.toLowerCase() == "kilogram"
            ? "kg"
            : "gram",
        "courier_service": courierService.toLowerCase(),
      },
    );

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  // ============================================================
  // ADD TO CART
  // ============================================================

  static Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse("$_baseUrl/cart/add"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: {
        "product_id": productId.toString(),
        "quantity": quantity.toString(),
      },
    );

    return jsonDecode(response.body);
  }

  // ============================================================
  // REMOVE SINGLE PRODUCT FROM CART
  // ============================================================

  static Future<Map<String, dynamic>> removeFromCart({
    required int productId,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse("$_baseUrl/cart/remove/$productId"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  // ============================================================
  // REMOVE ENTIRE CART
  // DELETE /api/cart/removeCart
  //
  // Body:
  // {
  //   "id": "194"
  // }
  // ============================================================

  static Future<Map<String, dynamic>> removeCart({required String id}) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse("$_baseUrl/cart/removeCart"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"id": id}),
    );

    log("Remove Cart Status: ${response.statusCode}");
    log("Remove Cart Response: ${response.body}");

    return jsonDecode(response.body);
  }

  // ============================================================
  // UPDATE CART QUANTITY
  // ============================================================

  static Future<Map<String, dynamic>> updateCart({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    final response = await http.patch(
      Uri.parse("$_baseUrl/cart/update/$productId"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"quantity": quantity}),
    );

    log("Status:----------- ${response.statusCode}");
    log("Body:------- ${response.body}");

    return jsonDecode(response.body);
  }
}
