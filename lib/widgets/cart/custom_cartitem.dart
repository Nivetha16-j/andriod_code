import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
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
            content: Text(
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
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item["image"] ?? "",
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                height: 70,
                width: 70,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Free 2 - 4 days shipping",
                  style: TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 5),

                const Text("7 days return", style: TextStyle(fontSize: 12)),

                const SizedBox(height: 5),

                Row(
                  children: [
                    if (showDiscount) ...[
                      Text(
                        item["formatted_compare_price"],
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    Text(
                      displayPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                if (!isPhysicalConversion &&
                    hasCoupon &&
                    provider.coupon != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "Coupon ${provider.coupon!["code"]} applied",
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          Column(
            children: [
              // ==================================================
              // DELETE
              // ==================================================
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primaryRed,
                ),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xffF7F7F7),
                      title: const Text("Remove Item"),
                      content: const Text(
                        "Are you sure you want to remove this product from your cart?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: Text(
                            "Remove",
                            style: TextStyle(color: AppColors.primaryRed),
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
                          content: Text("Product removed from cart"),
                        ),
                      );
                    }
                  }
                },
              ),

              // ==================================================
              // QUANTITY
              // ==================================================
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // ==================================================
                    // MINUS
                    // ==================================================
                    IconButton(
                      onPressed: canPurchase
                          ? () async {
                              final provider = context.read<CartProvider>();

                              final qty = _getQuantity(item["quantity"]);

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
                      icon: const Icon(Icons.remove),
                    ),

                    Text(
                      item["quantity"].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    // ==================================================
                    // PLUS
                    // ==================================================
                    IconButton(
                      onPressed: canPurchase
                          ? () async {
                              final cartProvider = context.read<CartProvider>();

                              // Only apply conversion weight validation
                              // when physical conversion is active.
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

                              final qty = _getQuantity(item["quantity"]);

                              await cartProvider.updateCartQuantity(
                                productId: item["product_id"],
                                quantity: qty + 1,
                              );
                            }
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
