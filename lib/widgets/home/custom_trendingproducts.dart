import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
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

    log("TrendingProducts initState");

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

  String? _validatePhysicalConversion(BuildContext context) {
    final physicalProvider = context.read<PhysicalConversionProvider>();

    log("proooooooo $product");

    return physicalProvider.validateProduct(
      // brand: product['brand']?.toString(),
      metalType: product['metal_type']?.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // ========================================================
                  // PHYSICAL CONVERSION MODE
                  // ========================================================

                  if (physicalProvider.isActive) {
                    final physicalCart = physicalProvider.physicalCart;

                    final physicalItemIndex = physicalCart.indexWhere(
                      (item) => '${item['product_id']}' == '${product["id"]}',
                    );

                    final bool isInPhysicalCart = physicalItemIndex != -1;

                    final Map<String, dynamic>? physicalItem = isInPhysicalCart
                        ? physicalCart[physicalItemIndex]
                        : null;

                    final int physicalQuantity =
                        int.tryParse('${physicalItem?['quantity'] ?? 0}') ?? 0;

                    // ======================================================
                    // ALREADY IN PHYSICAL CART
                    // ======================================================

                    if (isInPhysicalCart) {
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
                                if (physicalQuantity <= 1) {
                                  await physicalProvider.removePhysicalProduct(
                                    product["id"],
                                  );
                                } else {
                                  await physicalProvider.updatePhysicalQuantity(
                                    productId: product["id"],
                                    quantity: physicalQuantity - 1,
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
                              '$physicalQuantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            InkWell(
                              onTap: () async {
                                final error = _validatePhysicalConversion(
                                  context,
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

                                await physicalProvider.addPhysicalProduct(
                                  product: product,
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

                    // ======================================================
                    // NOT IN PHYSICAL CART
                    // ======================================================

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        final error = _validatePhysicalConversion(context);

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

                        final success = await physicalProvider
                            .addPhysicalProduct(product: product);

                        if (!success) {
                          return;
                        }

                        debugPrint(
                          '✅ Added to physical cart: '
                          '${product["name"]}',
                        );
                      },
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  // ========================================================
                  // NORMAL CART MODE
                  // ========================================================

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

                  final bool isInCart = cartProvider.isProductInCart(
                    product["id"],
                  );

                  final Map<String, dynamic>? cartItem = isInCart
                      ? cartProvider.cartItems.firstWhere(
                          (item) =>
                              '${item["product_id"]}' == '${product["id"]}',
                        )
                      : null;

                  final int cartQuantity =
                      int.tryParse('${cartItem?["quantity"] ?? 0}') ?? 0;

                  // ========================================================
                  // NORMAL CART PRODUCT EXISTS
                  // ========================================================

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
                              if (cartQuantity <= 1) {
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
                            '$cartQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          InkWell(
                            onTap: () async {
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

                  // ========================================================
                  // NORMAL ADD TO CART
                  // ========================================================

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: cartProvider.isAdding(product["id"])
                        ? null
                        : () async {
                            final success = await cartProvider.addToCart(
                              productId: product["id"],
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
