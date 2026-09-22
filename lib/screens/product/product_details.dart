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
import 'package:junubullion/widgets/custom_translated_text.dart';
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
  int? selectedTab;
  int _currentIndex = 3;

  late final ScrollController _scrollController;

  String? _lastCurrency;
  String? _lastUnit;

  Timer? _timer;

  late PageController _pageController;
  bool isDescriptionExpanded = false;
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
      ..showSnackBar(SnackBar(content: TranslatedText(message)));
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

    final screenWidth = MediaQuery.of(context).size.width;

    // Your screen has 14px padding on both sides.
    final availableWidth = screenWidth - 28;

    final maxExtent = _scrollController.position.maxScrollExtent;

    if (maxExtent <= 0) return;

    final currentOffset = _scrollController.offset;

    // Move exactly one viewport = next 2 products
    double targetOffset = currentOffset + availableWidth;

    if (targetOffset > maxExtent) {
      targetOffset = maxExtent;
    }

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
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

    _pageController = PageController(initialPage: selectedImage);

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
    _pageController.dispose();
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
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.BgGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.isNotEmpty ? images.length : 1,

                  onPageChanged: (index) {
                    setState(() {
                      selectedImage = index;
                    });

                    log("Selected image index: $index");
                  },

                  itemBuilder: (context, index) {
                    final String image = images.isNotEmpty
                        ? images[index]['url']?.toString() ?? ''
                        : imageUrl;

                    log("Displaying image $index: $image");

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.network(
                        image,
                        fit: BoxFit.contain,

                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },

                        errorBuilder: (context, error, stackTrace) {
                          log("IMAGE LOAD ERROR [$index]: $image\n$error");

                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ========================================================
              // IMAGE INDICATORS
              // ========================================================
              if (images.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final bool isSelected = selectedImage == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 8,
                      width: isSelected ? 28 : 13,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B2020)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),

              const SizedBox(height: 15),

              TranslatedText(
                metalType,
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),

              TranslatedText(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 21,
                ),
              ),

              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    description,
                    maxLines: isDescriptionExpanded ? null : 4,
                    overflow: isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, height: 1.6),
                  ),

                  const SizedBox(height: 4),

                  if (description.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isDescriptionExpanded = !isDescriptionExpanded;
                        });
                      },
                      child: Text(
                        isDescriptionExpanded ? "View Less" : "View More",
                        style: const TextStyle(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

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

                  final int displayQuantity = isInCart && cartQuantity > 0
                      ? cartQuantity
                      : quantity;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ======================================================
                      // PRICE + STOCK
                      // ======================================================
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: TranslatedText(
                                price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            TranslatedText(
                              canPurchase ? "In Stock" : "Out of Stock",
                              maxLines: 1,
                              style: TextStyle(
                                color: canPurchase ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ======================================================
                      // QUANTITY
                      // ======================================================
                      Container(
                        height: 42,
                        // padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.lightRed,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // MINUS
                            _quantityButton(
                              icon: Icons.remove,
                              onPressed: displayQuantity <= 1
                                  ? null
                                  : () async {
                                      if (isInCart) {
                                        await cartProvider.updateCartQuantity(
                                          productId: productId,
                                          quantity: cartQuantity - 1,
                                        );
                                      } else {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    },
                            ),

                            // QUANTITY
                            SizedBox(
                              width: 25,
                              child: Center(
                                child: TranslatedText(
                                  '$displayQuantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            // PLUS
                            _quantityButton(
                              icon: Icons.add,
                              onPressed: () async {
                                // ============================================
                                // PHYSICAL CONVERSION VALIDATION
                                // ============================================

                                if (physicalProvider.isActive) {
                                  if (_isDigitalProduct(product)) {
                                    _showMessage(
                                      "Digital products cannot be added during physical conversion.",
                                    );
                                    return;
                                  }

                                  final error = physicalProvider
                                      .validateProduct(
                                        metalType: product['metal_type']
                                            ?.toString(),
                                      );

                                  if (error != null) {
                                    _showMessage(error);
                                    return;
                                  }

                                  final weightError = _validateConversionWeight(
                                    cartProvider,
                                    product: product,
                                    quantityToAdd: 1,
                                  );

                                  if (weightError != null) {
                                    _showMessage(weightError);
                                    return;
                                  }
                                }

                                // ============================================
                                // UPDATE QUANTITY
                                // ============================================

                                if (isInCart) {
                                  await cartProvider.updateCartQuantity(
                                    productId: productId,
                                    quantity: cartQuantity + 1,
                                  );
                                } else {
                                  setState(() {
                                    quantity++;
                                  });
                                }
                              },
                            ),
                          ],
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
              // Wrap(
              //   crossAxisAlignment: WrapCrossAlignment.center,
              //   children: [
              //     const TranslatedText(
              //       'Categories: ',
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontSize: 15,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     TranslatedText(
              //       categories,
              //       style: const TextStyle(color: Colors.black, fontSize: 15),
              //     ),
              //   ],
              // ),

              // const SizedBox(height: 20),

              // ========================================================
              // TABS
              // ========================================================
              // ========================================================
              // TABS
              // ========================================================
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: tabButton("Reviews", 1)),
                      const SizedBox(width: 8),
                      Expanded(child: tabButton("Brands", 2)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ====================================================
                  // SHOW CONTENT ONLY WHEN A TAB IS SELECTED
                  // ====================================================
                  if (selectedTab != null)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ============================================================
                        // CONTENT BOX
                        // ============================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ========================================================
                              // REVIEWS CONTENT
                              // ========================================================
                              if (selectedTab == 1)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (reviews.isEmpty)
                                      const TranslatedText(
                                        "No reviews available for this product.",
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: reviews.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 30),
                                        itemBuilder: (context, index) {
                                          final review = reviews[index];

                                          final customer =
                                              review["customer"] ?? {};

                                          final DateTime createdAt =
                                              DateTime.parse(
                                                review["created_at"],
                                              );

                                          final formattedDate = DateFormat(
                                            'dd MMM yyyy • hh:mm a',
                                          ).format(createdAt.toLocal());

                                          final int rating =
                                              int.tryParse(
                                                '${review["rating"] ?? 0}',
                                              ) ??
                                              0;

                                          return Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: TranslatedText(
                                                            customer["name"] ??
                                                                "Anonymous",
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width: 5,
                                                        ),

                                                        Flexible(
                                                          child: TranslatedText(
                                                            formattedDate,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                              fontSize: 13,
                                                            ),
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
                                                          color: star < rating
                                                              ? Colors.amber
                                                              : Colors
                                                                    .grey
                                                                    .shade300,
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 8),

                                                    TranslatedText(
                                                      review["description"] ??
                                                          "",
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

                                    // ==================================================
                                    // ADD REVIEW
                                    // ==================================================
                                    const TranslatedText(
                                      "Add a review",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 6,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const TranslatedText(
                                              "Your rating ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TranslatedText(
                                              "*",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            5,
                                            (index) => IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  selectedRating = index + 1;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.star,
                                                size: 22,
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

                                    Row(
                                      children: [
                                        const TranslatedText(
                                          "Your review ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TranslatedText(
                                          "*",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
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
                                      height: 42,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xffD7A420,
                                          ),
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: reviewProvider.isLoading
                                            ? null
                                            : submitReview,
                                        child: reviewProvider.isLoading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.black,
                                                    ),
                                              )
                                            : const TranslatedText("Submit"),
                                      ),
                                    ),
                                  ],
                                )
                              // ========================================================
                              // BRANDS CONTENT
                              // ========================================================
                              else if (selectedTab == 2)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    top: 5,
                                  ),
                                  child: TranslatedText(
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

                        // ============================================================
                        // CLOSE BUTTON - TOP RIGHT OF BOX
                        // ============================================================
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 3,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                setState(() {
                                  selectedTab = null;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ========================================================
              // RELATED PRODUCTS
              // ========================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TranslatedText(
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
                          const TranslatedText(
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

                    final screenWidth = MediaQuery.of(context).size.width;
                    final availableWidth = screenWidth - 28;
                    final cardWidth = (availableWidth - 14) / 2;

                    return Container(
                      width: cardWidth,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.BgGradient,
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
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  image,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // const SizedBox(height: 8),
                              TranslatedText(
                                livePrice,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.mustard,
                                ),
                              ),

                              // const SizedBox(height: 8),
                              TranslatedText(
                                relatedName,
                                maxLines: 2,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              // TranslatedText(
                              //   relatedCanPurchase
                              //       ? "In Stock"
                              //       : "Out of Stock",
                              //   style: TextStyle(
                              //     color: relatedCanPurchase
                              //         ? Colors.green
                              //         : Colors.red,
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),

                              // const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                height: 36,
                                child: Consumer2<CartProvider, PhysicalConversionProvider>(
                                  builder: (context, cartProvider, physicalProvider, child) {
                                    if (!relatedCanPurchase) {
                                      return ElevatedButton(
                                        onPressed: null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromRGBO(
                                            218,
                                            218,
                                            218,
                                            1,
                                          ),
                                          foregroundColor: Colors.black54,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: TranslatedText(
                                            "Out of Stock",
                                            maxLines: 1,
                                          ),
                                        ),
                                      );
                                    }

                                    final productId = relatedProduct["id"];

                                    // ============================================================
                                    // CHECK WHETHER RELATED PRODUCT IS ALREADY IN CART
                                    // ============================================================

                                    final bool isInCart = cartProvider
                                        .isProductInCart(productId);

                                    Map<String, dynamic>? cartItem;

                                    if (isInCart) {
                                      try {
                                        cartItem = cartProvider.cartItems
                                            .firstWhere(
                                              (item) =>
                                                  '${item["product_id"]}' ==
                                                  '$productId',
                                            );
                                      } catch (_) {
                                        cartItem = null;
                                      }
                                    }

                                    final int cartQuantity =
                                        int.tryParse(
                                          '${cartItem?["quantity"] ?? 0}',
                                        ) ??
                                        0;

                                    // ============================================================
                                    // EXISTING CART ITEM -> SHOW - QUANTITY +
                                    // ============================================================

                                    if (isInCart && cartQuantity > 0) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryRed,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // ------------------------------------------------------
                                            // MINUS
                                            // ------------------------------------------------------
                                            InkWell(
                                              onTap: () async {
                                                if (cartQuantity <= 1) {
                                                  await cartProvider
                                                      .removeFromCart(
                                                        productId,
                                                      );
                                                } else {
                                                  await cartProvider
                                                      .updateCartQuantity(
                                                        productId: productId,
                                                        quantity:
                                                            cartQuantity - 1,
                                                      );
                                                }
                                              },
                                              child: const Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),

                                            // ------------------------------------------------------
                                            // QUANTITY
                                            // ------------------------------------------------------
                                            TranslatedText(
                                              '$cartQuantity',
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
                                                if (physicalProvider.isActive) {
                                                  // 1. Digital product validation
                                                  if (isRelatedDigital) {
                                                    _showMessage(
                                                      "Digital products cannot be added during physical conversion.",
                                                    );
                                                    return;
                                                  }

                                                  // 2. Metal validation
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

                                                  // 3. Weight validation
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

                                                await cartProvider
                                                    .updateCartQuantity(
                                                      productId: productId,
                                                      quantity:
                                                          cartQuantity + 1,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          cartProvider.isAdding(productId)
                                          ? null
                                          : () async {
                                              // ==================================================
                                              // PHYSICAL CONVERSION VALIDATION
                                              // ==================================================

                                              if (physicalProvider.isActive) {
                                                // Digital product validation
                                                if (isRelatedDigital) {
                                                  _showMessage(
                                                    "Digital products cannot be added during physical conversion.",
                                                  );
                                                  return;
                                                }

                                                // Metal validation
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

                                                // Weight validation
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
                                              // ADD TO CART
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
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/Cart.png',
                                                  height: 24,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: TranslatedText(
                                                      "ADD TO CART",
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
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

  Widget tabButton(String title, int tabIndex) {
    final bool isSelected = selectedTab == tabIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tabIndex;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: TranslatedText(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 35,
        height: 30,
        child: Material(
          color: const Color(0xFF982020),
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(7),
            child: Center(child: Icon(icon, color: Colors.white, size: 20)),
          ),
        ),
      ),
    );
  }
}
