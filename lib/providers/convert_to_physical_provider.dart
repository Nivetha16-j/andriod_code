import 'dart:developer';

import 'package:flutter/foundation.dart';

class PhysicalConversionProvider extends ChangeNotifier {
  bool _isActive = false;
  String? _metal;
  double? _amount;

  bool get isActive => _isActive;
  String? get metal => _metal;
  double? get amount => _amount;

  String get formattedAmount {
    if (_amount == null) return '0';
    return _amount!.toStringAsFixed(4);
  }

  void startConversion({required String metal, required double amount}) {
    log("convvvv $metal $amount");

    _isActive = true;
    _metal = metal;
    _amount = amount;

    notifyListeners();
  }

  void cancelConversion() {
    _isActive = false;
    _metal = null;
    _amount = null;

    notifyListeners();
  }

  String? validateProduct({
    required String? brand,
    required String? metalType,
  }) {
    // ----------------------------------------------------------
    // NORMAL CART
    // ----------------------------------------------------------
    if (!_isActive) {
      return null;
    }

    final normalizedBrand = brand?.trim().toLowerCase() ?? '';

    final normalizedMetal = metalType?.trim().toLowerCase() ?? '';

    final requiredMetal = _metal?.trim().toLowerCase() ?? '';

    // ----------------------------------------------------------
    // BRAND VALIDATION
    // ----------------------------------------------------------
    // Only JSC products are allowed during physical conversion.
    if (normalizedBrand != 'jsc') {
      return 'Only JSC products can be added during physical conversion.';
    }

    // ----------------------------------------------------------
    // METAL VALIDATION
    // ----------------------------------------------------------
    if (normalizedMetal != requiredMetal) {
      final displayMetal = requiredMetal.isNotEmpty
          ? requiredMetal[0].toUpperCase() + requiredMetal.substring(1)
          : 'selected metal';

      return 'Only $displayMetal products can be added to this physical conversion.';
    }

    return null;
  }
}
