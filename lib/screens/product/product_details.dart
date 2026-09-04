import 'dart:async';
import 'dart:developer';

import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/product_detail_provider.dart';
import 'package:junubullion/providers/review_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedImage = 0;
  int quantity = 1;
  int selectedTab = 0;
  int _currentIndex = 3;

  late final ScrollController _scrollController;

  String? _lastCurrency;
  String? _lastUnit;

  Timer? _timer;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  // ============================================================
  // HELPERS
  // ============================================================

  bool _isDigitalProduct(Map<String, dynamic> product) {
    final String brand = (product['brand'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    return brand == "GSP" || brand == "JSC";
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // PRODUCT WEIGHT
  // ============================================================

  double _getProductWeightInGrams(Map<String, dynamic> product) {
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

  // ============================================================
  // CURRENT CART TOTAL WEIGHT
  // ============================================================

  double _getCartTotalWeightInGrams(CartProvider cartProvider) {
    double totalWeight = 0;

    for (final item in cartProvider.cartItems) {
      final weight = double.tryParse('${item['weight_grams'] ?? 0}') ?? 0;

      // weight_grams is already the line total.
      // DO NOT multiply by quantity.
      totalWeight += weight;
    }

    log(
      '⚖️ CURRENT CART TOTAL WEIGHT -> '
      '${totalWeight}g',
    );

    return totalWeight;
  }

  // ============================================================
  // PHYSICAL CONVERSION WEIGHT VALIDATION
  // ============================================================

  String? _validateConversionWeight(
    CartProvider cartProvider, {
    required Map<String, dynamic> product,
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

    final productWeight = _getProductWeightInGrams(product);

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

  // ============================================================
  // SLIDER
  // ============================================================

  void _slideNext() {
    if (!_scrollController.hasClients) return;

    final double currentOffset = _scrollController.offset;

    final double maxExtent = _scrollController.position.maxScrollExtent;

    if (maxExtent <= 0) return;

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

  // ============================================================
  // REVIEW
  // ============================================================

  Future<void> submitReview() async {
    if (selectedRating == 0) {
      _showMessage("Please select a rating");
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      _showMessage("Please enter your review");
      return;
    }

    final token = await SessionManager.getToken();

    if (token == null) {
      _showMessage("Please login first");
      return;
    }

    final reviewProvider = context.read<ReviewProvider>();

    final response = await reviewProvider.submitReview(
      token: token,
      productId: widget.productId,
      rating: selectedRating,
      description: reviewController.text.trim(),
    );

    log("resssssssssss $response..........//..........}");

    if (response["success"] == true) {
      reviewController.clear();

      setState(() {
        selectedRating = 0;
      });

      await _fetchProductDetails();

      _showMessage(response["message"] ?? "Review submitted successfully");
    } else {
      _showMessage(response["message"] ?? "Something went wrong");
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchProductDetails(showLoader: true);

      if (!mounted) return;

      final cart = context.read<CartProvider>();

      if (cart.isProductInCart(widget.productId)) {
        final cartItem = cart.cartItems.firstWhere(
          (e) => '${e["product_id"]}' == '${widget.productId}',
        );

        setState(() {
          quantity = int.tryParse('${cartItem["quantity"] ?? 1}') ?? 1;
        });
      } else {
        setState(() {
          quantity = 1;
        });
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _fetchProductDetails(showLoader: false);
      }
    });
  }

  // ============================================================
  // CURRENCY
  // ============================================================

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
        _fetchProductDetails(showLoader: false);
      }
    });
  }

  Future<void> _fetchProductDetails({bool showLoader = false}) {
    final currency = context.read<CurrencyProvider>();

    return context.read<ProductDetailsProvider>().fetchProductDetails(
      widget.productId,
      currency: currency.selectedCurrency,
      unit: currency.selectedUnit,
      showLoader: showLoader,
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  void dispose() {
    reviewController.dispose();
    _scrollController.dispose();
    _timer?.cancel();

    super.dispose();
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailsProvider>();

    final reviewProvider = context.watch<ReviewProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = provider.product!;

    log("pppppppppppppppppppp $product");

    final reviews = provider.reviews ?? [];

    final subcategories = provider.subcategories ?? [];

    final relatedProducts = provider.relatedProducts;

    final List<dynamic> images = product['images'] ?? [];

    final String metalType = product['metal_type']?.toString() ?? "";

    final String name = product['name']?.toString() ?? '';

    final String price = product['live_price']?.toString() ?? '--';

    final bool isInStock = product['stock_status'] == 'in_stock';

    final bool canPurchase = isInStock;

    final bool isDigitalProduct = _isDigitalProduct(product);

    final String imageUrl =
        "https://staging.junubullion.com/storage/${product['image_path']}";

    String description = product['description'] ?? '';

    description = description
        .replaceAll(RegExp(r'<p[^>]*>'), '')
        .replaceAll('</p>', '\n\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();

    final String shortDescriptionHtml = product['short_description'] ?? "";

    final String shortDescription =
        parse(shortDescriptionHtml).documentElement?.text ?? '';

    final String brand = (product['brand'] ?? '').toString().trim();

    final String categoryName = product['category']?['name']?.toString() ?? '';

    final String subCategoryNames = subcategories
        .map((e) => e['name'].toString())
        .join(', ');

    final String categories = [
      categoryName,
      if (subCategoryNames.isNotEmpty) subCategoryNames,
    ].join(', ');

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================================
              // MAIN IMAGE
              // ========================================================
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(color: Color(0xffF9EAEA)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    images.isNotEmpty ? images[selectedImage]['url'] : imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ========================================================
              // THUMBNAILS
              // ========================================================
              Row(
                children: List.generate(images.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedImage == index
                              ? Colors.brown
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Image.network(
                        images[index]['url'],
                        fit: BoxFit.contain,
                        height: 80,
                        width: 80,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 15),

              Text(
                metalType,
                style: const TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 21,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                canPurchase ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: canPurchase ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                shortDescription,
                style: const TextStyle(color: Colors.black87, height: 1.6),
              ),

              const SizedBox(height: 20),

              Consumer2<CartProvider, PhysicalConversionProvider>(
                builder: (context, cartProvider, physicalProvider, child) {
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

                  final bool isPhysicalMode = physicalProvider.isActive;

                  return Row(
                    children: [
                      // ============================================================
                      // QUANTITY
                      // ============================================================
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xfff1f1f1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: !isInCart || cartQuantity <= 1
                                    ? null
                                    : () async {
                                        await cartProvider.removeFromCart(
                                          productId,
                                        );
                                      },
                              ),

                              Text(
                                isInCart ? cartQuantity.toString() : "1",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: !isInCart
                                    ? null
                                    : () async {
                                        if (isPhysicalMode) {
                                          // Digital products are never allowed
                                          // during physical conversion.
                                          if (isDigitalProduct) {
                                            _showMessage(
                                              "Digital products cannot be added during physical conversion.",
                                            );
                                            return;
                                          }

                                          // Metal validation.
                                          final validationError =
                                              physicalProvider.validateProduct(
                                                metalType: product['metal_type']
                                                    ?.toString(),
                                              );

                                          if (validationError != null) {
                                            _showMessage(validationError);
                                            return;
                                          }

                                          // Weight validation.
                                          final weightError =
                                              _validateConversionWeight(
                                                cartProvider,
                                                product: product,
                                                quantityToAdd: 1,
                                              );

                                          if (weightError != null) {
                                            _showMessage(weightError);
                                            return;
                                          }
                                        }

                                        await cartProvider.updateCartQuantity(
                                          productId: productId,
                                          quantity: cartQuantity + 1,
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ============================================================
                      // ADD TO CART / GO TO CART
                      // ============================================================
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canPurchase
                                  ? AppColors.primaryRed
                                  : const Color.fromRGBO(218, 218, 218, 1),
                              foregroundColor: canPurchase
                                  ? Colors.white
                                  : Colors.black54,
                              elevation: canPurchase ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            onPressed: !canPurchase
                                ? null
                                : cartProvider.isAdding(productId)
                                ? null
                                : () async {
                                    // ==================================================
                                    // PHYSICAL CONVERSION VALIDATION
                                    // ==================================================

                                    if (isPhysicalMode) {
                                      if (isDigitalProduct) {
                                        _showMessage(
                                          "Digital products cannot be added during physical conversion.",
                                        );
                                        return;
                                      }

                                      final validationError = physicalProvider
                                          .validateProduct(
                                            metalType: product['metal_type']
                                                ?.toString(),
                                          );

                                      if (validationError != null) {
                                        _showMessage(validationError);
                                        return;
                                      }

                                      final weightError =
                                          _validateConversionWeight(
                                            cartProvider,
                                            product: product,
                                            quantityToAdd: quantity,
                                          );

                                      if (weightError != null) {
                                        _showMessage(weightError);
                                        return;
                                      }
                                    }

                                    // ==================================================
                                    // ALREADY IN API CART
                                    // ==================================================

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

                                    // ==================================================
                                    // ADD TO API CART
                                    // ==================================================

                                    final success = await cartProvider
                                        .addToCart(
                                          productId: productId,
                                          quantity: quantity,
                                        );

                                    if (!context.mounted) return;

                                    _showMessage(
                                      success
                                          ? "Added to Cart"
                                          : "Failed to add product",
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
                                    child: Text(
                                      !canPurchase
                                          ? "OUT OF STOCK"
                                          : isInCart
                                          ? "GO TO CART"
                                          : "ADD TO CART",
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // ========================================================
              // CATEGORIES
              // ========================================================
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    const TextSpan(
                      text: "Categories: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: categories),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ========================================================
              // TABS
              // ========================================================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        tabButton("Description", 0),
                        const SizedBox(width: 8),
                        tabButton("Reviews", 1),
                        const SizedBox(width: 8),
                        tabButton("Brands", 2),
                      ],
                    ),

                    const SizedBox(height: 18),

                    if (selectedTab == 0)
                      Text(
                        description,
                        style: const TextStyle(
                          height: 1.8,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      )
                    else if (selectedTab == 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reviews",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          if (reviews.isEmpty)
                            const Text(
                              "No reviews available for this product.",
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 30),
                              itemBuilder: (context, index) {
                                final review = reviews[index];

                                final customer = review["customer"] ?? {};

                                final DateTime createdAt = DateTime.parse(
                                  review["created_at"],
                                );

                                final formattedDate = DateFormat(
                                  'dd MMM yyyy • hh:mm a',
                                ).format(createdAt.toLocal());

                                return Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      child: Icon(Icons.person),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  customer["name"] ??
                                                      "Anonymous",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 6),

                                          Row(
                                            children: List.generate(
                                              5,
                                              (star) => Icon(
                                                Icons.star,
                                                size: 18,
                                                color:
                                                    star <
                                                        (review["rating"] ?? 0)
                                                    ? Colors.amber
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          Text(
                                            review["description"] ?? "",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                          const SizedBox(height: 20),

                          const Text(
                            "Add a review",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Text(
                                "Your rating ",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Text(
                                "*",
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        selectedRating = index + 1;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.star,
                                      color: index < selectedRating
                                          ? Colors.amber
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "Your review *",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: reviewController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: 100,
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffD7A420),
                                foregroundColor: Colors.black,
                              ),
                              onPressed: reviewProvider.isLoading
                                  ? null
                                  : submitReview,
                              child: reviewProvider.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text("Submit"),
                            ),
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          brand,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ========================================================
              // RELATED PRODUCTS
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Related Products",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _slideNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'See All',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final relatedProduct = relatedProducts[index];

                    log("related product $relatedProduct");

                    final String image =
                        "https://staging.junubullion.com/storage/${relatedProduct['image_path'] ?? ''}";

                    final String relatedName =
                        relatedProduct['name']?.toString() ?? '';

                    final String livePrice =
                        relatedProduct['live_price']?.toString() ?? '--';

                    final String stockStatus =
                        relatedProduct['stock_status']?.toString() ??
                        'out_of_stock';

                    final bool relatedCanPurchase = stockStatus == "in_stock";

                    final bool isRelatedDigital = _isDigitalProduct(
                      relatedProduct as Map<String, dynamic>,
                    );

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(251, 242, 242, 1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                productId: relatedProduct["id"],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  image,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                relatedName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              Text(
                                relatedCanPurchase
                                    ? "In Stock"
                                    : "Out of Stock",
                                style: TextStyle(
                                  color: relatedCanPurchase
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                livePrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 8),

                              SizedBox(
                                width: double.infinity,
                                child: Consumer2<CartProvider, PhysicalConversionProvider>(
                                  builder: (context, cartProvider, physicalProvider, child) {
                                    final productId = relatedProduct["id"];

                                    final bool isInNormalCart = cartProvider
                                        .isProductInCart(productId);

                                    final bool physicalMode =
                                        physicalProvider.isActive;

                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: relatedCanPurchase
                                            ? AppColors.primaryRed
                                            : const Color.fromRGBO(
                                                218,
                                                218,
                                                218,
                                                1,
                                              ),
                                        foregroundColor: relatedCanPurchase
                                            ? Colors.white
                                            : Colors.black54,
                                        elevation: relatedCanPurchase ? 2 : 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),

                                      onPressed: !relatedCanPurchase
                                          ? null
                                          : cartProvider.isAdding(productId)
                                          ? null
                                          : () async {
                                              // ==================================================
                                              // PHYSICAL CONVERSION VALIDATION
                                              // ==================================================

                                              if (physicalMode) {
                                                if (isRelatedDigital) {
                                                  _showMessage(
                                                    "Digital products cannot be added during physical conversion.",
                                                  );
                                                  return;
                                                }

                                                final error = physicalProvider
                                                    .validateProduct(
                                                      metalType:
                                                          relatedProduct['metal_type']
                                                              ?.toString(),
                                                    );

                                                if (error != null) {
                                                  _showMessage(error);
                                                  return;
                                                }

                                                final weightError =
                                                    _validateConversionWeight(
                                                      cartProvider,
                                                      product: relatedProduct,
                                                      quantityToAdd: 1,
                                                    );

                                                if (weightError != null) {
                                                  _showMessage(weightError);
                                                  return;
                                                }
                                              }

                                              // ==================================================
                                              // ALREADY IN API CART
                                              // ==================================================

                                              if (isInNormalCart) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const MainScreen(
                                                          initialIndex: 2,
                                                        ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // ==================================================
                                              // ADD TO NORMAL API CART
                                              // ==================================================

                                              final success = await cartProvider
                                                  .addToCart(
                                                    productId: productId,
                                                    quantity: 1,
                                                  );

                                              if (!context.mounted) return;

                                              _showMessage(
                                                success
                                                    ? "Added to Cart"
                                                    : "Failed to add product",
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
                                              child: Text(
                                                !relatedCanPurchase
                                                    ? "Out of stock"
                                                    : isInNormalCart
                                                    ? "GO TO CART"
                                                    : "ADD TO CART",
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  // ============================================================
  // TAB BUTTON
  // ============================================================

  Widget tabButton(String title, int index) {
    final bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : const Color(0xffF5ECEC),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}
