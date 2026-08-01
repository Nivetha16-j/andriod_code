import 'package:flutter/material.dart';
import 'package:junubullion/services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _service = OrdersService();

  bool isLoading = false;
  String? error;

  List<dynamic> orders = [];

  Future<void> fetchOrders() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      orders = await _service.fetchOrders();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
