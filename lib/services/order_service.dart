import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class OrdersService {
  static const String baseUrl =
      "https://staging.junubullion.com/api/my-account/orders";

  Future<Map<String, dynamic>> fetchOrders() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return {
        "orders": json["data"]["data"] ?? [],
        "total": json["data"]["total"] ?? 0,
      };
    } else {
      throw Exception("Failed to fetch orders");
    }
  }
}
