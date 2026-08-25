import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

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
      if (mounted) {
        _fetchProducts();
      }
    });
  }

  Future<void> _fetchProducts() {
    final currency = context.read<CurrencyProvider>();

    return context.read<ExclusiveProductProvider>().fetchProducts(
      endpoint: _endpoints[_selectedCategoryIndex],
      currency: currency.selectedCurrency,
      unit: currency.selectedUnit,
    );
  }

  List<dynamic> _filteredProducts(List<dynamic> products) {
    if (_selectedCategoryIndex == 0) {
      return products;
    }

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
    final productProvider = context.watch<ExclusiveProductProvider>();

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayedProducts = productProvider.products;

    final allFilteredProducts = _filteredProducts(displayedProducts);

    final productsToDisplay = allFilteredProducts.take(_displayCount).toList();

    final hasMoreProducts = _displayCount < allFilteredProducts.length;

    log("productsToDisplay $productsToDisplay");

    final Widget content = RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: SingleChildScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Text(
              "Our Products",
              style: TextStyle(
                fontSize: 34.0,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(208, 145, 29, 1),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
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
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryRed,
                    backgroundColor: const Color(0xFFE0E0E0),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

            const SizedBox(height: 20),

            productsToDisplay.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No products found in this category.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (context, index) {
                      final product =
                          productsToDisplay[index] as Map<String, dynamic>;

                      final String brand = (product['brand'] ?? '')
                          .toString()
                          .trim()
                          .toUpperCase();

                      final bool isDigitalProduct =
                          brand == "GSP" || brand == "JSC";

                      return _ProductGridCard(
                        product: product,
                        currencyProvider: currencyProvider,
                        isDigitalProduct: isDigitalProduct,
                      );
                    },
                  ),

            const SizedBox(height: 24),

            if (hasMoreProducts)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _displayCount += 6;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Text(
                    'View more',
                    style: TextStyle(
                      fontSize: 16,
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

  String? _validatePhysicalProduct(BuildContext context) {
    final physicalProvider = context.read<PhysicalConversionProvider>();

    return physicalProvider.validateProduct(
      metalType: product['metal_type']?.toString(),
    );
  }

  Future<void> _addProduct(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    final productId = product["id"];

    final physicalProvider = context.read<PhysicalConversionProvider>();

    // ============================================================
    // PHYSICAL CONVERSION MODE
    // ============================================================

    if (physicalProvider.isActive) {
      // Digital products cannot be added during physical conversion
      if (isDigitalProduct) {
        _showMessage(
          "Digital products cannot be added during physical conversion.",
        );
        return;
      }

      // Validate physical product
      final validationError = _validatePhysicalProduct(context);

      log(
        "PHYSICAL PRODUCT VALIDATION -> "
        "${product['name']} -> $validationError",
      );

      if (validationError != null) {
        _showMessage(validationError);
        return;
      }
    }

    // ============================================================
    // NORMAL CART
    // ============================================================

    final success = await cartProvider.addToCart(
      productId: productId,
      quantity: 1,
    );

    if (!context.mounted) {
      return;
    }

    _showMessage(success ? "Added to Cart" : "Failed to add product");
  }

  Future<void> _increaseQuantity(
    BuildContext context,
    CartProvider cartProvider,
    int currentQuantity,
  ) async {
    final productId = product["id"];

    final physicalProvider = context.read<PhysicalConversionProvider>();

    // ============================================================
    // PHYSICAL CONVERSION MODE
    // ============================================================

    if (physicalProvider.isActive) {
      // Digital products cannot be modified during physical conversion
      if (isDigitalProduct) {
        _showMessage(
          "Digital products cannot be added during physical conversion.",
        );
        return;
      }

      final validationError = _validatePhysicalProduct(context);

      if (validationError != null) {
        _showMessage(validationError);
        return;
      }
    }

    // ============================================================
    // NORMAL CART
    // ============================================================

    await cartProvider.updateCartQuantity(
      productId: productId,
      quantity: currentQuantity + 1,
    );
  }

  Widget _buildCartButton(
    BuildContext context,
    CartProvider cartProvider,
    PhysicalConversionProvider physicalProvider,
    bool canPurchase,
  ) {
    final productId = product["id"];

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
    // PHYSICAL CONVERSION + DIGITAL PRODUCT
    // ============================================================

    if (physicalProvider.isActive && isDigitalProduct) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 2,
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
    // NORMAL CART
    // ============================================================

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
    // ALREADY IN CART
    // ============================================================

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
              '$cartQuantity',
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
                  await _increaseQuantity(context, cartProvider, cartQuantity);
                },
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
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: cartProvider.isAdding(productId)
          ? null
          : () async {
              await _addProduct(context, cartProvider);
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

    final bool canPurchase = product["stock_status"] == "in_stock";

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
                  return _buildCartButton(
                    context,
                    cartProvider,
                    physicalProvider,
                    canPurchase,
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
