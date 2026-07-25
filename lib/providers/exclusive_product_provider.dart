import 'package:flutter/material.dart';
import '../services/exclusive_product_service.dart';

class ExclusiveProductProvider extends ChangeNotifier {
  final ExclusiveProductService _service = ExclusiveProductService();

  bool isLoading = false;

  List<dynamic> products = [];

  String _currentEndpoint = "exclusive-products";

  Future<void> fetchProducts({String endpoint = "exclusive-products"}) async {
    _currentEndpoint = endpoint;

    isLoading = true;
    notifyListeners();

    try {
      products = await _service.getProducts(endpoint);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
