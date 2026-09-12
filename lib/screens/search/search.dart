import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/services/recently_viewed_service.dart';
import 'package:junubullion/services/search_service.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _recentlyViewedController = ScrollController();

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
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Flexible(
                    child: InkWell(
                      onTap: () {
                        if (!_recentlyViewedController.hasClients) {
                          return;
                        }

                        _recentlyViewedController.animateTo(
                          _recentlyViewedController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const TranslatedText(
                        "See All",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// RECENTLY VIEWED PRODUCTS
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _recentlyViewedController,
                  itemCount: recentlyViewed.length,
                  itemBuilder: (context, index) {
                    final product = recentlyViewed[index];

                    log("PPPPPP ---- $product");

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  productId: product["id"],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 110,
                            margin: const EdgeInsets.only(right: 12, top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                /// Product Image
                                SizedBox(
                                  height: 85,
                                  width: 110,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      "https://staging.junubullion.com/storage/${product["image_path"]}",
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) {
                                        return const Icon(Icons.image);
                                      },
                                    ),
                                  ),
                                ),

                                /// Product Name
                                Expanded(
                                  child: TranslatedText(
                                    product["name"]?.toString() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// Close Button
                        Positioned(
                          top: 0,
                          right: 4,
                          child: InkWell(
                            onTap: () async {
                              await RecentlyViewedService.removeProduct(
                                product["id"],
                              );

                              await loadRecentlyViewed();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
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
