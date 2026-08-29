import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/services/account_services.dart';
import 'package:junubullion/services/cart_services.dart';
import 'package:junubullion/services/session_manager.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> cartItems = [];

  bool isLoading = false;
  final Set<int> addingProducts = {};

  int get cartCount => cartItems.length;
  String selectedDeliveryMethod = "Standard";

  bool isCouponRemoved = false;

  String subTotal = "";
  String formattedSubtotal = "";
  String formattedOrderTotal = "";
  String formattedTransactionFee = "";
  String formattedCourierFee = "";

  Map<String, dynamic>? coupon;

  String formattedDiscount = "";
  String formattedDiscountPrice = "";

  String _currency = "USD";
  String _unit = "gram";

  String get currency => _currency;
  String get unit => _unit;

  double subtotalAmount = 0;
  double courierAmount = 0;
  double transactionFeeAmount = 0;
  double gstAmount = 0;
  double totalAmount = 0;

  String currencySymbol = "";
  String formattedGST = "";

  bool isCourierFree = false;
  bool showTax = false;

  bool isAdding(int productId) => addingProducts.contains(productId);

  /// Call this whenever currency/unit changes
  void updateSelection({required String currency, required String unit}) {
    _currency = currency;
    _unit = unit;
    notifyListeners();
  }

  Future<void> fetchCart() async {
    log("🔥 fetchCart() called");
    isLoading = true;
    notifyListeners();

    try {
      final response = await CartService.fetchCart(
        currency: _currency,
        unit: _unit,
        courierService: selectedDeliveryMethod,
      );

      log("ccccccccc $_currency......$_unit...$response");

      if (response["status"] == true) {
        cartItems = response["data"]["summary"]["items"] ?? [];

        final summary = response["data"]["summary"];

        final symbol = summary["symbol"];
        currencySymbol = summary["symbol"];

        subtotalAmount = (summary["subtotal"] as num).toDouble();

        isCourierFree = summary["courier"]?["is_free"] ?? false;
        courierAmount = isCourierFree
            ? 0
            : (summary["courier"]["amount"] as num).toDouble();

        formattedSubtotal =
            "$symbol${NumberFormat('#,##0.00').format(summary["subtotal"])}";

        // formattedOrderTotal =
        //     "$symbol${NumberFormat('#,##0.00').format(summary["total"])}";
        // formattedTransactionFee =
        //     "$symbol${NumberFormat('#,##0.00').format(summary["transaction_fee"])}";

        transactionFeeAmount = (summary["transaction_fee"] as num).toDouble();

        gstAmount = (summary["tax"] as num).toDouble();

        totalAmount = (summary["total"] as num).toDouble();

        showTax = summary["show_tax"] ?? false;
        // } else {
        //   gstAmount = 0;

        //   totalAmount = subtotalAmount + courierAmount + transactionFeeAmount;
        // }

        formattedTransactionFee =
            summary["formatted_transaction_fee"] ??
            "$currencySymbol${NumberFormat('#,##0.00').format(transactionFeeAmount)}";

        formattedGST =
            summary["formatted_tax"] ??
            "$currencySymbol${NumberFormat('#,##0.00').format(gstAmount)}";

        formattedOrderTotal =
            summary["formatted_total"] ??
            "$currencySymbol${NumberFormat('#,##0.00').format(totalAmount)}";

        isCourierFree = summary["courier"]?["is_free"] ?? false;

        formattedCourierFee = isCourierFree
            ? "$currencySymbol 0.00"
            : summary["courier"]["formatted_amount"];

        if (isCouponRemoved) {
          coupon = null;
          formattedDiscount = "";
          formattedDiscountPrice = "";
        } else {
          coupon = summary["coupon"];
        }

        if (!isCouponRemoved && coupon != null) {
          formattedDiscount = coupon!["formatted_amount"] ?? "";

          formattedDiscountPrice =
              "${summary["symbol"]}${((summary["subtotal"] as num) - (summary["discount"] as num)).toStringAsFixed(2)}";
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Fetch Cart Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart({
    required int productId,
    int quantity = 1,
    bool refreshCart = true,
  }) async {
    addingProducts.add(productId);
    notifyListeners();

    try {
      final response = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      log("CARTTT $response");

      if (response["status"] == true) {
        restoreCoupon();

        if (refreshCart) {
          await fetchCart();
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Add Cart Error: $e");
      return false;
    } finally {
      addingProducts.remove(productId);
      notifyListeners();
    }
  }

  bool isProductInCart(int productId) {
    return cartItems.any((item) => item["product_id"] == productId);
  }

  Future<bool> removeFromCart(int productId) async {
    try {
      final response = await CartService.removeFromCart(productId: productId);

      if (response["status"] == true) {
        await fetchCart();
        if (cartItems.isEmpty) {
          isCouponRemoved = false;
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Remove Cart Error: $e");
      return false;
    }
  }

  Future<bool> updateCartQuantity({
    required int productId,
    required int quantity,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final response = await CartService.updateCart(
        productId: productId,
        quantity: quantity,
        token: token!,
      );

      if (response["status"] == true) {
        await fetchCart();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Update Cart Error: $e");
      return false;
    }
  }

  // Future<void> updateCourier({
  //   required String currency,
  //   required String service,
  // }) async {
  //   log("✅ updateCourier() called");
  //   final response = await CartService.updateCourierCharge(
  //     currency: currency,
  //     courierService: service,
  //   );

  //   log("Courier Response: $response");

  //   if (response["status"] == true) {
  //     final summary = response["data"]["cart"];

  //     formattedCourierFee = summary["courier"]["formatted_amount"];

  //     formattedTransactionFee =
  //         "${summary["symbol"]}${summary["transaction_fee"].toStringAsFixed(2)}";

  //     formattedOrderTotal =
  //         "${summary["symbol"]}${summary["total"].toStringAsFixed(2)}";

  //     selectedDeliveryMethod = service;
  //     await fetchCart();

  //     log(
  //       "Courier Updated: $formattedCourierFee, $formattedTransactionFee, $formattedOrderTotal",
  //     );

  //     notifyListeners();
  //   }
  // }

  double get subtotal {
    double total = 0;

    for (var item in cartItems) {
      final double price =
          double.tryParse(
            (item["effective_unit_price"] ??
                    item["unit_price"] ??
                    item["price"] ??
                    0)
                .toString(),
          ) ??
          0;

      final int quantity = int.tryParse(item["quantity"].toString()) ?? 0;

      total += price * quantity;
    }

    return total;
  }

  void clearCart() {
    cartItems.clear();
    // subtotal = 0;
    notifyListeners();
  }

  void setDeliveryMethod(String method) {
    selectedDeliveryMethod = method;
    notifyListeners();
  }

  void removeCouponLocally() {
    isCouponRemoved = true;
    coupon = null;
    formattedDiscount = "";
    formattedDiscountPrice = "";
    notifyListeners();
  }

  void restoreCoupon() {
    isCouponRemoved = false;
  }

  Future<bool> moveCartToPhysicalOrder() async {
    try {
      // ============================================================
      // CASE 1: CART IS EMPTY
      // ============================================================
      // Do NOT:
      // - call account details API
      // - remove backend cart
      // - save products to SharedPreferences
      //
      // Just allow the physical order flow to start directly.
      // ============================================================

      if (cartItems.isEmpty) {
        log('🟢 Normal cart is empty.');
        log('➡️ Skipping account API');
        log('➡️ Skipping remove cart API');
        log('➡️ Skipping local storage');
        log('✅ Starting physical order directly');

        return true;
      }

      // ============================================================
      // CASE 2: CART HAS PRODUCTS
      // ============================================================

      final products = cartItems
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      log(
        '📦 Saving ${products.length} products '
        'for physical order',
      );

      // Save normal cart products temporarily
      await SessionManager.savePhysicalOrderProducts(products);

      log('✅ Products saved locally');

      // ============================================================
      // GET ACCOUNT DETAILS
      // ============================================================

      final accountService = AccountService();

      final accountResponse = await accountService.fetchAccountDetails();

      log('👤 Account Response: $accountResponse');

      final accountData = accountResponse['data'] as Map<String, dynamic>?;

      final accountId = accountData?['id'];

      if (accountId == null) {
        log('❌ Account ID not found');

        await SessionManager.clearPhysicalOrderProducts();

        return false;
      }

      log('👤 Account ID: $accountId');

      // ============================================================
      // REMOVE NORMAL CART FROM BACKEND
      // ============================================================

      final removeResponse = await CartService.removeCart();

      log('🗑️ Remove Cart Response: $removeResponse');

      if (removeResponse['status'] != true) {
        log('❌ Failed to remove backend cart');

        await SessionManager.clearPhysicalOrderProducts();

        return false;
      }

      log('✅ Backend cart removed');

      // ============================================================
      // CLEAR LOCAL NORMAL CART
      // ============================================================

      cartItems.clear();

      notifyListeners();

      log('✅ Normal cart cleared');

      return true;
    } catch (e, stackTrace) {
      log('❌ moveCartToPhysicalOrder error: $e', stackTrace: stackTrace);

      // Only clear saved products if we actually saved them.
      if (cartItems.isNotEmpty) {
        await SessionManager.clearPhysicalOrderProducts();
      }

      return false;
    }
  }

  Future<bool> restorePhysicalOrderProducts() async {
    try {
      final products = await SessionManager.getPhysicalOrderProducts();

      if (products.isEmpty) {
        log('ℹ️ No saved products to restore');
        return true;
      }

      log(
        '♻️ Restoring ${products.length} products '
        'from secure storage',
      );

      bool allRestored = true;

      for (final product in products) {
        final dynamic productId = product['product_id'];

        if (productId == null) {
          log('⚠️ Saved product has no product_id: $product');
          allRestored = false;
          continue;
        }

        final int quantity = int.tryParse('${product['quantity'] ?? 1}') ?? 1;

        log(
          '♻️ Restoring product '
          'productId=$productId '
          'quantity=$quantity',
        );

        final success = await addToCart(
          productId: int.parse(productId.toString()),
          quantity: quantity,
        );

        if (!success) {
          log(
            '❌ Failed to restore product '
            'productId=$productId',
          );

          allRestored = false;
        }
      }

      // Only clear secure storage if EVERYTHING was restored.
      if (allRestored) {
        await SessionManager.clearPhysicalOrderProducts();

        log('🧹 Saved physical-order products cleared');
      } else {
        log(
          '⚠️ Some products failed to restore. '
          'Keeping secure-storage data for retry.',
        );
      }

      // Fetch the actual backend cart once.
      await fetchCart();

      log(
        '♻️ Restore completed. '
        'cartItems=${cartItems.length}',
      );

      return allRestored;
    } catch (e, stackTrace) {
      log('❌ restorePhysicalOrderProducts error: $e', stackTrace: stackTrace);

      return false;
    }
  }

  Future<bool> removeCurrentBackendCart() async {
    try {
      log('🗑️ Removing current backend cart...');

      final accountService = AccountService();

      final accountResponse = await accountService.fetchAccountDetails();

      log('👤 Account response: $accountResponse');

      final accountData = accountResponse['data'] as Map<String, dynamic>?;

      final accountId = accountData?['id'];

      if (accountId == null) {
        log('❌ Account ID not found while removing cart');
        return false;
      }

      log('👤 Account ID: $accountId');

      final response = await CartService.removeCart();

      log('🗑️ REMOVE CURRENT CART RESPONSE: $response');

      if (response['status'] == true) {
        cartItems.clear();

        notifyListeners();

        log('✅ Current backend cart removed successfully');

        return true;
      }

      log(
        '❌ Failed to remove current backend cart: '
        '${response['message'] ?? 'Unknown error'}',
      );

      return false;
    } catch (e, stackTrace) {
      log('❌ removeCurrentBackendCart error: $e', stackTrace: stackTrace);

      return false;
    }
  }
}
