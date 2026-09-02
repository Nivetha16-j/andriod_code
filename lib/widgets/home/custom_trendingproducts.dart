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

class TrendingProductsSection extends StatefulWidget {
  final List<dynamic>? products;
  final VoidCallback? onSeeAllTap;
  final String currency;
  final String unit;

  const TrendingProductsSection({
    super.key,
    this.products,
    this.onSeeAllTap,
    required this.currency,
    required this.unit,
  });

  static const String imageBaseUrl = 'https://staging.junubullion.com/storage/';

  @override
  State<TrendingProductsSection> createState() =>
      _TrendingProductsSectionState();
}

class _TrendingProductsSectionState extends State<TrendingProductsSection> {
  late final ScrollController _scrollController;

  // Local state for live-updated product list
  List<dynamic>? _liveProducts;
  Timer? _refreshTimer;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    log("TrendingProducts initState ${widget.products}");

    _scrollController = ScrollController();
    _liveProducts = widget.products;
    _start1SecAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant TrendingProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currency != oldWidget.currency ||
        widget.unit != oldWidget.unit) {
      _start1SecAutoRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // --- 1-Second Timer for Live Prices in Trending Products ---
  void _start1SecAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      log("Timer firedddd: ${DateTime.now()}");

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
            homeData['data']['trending_products'] as List<dynamic>?;

        log("TrendingProducts fetched products: $products");

        if (mounted && products != null) {
          setState(() {
            _liveProducts = products;
          });
        }
      } catch (e) {
        log(e.toString());
      } finally {
        _isFetching = false;
      }
    });
  }

  void _slideNext() {
    if (!_scrollController.hasClients) return;

    final double currentOffset = _scrollController.offset;
    final double maxExtent = _scrollController.position.maxScrollExtent;

    if (maxExtent <= 0) return;

    // Already at the end → do nothing
    if (currentOffset >= maxExtent - 10) {
      return;
    }

    double targetOffset = currentOffset + 328.0;

    if (targetOffset > maxExtent) {
      targetOffset = maxExtent;
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsList = _liveProducts ?? widget.products;

    if (productsList == null || productsList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER ROW (Title + See All) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending Products',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _slideNext();
                  // if (widget.onSeeAllTap != null) {
                  //   widget.onSeeAllTap!();
                  // }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 2.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // --- HORIZONTAL PRODUCT LIST ---
          SizedBox(
            height: 290.0,
            child: ListView.builder(
              key: const PageStorageKey<String>('trending_products_list'),
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              scrollDirection: Axis.horizontal,
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                final product = productsList[index] as Map<String, dynamic>;
                return _ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Product Card Widget
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    log(
      "Building ProductCard for product: ${product['weight']} ${product['weight_unit']} - ${product['name']}",
    );
    final String name = product['name']?.toString() ?? 'Product Name';

    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    final String? imageUrlFromApi = product['image_url']?.toString();

    final String? imagePath = product['image_path']?.toString();

    final String fullImageUrl =
        (imageUrlFromApi != null && imageUrlFromApi.isNotEmpty)
        ? imageUrlFromApi
        : ((imagePath != null && imagePath.isNotEmpty)
              ? '${TrendingProductsSection.imageBaseUrl}$imagePath'
              : '');

    final bool canPurchase = product["stock_status"] == "in_stock";

    final String brand = (product['brand'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    final bool isDigitalProduct = brand == "GSP" || brand == "JSC";

    double _getProductWeightInGrams() {
      final weight = double.tryParse('${product['weight'] ?? 0}') ?? 0;

      final unit = (product['weight_unit'] ?? 'gram')
          .toString()
          .trim()
          .toLowerCase();

      switch (unit) {
        case 'gram':
        case 'grams':
        case 'g':
          return weight;

        case 'kg':
        case 'kilogram':
        case 'kilograms':
          return weight * 1000;

        case 'toz':
        case 'troy_ounce':
        case 'troy_ounces':
        case 'oz':
          return weight * 31.1035;

        default:
          log(
            '⚠️ UNKNOWN PRODUCT WEIGHT UNIT -> '
            'weight=$weight unit=$unit',
          );
          return weight;
      }
    }

    double _getCartTotalWeightInGrams(CartProvider cartProvider) {
      double totalWeight = 0;

      for (final item in cartProvider.cartItems) {
        final weight = double.tryParse('${item['weight_grams'] ?? 0}') ?? 0;

        // IMPORTANT:
        // weight_grams is already the total weight of that cart line.
        totalWeight += weight;
      }

      log('⚖️ CURRENT CART TOTAL WEIGHT -> ${totalWeight}g');

      return totalWeight;
    }

    String? _validateConversionWeight(
      CartProvider cartProvider, {
      required int quantityToAdd,
    }) {
      final physicalProvider = context.read<PhysicalConversionProvider>();

      if (!physicalProvider.isActive) {
        return null;
      }

      final conversionLimit = physicalProvider.amount;

      if (conversionLimit <= 0) {
        return null;
      }

      final productWeight = _getProductWeightInGrams();

      if (productWeight <= 0) {
        log(
          '⚠️ INVALID PRODUCT WEIGHT -> '
          'product=${product['name']} '
          'weight=${product['weight']} '
          'unit=${product['weight_unit']}',
        );

        return null;
      }

      final currentCartWeight = _getCartTotalWeightInGrams(cartProvider);

      final addedWeight = productWeight * quantityToAdd;

      final newTotalWeight = currentCartWeight + addedWeight;

      log(
        '⚖️ PHYSICAL CONVERSION WEIGHT CHECK -> '
        'product=${product['name']} '
        'productWeight=${productWeight}g '
        'currentCartWeight=${currentCartWeight}g '
        'adding=${addedWeight}g '
        'newTotal=${newTotalWeight}g '
        'limit=${conversionLimit}g',
      );

      if (newTotalWeight > conversionLimit + 0.000001) {
        final remainingWeight = (conversionLimit - currentCartWeight).clamp(
          0,
          conversionLimit,
        );

        return 'You can add only '
            '${remainingWeight.toStringAsFixed(2)}g more. '
            'Your physical conversion limit is '
            '${conversionLimit.toStringAsFixed(2)}g.';
      }

      return null;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product["id"]),
          ),
        );
      },
      child: Container(
        width: 170.0,
        margin: const EdgeInsets.only(right: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 170.0,
              width: 170.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: AppColors.primaryRed, width: 1.2),
              ),
              padding: const EdgeInsets.all(12.0),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.fill,
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

            const SizedBox(height: 8.0),

            SizedBox(
              height: 34.0,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 6.0),

            Text(
              priceText,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 6.0),

            SizedBox(
              width: double.infinity,
              height: 36,
              child: Consumer2<CartProvider, PhysicalConversionProvider>(
                builder: (context, cartProvider, physicalProvider, child) {
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
                      child: const Text('Out of stock'),
                    );
                  }

                  final productId = product["id"];

                  final bool isInCart = cartProvider.isProductInCart(productId);

                  Map<String, dynamic>? cartItem;

                  if (isInCart) {
                    try {
                      cartItem = cartProvider.cartItems.firstWhere(
                        (item) => '${item["product_id"]}' == '$productId',
                      );
                    } catch (_) {
                      cartItem = null;
                    }
                  }

                  final int cartQuantity =
                      int.tryParse('${cartItem?["quantity"] ?? 0}') ?? 0;

                  // ============================================================
                  // EXISTING CART ITEM
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
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),

                          Text(
                            '$cartQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          InkWell(
                            onTap: () async {
                              if (physicalProvider.isActive) {
                                // 1. Validate metal
                                final error = physicalProvider.validateProduct(
                                  metalType: product['metal_type']?.toString(),
                                );

                                if (error != null) {
                                  Fluttertoast.showToast(
                                    msg: error,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                  );
                                  return;
                                }

                                // 2. Validate conversion weight
                                final weightError = _validateConversionWeight(
                                  cartProvider,
                                  quantityToAdd: 1,
                                );

                                if (weightError != null) {
                                  Fluttertoast.showToast(
                                    msg: weightError,
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                  );
                                  return;
                                }
                              }

                              // 3. Only update if validation passed
                              await cartProvider.updateCartQuantity(
                                productId: productId,
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

                  // ============================================================
                  // ADD TO CART
                  // ============================================================

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: cartProvider.isAdding(productId)
                        ? null
                        : () async {
                            if (physicalProvider.isActive) {
                              final error = physicalProvider.validateProduct(
                                metalType: product['metal_type']?.toString(),
                              );

                              if (error != null) {
                                Fluttertoast.showToast(
                                  msg: error,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  fontSize: 14,
                                );
                                return;
                              }

                              final weightError = _validateConversionWeight(
                                cartProvider,
                                quantityToAdd: 1,
                              );

                              if (weightError != null) {
                                Fluttertoast.showToast(
                                  msg: weightError,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  textColor: Colors.white,
                                  fontSize: 14,
                                );
                                return;
                              }
                            }

                            final success = await cartProvider.addToCart(
                              productId: productId,
                              quantity: 1,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Added to Cart'
                                      : 'Failed to add product',
                                ),
                              ),
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
                            'ADD TO CART',
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
