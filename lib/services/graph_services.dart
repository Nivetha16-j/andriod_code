import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class GraphServices {
  static const String _baseUrl = 'https://staging.junubullion.com/api';

  static Future<Map<String, dynamic>> fetchGraph({
    required String currency,
    required String unit,
    String metal = 'gold',
    String range = '1d',
  }) async {
    final token = await SessionManager.getToken();

    final uri = Uri.parse('$_baseUrl/spot-prices/chart').replace(
      queryParameters: {
        'metal': metal,
        'currency': currency,
        'unit': unit,
        'range': range,
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    log("Graphhhhhhhressssss ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to fetch graph: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> fetchMoreGraphs({
    required String currency,
    required String unit,
    String metal = 'gold',
    String range = '1d',
  }) async {
    final token = await SessionManager.getToken();

    final uri = Uri.parse('$_baseUrl/spot-charts').replace(
      queryParameters: {
        'metal': metal,
        'currency': currency,
        'unit': unit,
        'range': range,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
      },
    );

    log("MoreGraphs ${response.statusCode} range=$range ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return Map<String, dynamic>.from(decoded['data'] ?? decoded);
    }

    throw Exception(
      'Failed to fetch graph: ${response.statusCode} ${response.body}',
    );
  }
}
