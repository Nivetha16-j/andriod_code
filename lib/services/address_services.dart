import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class AddressService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<Map<String, dynamic>> updateAddress(String address) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/my-account/addresses"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"address": address}),
    );

    log("Update Address Status : ${response.statusCode}");
    log("Update Address Response : ${response.body}");

    return jsonDecode(response.body);
  }
}
