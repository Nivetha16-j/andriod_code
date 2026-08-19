import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_isFetching || !mounted) return;

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
        debugPrint(e.toString());
      } finally {
        _isFetching = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = _liveProducts ?? widget.products;

    if (products == null || products.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayProducts = products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              return _ExclusiveProductCard(product: displayProducts[index]);
            },
          ),
        ],
      ),
    );
  }
}

// Individual Exclusive Product Card
class _ExclusiveProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ExclusiveProductCard({required this.product});

  String? _validatePhysicalConversion(BuildContext context) {
    final physicalProvider = context.read<PhysicalConversionProvider>();

    return physicalProvider.validateProduct(
      brand: product['brand']?.toString(),
      metalType: product['metal_type']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Title/Name
    final String name = product['name']?.toString() ?? 'Product Name';

    // 2. Price
    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    // 3. Image
    final String? imagePath = product['image_path']?.toString();
    final String fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? '${ExclusiveCollectionsSection.imageBaseUrl}$imagePath'
        : '';

    final bool canPurchase = product["stock_status"] == "in_stock";

    return InkWell(
      onTap: () {
        log("Product tapped");
        log("Proooo $product");

        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product["id"]),
            ),
          );
        } catch (e, s) {
          log("Navigation Error: $e.......$s");
          log(s.toString());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 10.0),

            // Title (Fixed height for 2 lines so price alignment is uniform across grid)
            SizedBox(
              height: 36.0,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: ExclusiveCollectionsSection.primaryDarkRed,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 6.0),

            // Price Tag
            Text(
              priceText,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6.0),

            SizedBox(
              width: double.infinity,
              height: 36,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final isInCart = cartProvider.isProductInCart(product["id"]);

                  final cartItem = isInCart
                      ? cartProvider.cartItems.firstWhere(
                          (e) => e["product_id"] == product["id"],
                        )
                      : null;

                  final int cartQuantity = cartItem?["quantity"] ?? 0;

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

                  if (isInCart) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () async {
                              if (cartQuantity == 1) {
                                await cartProvider.removeFromCart(
                                  product["id"],
                                );
                              } else {
                                await cartProvider.updateCartQuantity(
                                  productId: product["id"],
                                  quantity: cartQuantity - 1,
                                );
                              }
                            },
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                          Text(
                            "$cartQuantity",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          InkWell(
                            // onTap: () async {
                            //   await cartProvider.updateCartQuantity(
                            //     productId: product["id"],
                            //     quantity: cartQuantity + 1,
                            //   );
                            // },
                            onTap: () async {
                              final validationError =
                                  _validatePhysicalConversion(context);

                              if (validationError != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(validationError)),
                                );

                                return;
                              }

                              await cartProvider.updateCartQuantity(
                                productId: product["id"],
                                quantity: cartQuantity + 1,
                              );
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // onPressed: cartProvider.isAdding(product["id"])
                    //     ? null
                    //     : () async {
                    //         bool success = await cartProvider.addToCart(
                    //           productId: product["id"],
                    //           quantity: 1,
                    //         );

                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(
                    //             content: Text(
                    //               success
                    //                   ? "Added to Cart"
                    //                   : "Failed to add product",
                    //             ),
                    //           ),
                    //         );
                    //       },
                    onPressed: cartProvider.isAdding(product["id"])
                        ? null
                        : () async {
                            // --------------------------------------------------
                            // Check Physical Conversion restrictions
                            // --------------------------------------------------
                            final validationError = _validatePhysicalConversion(
                              context,
                            );

                            // If conversion is active and product is invalid,
                            // stop here.
                            if (validationError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(validationError)),
                              );

                              return;
                            }

                            // --------------------------------------------------
                            // Normal Add To Cart
                            // --------------------------------------------------
                            final bool success = await cartProvider.addToCart(
                              productId: product["id"],
                              quantity: 1,
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "Added to Cart"
                                      : "Failed to add product",
                                ),
                              ),
                            );
                          },
                    child: cartProvider.isAdding(product["id"])
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
