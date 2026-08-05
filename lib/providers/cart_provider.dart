import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<bool> addToCart({required int productId, int quantity = 1}) async {
    addingProducts.add(productId);
    notifyListeners();

    try {
      final response = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      log("CARTTT ${response}");

      if (response["status"] == true) {
        restoreCoupon();
        await fetchCart();
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
}
