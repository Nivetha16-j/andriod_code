import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';

class PhysicalConversionProvider extends ChangeNotifier {
  // ============================================================
  // BACKEND-SOURCED STATE ONLY
  // ============================================================

  bool _isActive = false;
  String? _metal;
  double _amount = 0;

  bool _isFetchingStatus = false;

  String? _plan;

  String? get plan => _plan;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isActive => _isActive;

  String? get metal => _metal;

  double get amount => _amount;

  bool get isFetchingStatus => _isFetchingStatus;

  String get formattedAmount {
    return _amount.toStringAsFixed(4);
  }

  // ============================================================
  // SET STATE FROM BACKEND
  //
  // IMPORTANT:
  // Nothing is saved to SharedPreferences.
  //
  // Backend is the ONLY source of truth.
  // ============================================================

  void _setInactive() {
    _isActive = false;
    _metal = null;
    _amount = 0;

    log(
      '🛑 PHYSICAL CONVERSION STATE -> '
      'INACTIVE',
    );

    notifyListeners();
  }

  void _setActive({
    required String? metal,
    required double amount,
    String? plan,
  }) {
    _isActive = true;
    _metal = metal;
    _amount = amount;

    if (plan != null && plan.isNotEmpty) {
      _plan = plan.toLowerCase();
    }

    log(
      '✅ PHYSICAL CONVERSION STATE -> '
      'ACTIVE '
      'plan=$_plan '
      'metal=$_metal '
      'amount=$_amount',
    );

    notifyListeners();
  }

  Future<void> fetchConversionStatus({
    bool showLoader = false,
    String? plan,
  }) async {
    if (_isFetchingStatus) {
      log('⏭️ fetchConversionStatus already running');
      return;
    }

    _isFetchingStatus = true;

    if (showLoader) {
      notifyListeners();
    }

    try {
      log('🌐 FETCHING PHYSICAL CONVERSION STATUS FROM BACKEND');

      final response = await JscService.fetchConvertDetails();

      log('📦 CONVERSION STATUS RESPONSE: $response');

      // ============================================================
      // BACKEND RESPONSE STATUS
      // ============================================================

      final apiStatus = response['status'] == true;

      final data = response['data'];

      // ============================================================
      // IMPORTANT:
      //
      // Backend can return:
      //
      // {
      //   "status": false,
      //   "message": "No active physical conversion found.",
      //   "data": null
      // }
      //
      // This means conversion is NOT ACTIVE.
      // ============================================================

      if (!apiStatus || data == null) {
        log(
          '🛑 NO ACTIVE PHYSICAL CONVERSION FROM BACKEND '
          '-> clearing provider state',
        );

        _setInactive();

        return;
      }

      // ============================================================
      // VALIDATE DATA
      // ============================================================

      if (data is! Map<String, dynamic>) {
        log(
          '⚠️ INVALID CONVERSION DATA '
          '-> clearing provider state',
        );

        _setInactive();

        return;
      }

      // ============================================================
      // READ BACKEND STATUS
      // ============================================================

      final status = data['status']?.toString().trim().toLowerCase() ?? '';

      final metal = data['metal']?.toString();

      final amount =
          double.tryParse('${data['amount_grams'] ?? data['amount'] ?? 0}') ??
          0;

      log(
        '🔎 BACKEND CONVERSION STATUS -> '
        'status=$status '
        'metal=$metal '
        'amount=$amount',
      );

      // ============================================================
      // ACTIVE
      // ============================================================

      if (status == 'active' && amount > 0) {
        _setActive(metal: metal, amount: amount, plan: plan);

        return;
      }

      // ============================================================
      // ANY NON-ACTIVE STATE
      // ============================================================

      log(
        '🛑 BACKEND CONVERSION IS NOT ACTIVE '
        '-> status=$status',
      );

      _setInactive();
    } catch (e, stackTrace) {
      log('❌ fetchConversionStatus ERROR: $e', stackTrace: stackTrace);

      // ============================================================
      // IMPORTANT
      //
      // Real network/server exception:
      // KEEP EXISTING STATE.
      //
      // But the 404 "No active conversion" response will NOT reach
      // this catch anymore because JscService now returns its JSON.
      // ============================================================
    } finally {
      _isFetchingStatus = false;

      if (showLoader) {
        notifyListeners();
      }
    }
  }

  void setConversionPlan(String plan) {
    final normalizedPlan = plan.trim().toLowerCase();

    if (normalizedPlan != 'jsc' && normalizedPlan != 'gsp') {
      log('⚠️ Invalid physical conversion plan: $plan');
      return;
    }

    _plan = normalizedPlan;

    log('📌 PHYSICAL CONVERSION PLAN -> $_plan');

    notifyListeners();
  }

  // ============================================================
  // START CONVERSION
  //
  // DO NOT manually say "active" here.
  //
  // The API has already created the conversion.
  // So immediately fetch the backend state.
  // ============================================================

  Future<bool> startConversion({
    required String metal,
    required double amount,
    required String currency,
  }) async {
    try {
      log(
        '🚀 START CONVERSION -> '
        'metal=$metal '
        'amount=$amount '
        'currency=$currency',
      );

      final response = await JscService.convertToPhysical(
        metal: metal,
        amount: amount,
        currency: currency,
      );

      log('🔥 START CONVERSION RESPONSE: $response');

      final success = response['status'] == true;

      if (!success) {
        log(
          '❌ START CONVERSION FAILED -> '
          '${response['message'] ?? 'Unknown error'}',
        );

        return false;
      }

      // ========================================================
      // IMPORTANT
      //
      // Do NOT do:
      //
      // _isActive = true;
      //
      // Instead ask backend what the actual state is.
      // ========================================================

      await fetchConversionStatus();

      return _isActive;
    } catch (e, stackTrace) {
      log('❌ startConversion ERROR: $e', stackTrace: stackTrace);

      return false;
    }
  }

  // ============================================================
  // CANCEL CONVERSION
  // ============================================================

  Future<bool> cancelConversion({
    required CartProvider cartProvider,
    required CurrencyProvider currencyProvider,
  }) async {
    try {
      log('🛑 CANCEL PHYSICAL CONVERSION');

      // ========================================================
      // GET CURRENT STATE
      // ========================================================

      final currentMetal = _metal;
      final currentAmount = _amount;
      final currency = currencyProvider.selectedCurrency;

      if (!_isActive ||
          currentMetal == null ||
          currentMetal.trim().isEmpty ||
          currentAmount <= 0) {
        log(
          '❌ Cannot cancel -> '
          'no active backend conversion available',
        );

        await fetchConversionStatus();

        return false;
      }

      log(
        '🚀 CANCEL API -> '
        'metal=$currentMetal '
        'amount=$currentAmount '
        'currency=$currency',
      );

      // ========================================================
      // STEP 1: CANCEL BACKEND CONVERSION
      // ========================================================

      final response = await JscService.cancelPhysicalConversion(
        metal: currentMetal,
        amount: currentAmount,
        currency: currency,
      );

      log('🔥 CANCEL RESPONSE: $response');

      final success = response['status'] == true;

      if (!success) {
        log(
          '❌ CANCEL API FAILED -> '
          '${response['message'] ?? 'Unknown error'}',
        );

        // Backend did not confirm cancellation.
        // Keep current frontend state and refresh it.
        await fetchConversionStatus();

        return false;
      }

      log('✅ BACKEND CONVERSION CANCELLED');

      // ========================================================
      // STEP 2: REMOVE PHYSICAL CART
      // ========================================================

      final cartRemoved = await cartProvider.removeCurrentBackendCart();

      if (!cartRemoved) {
        log('❌ Physical cart could not be removed');

        // Backend conversion is already cancelled.
        // We should still refresh backend state.
        await fetchConversionStatus();

        return false;
      }

      log('✅ PHYSICAL CART REMOVED');

      // ========================================================
      // STEP 3: RESTORE ORIGINAL NORMAL CART
      // ========================================================

      final restored = await cartProvider.restorePhysicalOrderProducts();

      if (!restored) {
        log('❌ ORIGINAL NORMAL CART COULD NOT BE RESTORED');

        await fetchConversionStatus();

        return false;
      }

      log('✅ ORIGINAL NORMAL CART RESTORED');

      // ========================================================
      // STEP 4: CLEAR FRONTEND CONVERSION STATE IMMEDIATELY
      // ========================================================

      clearActiveConversion();

      // ========================================================
      // STEP 5: FETCH NORMAL CART
      // ========================================================

      await cartProvider.fetchCart();

      log(
        '✅ NORMAL CART FETCHED -> '
        'items=${cartProvider.cartItems.length}',
      );

      // ========================================================
      // STEP 6: SUCCESS
      // ========================================================

      return true;
    } catch (e, stackTrace) {
      log('❌ cancelConversion ERROR: $e', stackTrace: stackTrace);

      return false;
    }
  }

  // ============================================================
  // VALIDATE PRODUCT
  // ============================================================

  String? validateProduct({String? metalType}) {
    if (!_isActive) {
      return null;
    }

    final normalizedProductMetal = metalType?.trim().toLowerCase();

    final normalizedConversionMetal = _metal?.trim().toLowerCase();

    log(
      'validateProduct -> '
      'productMetal=$normalizedProductMetal '
      'conversionMetal=$normalizedConversionMetal',
    );

    if (normalizedConversionMetal != normalizedProductMetal) {
      return 'Only $_metal products can be added during this conversion.';
    }

    return null;
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

  // void reset() {
  //   _isActive = false;
  //   _metal = null;
  //   _amount = 0;

  //   log('🧹 PHYSICAL CONVERSION PROVIDER RESET');

  //   notifyListeners();
  // }

  void clearActiveConversion() {
    _isActive = false;
    _metal = null;
    _amount = 0;
    _plan = null;

    log('🧹 PHYSICAL CONVERSION CLEARED FROM PROVIDER');

    notifyListeners();
  }
}
