import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/account_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:marquee/marquee.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _brandPageController = PageController();
  int _brandPage = 0;
  int _currentIndex = 0;
  final GlobalKey _brandsSectionKey = GlobalKey();

  void _scrollToBrands() {
    final context = _brandsSectionKey.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  final AccountService _accountService = AccountService();

  List<dynamic> _brands = [];
  bool _isLoading = false;

  int _selectedCategoryIndex = 0;

  final List<String> _categories = ["All Brands", "Gold", "Silver"];

  List<dynamic> getFilteredBrands(List<dynamic> brands) {
    switch (_selectedCategoryIndex) {
      case 1:
        return brands.where((e) => e["type"] == "Gold").toList();

      case 2:
        return brands.where((e) => e["type"] == "Silver").toList();

      default:
        return brands.where((e) => e["type"] == "Gold & Silver").toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _accountService.fetchBrands();

      if (response['status'] == true) {
        setState(() {
          _brands = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Brands Error : $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBrands = getFilteredBrands(_brands);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xffFAFAF8),

      drawer: const CustomDrawer(),

      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // TOP BANNER
                    // --------------------------------------------------
                    Container(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(20),
                        gradient: AppColors.BgGradient,
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(14),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: AppColors.BgGradient,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TranslatedText(
                              "TRUSTED. AUTHENTIC. VALUABLE.",
                              style: TextStyle(
                                color: Color(0xffD4A017),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 12),

                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: "World's Most Trusted\n",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Bullion Brands",
                                    style: TextStyle(
                                      color: AppColors.mustard,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            const TranslatedText(
                              "Invest In Globally Recognized Gold & Silver Bullion "
                              "From The World's Most Trusted Mints And Refiners.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _scrollToBrands,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffD4A017),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: TranslatedText(
                                  "Explore Brands",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --------------------------------------------------
                    // BRAND LOGOS
                    // --------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.all(9),
                      child: const BrandMarquee(),
                    ),

                    // --------------------------------------------------
                    // TITLE
                    // --------------------------------------------------
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TranslatedText(
                        "Why Invest In Trusted Brands?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --------------------------------------------------
                    // FEATURE CARDS
                    // --------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double itemWidth =
                              (constraints.maxWidth - 15) / 2;

                          return Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            children: const [
                              FeatureCard(
                                width: 0,
                                icon: "assets/i1.png",
                                title: "100% Authentic",
                                description:
                                    "Every Product Is Sourced Directly From "
                                    "World-Renowned Mints And Refineries.",
                              ),

                              FeatureCard(
                                width: 0,
                                icon: "assets/i2.png",
                                title: "Global Recognition",
                                description:
                                    "Our Brands Are Globally Recognized And "
                                    "Easily Tradable Worldwide.",
                              ),

                              FeatureCard(
                                width: 0,
                                icon: "assets/i3.png",
                                title: "High Purity",
                                description:
                                    "Assured Purity And Quality That Meets "
                                    "International Bullion Standards.",
                              ),

                              FeatureCard(
                                width: 0,
                                icon: "assets/i4.png",
                                title: "Secure Investment",
                                description:
                                    "Physical Metals From Trusted Brands "
                                    "Provide Long-Term Value And Security.",
                              ),
                            ].map((card) => SizedBox(width: itemWidth, child: card)).toList(),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --------------------------------------------------
                    // OUR GOLD & SILVER BRANDS
                    // --------------------------------------------------
                    Container(
                      key: _brandsSectionKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TranslatedText(
                          "Our Gold & Silver Brands",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // BRAND CATEGORY TABS
                    // --------------------------------------------------
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _brandCategory("All Brands", 0),
                          _brandCategory("Gold", 1),
                          _brandCategory("Silver", 2),
                          // _brandCategory("Gold Coins"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --------------------------------------------------
                    // BRAND CARDS
                    // --------------------------------------------------
                    // --------------------------------------------------
                    // BRAND CARDS
                    // --------------------------------------------------
                    // --------------------------------------------------
                    // BRAND CARDS
                    // --------------------------------------------------
                    Container(
                      // color: Colors.blue,
                      height: 230,
                      child: PageView.builder(
                        controller: _brandPageController,
                        itemCount: (filteredBrands.length / 2).ceil(),
                        onPageChanged: (index) {
                          setState(() {
                            _brandPage = index;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          final int firstIndex = pageIndex * 2;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _brandCard(
                                      image:
                                          filteredBrands[firstIndex]["image"] ??
                                          "",
                                      brandName:
                                          filteredBrands[firstIndex]["name"] ??
                                          "",
                                      category:
                                          filteredBrands[firstIndex]["type"] ??
                                          "",
                                    ),
                                  ),

                                  const SizedBox(width: 28),

                                  Expanded(
                                    child:
                                        firstIndex + 1 < filteredBrands.length
                                        ? _brandCard(
                                            image:
                                                filteredBrands[firstIndex +
                                                    1]["image"]!,
                                            brandName:
                                                filteredBrands[firstIndex +
                                                    1]["name"]!,
                                            category:
                                                filteredBrands[firstIndex +
                                                    1]["type"]!,
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --------------------------------------------------
                    // SEE ALL / NEXT
                    // --------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            if (_brandPage <
                                (filteredBrands.length / 2).ceil() - 1) {
                              _brandPageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Optional: go back to first 2 products
                              _brandPageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(
                            _brandPage < (filteredBrands.length / 2).ceil() - 1
                                ? "See All"
                                : "See Less",
                            style: const TextStyle(
                              color: Color(0xffC69200),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
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

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  Widget _brandCategory(String title, int index) {
    final isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
          _brandPage = 0;
        });

        _brandPageController.jumpToPage(0);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mustard : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.mustard),
        ),
        child: Center(
          child: TranslatedText(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : AppColors.mustard,
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandCard({
    required String image,
    required String brandName,
    required String category,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.sandal,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.mustard, width: 1.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand/Product Image
          SizedBox(
            height: 155,
            width: double.infinity,
            child: Image.network(
              "https://staging.junubullion.com/storage/$image",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported_outlined, size: 45);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Brand Name
          TranslatedText(
            brandName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 7),

          // Category
          TranslatedText(
            category,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final double width;
  final String icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == 0 ? double.infinity : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sandal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE39E1C), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            icon,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint("Feature icon error: $icon");

              return const SizedBox(
                height: 40,
                width: 40,
                child: Icon(Icons.image_not_supported, size: 30),
              );
            },
          ),

          const SizedBox(height: 12),

          TranslatedText(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          TranslatedText(
            description,
            style: const TextStyle(fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class BrandMarquee extends StatefulWidget {
  const BrandMarquee({super.key});

  @override
  State<BrandMarquee> createState() => _BrandMarqueeState();
}

class _BrandMarqueeState extends State<BrandMarquee> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _autoScroll();
  }

  Future<void> _autoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 30));

      if (!_scrollController.hasClients) continue;

      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(_scrollController.offset + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _brandLogo("assets/brand1.png"),
          _brandLogo("assets/b2.webp"),
          _brandLogo("assets/b3.webp"),
          _brandLogo("assets/b4.webp"),

          // duplicate for seamless looping
          _brandLogo("assets/brand1.png"),
          _brandLogo("assets/b2.webp"),
          _brandLogo("assets/b3.webp"),
          _brandLogo("assets/b4.webp"),
        ],
      ),
    );
  }

  Widget _brandLogo(String asset) {
    return SizedBox(
      width: 100,
      height: 65,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("Brand asset error: $asset");
          return const Icon(Icons.image_not_supported, size: 35);
        },
      ),
    );
  }
}
