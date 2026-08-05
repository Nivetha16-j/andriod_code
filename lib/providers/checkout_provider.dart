import 'package:flutter/material.dart';
import 'package:junubullion/services/checkout_service.dart';

class CheckoutProvider extends ChangeNotifier {
  final CheckoutService _service = CheckoutService();

  bool isLoading = false;
  List<String> paymentMethods = [];

  Future<void> fetchPaymentMethods() async {
    isLoading = true;
    notifyListeners();

    try {
      paymentMethods = await _service.fetchPaymentMethods();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
