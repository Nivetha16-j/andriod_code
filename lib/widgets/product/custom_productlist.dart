import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/currency_provider.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final bool isEmbedded;
  final ScrollController scrollController;
  final Future<void> Function()? onRefresh;

  const ProductListScreen({
    super.key,
    this.title = 'Our Products',
    this.isEmbedded = false,
    required this.scrollController,
    this.onRefresh,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _selectedCategoryIndex = 0;
  String? _lastCurrency;
  String? _lastUnit;

  // 1. Variable to control how many items are shown
  int _displayCount = 6;

  final List<String> _categories = [
    'All Items',
    'Gold Coin',
    'Gold Bar',
    'Silver Coin',
    'Silver Bar',
  ];

  final List<String> _endpoints = [
    "exclusive-products",
    "gold-coins",
    "gold-bars",
    "silver-coins",
    "silver-bars",
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currencyProvider = context.watch<CurrencyProvider>();

    if (_lastCurrency == currencyProvider.selectedCurrency &&
        _lastUnit == currencyProvider.selectedUnit) {
      return;
    }

    _lastCurrency = currencyProvider.selectedCurrency;
    _lastUnit = currencyProvider.selectedUnit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchProducts();
    });
  }

  // Future<void> _fetchProducts() {
  //   final currencyProvider = context.read<CurrencyProvider>();
  //   return context.read<ExclusiveProductProvider>().fetchProducts(
  //     endpoint: _endpoints[_selectedCategoryIndex],
  //   );
  // }

  Future<void> _fetchProducts() {
    final currency = context.read<CurrencyProvider>();

    return context.read<ExclusiveProductProvider>().fetchProducts(
      endpoint: _endpoints[_selectedCategoryIndex],
      currency: currency.selectedCurrency,
      unit: currency.selectedUnit,
    );
  }

  // Gets the filtered list based on category
  List<dynamic> _filteredProducts(List<dynamic> products) {
    if (_selectedCategoryIndex == 0) return products;

    final selectedCategory = _categories[_selectedCategoryIndex].toLowerCase();

    return products.where((product) {
      final String name = (product['name'] ?? '').toString().toLowerCase();
      final String subcategory = (product['subcategory'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(selectedCategory) ||
          subcategory.contains(selectedCategory);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final productProvider = context.watch<ExclusiveProductProvider>();

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayedProducts = productProvider.products;

    final allFilteredProducts = _filteredProducts(displayedProducts);

    final productsToDisplay = allFilteredProducts.take(_displayCount).toList();

    log("productsToDisplay $productsToDisplay");

    final hasMoreProducts = _displayCount < allFilteredProducts.length;

    final Widget content = RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: SingleChildScrollView(
        controller: widget.scrollController, // Attached controller
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Text(
              "Our Products",
              style: const TextStyle(
                fontSize: 34.0,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(208, 145, 29, 1),
              ),
            ),
            SizedBox(height: 12.0),
            // Filter Pills
            SizedBox(
              height: 38.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8.0),
                itemBuilder: (context, index) {
                  final bool isSelected = _selectedCategoryIndex == index;
                  return ChoiceChip(
                    label: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13.0,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryRed,
                    backgroundColor: const Color(0xFFE0E0E0),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide.none,
                    ),
                    onSelected: (selected) async {
                      setState(() {
                        _selectedCategoryIndex = index;
                        _displayCount = 6;
                      });

                      await _fetchProducts();
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20.0),

            // Product Grid
            productsToDisplay.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Text(
                        'No products found in this category.',
                        style: TextStyle(color: Colors.grey, fontSize: 14.0),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productsToDisplay.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) {
                      final product =
                          productsToDisplay[index] as Map<String, dynamic>;

                      // The first 4 products returned by the API are digital products.
                      final int apiIndex = displayedProducts.indexOf(product);

                      final bool isDigitalProduct =
                          _selectedCategoryIndex == 0 &&
                          apiIndex >= 0 &&
                          apiIndex < 4;

                      return _ProductGridCard(
                        product: product,
                        currencyProvider: currencyProvider,
                        isDigitalProduct: isDigitalProduct,
                      );
                    },
                  ),

            const SizedBox(height: 24.0),

            // 6. View More Button (Only show if there are hidden products)
            if (hasMoreProducts)
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Add 6 more to the display count
                    _displayCount += 6;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'View more',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return Container(color: const Color(0xFFFAFAFA), child: content);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // appBar: AppBar(

      //   title: Text(
      //     widget.title,
      //     style: const TextStyle(
      //       color: Color(0xFFC88E2B),
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24.0,
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   automaticallyImplyLeading: !widget.isEmbedded,
      //   iconTheme: const IconThemeData(color: Colors.black87),
      // ),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: content,
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final dynamic currencyProvider;
  final bool isDigitalProduct;

  const _ProductGridCard({
    required this.product,
    required this.currencyProvider,
    required this.isDigitalProduct,
  });

  // ================================================================
  // VALIDATE GOLD / SILVER PHYSICAL PRODUCT
  // ================================================================

  String? _validatePhysicalProduct(BuildContext context) {
    final physicalProvider = context.read<PhysicalConversionProvider>();

    return physicalProvider.validateProduct(
      brand: product['brand']?.toString(),
      metalType: product['metal_type']?.toString(),
    );
  }

  // ================================================================
  // MESSAGE
  // ================================================================

  void _showMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
  // ========================================================================
  // PHYSICAL CONVERSION BUTTON
  // ========================================================================

  Widget _buildPhysicalConversionButton({
    required BuildContext context,
    required PhysicalConversionProvider physicalProvider,
    required bool isDigital,
    required bool canPurchase,
  }) {
    final productId = product["id"];

    // ============================================================
    // DIGITAL PRODUCT
    // First 4 products from API
    // ============================================================

    if (isDigital) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          _showMessage(
            "Digital products cannot be added during physical conversion.",
          );
        },
        child: const Text(
          "ADD TO CART",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      );
    }

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
        child: const Text(
          "OUT OF STOCK",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    }

    // ============================================================
    // FIND IN LOCAL PHYSICAL CART
    // ============================================================

    final int physicalItemIndex = physicalProvider.physicalCart.indexWhere(
      (item) => item['product_id'] == productId,
    );

    final bool isInPhysicalCart = physicalItemIndex != -1;

    final Map<String, dynamic>? physicalItem = isInPhysicalCart
        ? physicalProvider.physicalCart[physicalItemIndex]
        : null;

    final int physicalQuantity = physicalItem?['quantity'] ?? 0;

    // ============================================================
    // ALREADY IN PHYSICAL CART
    // ============================================================

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
                  await physicalProvider.removePhysicalProduct(productId);
                } else {
                  await physicalProvider.updatePhysicalQuantity(
                    productId: productId,
                    quantity: physicalQuantity - 1,
                  );
                }
              },
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
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
                final validationError = _validatePhysicalProduct(context);

                if (validationError != null) {
                  _showMessage(validationError);
                  return;
                }

                final success = await physicalProvider.addPhysicalProduct(
                  product: product,
                );

                if (!success) {
                  _showMessage("Unable to add product.");
                }
              },
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // NOT IN PHYSICAL CART
    // ============================================================

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () async {
        // Gold / Silver validation
        final validationError = _validatePhysicalProduct(context);

        log(
          "PHYSICAL PRODUCT VALIDATION -> "
          "${product['name']} -> $validationError",
        );

        if (validationError != null) {
          _showMessage(validationError);
          return;
        }

        // Add ONLY to local physical cart
        final success = await physicalProvider.addPhysicalProduct(
          product: product,
        );

        if (!context.mounted) {
          return;
        }

        if (!success) {
          _showMessage(
            "Product could not be added to physical conversion cart.",
          );
        }
      },
      child: const Text(
        "ADD TO CART",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

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
          (item) => item["product_id"] == productId,
        );
      } catch (_) {
        cartItem = null;
      }
    }

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
        child: const Text(
          "OUT OF STOCK",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (isInCart && cartQuantity > 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [
            Expanded(
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                onPressed: () async {
                  if (cartQuantity <= 1) {
                    await cartProvider.removeFromCart(productId);
                  } else {
                    await cartProvider.updateCartQuantity(
                      productId: productId,
                      quantity: cartQuantity - 1,
                    );
                  }
                },
              ),
            ),

            Text(
              "$cartQuantity",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Expanded(
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                onPressed: () async {
                  await cartProvider.updateCartQuantity(
                    productId: productId,
                    quantity: cartQuantity + 1,
                  );
                },
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      onPressed: cartProvider.isAdding(productId)
          ? null
          : () async {
              final success = await cartProvider.addToCart(
                productId: productId,
                quantity: 1,
              );

              if (!context.mounted) {
                return;
              }

              _showMessage(success ? "Added to Cart" : "Failed to add product");
            },

      child: cartProvider.isAdding(productId)
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              "ADD TO CART",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = product['name']?.toString() ?? 'Product Name';

    final String priceText = product['live_price']?.toString() ?? '--';

    final String? imagePath = product['image_path']?.toString();

    final String fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? 'https://staging.junubullion.com/storage/$imagePath'
        : '';

    final bool isInStock = product["stock_status"] == "in_stock";

    final bool canPurchase = isInStock;

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
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
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

            const SizedBox(height: 8),

            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                canPurchase ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: canPurchase
                      ? const Color(0xFF2E7D32)
                      : AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                priceText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 36,
              child: Consumer2<CartProvider, PhysicalConversionProvider>(
                builder: (context, cartProvider, physicalProvider, child) {
                  // =================================================
                  // PHYSICAL CONVERSION MODE
                  // =================================================

                  if (physicalProvider.isActive) {
                    return _buildPhysicalConversionButton(
                      context: context,
                      physicalProvider: physicalProvider,
                      isDigital: isDigitalProduct,
                      canPurchase: canPurchase,
                    );
                  }

                  // =================================================
                  // NORMAL MODE
                  // =================================================

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
}
