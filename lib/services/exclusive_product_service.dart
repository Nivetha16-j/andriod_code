import 'dart:convert';
import 'package:http/http.dart' as http;

class ExclusiveProductService {
  // Future<List<dynamic>> getProducts(String endpoint) async {
  //   final response = await http.get(
  //     Uri.parse("https://staging.junubullion.com/api/$endpoint"),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data["products"] ?? [];
  //   }

  //   throw Exception("Failed to load products");
  // }

  Future<List<dynamic>> getProducts({
    required String endpoint,
    required String currency,
    required String unit,
  }) async {
    final uri = Uri.parse("https://staging.junubullion.com/api/$endpoint")
        .replace(
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
      final data = jsonDecode(response.body);
      return data["products"] ?? [];
    }

    throw Exception("Failed to load products");
  }
}
