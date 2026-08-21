import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ExclusiveCollectionsSection extends StatefulWidget {
  final List<dynamic>? products;
  final VoidCallback? onViewMoreTap;
  final String currency;
  final String unit;

  const ExclusiveCollectionsSection({
    super.key,
    this.products,
    this.onViewMoreTap,
    required this.currency,
    required this.unit,
  });

  static const Color primaryDarkRed = Color(0xFF7A1C1C);
  static const Color accentGold = Color(0xFFC59800);
  static const String imageBaseUrl = 'https://staging.junubullion.com/storage/';

  @override
  State<ExclusiveCollectionsSection> createState() =>
      _ExclusiveCollectionsSectionState();
}

class _ExclusiveCollectionsSectionState
    extends State<ExclusiveCollectionsSection> {
  List<dynamic>? _liveProducts;

  Timer? _refreshTimer;

  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    _liveProducts = widget.products;

    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant ExclusiveCollectionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currency != oldWidget.currency ||
        widget.unit != oldWidget.unit) {
      _refreshTimer?.cancel();

      _startAutoRefresh();
    }

    if (widget.products != oldWidget.products) {
      _liveProducts = widget.products;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();

    super.dispose();
  }

  // ============================================================
  // LIVE PRICE REFRESH
  // ============================================================

  void _startAutoRefresh() {
    _refreshTimer?.cancel();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isFetching || !mounted) {
        return;
      }

      _isFetching = true;

      try {
        final homeData = await ApiService.fetchHomeData(
          currency: widget.currency,
          unit: widget.unit == "Gram"
              ? "gram"
              : widget.unit == "Ounce"
              ? "toz"
              : "kg",
        );

        final products =
            homeData['data']?['exclusive_products'] as List<dynamic>?;

        if (mounted && products != null) {
          setState(() {
            _liveProducts = products;
          });
        }
      } catch (e) {
        debugPrint('Exclusive products refresh error: $e');
      } finally {
        _isFetching = false;
      }
    });
  }

  void _updateDigitalProducts(List<dynamic> products) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PhysicalConversionProvider>().setDigitalProductIds(
        products.take(4).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = _liveProducts ?? widget.products;

    if (products == null || products.isEmpty) {
      return const SizedBox.shrink();
    }

    // ------------------------------------------------------------
    // ONLY FIRST 4 PRODUCTS ARE SHOWN ON HOME SCREEN
    // These 4 are DIGITAL PRODUCTS.
    // ------------------------------------------------------------

    final displayProducts = products.take(4).toList();

    _updateDigitalProducts(products);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // HEADER
          // ========================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Exclusive Collections",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              InkWell(
                onTap: widget.onViewMoreTap,
                child: const Text(
                  "View more",
                  style: TextStyle(
                    color: ExclusiveCollectionsSection.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========================================================
          // PRODUCTS
          // ========================================================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = displayProducts[index] as Map<String, dynamic>;

              return _ExclusiveProductCard(product: product);
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXCLUSIVE PRODUCT CARD
// ============================================================================

class _ExclusiveProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ExclusiveProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // PRODUCT DETAILS
    // ============================================================

    final String name = product['name']?.toString() ?? 'Product Name';

    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    final String? imagePath = product['image_path']?.toString();

    final String fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? '${ExclusiveCollectionsSection.imageBaseUrl}$imagePath'
        : '';

    final bool canPurchase = product["stock_status"] == "in_stock";

    return InkWell(
      onTap: () {
        log("Product tapped");
        log("Product: $product");

        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product["id"]),
            ),
          );
        } catch (e, s) {
          log("Navigation Error: $e");
          log(s.toString());
        }
      },

      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // IMAGE
            // ======================================================
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ======================================================
            // NAME
            // ======================================================
            SizedBox(
              height: 36,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ExclusiveCollectionsSection.primaryDarkRed,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ======================================================
            // PRICE
            // ======================================================
            Text(
              priceText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6),

            // ======================================================
            // CART BUTTON
            // ======================================================
            SizedBox(
              width: double.infinity,
              height: 36,
              child: Consumer2<CartProvider, PhysicalConversionProvider>(
                builder: (context, cartProvider, physicalProvider, child) {
                  // ==================================================
                  // PHYSICAL CONVERSION ACTIVE
                  //
                  // IMPORTANT:
                  // These first 4 Exclusive Collection products
                  // are DIGITAL PRODUCTS.
                  //
                  // They must NOT:
                  // - go to normal cart
                  // - go to physical cart
                  // - change quantity
                  //
                  // Just show toast.
                  // ==================================================

                  if (physicalProvider.isActive) {
                    return _buildDigitalProductConversionButton(context);
                  }

                  // ==================================================
                  // NORMAL CART MODE
                  // ==================================================

                  return _buildNormalCartButton(
                    context: context,
                    cartProvider: cartProvider,
                    canPurchase: canPurchase,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // DIGITAL PRODUCT BUTTON DURING PHYSICAL CONVERSION
  // ========================================================================

  Widget _buildDigitalProductConversionButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      onPressed: () {
        Fluttertoast.showToast(
          msg: "Digital products cannot be added during physical conversion.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 14,
        );
      },

      child: const Text(
        "ADD TO CART",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  // ========================================================================
  // NORMAL CART BUTTON
  // ========================================================================

  Widget _buildNormalCartButton({
    required BuildContext context,
    required CartProvider cartProvider,
    required bool canPurchase,
  }) {
    final productId = product["id"];

    // ============================================================
    // CHECK NORMAL CART
    // ============================================================

    final bool isInCart = cartProvider.isProductInCart(productId);

    Map<String, dynamic>? cartItem;

    if (isInCart) {
      try {
        cartItem = cartProvider.cartItems.firstWhere(
          (item) => item["product_id"] == productId,
        );
      } catch (_) {
        cartItem = null;
      }
    }

    final int cartQuantity = cartItem?["quantity"] ?? 0;

    // ============================================================
    // OUT OF STOCK
    // ============================================================

    if (!canPurchase) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
          foregroundColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text("Out of stock"),
      );
    }

    // ============================================================
    // PRODUCT ALREADY IN NORMAL CART
    // ============================================================

    if (isInCart && cartQuantity > 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ------------------------------------------------------
            // MINUS
            // ------------------------------------------------------
            InkWell(
              onTap: () async {
                if (cartQuantity <= 1) {
                  await cartProvider.removeFromCart(productId);
                } else {
                  await cartProvider.updateCartQuantity(
                    productId: productId,
                    quantity: cartQuantity - 1,
                  );
                }
              },
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
            ),

            // ------------------------------------------------------
            // QUANTITY
            // ------------------------------------------------------
            Text(
              "$cartQuantity",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            // ------------------------------------------------------
            // PLUS
            // ------------------------------------------------------
            InkWell(
              onTap: () async {
                await cartProvider.updateCartQuantity(
                  productId: productId,
                  quantity: cartQuantity + 1,
                );
              },
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // ADD TO NORMAL CART
    // ============================================================

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      onPressed: cartProvider.isAdding(productId)
          ? null
          : () async {
              final bool success = await cartProvider.addToCart(
                productId: productId,
                quantity: 1,
              );

              if (!context.mounted) {
                return;
              }

              Fluttertoast.showToast(
                msg: success ? "Added to Cart" : "Failed to add product",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },

      child: cartProvider.isAdding(productId)
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              "ADD TO CART",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }
}
