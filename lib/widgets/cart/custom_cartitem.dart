import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool canPurchase = item["stock_status"] == "in_stock";

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
              // height: 70,
              width: 70,
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

                Text(
                  "Free 2 - 4 days shipping",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text("7 days return", style: const TextStyle(fontSize: 12)),

                const SizedBox(height: 5),

                Text(
                  item["formatted_unit_price"] ??
                      item["formatted_effective_unit_price"] ??
                      "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
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
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
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

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Product removed from cart"),
                        ),
                      );
                    }
                  }
                },
              ),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: canPurchase
                          ? () async {
                              final provider = context.read<CartProvider>();

                              final qty = item["quantity"];

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

                    IconButton(
                      onPressed: canPurchase
                          ? () async {
                              final provider = context.read<CartProvider>();

                              final qty = item["quantity"];

                              await provider.updateCartQuantity(
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
