import 'dart:developer';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/providers/product_detail_provider.dart';
import 'package:junubullion/providers/review_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/home_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
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

  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

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

  Future<void> submitReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a rating")));
      return;
    }

    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your review")));
      return;
    }

    final token = await SessionManager.getToken();

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first")));
      return;
    }

    final reviewProvider = context.read<ReviewProvider>();
    final productProvider = context.read<ProductDetailsProvider>();

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

      // Refresh product details (includes reviews)
      await productProvider.fetchProductDetails(widget.productId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["message"])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"] ?? "Something went wrong")),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailsProvider>().fetchProductDetails(
        widget.productId,
      );
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductDetailsProvider>();
    final reviewProvider = context.watch<ReviewProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.product == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }

    final product = provider.product!;
    final reviews = provider.reviews!;
    final subcategories = provider.subcategories!;

    final relatedProducts = provider.relatedProducts;

    final List<dynamic> images = product['images'] ?? [];

    final String metalType = product['metal_type']?.toString() ?? "";

    final String name = product['name']?.toString() ?? '';

    final String price = product['live_price']?.toString() ?? '--';

    final bool isInStock = product['stock_status'] == 'in_stock';

    final String imageUrl =
        "https://staging.junubullion.com/storage/${product['image_path']}";

    String description = product['description'] ?? '';

    description = description
        .replaceAll(RegExp(r'<p[^>]*>'), '') // remove opening <p>
        .replaceAll('</p>', '\n\n') // new line after each paragraph
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '') // remove remaining HTML tags
        .replaceAll('&nbsp;', ' ')
        .trim();

    final String shortDescriptionHtml = product['short_description'] ?? "";

    final String shortDescription =
        parse(shortDescriptionHtml).documentElement?.text ?? '';

    final String brand = (product['brand'] ?? '')
        .toString()
        .replaceAll('\r\n', '\n')
        .trim();

    debugPrint("reviewsssssss ${reviews}");

    final String categoryName = product['category']?['name']?.toString() ?? '';

    final String subCategoryNames = subcategories
        .map((e) => e['name'].toString())
        .join(', ');

    final String categories = [
      categoryName,
      if (subCategoryNames.isNotEmpty) subCategoryNames,
    ].join(', ');

    return Scaffold(
      backgroundColor: Color(0xffFAFAF8),
      appBar: CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Main Image
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xffF9EAEA),
                  // borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    images.isNotEmpty ? images[selectedImage]['url'] : imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Thumbnails
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
                        // borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.network(
                        images[index]['url'], // ✅ Correct
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
                style: TextStyle(
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
                isInStock ? "In Stock" : "Out of Stock",
                style: TextStyle(
                  color: isInStock ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                shortDescription,
                style: const TextStyle(color: Colors.black87, height: 1.6),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
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
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            quantity.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => quantity++);
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8D2423),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "ADD TO CART",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

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
                          /// Existing Reviews
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
                                    CircleAvatar(
                                      radius: 30,
                                      child: Icon(Icons.person),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              customer["name"] ?? "Anonymous",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 5),
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
                                                  star < (review["rating"] ?? 0)
                                                  ? Colors.amber
                                                  : Colors.grey.shade300,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        Text(
                                          review["description"] ?? "",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),

                          const SizedBox(height: 20),

                          /// Add Review
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
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          brand,
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Related Products",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

              const SizedBox(height: 16),

              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  itemCount: relatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = relatedProducts[index];

                    log("ppppppppppppp $product");

                    final String image =
                        "https://staging.junubullion.com/storage/${product['image_path'] ?? ''}";

                    final String name = product['name']?.toString() ?? '';

                    final String livePrice =
                        product['live_price']?.toString() ?? '--';

                    final String stockStatus =
                        product['stock_status']?.toString() ?? 'out_of_stock';

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(251, 242, 242, 1),
                        borderRadius: BorderRadius.circular(16),
                        // boxShadow: [
                        //   BoxShadow(color: Colors.black12, blurRadius: 6),
                        // ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(
                                productId: product["id"],
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
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                stockStatus == "in_stock"
                                    ? "In Stock"
                                    : "Out of Stock",
                                style: TextStyle(
                                  color: product['stock_status'] == "in_stock"
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
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    "Add to cart",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
              SizedBox(height: 20),
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

  Widget tabButton(String title, int index) {
    bool isSelected = selectedTab == index;

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
