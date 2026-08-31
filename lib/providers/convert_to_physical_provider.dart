// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:junubullion/providers/cart_provider.dart';
// import 'package:junubullion/providers/currency_provider.dart';
// import 'package:junubullion/services/jsc_services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PhysicalConversionProvider extends ChangeNotifier {
//   bool _isActive = false;
//   String? _metal;
//   double _amount = 0;

//   bool get isActive => _isActive;

//   String? get metal => _metal;

//   double get amount => _amount;

//   String get formattedAmount {
//     return _amount.toStringAsFixed(4);
//   }

//   // ============================================================
//   // SHARED PREFERENCES KEYS
//   // ============================================================

//   static const String _physicalActiveKey = 'physical_conversion_active';

//   static const String _physicalMetalKey = 'physical_conversion_metal';

//   static const String _physicalAmountKey = 'physical_conversion_amount';

//   // ============================================================
//   // INITIALIZE FROM LOCAL CACHE
//   //
//   // Used when app restarts so the active conversion remains visible.
//   //
//   // Backend API is still the actual source of truth.
//   // ============================================================

//   Future<void> initializePhysicalConversion() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       final active = prefs.getBool(_physicalActiveKey) ?? false;
//       final metal = prefs.getString(_physicalMetalKey);
//       final amount = prefs.getDouble(_physicalAmountKey) ?? 0;

//       if (active && metal != null && metal.trim().isNotEmpty && amount > 0) {
//         _isActive = true;
//         _metal = metal;
//         _amount = amount;

//         log(
//           '📦 PHYSICAL CONVERSION RESTORED FROM CACHE -> '
//           'active=$_isActive '
//           'metal=$_metal '
//           'amount=$_amount',
//         );
//       } else {
//         _isActive = false;
//         _metal = null;
//         _amount = 0;

//         log('📦 NO ACTIVE PHYSICAL CONVERSION IN CACHE');
//       }

//       notifyListeners();
//     } catch (e, stackTrace) {
//       log('❌ initializePhysicalConversion error: $e', stackTrace: stackTrace);
//     }
//   }

//   // ============================================================
//   // UPDATE FROM API
//   //
//   // API IS THE SOURCE OF TRUTH.
//   //
//   // status = active
//   //     -> conversion active
//   //     -> save locally
//   //
//   // status != active
//   //     -> conversion inactive
//   //     -> clear locally
//   // ============================================================

//   Future<void> updateFromApi({
//     required String status,
//     String? metal,
//     double? amount,
//   }) async {
//     try {
//       final normalizedStatus = status.trim().toLowerCase();

//       if (normalizedStatus == 'active') {
//         _isActive = true;
//         _metal = metal;
//         _amount = amount ?? 0;

//         log(
//           '✅ PHYSICAL CONVERSION ACTIVE FROM API -> '
//           'metal=$_metal '
//           'amount=$_amount',
//         );

//         await _saveConversionLocally(
//           active: true,
//           metal: _metal,
//           amount: _amount,
//         );
//       } else {
//         await _clearConversionState();

//         log(
//           '🛑 PHYSICAL CONVERSION INACTIVE FROM API -> '
//           'status=$normalizedStatus',
//         );
//       }

//       notifyListeners();
//     } catch (e, stackTrace) {
//       log('❌ updateFromApi error: $e', stackTrace: stackTrace);
//     }
//   }

//   // ============================================================
//   // SAVE CONVERSION LOCALLY
//   // ============================================================

//   Future<void> _saveConversionLocally({
//     required bool active,
//     String? metal,
//     double? amount,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.setBool(_physicalActiveKey, active);

//     if (active) {
//       await prefs.setString(_physicalMetalKey, metal ?? '');

//       await prefs.setDouble(_physicalAmountKey, amount ?? 0);
//     }
//   }

//   // ============================================================
//   // CLEAR CONVERSION STATE
//   //
//   // Clears BOTH:
//   // 1. Provider memory
//   // 2. SharedPreferences
//   //
//   // This should only happen after the cancel API succeeds.
//   // ============================================================

//   Future<void> _clearConversionState() async {
//     // Clear provider memory.
//     _isActive = false;
//     _metal = null;
//     _amount = 0;

//     // Clear local cache.
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.remove(_physicalActiveKey);
//     await prefs.remove(_physicalMetalKey);
//     await prefs.remove(_physicalAmountKey);

//     log('🧹 PHYSICAL CONVERSION STATE + CACHE CLEARED');
//   }

//   // ============================================================
//   // START CONVERSION
//   // ============================================================

//   Future<void> startConversion({
//     required String metal,
//     required double amount,
//   }) async {
//     _isActive = true;
//     _metal = metal;
//     _amount = amount;

//     await _saveConversionLocally(active: true, metal: metal, amount: amount);

//     log(
//       '🚀 PHYSICAL CONVERSION STARTED -> '
//       'metal=$metal '
//       'amount=$amount',
//     );

//     notifyListeners();
//   }

//   // ============================================================
//   // CANCEL CONVERSION
//   //
//   // FLOW:
//   //
//   // 1. Get active conversion details
//   // 2. Call cancel API
//   // 3. If API succeeds:
//   //      - restore previous normal cart
//   //      - clear provider state
//   //      - clear SharedPreferences
//   //      - fetch normal cart
//   // 4. If API fails:
//   //      - DO NOT clear conversion
//   //      - DO NOT restore cart
//   // ============================================================

//   Future<bool> cancelConversion({
//     required CartProvider cartProvider,
//     required CurrencyProvider currencyProvider,
//   }) async {
//     try {
//       log('🛑 Cancelling physical conversion');

//       // ============================================================
//       // STEP 1: SAVE CURRENT CONVERSION DETAILS
//       // ============================================================

//       final currentMetal = _metal;
//       final currentAmount = _amount;
//       final currency = currencyProvider.selectedCurrency;

//       if (!_isActive ||
//           currentMetal == null ||
//           currentMetal.trim().isEmpty ||
//           currentAmount <= 0) {
//         log('⚠️ No active physical conversion to cancel');
//         return false;
//       }

//       log(
//         '🚀 CANCEL CONVERSION API -> '
//         'metal=$currentMetal '
//         'amount=$currentAmount '
//         'currency=$currency',
//       );

//       // ============================================================
//       // STEP 2: CANCEL PHYSICAL CONVERSION API
//       // ============================================================

//       final response = await JscService.cancelPhysicalConversion(
//         metal: currentMetal,
//         amount: currentAmount,
//         currency: currency,
//       );

//       log('🔥 CANCEL CONVERSION RESPONSE: $response');

//       final bool apiStatus = response['status'] == true;

//       if (!apiStatus) {
//         log(
//           '❌ CANCEL CONVERSION FAILED -> '
//           '${response['message'] ?? 'Unknown error'}',
//         );

//         // IMPORTANT:
//         // Keep physical conversion active.
//         // Keep saved products untouched.
//         return false;
//       }

//       log('✅ PHYSICAL CONVERSION CANCELLED BY API');

//       // ============================================================
//       // STEP 3: REMOVE PHYSICAL-CONVERSION CART
//       //
//       // The backend cart may currently contain the product added
//       // during physical conversion with price 0.0.
//       //
//       // Remove that cart BEFORE restoring the original products.
//       // ============================================================

//       final cartRemoved = await cartProvider.removeCurrentBackendCart();

//       if (!cartRemoved) {
//         log(
//           '❌ Physical conversion cancelled, '
//           'but current backend cart could not be removed.',
//         );

//         // Do NOT clear local conversion state.
//         // Do NOT clear saved products.
//         //
//         // This allows us to avoid losing the user's original cart.
//         return false;
//       }

//       log('✅ Physical conversion cart removed');

//       // ============================================================
//       // STEP 4: RESTORE ORIGINAL NORMAL CART
//       //
//       // These products were saved when Start Order was clicked.
//       // ============================================================

//       final restored = await cartProvider.restorePhysicalOrderProducts();

//       if (!restored) {
//         log(
//           '⚠️ Physical conversion cancelled, '
//           'but some original products could not be restored.',
//         );

//         // Do not pretend the whole flow completed.
//         // Secure-storage products remain if restoration failed.
//         return false;
//       }

//       log('✅ ORIGINAL NORMAL CART RESTORED');

//       // ============================================================
//       // STEP 5: CLEAR PHYSICAL CONVERSION STATE
//       // ============================================================

//       await _clearConversionState();

//       log('🧹 PHYSICAL CONVERSION STATE CLEARED');

//       notifyListeners();

//       // ============================================================
//       // STEP 6: FETCH NORMAL CART
//       // ============================================================

//       await cartProvider.fetchCart();

//       log(
//         '✅ NORMAL CART FETCHED AFTER CANCELLATION -> '
//         'items=${cartProvider.cartItems.length}',
//       );

//       return true;
//     } catch (e, stackTrace) {
//       log('❌ cancelConversion error: $e', stackTrace: stackTrace);

//       return false;
//     }
//   }

//   // ============================================================
//   // VALIDATE PRODUCT
//   // ============================================================

//   String? validateProduct({String? metalType}) {
//     if (!_isActive) {
//       return null;
//     }

//     final normalizedMetal = metalType?.trim().toLowerCase();

//     final conversionMetal = _metal?.trim().toLowerCase();

//     log(
//       'validateProduct -> '
//       'productMetal=$normalizedMetal '
//       'conversionMetal=$conversionMetal',
//     );

//     if (conversionMetal != normalizedMetal) {
//       return 'Only $_metal products can be added during this conversion.';
//     }

//     return null;
//   }

//   // ============================================================
//   // DIGITAL PRODUCTS
//   // ============================================================

//   final Set<dynamic> digitalProductIds = {};

//   void setDigitalProductIds(List<dynamic> products) {
//     digitalProductIds
//       ..clear()
//       ..addAll(
//         products
//             .take(4)
//             .map((product) => product['id'])
//             .where((id) => id != null),
//       );

//     log('DIGITAL PRODUCT IDS: $digitalProductIds');

//     notifyListeners();
//   }

//   bool isDigitalProduct(dynamic productId) {
//     return digitalProductIds.contains(productId);
//   }

//   Future<void> fetchConversionStatus() async {
//     try {
//       log('🔄 FETCHING PHYSICAL CONVERSION STATUS...');

//       final response = await JscService.fetchConvertDetails();

//       log('📦 CONVERT DETAILS RESPONSE: $response');

//       // --------------------------------------------------------
//       // Validate response
//       // --------------------------------------------------------

//       if (response['status'] != true) {
//         log(
//           '⚠️ CONVERSION STATUS API FAILED/NOT SUCCESSFUL'
//           ' -> keeping current local state',
//         );

//         return;
//       }

//       final data = response['data'];

//       if (data is! Map<String, dynamic>) {
//         log(
//           '⚠️ INVALID CONVERSION DATA '
//           '-> keeping current local state',
//         );

//         return;
//       }

//       // --------------------------------------------------------
//       // Backend status
//       // --------------------------------------------------------

//       final status = data['status']?.toString().trim().toLowerCase() ?? '';

//       final metal = data['metal']?.toString();

//       final amount =
//           double.tryParse('${data['amount_grams'] ?? data['amount'] ?? 0}') ??
//           0;

//       log(
//         '📦 BACKEND CONVERSION -> '
//         'status=$status '
//         'metal=$metal '
//         'amount=$amount',
//       );

//       // --------------------------------------------------------
//       // ONLY backend "active" means active.
//       // --------------------------------------------------------

//       if (status == 'active') {
//         await updateFromApi(status: 'active', metal: metal, amount: amount);

//         log(
//           '✅ ACTIVE CONVERSION RESTORED FROM BACKEND -> '
//           'active=$_isActive '
//           'metal=$_metal '
//           'amount=$_amount',
//         );

//         return;
//       }

//       // --------------------------------------------------------
//       // Backend explicitly says inactive/cancelled.
//       // --------------------------------------------------------

//       if (status == 'inactive' ||
//           status == 'cancelled' ||
//           status == 'completed') {
//         await updateFromApi(status: status);

//         log(
//           '🛑 BACKEND EXPLICITLY SAYS INACTIVE -> '
//           'state cleared',
//         );

//         return;
//       }

//       // --------------------------------------------------------
//       // Unknown status.
//       //
//       // DO NOT clear local state.
//       // --------------------------------------------------------

//       log(
//         '⚠️ UNKNOWN CONVERSION STATUS="$status" '
//         '-> keeping current local state',
//       );
//     } catch (e, stackTrace) {
//       log('❌ fetchConversionStatus ERROR: $e', stackTrace: stackTrace);

//       // IMPORTANT:
//       // Never clear physical conversion here.
//       //
//       // Network/API failure != conversion cancelled.
//     }
//   }
// }

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

  void _setActive({required String? metal, required double amount}) {
    _isActive = true;
    _metal = metal;
    _amount = amount;

    log(
      '✅ PHYSICAL CONVERSION STATE -> '
      'ACTIVE '
      'metal=$_metal '
      'amount=$_amount',
    );

    notifyListeners();
  }

  Future<void> fetchConversionStatus({bool showLoader = false}) async {
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
        _setActive(metal: metal, amount: amount);

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

    log('🧹 PHYSICAL CONVERSION CLEARED FROM PROVIDER');

    notifyListeners();
  }
}
