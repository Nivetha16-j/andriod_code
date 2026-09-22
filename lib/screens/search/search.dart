import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/services/recently_viewed_service.dart';
import 'package:junubullion/services/search_service.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final PageController _recentlyViewedController = PageController();
  int _recentlyViewedPage = 0;

  List<dynamic> searchResults = [];
  List<Map<String, dynamic>> recentlyViewed = [];

  bool isLoading = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadRecentlyViewed();
  }

  Future<void> loadRecentlyViewed() async {
    recentlyViewed = await RecentlyViewedService.getProducts();

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _recentlyViewedController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> searchProducts(String keyword) async {
    if (keyword.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        searchResults = [];
        isLoading = false;
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final products = await SearchService.searchProducts(keyword);

      if (!mounted) return;

      setState(() {
        searchResults = products;
      });
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search Field
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(const Duration(milliseconds: 400), () {
                  searchProducts(value);
                });
              },
              decoration: InputDecoration(
                hint: const TranslatedText('Search products'),

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryRed,
                ),

                // Background color
                filled: true,
                fillColor: AppColors.offWhite,

                // Normal border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 1,
                  ),
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchResults = [];
                            isLoading = false;
                          });
                        },
                      )
                    : null,

                // Border when TextField is focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (isSearching) ...[
              /// SEARCH RESULTS
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (searchResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: TranslatedText(
                      "No products found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final product = searchResults[index];

                    log("searchResults $searchResults");

                    return Column(
                      children: [
                        ListTile(
                          onTap: () async {
                            await RecentlyViewedService.addProduct(product);

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  productId: product["id"],
                                ),
                              ),
                            ).then((_) {
                              loadRecentlyViewed();
                            });
                          },
                          leading: Image.network(
                            "https://staging.junubullion.com/storage/${product['image_path']}",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Icon(Icons.image);
                            },
                          ),

                          // API data - keep normal Text for now
                          title: TranslatedText(
                            product["name"]?.toString() ?? "",
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
            ] else ...[
              /// RECENTLY VIEWED HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const TranslatedText(
                      "Recently Viewed",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Flexible(
                    child: InkWell(
                      onTap: () {
                        if (recentlyViewed.length <= 2) return;

                        final totalPages = (recentlyViewed.length / 2).ceil();

                        int nextPage = _recentlyViewedPage + 1;

                        if (nextPage >= totalPages) {
                          nextPage = 0;
                        }

                        _recentlyViewedController.animateToPage(
                          nextPage,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const TranslatedText(
                        "See All",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// RECENTLY VIEWED PRODUCTS
              SizedBox(
                height: 170,
                child: PageView.builder(
                  controller: _recentlyViewedController,
                  itemCount: (recentlyViewed.length / 2).ceil(),
                  onPageChanged: (page) {
                    setState(() {
                      _recentlyViewedPage = page;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final int firstIndex = pageIndex * 2;

                    final int secondIndex = firstIndex + 1;
                    log("recentlyViewed $recentlyViewed");

                    return Row(
                      children: [
                        // =========================
                        // FIRST PRODUCT
                        // =========================
                        Expanded(
                          child: _RecentlyViewedCard(
                            product: recentlyViewed[firstIndex],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(
                                    productId: recentlyViewed[firstIndex]["id"],
                                  ),
                                ),
                              );
                            },
                            onRemove: () async {
                              await RecentlyViewedService.removeProduct(
                                recentlyViewed[firstIndex]["id"],
                              );

                              await loadRecentlyViewed();
                            },
                          ),
                        ),

                        const SizedBox(width: 10),

                        // =========================
                        // SECOND PRODUCT
                        // =========================
                        Expanded(
                          child: secondIndex < recentlyViewed.length
                              ? _RecentlyViewedCard(
                                  product: recentlyViewed[secondIndex],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailsScreen(
                                          productId:
                                              recentlyViewed[secondIndex]["id"],
                                        ),
                                      ),
                                    );
                                  },
                                  onRemove: () async {
                                    await RecentlyViewedService.removeProduct(
                                      recentlyViewed[secondIndex]["id"],
                                    );

                                    await loadRecentlyViewed();
                                  },
                                )
                              : const SizedBox(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentlyViewedCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentlyViewedCard({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              gradient: AppColors.BgGradient,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // =========================
                  // PRODUCT IMAGE
                  // =========================
                  SizedBox(
                    height: 85,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: Image.network(
                        "https://staging.junubullion.com/storage/${product["image_path"]}",
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.image,
                            size: 35,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),

                  // =========================
                  // PRODUCT NAME
                  // =========================
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TranslatedText(
                      product["live_price"]?.toString() ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mustard,
                      ),
                    ),
                  ),
                  TranslatedText(
                    product["name"]?.toString() ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // CLOSE BUTTON
          // =========================
          Positioned(
            top: -7,
            right: -5,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  // border: Border.all(color: AppColors.red),
                ),
                child: const Icon(Icons.close, size: 14, color: AppColors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
