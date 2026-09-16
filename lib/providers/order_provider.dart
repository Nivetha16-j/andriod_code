import 'dart:developer';

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

      log("Fetched orders: ${result["orders"]}");

      orders = List<dynamic>.from(result["orders"] ?? []);
      totalOrders = result["total"] ?? orders.length;
    } catch (e) {
      log("Fetch orders error: $e");
      error = e.toString();
      orders = [];
      totalOrders = 0;
    }

    isLoading = false;
    notifyListeners();
  }
}
