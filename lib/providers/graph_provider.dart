import 'package:flutter/material.dart';
import 'package:junubullion/services/graph_services.dart';

class GraphProvider extends ChangeNotifier {
  bool isLoading = false;
  bool _isFetching = false;

  String? errorMessage;

  Map<String, dynamic>? graphData;

  final Map<String, String> unitMap = {
    'Gram': 'gram',
    'Kg': 'kg',
    'Toz': 'toz',
  };

  Future<void> fetchSingleGraph({
    String currency = 'USD',
    String unit = 'Gram',
  }) async {
    if (_isFetching) return;

    _isFetching = true;
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      graphData = await GraphServices.fetchGraph(
        currency: currency,
        unit: unitMap[unit] ?? 'gram',
      );
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    _isFetching = false;

    notifyListeners();
  }
}
