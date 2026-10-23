import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:junubullion/models/wallet_dashboard_model.dart';
import 'package:junubullion/services/session_manager.dart';

class BalanceApi {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<WalletDashboardModel> fetchBalanceData(String currency) async {
    log("fetchBalanceData started");

    final token = await SessionManager.getToken();

    log("Token: $token");

    final response = await http.get(
      Uri.parse(
        '$baseUrl/wallet-dashboard',
      ).replace(queryParameters: {"currency": currency}),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("Status Codee: ${response.statusCode}");
    log("Response: ${response.body}");

    // if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    log("jjjjjj $jsonData");

    return WalletDashboardModel.fromJson(jsonData);
    // } else {
    //   throw Exception("Failed to load balance");
    // }
  }
}
