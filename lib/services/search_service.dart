import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<List<dynamic>> searchProducts(String keyword) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/product-search?search=${Uri.encodeComponent(keyword)}",
      ),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json["status"] == true) {
        return json["data"] ?? [];
      }
    }

    return [];
  }
}
