import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://staging.junubullion.com/api';

  /// Fetches home screen data from the API.
  static Future<Map<String, dynamic>> fetchHomeData({
    String currency = "USD",
    String unit = "gram",
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl/home',
    ).replace(queryParameters: {'currency': currency, 'unit': unit});

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
        },
      );

      log('ApiService: Fetching home data from ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load data (Status Code: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchSpotPrice({
    required String currency,
    required String unit,
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl/home',
    ).replace(queryParameters: {'currency': currency, 'unit': unit});

    log('🔥 ACTUAL API URL: $url');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    log('🔥 STATUS: ${response.statusCode}');
    log('🔥 RAW API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data['data']['spot_prices'];
    } else {
      throw Exception('Failed to fetch spot price');
    }
  }

  // static Future<Map<String, dynamic>> fetchProductDetails(int id) async {
  //   final response = await http.get(Uri.parse("$_baseUrl/product-details/$id"));

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   }

  //   throw Exception("Failed to fetch product details");
  // }

  static Future<Map<String, dynamic>> fetchProductDetails({
    required int id,
    required String currency,
    required String unit,
  }) async {
    final uri = Uri.parse("$_baseUrl/product-details/$id").replace(
      queryParameters: {
        "currency": currency,
        "unit": unit.toLowerCase() == "ounce"
            ? "toz"
            : unit.toLowerCase() == "kilogram"
            ? "kg"
            : "gram",
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed");
  }

  static Future<Map<String, dynamic>> addReview({
    required String token,
    required int productId,
    required int rating,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/reviews"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {
        "product_id": productId.toString(),
        "rating": rating.toString(),
        "description": description,
      },
    );

    return jsonDecode(response.body);
  }
}
