import 'package:flutter/material.dart';
import '../services/exclusive_product_service.dart';

class ExclusiveProductProvider extends ChangeNotifier {
  final ExclusiveProductService _service = ExclusiveProductService();

  bool isLoading = false;

  List<dynamic> products = [];

  String _currentEndpoint = "exclusive-products";

  String get currentEndpoint => _currentEndpoint;

  // Future<void> fetchProducts({String endpoint = "exclusive-products"}) async {
  //   _currentEndpoint = endpoint;

  //   isLoading = true;
  //   notifyListeners();

  //   try {
  //     products = await _service.getProducts(endpoint);
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchProducts({
    String endpoint = "exclusive-products",
    required String currency,
    required String unit,
    bool showLoader = true,
  }) async {
    _currentEndpoint = endpoint;

    if (showLoader) {
      isLoading = true;
      products = []; // Clear previous products
      notifyListeners();
    }

    try {
      products = await _service.getProducts(
        endpoint: endpoint,
        currency: currency,
        unit: unit,
      );
    } finally {
      if (showLoader) {
        isLoading = false;
      }
      notifyListeners();
    }
  }
}
