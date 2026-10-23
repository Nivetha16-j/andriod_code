import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/wallet_dashboard_model.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/balance_services.dart';

class BalanceProvider extends ChangeNotifier {
  bool isLoading = false;

  WalletDashboardModel? balanceData;

  Future<void> fetchBalance({required String currency}) async {
    log("fetchBalance called");

    isLoading = true;
    notifyListeners();

    try {
      balanceData = await BalanceApi.fetchBalanceData(currency);
      log("API Success");
    } catch (e) {
      log("API Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
