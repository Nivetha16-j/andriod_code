import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static const String _physicalCartKey = 'physical_conversion_cart';
  static const String _physicalActiveKey = 'physical_conversion_active';
  static const String _physicalMetalKey = 'physical_conversion_metal';
  static const String _physicalAmountKey = 'physical_conversion_amount';

  List<Map<String, dynamic>> _physicalCart = [];

  List<Map<String, dynamic>> get physicalCart =>
      List.unmodifiable(_physicalCart);

  int get physicalCartCount {
    int count = 0;

    for (final item in _physicalCart) {
      count += int.tryParse('${item['quantity'] ?? 0}') ?? 0;
    }

    return count;
  }

  Future<void> initializePhysicalConversion() async {
    final prefs = await SharedPreferences.getInstance();

    _isActive = prefs.getBool(_physicalActiveKey) ?? false;

    _metal = prefs.getString(_physicalMetalKey);

    _amount = prefs.getDouble(_physicalAmountKey) ?? 0;

    final cartJson = prefs.getString(_physicalCartKey);

    _physicalCart = [];

    if (cartJson != null && cartJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(cartJson);

        if (decoded is List) {
          _physicalCart = decoded
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        }
      } catch (e) {
        debugPrint('❌ Physical cart restore error: $e');
        _physicalCart = [];
      }
    }

    debugPrint(
      'PHYSICAL INIT -> '
      'active=$_isActive '
      'metal=$_metal '
      'amount=$_amount '
      'cart=$_physicalCart',
    );

    notifyListeners();
  }

  Future<void> startConversion({
    required String metal,
    required double amount,
  }) async {
    _isActive = true;
    _metal = metal;
    _amount = amount;

    _physicalCart = [];

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_physicalActiveKey, true);
    await prefs.setString(_physicalMetalKey, metal);
    await prefs.setDouble(_physicalAmountKey, amount);
    await prefs.setString(_physicalCartKey, jsonEncode(_physicalCart));

    debugPrint(
      '🚀 PHYSICAL CONVERSION STARTED -> '
      'metal=$metal amount=$amount',
    );

    notifyListeners();
  }

  Future<bool> addPhysicalProduct({
    required Map<String, dynamic> product,
  }) async {
    if (!_isActive) {
      debugPrint('❌ Physical conversion is not active.');
      return false;
    }

    final validationError = validateProduct(
      // brand: product['brand']?.toString(),
      metalType: product['metal_type']?.toString(),
    );

    if (validationError != null) {
      debugPrint(
        '❌ Physical conversion validation failed: '
        '$validationError',
      );
      return false;
    }

    final productId = product['id'];

    if (productId == null) {
      debugPrint('❌ Product ID is null.');
      return false;
    }

    final index = _physicalCart.indexWhere(
      (item) => '${item['product_id']}' == '$productId',
    );

    if (index != -1) {
      final currentQuantity =
          int.tryParse('${_physicalCart[index]['quantity'] ?? 0}') ?? 0;

      _physicalCart[index]['quantity'] = currentQuantity + 1;
    } else {
      _physicalCart.add({
        'product_id': productId,
        'quantity': 1,

        'name': product['name'],
        'image_url': product['image_url'],
        'image_path': product['image_path'],
        'brand': product['brand'],
        'metal_type': product['metal_type'],
        'price': 0,
        'formatted_price': '0.00',
        'live_price': '0.00',
      });
    }

    await _savePhysicalCart();

    debugPrint('🛒 PHYSICAL CART UPDATED -> $_physicalCart');

    notifyListeners();

    return true;
  }

  Future<void> updatePhysicalQuantity({
    required dynamic productId,
    required int quantity,
  }) async {
    final index = _physicalCart.indexWhere(
      (item) => '${item['product_id']}' == '$productId',
    );

    if (index == -1) {
      return;
    }

    if (quantity <= 0) {
      _physicalCart.removeAt(index);
    } else {
      _physicalCart[index]['quantity'] = quantity;
    }

    await _savePhysicalCart();

    notifyListeners();
  }

  Future<void> removePhysicalProduct(dynamic productId) async {
    _physicalCart.removeWhere(
      (item) => '${item['product_id']}' == '$productId',
    );

    await _savePhysicalCart();

    notifyListeners();
  }

  Future<void> clearPhysicalCart() async {
    _physicalCart.clear();

    await _savePhysicalCart();

    notifyListeners();
  }

  Future<void> cancelConversion() async {
    final prefs = await SharedPreferences.getInstance();

    _physicalCart.clear();

    _isActive = false;
    _metal = null;
    _amount = 0;

    await prefs.remove(_physicalCartKey);
    await prefs.remove(_physicalActiveKey);
    await prefs.remove(_physicalMetalKey);
    await prefs.remove(_physicalAmountKey);

    debugPrint('🛑 PHYSICAL CONVERSION CANCELLED');

    notifyListeners();
  }

  Future<void> _savePhysicalCart() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_physicalCartKey, jsonEncode(_physicalCart));
  }

  String? validateProduct({String? metalType}) {
    if (!_isActive) {
      return null;
    }

    log("validateProduct $metalType");

    final normalizedMetal = metalType?.trim().toLowerCase();

    if (_metal?.trim().toLowerCase() != normalizedMetal) {
      return 'Only $_metal products can be added during this conversion.';
    }

    return null;
  }

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

    debugPrint('DIGITAL PRODUCT IDS: $digitalProductIds');

    notifyListeners();
  }

  bool isDigitalProduct(dynamic productId) {
    return digitalProductIds.contains(productId);
  }
}
