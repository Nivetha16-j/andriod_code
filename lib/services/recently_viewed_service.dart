import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedService {
  static const String key = "recently_viewed_products";

  static Future<void> addProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> products = prefs.getStringList(key) ?? [];

    // Remove if already exists
    products.removeWhere((item) {
      final p = jsonDecode(item);
      return p["id"] == product["id"];
    });

    // Add to top
    products.insert(0, jsonEncode(product));

    // Keep only last 10
    if (products.length > 10) {
      products = products.sublist(0, 10);
    }

    await prefs.setStringList(key, products);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(key) ?? [];

    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> removeProduct(int productId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> products = prefs.getStringList(key) ?? [];

    products.removeWhere((item) {
      final product = jsonDecode(item);
      return product["id"] == productId;
    });

    await prefs.setStringList(key, products);
  }
}
