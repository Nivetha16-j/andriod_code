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
  String? fulfillment;
  String? digitalSubtype;

  bool isAdding(int productId) => addingProducts.contains(productId);

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

      log(
        "🛒 CART RESPONSE -> "
        "$_currency / $_unit / $selectedDeliveryMethod / $response",
      );

      if (response["status"] == true) {
        final data = response["data"] as Map<String, dynamic>?;

        final summary = data?["summary"] as Map<String, dynamic>?;

        if (summary is Map<String, dynamic>) {
          fulfillment = summary["fulfillment"]?.toString();
          digitalSubtype = summary["digital_subtype"]?.toString();
        }

        if (summary == null) {
          log("⚠️ Cart response has no summary");

          cartItems = [];

          notifyListeners();
          return;
        }

        final items = summary["items"];

        cartItems = items is List ? List<dynamic>.from(items) : <dynamic>[];

        log("🛒 BACKEND CART ITEMS -> ${cartItems.length}");

        final symbol = summary["symbol"]?.toString() ?? "";

        currencySymbol = symbol;

        subtotalAmount = (summary["subtotal"] as num?)?.toDouble() ?? 0.0;

        formattedSubtotal =
            summary["formatted_subtotal"] ??
            "$symbol${NumberFormat('#,##0.00').format(subtotalAmount)}";

        final courier = summary["courier"] as Map<String, dynamic>?;

        isCourierFree = courier?["is_free"] == true;

        courierAmount = isCourierFree
            ? 0.0
            : (courier?["amount"] as num?)?.toDouble() ?? 0.0;

        formattedCourierFee = isCourierFree
            ? "$symbol 0.00"
            : courier?["formatted_amount"]?.toString() ??
                  "$symbol${NumberFormat('#,##0.00').format(courierAmount)}";

        transactionFeeAmount =
            (summary["transaction_fee"] as num?)?.toDouble() ?? 0.0;

        formattedTransactionFee =
            summary["formatted_transaction_fee"]?.toString() ??
            "$symbol${NumberFormat('#,##0.00').format(transactionFeeAmount)}";

        gstAmount = (summary["tax"] as num?)?.toDouble() ?? 0.0;

        formattedGST =
            summary["formatted_tax"]?.toString() ??
            "$symbol${NumberFormat('#,##0.00').format(gstAmount)}";

        showTax = summary["show_tax"] == true;

        totalAmount = (summary["total"] as num?)?.toDouble() ?? 0.0;

        formattedOrderTotal =
            summary["formatted_total"]?.toString() ??
            "$symbol${NumberFormat('#,##0.00').format(totalAmount)}";

        if (isCouponRemoved) {
          coupon = null;
          formattedDiscount = "";
          formattedDiscountPrice = "";
        } else {
          coupon = summary["coupon"] as Map<String, dynamic>?;

          if (coupon != null) {
            formattedDiscount = coupon!["formatted_amount"]?.toString() ?? "";

            final discount = (summary["discount"] as num?)?.toDouble() ?? 0.0;

            formattedDiscountPrice =
                "$symbol${(subtotalAmount - discount).toStringAsFixed(2)}";
          } else {
            formattedDiscount = "";
            formattedDiscountPrice = "";
          }
        }

        notifyListeners();

        log(
          "✅ CART STATE UPDATED -> "
          "items=${cartItems.length}, "
          "subtotal=$subtotalAmount, "
          "total=$totalAmount",
        );
      } else {
        log(
          "⚠️ CART API FAILED -> "
          "${response["message"] ?? "Unknown error"}",
        );
      }
    } catch (e, stackTrace) {
      log("❌ Fetch Cart Error: $e", stackTrace: stackTrace);
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
      log('🗑️ Removing product from cart -> productId=$productId');

      final response = await CartService.removeFromCart(productId: productId);

      log('🗑️ REMOVE PRODUCT RESPONSE -> $response');

      if (response["status"] == true) {
        cartItems.removeWhere((item) => item["product_id"] == productId);

        log(
          '🗑️ LOCAL CART AFTER REMOVE -> '
          'items=${cartItems.length}',
        );

        notifyListeners();

        await fetchCart();

        if (cartItems.isEmpty) {
          isCouponRemoved = false;
          coupon = null;
          formattedDiscount = "";
          formattedDiscountPrice = "";
          notifyListeners();
        }

        return true;
      }

      log(
        '❌ REMOVE PRODUCT FAILED -> '
        '${response["message"] ?? "Unknown error"}',
      );

      return false;
    } catch (e, stackTrace) {
      log("❌ Remove Cart Error: $e", stackTrace: stackTrace);

      return false;
    }
  }

  Future<bool> updateCartQuantity({
    required int productId,
    required int quantity,
  }) async {
    try {
      log(
        '🔄 UPDATE CART -> '
        'productId=$productId '
        'quantity=$quantity',
      );

      if (quantity <= 0) {
        return await removeFromCart(productId);
      }

      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        log('❌ No token available');

        return false;
      }

      final response = await CartService.updateCart(
        productId: productId,
        quantity: quantity,
        token: token,
      );

      log('🔄 UPDATE CART RESPONSE -> $response');

      if (response["status"] == true) {
        await fetchCart();
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      log("❌ Update Cart Error: $e", stackTrace: stackTrace);

      return false;
    }
  }

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
      if (cartItems.isEmpty) {
        log('🟢 Normal cart is empty.');
        log('➡️ Skipping account API');
        log('➡️ Skipping remove cart API');
        log('➡️ Skipping local storage');
        log('✅ Starting physical order directly');

        return true;
      }

      final products = cartItems
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      log(
        '📦 Saving ${products.length} products '
        'for physical order',
      );

      await SessionManager.savePhysicalOrderProducts(products);

      log('✅ Products saved locally');

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

      final removeResponse = await CartService.removeCart();

      log('🗑️ Remove Cart Response: $removeResponse');

      if (removeResponse['status'] != true) {
        log('❌ Failed to remove backend cart');

        await SessionManager.clearPhysicalOrderProducts();

        return false;
      }

      log('✅ Backend cart removed');

      cartItems.clear();

      notifyListeners();

      log('✅ Normal cart cleared');

      return true;
    } catch (e, stackTrace) {
      log('❌ moveCartToPhysicalOrder error: $e', stackTrace: stackTrace);

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

      if (allRestored) {
        await SessionManager.clearPhysicalOrderProducts();

        log('🧹 Saved physical-order products cleared');
      } else {
        log(
          '⚠️ Some products failed to restore. '
          'Keeping secure-storage data for retry.',
        );
      }

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
