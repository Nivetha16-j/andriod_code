import 'package:flutter/material.dart';
import '../services/exclusive_product_service.dart';

class ExclusiveProductProvider extends ChangeNotifier {
  final ExclusiveProductService _service = ExclusiveProductService();

  bool isLoading = false;

  List<dynamic> products = [];

  String _currentEndpoint = "exclusive-products";

  String get currentEndpoint => _currentEndpoint;
  int _productRequestId = 0;

  Future<void> fetchProducts({
    String endpoint = "exclusive-products",
    required String currency,
    required String unit,
    bool showLoader = true,
  }) async {
    final int requestId = ++_productRequestId;

    _currentEndpoint = endpoint;

    if (showLoader) {
      isLoading = true;
      products = [];
      notifyListeners();
    }

    try {
      final newProducts = await _service.getProducts(
        endpoint: endpoint,
        currency: currency,
        unit: unit,
      );

      // Ignore an older request if a newer category request
      // has already started.
      if (requestId != _productRequestId) {
        return;
      }

      products = newProducts;
    } catch (e) {
      debugPrint(
        '❌ fetchProducts error '
        'endpoint=$endpoint: $e',
      );

      if (requestId == _productRequestId) {
        products = [];
      }
    } finally {
      if (requestId == _productRequestId) {
        if (showLoader) {
          isLoading = false;
        }

        notifyListeners();
      }
    }
  }

  void clearProducts() {
    products = [];
    notifyListeners();
  }
}
