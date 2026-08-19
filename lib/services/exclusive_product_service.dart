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
      "https://staging.junubullion.com/api/$endpoint",
    ).replace(queryParameters: {"currency": currency, "unit": apiUnit});

    try {
      log("EXCLUSIVE API URL: $uri");

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      log("EXCLUSIVE API STATUS: ${response.statusCode}");

      log("EXCLUSIVE API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["products"] ?? [];
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
