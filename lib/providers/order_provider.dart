import 'package:flutter/material.dart';
import 'package:junubullion/services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _service = OrdersService();

  bool isLoading = false;
  String? error;

  List<dynamic> orders = [];
  int totalOrders = 0;

  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.fetchOrders();

      //  orders = result["orders"];
      orders = result["orders"];
      totalOrders = result["total"];
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
