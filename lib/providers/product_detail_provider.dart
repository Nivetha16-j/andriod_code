import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';

class ProductDetailsProvider extends ChangeNotifier {
  bool isLoading = false;

  Map<String, dynamic>? product;
  List<dynamic> relatedProducts = [];
  List<dynamic> reviews = [];
  List<dynamic> subcategories = [];

  Future<void> fetchProductDetails(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchProductDetails(id);

      debugPrint(
        "Ppppppppppppp ${response["data"]['subcategories']}........${response["data"]["product"]['category']['name']}",
      );

      product = response["data"]["product"];

      relatedProducts = response["data"]["related_products"] ?? [];

      reviews = response["data"]["reviews"] ?? [];

      subcategories = response["data"]["subcategories"] ?? [];
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
