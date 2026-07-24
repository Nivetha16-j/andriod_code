import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  String _selectedCurrency = "USD";
  String _selectedUnit = "Gram";

  String get selectedCurrency => _selectedCurrency;
  String get selectedUnit => _selectedUnit;

  void changeCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void changeUnit(String unit) {
    _selectedUnit = unit;
    notifyListeners();
  }

  void update(String currency, String unit) {
    _selectedCurrency = currency;
    _selectedUnit = unit;
    notifyListeners();
  }
}
