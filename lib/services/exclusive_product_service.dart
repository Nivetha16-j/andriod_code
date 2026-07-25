import 'dart:convert';
import 'package:http/http.dart' as http;

class ExclusiveProductService {
  Future<List<dynamic>> getProducts(String endpoint) async {
    final response = await http.get(
      Uri.parse("https://staging.junubullion.com/api/$endpoint"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["products"] ?? [];
    }

    throw Exception("Failed to load products");
  }
}
