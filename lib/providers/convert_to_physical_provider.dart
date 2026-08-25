import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junubullion/providers/cart_provider.dart';

class PhysicalConversionProvider extends ChangeNotifier {
  bool _isActive = false;
  String? _metal;
  double _amount = 0;

  bool get isActive => _isActive;

  String? get metal => _metal;

  double get amount => _amount;

  String get formattedAmount {
    return _amount.toStringAsFixed(4);
  }

  static const String _physicalActiveKey = 'physical_conversion_active';

  static const String _physicalMetalKey = 'physical_conversion_metal';

  static const String _physicalAmountKey = 'physical_conversion_amount';

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initializePhysicalConversion() async {
    final prefs = await SharedPreferences.getInstance();

    final active = prefs.getBool(_physicalActiveKey) ?? false;
    final metal = prefs.getString(_physicalMetalKey);
    final amount = prefs.getDouble(_physicalAmountKey) ?? 0;

    if (active && metal != null && metal.trim().isNotEmpty && amount > 0) {
      _isActive = true;
      _metal = metal;
      _amount = amount;
    } else {
      _isActive = false;
      _metal = null;
      _amount = 0;
    }

    log(
      'PHYSICAL INIT -> '
      'active=$_isActive '
      'metal=$_metal '
      'amount=$_amount',
    );

    notifyListeners();
  }

  // ============================================================
  // START CONVERSION
  // ============================================================

  Future<void> startConversion({
    required String metal,
    required double amount,
  }) async {
    _isActive = true;
    _metal = metal;
    _amount = amount;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_physicalActiveKey, true);
    await prefs.setString(_physicalMetalKey, metal);
    await prefs.setDouble(_physicalAmountKey, amount);

    log(
      '🚀 PHYSICAL CONVERSION STARTED -> '
      'metal=$metal amount=$amount',
    );

    notifyListeners();
  }

  // ============================================================
  // VALIDATE PRODUCT
  // ============================================================

  String? validateProduct({String? metalType}) {
    if (!_isActive) {
      return null;
    }

    final normalizedMetal = metalType?.trim().toLowerCase();

    final conversionMetal = _metal?.trim().toLowerCase();

    log(
      'validateProduct -> '
      'productMetal=$normalizedMetal '
      'conversionMetal=$conversionMetal',
    );

    if (conversionMetal != normalizedMetal) {
      return 'Only $_metal products can be added during this conversion.';
    }

    return null;
  }

  Future<void> cancelConversion({required CartProvider cartProvider}) async {
    try {
      log('🛑 Cancelling physical conversion');

      // Restore products that existed before conversion.
      await cartProvider.restorePhysicalOrderProducts();

      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_physicalActiveKey);
      await prefs.remove(_physicalMetalKey);
      await prefs.remove(_physicalAmountKey);

      _isActive = false;
      _metal = null;
      _amount = 0;

      await cartProvider.fetchCart();

      log('✅ Physical conversion cancelled');

      notifyListeners();
    } catch (e, stackTrace) {
      log('❌ cancelConversion error: $e', stackTrace: stackTrace);
    }
  }

  // ============================================================
  // DIGITAL PRODUCTS
  // ============================================================

  final Set<dynamic> digitalProductIds = {};

  void setDigitalProductIds(List<dynamic> products) {
    digitalProductIds
      ..clear()
      ..addAll(
        products
            .take(4)
            .map((product) => product['id'])
            .where((id) => id != null),
      );

    log('DIGITAL PRODUCT IDS: $digitalProductIds');

    notifyListeners();
  }

  bool isDigitalProduct(dynamic productId) {
    return digitalProductIds.contains(productId);
  }
}
