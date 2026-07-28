import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/theme/app_colors.dart';
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
                      return _ProductGridCard(
                        product: product,
                        currencyProvider: currencyProvider,
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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFFC88E2B),
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: !widget.isEmbedded,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: content,
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final currencyProvider;

  const _ProductGridCard({
    required this.product,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final String name = product['name']?.toString() ?? 'Product Name';

    log("lllllllllllllll : ${product['live_price']}");
    log(product.toString());
    log("Currency: ${product['currency']}");
    log("Live Price: ${product['live_price']}");

    final String priceText = product['live_price']?.toString() ?? '--';

    final String? imagePath = product['image_path']?.toString();
    final String fullImageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? 'https://staging.junubullion.com/storage/$imagePath'
        : '';

    final bool isInStock = product['stock_status'] == 'in_stock';

    final int quantity = int.tryParse(product["quantity"].toString()) ?? 0;

    final bool canPurchase =
        quantity > 0 && product["stock_status"] == "in_stock";

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
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F7),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
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
            Text(
              name,
              maxLines: 2,
              // textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                canPurchase ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: isInStock
                      ? const Color(0xFF2E7D32)
                      : AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                priceText,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              height: 36.0,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final isInCart = cartProvider.isProductInCart(product["id"]);

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInStock
                          ? AppColors.primaryRed
                          : const Color.fromRGBO(218, 218, 218, 1),
                      foregroundColor: isInStock
                          ? Colors.white
                          : Colors.black54,
                      elevation: isInStock ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: canPurchase
                        ? cartProvider.isAdding(product["id"])
                              ? null
                              : () async {
                                  if (isInCart) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MainScreen(initialIndex: 2),
                                      ),
                                    );
                                    return;
                                  }
                                  bool success = await cartProvider.addToCart(
                                    productId: product["id"],
                                    quantity: 1,
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success
                                            ? "Added to Cart"
                                            : "Failed to add product",
                                      ),
                                    ),
                                  );
                                }
                        : null,
                    child: cartProvider.isAdding(product["id"])
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            !canPurchase
                                ? "Out of stock"
                                : isInCart
                                ? "GO TO CART"
                                : "ADD TO CART",
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: isInStock ? Colors.white : Colors.black54,
                            ),
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
