import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';

class HomeProvider extends ChangeNotifier {
  Map<String, dynamic>? homeData;

  bool isLoading = false;
  String? errorMessage;

  bool _isFetching = false;

  static const Map<String, String> unitMap = {
    "Gram": "gram",
    "Ounce": "toz",
    "Kilogram": "kg",
  };

  Future<void> fetchHomeData({
    String currency = "USD",
    String unit = "Gram",
  }) async {
    if (_isFetching) return;

    _isFetching = true;

    if (homeData == null) {
      isLoading = true;
      notifyListeners();
    }

    try {
      homeData = await ApiService.fetchHomeData(
        currency: currency,
        unit: unitMap[unit] ?? "gram",
      );

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    _isFetching = false;
    notifyListeners();
  }
}
