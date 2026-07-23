import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    // 1. Extract Name
    final String name = product['name']?.toString() ?? 'Product Name';

    // 2. Extract Live Price from JSON Response
    // Checks "live_price" -> "formatted_price" -> "price" in priority order
    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    // 3. Extract Image Path / URL
    final String? imageUrlFromApi = product['image_url']?.toString();
    final String? imagePath = product['image_path']?.toString();

    final String fullImageUrl =
        (imageUrlFromApi != null && imageUrlFromApi.isNotEmpty)
        ? imageUrlFromApi
        : ((imagePath != null && imagePath.isNotEmpty)
              ? '${TrendingProductsSection.imageBaseUrl}$imagePath'
              : '');

    // 4. Extract Stock Status
    final bool isInStock = product['stock_status'] == 'in_stock';

    return Container(
      width: 170.0,
      margin: const EdgeInsets.only(right: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Image Container with Border & Rounded Corners
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
                    errorBuilder: (context, error, stackTrace) => const Icon(
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

          const SizedBox(height: 8.0),

          // Title
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

          // Display Live Price
          Text(
            priceText,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6.0),

          // Add to Cart / Out of Stock Button
          SizedBox(
            width: double.infinity,
            height: 36.0,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isInStock
                    ? AppColors.primaryRed
                    : const Color.fromRGBO(218, 218, 218, 1),
                foregroundColor: isInStock ? Colors.white : Colors.black54,
                elevation: isInStock ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: isInStock
                  ? () {
                      // Add to cart logic
                    }
                  : null,
              child: Text(
                isInStock ? 'Add to cart' : 'Out of stock',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: isInStock ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
