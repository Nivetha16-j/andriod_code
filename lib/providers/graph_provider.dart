import 'package:flutter/material.dart';
import 'package:junubullion/services/graph_services.dart';

class GraphProvider extends ChangeNotifier {
  bool isLoading = false;
  int _requestId = 0;

  String? errorMessage;

  Map<String, dynamic>? graphData;

  // Keys must match the dropdown labels in LiveSpotPriceCard
  final Map<String, String> unitMap = {
    'Gram': 'gram',
    'Ounce': 'toz',
    'Kilogram': 'kg',
  };

  Future<void> fetchSingleGraph({
    String currency = 'USD',
    String unit = 'Gram',
    String range = '1d',
  }) async {
    final int requestId = ++_requestId;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await GraphServices.fetchGraph(
        currency: currency,
        unit: unitMap[unit] ?? 'gram',
        range: range,
      );
      if (requestId != _requestId) return;
      graphData = data;
    } catch (e) {
      if (requestId != _requestId) return;
      errorMessage = e.toString();
      graphData = null; // don't keep showing the previous range's graph
      debugPrint('Graph fetch failed for range=$range: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ---- More Graphs screen state (separate from the home graph) ----
  bool moreLoading = false;
  String? moreError;
  Map<String, dynamic>? moreData; // the "data" object of the API response
  int _moreRequestId = 0;

  Future<void> fetchMoreGraphs({
    String metal = 'gold',
    String currency = 'USD',
    String unit = 'Gram',
    String range = '1d',
    bool clear = false, // true = drop the old data so the screen reloads fully
  }) async {
    final int requestId = ++_moreRequestId;

    moreLoading = true;
    moreError = null;
    if (clear) moreData = null;
    notifyListeners();

    try {
      final data = await GraphServices.fetchMoreGraphs(
        metal: metal,
        currency: currency,
        unit: unitMap[unit] ?? 'gram',
        range: range,
      );
      if (requestId != _moreRequestId) return;
      moreData = data;
    } catch (e) {
      if (requestId != _moreRequestId) return;
      moreError = e.toString();
      moreData = null;
    }

    moreLoading = false;
    notifyListeners();
  }
}
