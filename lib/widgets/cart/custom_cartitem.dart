import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isPhysicalConversion;

  const CartItemCard({
    super.key,
    required this.item,
    this.isPhysicalConversion = false,
  });

  // ============================================================
  // PARSE WEIGHT
  // ============================================================

  double _getWeightGrams(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // PARSE QUANTITY
  // ============================================================

  int _getQuantity(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // CALCULATE TOTAL CART WEIGHT
  //
  // Example:
  //
  // 20g x 1 = 20g
  // 5g  x 2 = 10g
  //
  // Total = 30g
  // ============================================================

  double _getCurrentCartWeight(CartProvider provider) {
    double totalWeight = 0;

    for (final cartItem in provider.cartItems) {
      // IMPORTANT:
      // Backend's weight_grams is already the TOTAL weight
      // for this cart line.
      //
      // Example:
      // quantity = 2
      // product weight = 5g
      // weight_grams = 10g
      //
      // So DO NOT multiply weight_grams by quantity again.

      final weight = _getWeightGrams(cartItem["weight_grams"]);

      totalWeight += weight;
    }

    return totalWeight;
  }

  // ============================================================
  // CHECK PHYSICAL CONVERSION LIMIT
  // ============================================================

  bool _canIncreasePhysicalQuantity(
    BuildContext context,
    CartProvider cartProvider,
    PhysicalConversionProvider physicalProvider,
  ) {
    // ------------------------------------------------------------
    // Only apply this validation during physical conversion.
    // ------------------------------------------------------------

    if (!isPhysicalConversion || !physicalProvider.isActive) {
      return true;
    }

    final conversionAmount = physicalProvider.amount;

    if (conversionAmount <= 0) {
      return true;
    }

    // ------------------------------------------------------------
    // Current total cart weight.
    //
    // IMPORTANT:
    // weight_grams from backend is already the line TOTAL.
    // ------------------------------------------------------------

    final currentCartWeight = _getCurrentCartWeight(cartProvider);

    // ------------------------------------------------------------
    // Get this product's current line weight and quantity.
    //
    // Example:
    //
    // quantity = 2
    // weight_grams = 10
    //
    // One additional quantity = 10 / 2 = 5g
    // ------------------------------------------------------------

    final currentQuantity = _getQuantity(item["quantity"]);

    final currentLineWeight = _getWeightGrams(item["weight_grams"]);

    double productWeight = 0;

    if (currentQuantity > 0 && currentLineWeight > 0) {
      productWeight = currentLineWeight / currentQuantity;
    }

    // ------------------------------------------------------------
    // Calculate the cart weight AFTER clicking +
    // ------------------------------------------------------------

    final newTotalWeight = currentCartWeight + productWeight;

    final allowed = newTotalWeight <= conversionAmount;

    debugPrint(
      '⚖️ PHYSICAL CART WEIGHT CHECK -> '
      'currentCartWeight=$currentCartWeight g, '
      'currentQuantity=$currentQuantity, '
      'currentLineWeight=$currentLineWeight g, '
      'productWeight=$productWeight g, '
      'newTotalWeight=$newTotalWeight g, '
      'conversionAmount=$conversionAmount g, '
      'allowed=$allowed',
    );

    if (!allowed) {
      final amountText = conversionAmount % 1 == 0
          ? conversionAmount.toInt().toString()
          : conversionAmount.toStringAsFixed(4);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: TranslatedText(
              'The selected products exceed your conversion allowance of $amountText g.',
            ),
          ),
        );
    }

    return allowed;
  }

  @override
  Widget build(BuildContext context) {
    final bool canPurchase = item["stock_status"] == "in_stock";

    final provider = context.watch<CartProvider>();

    final currencyProvider = context.watch<CurrencyProvider>();

    final hasCoupon =
        !provider.isCouponRemoved &&
        item["has_discount"] == true &&
        (item["coupon_line_discount"] ?? 0) > 0;

    final showDiscount =
        !isPhysicalConversion &&
        !provider.isCouponRemoved &&
        provider.coupon != null &&
        item["formatted_compare_price"] != null;

    final String displayPrice = isPhysicalConversion
        ? "${currencyProvider.selectedCurrency} 0.00"
        : showDiscount
        ? (item["formatted_effective_unit_price"] ?? "0.00")
        : item["formatted_compare_price"] ??
              item["formatted_unit_price"] ??
              "0.00";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB8C2D6), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // PRODUCT IMAGE
          // ============================================================
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.BgGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  item["image"] ?? "",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 35),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ============================================================
          // RIGHT CONTENT
          // ============================================================
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======================================================
                  // PRODUCT NAME + DELETE
                  // ======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TranslatedText(
                          item["name"] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xffF7F7F7),
                              title: const TranslatedText("Remove Item"),
                              content: const TranslatedText(
                                "Are you sure you want to remove this product from your cart?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const TranslatedText("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const TranslatedText(
                                    "Remove",
                                    style: TextStyle(
                                      color: AppColors.primaryRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            final success = await context
                                .read<CartProvider>()
                                .removeFromCart(item["product_id"]);

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: TranslatedText(
                                    "Product removed from cart",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Image.asset(
                          "assets/delete.png",
                          width: 35,
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // ======================================================
                  // SHIPPING
                  // ======================================================
                  const TranslatedText(
                    "Free 2 - 4 day shipping",
                    style: TextStyle(fontSize: 12),
                  ),

                  const Spacer(),

                  // ======================================================
                  // PRICE + QUANTITY
                  // ======================================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --------------------------------------------------
                      // PRICE
                      // --------------------------------------------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showDiscount)
                              TranslatedText(
                                item["formatted_compare_price"],
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),

                            TranslatedText(
                              displayPrice,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // const SizedBox(width: 15),

                      // --------------------------------------------------
                      // QUANTITY CONTROL
                      // --------------------------------------------------
                      Container(
                        height: 35,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E3E6),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // MINUS
                            _quantityButton(
                              icon: Icons.remove,
                              onPressed: canPurchase
                                  ? () async {
                                      final provider = context
                                          .read<CartProvider>();

                                      final qty = _getQuantity(
                                        item["quantity"],
                                      );

                                      if (qty == 1) {
                                        await provider.removeFromCart(
                                          item["product_id"],
                                        );
                                      } else {
                                        await provider.updateCartQuantity(
                                          productId: item["product_id"],
                                          quantity: qty - 1,
                                        );
                                      }
                                    }
                                  : null,
                            ),

                            // QUANTITY
                            SizedBox(
                              width: 25,
                              child: Center(
                                child: TranslatedText(
                                  item["quantity"].toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            // PLUS
                            _quantityButton(
                              icon: Icons.add,
                              onPressed: canPurchase
                                  ? () async {
                                      final cartProvider = context
                                          .read<CartProvider>();

                                      if (isPhysicalConversion) {
                                        final physicalProvider = context
                                            .read<PhysicalConversionProvider>();

                                        final canIncrease =
                                            _canIncreasePhysicalQuantity(
                                              context,
                                              cartProvider,
                                              physicalProvider,
                                            );

                                        if (!canIncrease) {
                                          return;
                                        }
                                      }

                                      final qty = _getQuantity(
                                        item["quantity"],
                                      );

                                      await cartProvider.updateCartQuantity(
                                        productId: item["product_id"],
                                        quantity: qty + 1,
                                      );
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ======================================================
                  // COUPON
                  // ======================================================
                  if (!isPhysicalConversion &&
                      hasCoupon &&
                      provider.coupon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: TranslatedText(
                        "Coupon ${provider.coupon!["code"]} applied",
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 35,
      height: 30,
      child: Material(
        color: const Color(0xFF982020),
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(7),
          child: Center(child: Icon(icon, color: Colors.white, size: 20)),
        ),
      ),
    );
  }
}
