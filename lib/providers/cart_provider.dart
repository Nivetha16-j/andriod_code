import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:junubullion/services/cart_services.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/services/session_manager.dart';

class CartProvider extends ChangeNotifier {
  List<dynamic> cartItems = [];

  bool isLoading = false;
  final Set<int> addingProducts = {};

  bool isAdding(int productId) {
    return addingProducts.contains(productId);
  }

  Future<void> fetchCart() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await CartService.fetchCart();
      log("ressssssssss $response");

      if (response["status"] == true) {
        cartItems = response["data"]["summary"]["items"] ?? [];
        log("Cart itemssssssss ${cartItems.length}");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<bool> addToCart({required int productId, int quantity = 1}) async {
  //   addingProducts.add(productId);
  //   notifyListeners();

  //   try {
  //     final response = await CartService.addToCart(
  //       productId: productId,
  //       quantity: quantity,
  //     );

  //     if (response["status"] == true) {
  //       cartItems = response["data"]["items"] ?? [];
  //       debugPrint("After Add: ${cartItems.length}");

  //       notifyListeners();
  //       return true;
  //     }

  //     return false;
  //   } finally {
  //     addingProducts.remove(productId);
  //     notifyListeners();
  //   }
  // }

  Future<bool> addToCart({required int productId, int quantity = 1}) async {
    addingProducts.add(productId);
    notifyListeners();

    try {
      final response = await CartService.addToCart(
        productId: productId,
        quantity: quantity,
      );

      if (response["status"] == true) {
        // Always reload the cart from GET /cart
        await fetchCart();
        return true;
      }

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
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  double get subtotal {
    double total = 0;

    for (var item in cartItems) {
      double price =
          double.tryParse(
            (item["effective_unit_price"] ??
                    item["unit_price"] ??
                    item["price"] ??
                    0)
                .toString(),
          ) ??
          0;

      int quantity = int.tryParse(item["quantity"].toString()) ?? 0;

      total += price * quantity;
    }

    return total;
  }
}
