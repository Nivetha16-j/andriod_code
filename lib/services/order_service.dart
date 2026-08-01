import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class OrdersService {
  static const String baseUrl =
      "https://staging.junubullion.com/api/my-account/orders";

  Future<List<dynamic>> fetchOrders() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("ressssssss ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["data"] ?? [];
    } else {
      throw Exception("Failed to fetch orders");
    }
  }
}
