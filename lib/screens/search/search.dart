import 'dart:async';
import 'dart:developer';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/services/recently_viewed_service.dart';
import 'package:junubullion/services/search_service.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

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
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final products = await SearchService.searchProducts(keyword);

      setState(() {
        searchResults = products;
      });
    } catch (e) {
      debugPrint("Search Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search Field
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // Updates UI when text changes

                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }

                _debounce = Timer(const Duration(milliseconds: 400), () {
                  searchProducts(value);
                });
              },
              decoration: InputDecoration(
                hintText: "Search products",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (searchController.text.isNotEmpty) ...[
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final product = searchResults[index];

                          log("searchResults $searchResults");

                          return Column(
                            children: [
                              ListTile(
                                onTap: () async {
                                  await RecentlyViewedService.addProduct(
                                    product,
                                  );

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
                                ),
                                title: Text(product["name"]),
                              ),
                              const Divider(height: 1),
                            ],
                          );
                        },
                      ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recently Viewed",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () {
                      _recentlyViewedController.animateTo(
                        _recentlyViewedController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      "See All",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

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
                            // height: 170,
                            margin: const EdgeInsets.only(right: 12, top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              // borderRadius: BorderRadius.circular(12),
                              // color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 85,
                                  width: 110,
                                  // decoration: BoxDecoration(
                                  // color: Colors.grey.shade200,
                                  //   borderRadius: const BorderRadius.vertical(
                                  //     top: Radius.circular(12),
                                  //   ),
                                  // ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      "https://staging.junubullion.com/storage/${product["image_path"]}",
                                      fit: BoxFit
                                          .contain, // Keeps entire product visible
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                                // Divider(),
                                Expanded(
                                  child: Text(
                                    product["name"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                // Text(
                                //   product["live_price"],
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                //   textAlign: TextAlign.center,
                                //   style: const TextStyle(fontSize: 12),
                                // ),
                              ],
                            ),
                          ),
                        ),

                        /// Close button
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

            //             Expanded(
            //   child: isLoading
            //       ? const Center(child: CircularProgressIndicator())
            //       : searchController.text.isEmpty
            //           ? GridView.builder(
            //   itemCount: recentlyViewed.length,
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     crossAxisSpacing: 16,
            //     mainAxisSpacing: 16,
            //     childAspectRatio: 0.8,
            //   ),
            //   itemBuilder: (context, index) {
            //     final product = recentlyViewed[index];

            //     return Container(
            //       decoration: BoxDecoration(
            //         border: Border.all(color: Colors.grey.shade300),
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Column(
            //         children: [
            //           Expanded(
            //             child: ClipRRect(
            //               borderRadius: const BorderRadius.vertical(
            //                 top: Radius.circular(12),
            //               ),
            //               child: Image.network(
            //                 product["image"]!,
            //                 fit: BoxFit.cover,
            //                 width: double.infinity,
            //               ),
            //             ),
            //           ),
            //           Padding(
            //             padding: const EdgeInsets.all(8),
            //             child: Text(
            //               product["name"]!,
            //               maxLines: 2,
            //               overflow: TextOverflow.ellipsis,
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // )
            //           : Expanded(
            //   child: ListView.separated(
            //     itemCount: searchResults.length,
            //     separatorBuilder: (_, __) => const Divider(height: 1),
            //     itemBuilder: (context, index) {
            //       final product = searchResults[index];

            //       return InkWell(
            //         onTap: () {
            //           // Navigate to Product Details
            //         },
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 12,
            //             vertical: 12,
            //           ),
            //           child: Row(
            //             children: [
            //               /// Product Image
            //               ClipRRect(
            //                 borderRadius: BorderRadius.circular(8),
            //                 child: Image.network(
            //                   "https://staging.junubullion.com/${product["image_path"]}",
            //                   width: 70,
            //                   height: 70,
            //                   fit: BoxFit.cover,
            //                   errorBuilder: (_, __, ___) => Container(
            //                     width: 70,
            //                     height: 70,
            //                     color: Colors.grey.shade200,
            //                     child: const Icon(Icons.image),
            //                   ),
            //                 ),
            //               ),

            //               const SizedBox(width: 12),

            //               /// Name & Price
            //               Expanded(
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       product["name"] ?? "",
            //                       maxLines: 2,
            //                       overflow: TextOverflow.ellipsis,
            //                       style: const TextStyle(
            //                         fontSize: 16,
            //                         fontWeight: FontWeight.w600,
            //                       ),
            //                     ),

            //                     const SizedBox(height: 8),

            //                     Text(
            //                       product["live_price"] ?? "",
            //                       style: const TextStyle(
            //                         fontSize: 18,
            //                         fontWeight: FontWeight.bold,
            //                         color: Colors.black,
            //                       ),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // )
            // )
          ],
        ),
      ),
    );
  }
}
