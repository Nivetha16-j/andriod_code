import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class ExclusiveProductService {
  Future<List<dynamic>> getProducts({
    required String endpoint,
    required String currency,
    required String unit,
  }) async {
    final apiUnit = unit.toLowerCase() == "ounce"
        ? "toz"
        : unit.toLowerCase() == "kilogram"
        ? "kg"
        : "gram";

    final uri = Uri.parse(
      "https://junubullion.com/api/$endpoint",
    ).replace(queryParameters: {"currency": currency, "unit": apiUnit});

    try {
      log("EXCLUSIVE API URL: $uri");

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      log("EXCLUSIVE API STATUS: ${response.statusCode}");

      log("EXCLUSIVE API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // return data["products"] ?? [];

        final productList = data["products"] ?? [];

        for (final product in productList) {
          log(
            'PRODUCT: ${product['name']} | '
            'CATEGORY ID: ${product['category_id']} | '
            'SUBCATEGORY ID: ${product['subcategory_id']} | '
            'SUBCATEGORY: ${product['subcategory']?['name']}',
          );
        }

        log("REQUESTED ENDPOINT: $endpoint");
        log("RETURNED PRODUCT COUNT: ${productList.length}");
        log(
          "FIRST PRODUCT: ${productList.isNotEmpty ? productList.first : 'No products'}",
        );

        return productList;
      }

      throw Exception(
        "Failed to load products. Status code: ${response.statusCode}",
      );
    } on TimeoutException {
      throw Exception("Exclusive products request timed out.");
    } on SocketException catch (e) {
      log("EXCLUSIVE API SOCKET ERROR: $e");

      throw Exception("Unable to connect to the server.");
    } on FormatException catch (e) {
      log("EXCLUSIVE API JSON ERROR: $e");

      throw Exception("Invalid response received from server.");
    } catch (e) {
      log("EXCLUSIVE API ERROR: $e");

      rethrow;
    }
  }
}
