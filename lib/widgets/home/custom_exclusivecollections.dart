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
  /// The 4 products that are actually displayed.
  ///
  /// IMPORTANT:
  /// These are fixed after the first load so the products do not change
  /// when the API returns the exclusive products in a different order.
  List<Map<String, dynamic>> _displayProducts = [];

  Timer? _refreshTimer;

  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    _initializeProducts(widget.products);

    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant ExclusiveCollectionsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Currency/unit changed.
    //
    // We DO NOT change which 4 products are displayed.
    // We only refresh their latest prices.
    if (widget.currency != oldWidget.currency ||
        widget.unit != oldWidget.unit) {
      _refreshTimer?.cancel();
      _startAutoRefresh();
    }

    // Parent provided a new product list.
    //
    // Only initialize if we don't already have our fixed 4 products.
    if (_displayProducts.isEmpty &&
        widget.products != null &&
        widget.products!.isNotEmpty) {
      _initializeProducts(widget.products);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ============================================================
  // INITIAL PRODUCT SET
  // ============================================================

  void _initializeProducts(List<dynamic>? products) {
    if (products == null || products.isEmpty) {
      return;
    }

    final firstFour = products
        .take(4)
        .whereType<Map>()
        .map((product) => Map<String, dynamic>.from(product))
        .toList();

    if (firstFour.isEmpty) {
      return;
    }

    setStateIfMounted(() {
      _displayProducts = firstFour;
    });

    _updateDigitalProducts(_displayProducts);
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

      // Nothing has been initialized yet.
      if (_displayProducts.isEmpty) {
        return;
      }

      _isFetching = true;

      try {
        final homeData = await ApiService.fetchHomeData(
          currency: widget.currency,
          unit: _apiUnit(widget.unit),
        );

        final products =
            homeData['data']?['exclusive_products'] as List<dynamic>?;

        if (!mounted || products == null || products.isEmpty) {
          return;
        }

        log("product exccc ${products.length}");

        _updateDisplayedProducts(products);
      } catch (e) {
        debugPrint('Exclusive products refresh error: $e');
      } finally {
        _isFetching = false;
      }
    });
  }

  // ============================================================
  // UNIT
  // ============================================================

  String _apiUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'gram':
        return 'gram';

      case 'ounce':
        return 'toz';

      default:
        return 'kg';
    }
  }

  // ============================================================
  // UPDATE ONLY EXISTING 4 PRODUCTS
  // ============================================================

  void _updateDisplayedProducts(List<dynamic> latestProducts) {
    final Map<String, Map<String, dynamic>> latestById = {};

    for (final item in latestProducts) {
      if (item is! Map) {
        continue;
      }

      final product = Map<String, dynamic>.from(item);

      final id = product['id'];

      if (id == null) {
        continue;
      }

      latestById[id.toString()] = product;
    }

    final updatedProducts = <Map<String, dynamic>>[];

    for (final oldProduct in _displayProducts) {
      final oldId = oldProduct['id'];

      if (oldId == null) {
        continue;
      }

      final latestProduct = latestById[oldId.toString()];

      if (latestProduct != null) {
        // Latest API data for the SAME product.
        //
        // This updates live_price, formatted_price, stock status, etc.
        // but keeps the product identity/order fixed.
        updatedProducts.add({...oldProduct, ...latestProduct});
      } else {
        // Product wasn't returned in this particular refresh.
        //
        // Keep the previous product instead of replacing it with
        // another product.
        updatedProducts.add(oldProduct);
      }
    }

    if (!mounted || updatedProducts.isEmpty) {
      return;
    }

    setState(() {
      _displayProducts = updatedProducts;
    });

    // Keep the exact same 4 products as digital products.
    _updateDigitalProducts(_displayProducts);
  }

  // ============================================================
  // DIGITAL PRODUCT IDS
  // ============================================================

  void _updateDigitalProducts(List<Map<String, dynamic>> products) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<PhysicalConversionProvider>().setDigitalProductIds(
        products.take(4).toList(),
      );
    });
  }

  void setStateIfMounted(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_displayProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    // ALWAYS exactly these same 4 products.
    final displayProducts = _displayProducts.take(4).toList();

    log(
      "Exclusive displayed products: "
      "${displayProducts.map((e) => '${e['id']} - ${e['name']}').toList()}",
    );

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
              final product = displayProducts[index];

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
    log("Excccccccc ${product['weight']}......${product['weight_unit']}");
    final String name = product['name']?.toString() ?? 'Product Name';

    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    final String? imagePath = product['image_path']?.toString();

    final String fullImageUrl = imagePath != null && imagePath.isNotEmpty
        ? '${ExclusiveCollectionsSection.imageBaseUrl}$imagePath'
        : '';

    final bool canPurchase = product["stock_status"] == "in_stock";

    return InkWell(
      onTap: () {
        log("Exclusive Product tapped");
        log("Product: $product");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: product["id"]),
          ),
        );
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
                  // PHYSICAL CONVERSION
                  //
                  // Exclusive products are digital products.
                  // They must NOT be added to physical cart.
                  // ==================================================

                  if (physicalProvider.isActive) {
                    return _buildDigitalProductConversionButton(context);
                  }

                  // ==================================================
                  // NORMAL CART
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text("ADD TO CART", maxLines: 1),
      ),
    );
  }

  // ========================================================================
  // PRODUCT WEIGHT
  // ========================================================================

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

  // ========================================================================
  // CURRENT CART TOTAL WEIGHT
  // ========================================================================

  double _getCartTotalWeightInGrams(CartProvider cartProvider) {
    double totalWeight = 0;

    for (final item in cartProvider.cartItems) {
      final weight = double.tryParse('${item['weight_grams'] ?? 0}') ?? 0;

      // IMPORTANT:
      // weight_grams is already the line's total weight.
      // Do NOT multiply by quantity.
      totalWeight += weight;
    }

    log(
      '⚖️ CURRENT CART TOTAL WEIGHT -> '
      '${totalWeight}g',
    );

    return totalWeight;
  }

  // ========================================================================
  // PHYSICAL CONVERSION WEIGHT VALIDATION
  // ========================================================================

  String? _validateConversionWeight(
    CartProvider cartProvider, {
    required int quantityToAdd,
    required BuildContext context,
  }) {
    final physicalProvider = Provider.of<PhysicalConversionProvider>(
      context,
      listen: false,
    );

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

  // ========================================================================
  // NORMAL CART BUTTON
  // ========================================================================

  Widget _buildNormalCartButton({
    required BuildContext context,
    required CartProvider cartProvider,
    required bool canPurchase,
  }) {
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

    final int cartQuantity = int.tryParse('${cartItem?["quantity"] ?? 0}') ?? 0;

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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text("OUT OF STOCK", maxLines: 1),
        ),
      );
    }

    // ============================================================
    // ALREADY IN CART
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
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
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
              onTap: () async {
                final weightError = _validateConversionWeight(
                  cartProvider,
                  quantityToAdd: 1,
                  context: context,
                );

                if (weightError != null) {
                  Fluttertoast.showToast(
                    msg: weightError,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                  return;
                }

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
    // ADD TO CART
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
              final weightError = _validateConversionWeight(
                cartProvider,
                quantityToAdd: 1,
                context: context,
              );

              if (weightError != null) {
                Fluttertoast.showToast(
                  msg: weightError,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                  fontSize: 14,
                );
                return;
              }

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
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("ADD TO CART", maxLines: 1),
            ),
    );
  }
}
