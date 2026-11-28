import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/menu/wallet.dart';
import 'package:junubullion/screens/product/product_details.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:provider/provider.dart';

class GspScreen extends StatefulWidget {
  const GspScreen({super.key});

  @override
  State<GspScreen> createState() => _GspScreenState();
}

class _GspScreenState extends State<GspScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedUserType;

  bool isLoadingApplication = true;
  bool hasGspRegistration = false;

  bool isMonthly = true;
  double selectedAmount = 160;

  final List<Map<String, dynamic>> planFeatures = [
    {
      "title": "Minimum Start",
      "content": [
        {
          "text": "Begin Your Gold Savings Journey With Only ",
          "highlight": false,
        },
        {"text": "SGD 20", "highlight": true},
        {
          "text": ", Making Gold Ownership Accessible To Everyone.",
          "highlight": false,
        },
      ],
    },
    {
      "title": "Currency Input",
      "content": [
        {"text": "Invest Conveniently Using ", "highlight": false},
        {"text": "Singapore Dollars (SGD)", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Gold Conversion",
      "content": [
        {"text": "Convert your savings based on the ", "highlight": false},
        {"text": "live market rate per gram", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Physical Withdrawal",
      "content": [
        {"text": "Physical withdrawal is available from ", "highlight": false},
        {"text": "10g accumulated", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Easy Saving",
      "content": [
        {
          "text": "Build your gold savings gradually with simple and ",
          "highlight": false,
        },
        {"text": "flexible contributions", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Secure Ownership",
      "content": [
        {
          "text": "Your savings are connected to real physical gold for ",
          "highlight": false,
        },
        {"text": "greater confidence", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Live Gold Rate",
      "content": [
        {
          "text": "Gold conversion is calculated using the current ",
          "highlight": false,
        },
        {"text": "live market price", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
    {
      "title": "Physical Gold",
      "content": [
        {"text": "Convert your accumulated savings into ", "highlight": false},
        {"text": "physical gold when eligible", "highlight": true},
        {"text": ".", "highlight": false},
      ],
    },
  ];

  final List<Map<String, String>> investmentOptions = [
    {"price": "₹1,475.69", "sgd": "SGD 20", "gold": "≈ 0.1g gold"},
    {"price": "₹7,378.46", "sgd": "SGD 100", "gold": "≈ 0.5g gold"},
    {"price": "₹36,892.31", "sgd": "SGD 500", "gold": "≈ 2.5g gold"},
    {"price": "₹368,923.12", "sgd": "SGD 5000", "gold": "≈ 25g gold"},
  ];

  final List<Map<String, String>> audienceItems = [
    {
      "title": "Young professionals",
      "description":
          "Build disciplined saving habits and start creating long-term wealth through gold.",
    },
    {
      "title": "Parents saving for children's future",
      "description":
          "Create a dedicated savings plan to support your children's future education and important milestones.",
    },
    {
      "title": "Families seeking wealth protection",
      "description":
          "Protect family wealth and build a tangible asset that can support your long-term financial goals.",
    },
    {
      "title": "First-time gold investors",
      "description":
          "A simple way for beginners to enter gold investing without requiring a large initial investment.",
    },
    {
      "title": "Individuals planning for retirement",
      "description":
          "Build a long-term gold reserve through consistent monthly savings for your retirement.",
    },
    {
      "title": "Anyone looking for a disciplined savings program",
      "description":
          "Develop a consistent saving routine and grow your gold holdings gradually over time.",
    },
  ];

  final List<Map<String, String>> planBenefits = [
    {
      "title": "Affordable Start",
      "description":
          "Begin your gold savings journey with only SGD 20, making gold ownership accessible to everyone.",
    },
    {
      "title": "Protection Against Inflation",
      "description":
          "Gold has traditionally been considered a store of value, helping preserve purchasing power over the long term.",
    },
    {
      "title": "Children's Education Fund",
      "description":
          "Build a dedicated savings plan to support future education expenses and important life milestones.",
    },
    {
      "title": "Retirement Planning",
      "description":
          "Create a gold-based retirement reserve through consistent monthly savings.",
    },
    {
      "title": "Disciplined Wealth Building",
      "description":
          "Develop disciplined saving habits and build long-term wealth accumulation through regular contributions.",
    },
    {
      "title": "Flexible Savings",
      "description":
          "Save at your own pace and increase your contributions whenever your financial situation allows.",
    },
    {
      "title": "Gold Ownership",
      "description":
          "Gradually accumulate gold and build a tangible asset for the future.",
    },
    {
      "title": "Secure Future",
      "description":
          "Build a stronger financial foundation with gold and create a tangible asset for the future.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkGspRegistration();
  }

  Future<void> _checkGspRegistration() async {
    try {
      final result = await JscService.getApplication(applicationType: 'GSP');

      if (!mounted) return;

      setState(() {
        hasGspRegistration = result["hasRegistration"] == true;
        isLoadingApplication = false;
      });
    } catch (e) {
      debugPrint('JSC registration check error: $e');

      if (!mounted) return;

      setState(() {
        hasGspRegistration = false;
        isLoadingApplication = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(gradient: AppColors.BgGradient),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(13),
                    padding: const EdgeInsets.all(15),
                    constraints: const BoxConstraints(minHeight: 240),
                    decoration: BoxDecoration(
                      gradient: AppColors.BgGradient,
                      borderRadius: BorderRadius.circular(18),
                      // border: Border.all(color: const Color(0xffD4A017), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TranslatedText(
                                    "Invest Your Gold For ",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                TranslatedText(
                                  "GOLD BALANCE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TranslatedText(
                                  "The Future",
                                  style: TextStyle(
                                    color: AppColors.mustard,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TranslatedText(
                                  "\$1000.25",
                                  style: TextStyle(
                                    color: Color(0xffE8C45A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // const SizedBox(height: 24),
                        const SizedBox(height: 24),

                        const TranslatedText(
                          "Start Building Wealth From Just 1 Gram",
                          style: TextStyle(
                            color: Color(0xffA7A9B4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomWallet(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mustard,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const TranslatedText(
                                "INVEST NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Image.asset("assets/GI.png", width: 100),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(minHeight: 160),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xffD4A017),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TranslatedText(
                          "Gold Savings Passbook(gsp)",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const TranslatedText(
                          "Start Your Gold Savings from SGD 20 Build your gold holdings gradually, with your future goals in mind. \nThe Junu Bullion Gold Savings Plan (GSP) is a smart and affordable savings program that allows customers to accumulate gold gradually through regular savings. Starting from only SGD 20, GSP helps individuals and families build long-term wealth, protect their savings from inflation, and achieve important financial goals. \nWhether you are planning for your child's education, retirement, wealth preservation, or future investments,GSP provides a simple and disciplined way to own gold over time.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "Featured Assets",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Consumer<ExclusiveProductProvider>(
              builder: (context, exclusiveProvider, child) {
                if (exclusiveProvider.isLoading &&
                    exclusiveProvider.products.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                log(
                  "exxxxxxxxxxx ${exclusiveProvider.products.length}........",
                );

                final List<Map<String, dynamic>> gspProducts = exclusiveProvider
                    .products
                    .where(
                      (product) =>
                          (product['brand'] ?? '')
                              .toString()
                              .trim()
                              .toUpperCase() ==
                          'GSP',
                    )
                    .map((product) => Map<String, dynamic>.from(product))
                    .toList();

                if (gspProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: TranslatedText(
                        "No GSP products available.",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double spacing = 12;
                      final double cellWidth =
                          (constraints.maxWidth - spacing) / 2;
                      final double textScale = MediaQuery.of(
                        context,
                      ).textScaler.scale(1.0).clamp(1.0, 1.3);

                      // image area (~1.0 x width) + room for name, price and button
                      final double cellHeight =
                          cellWidth * 0.8 + 130 * textScale;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gspProducts.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: 18,
                          mainAxisExtent: cellHeight,
                        ),
                        itemBuilder: (context, index) =>
                            _GspProductCard(product: gspProducts[index]),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "Product Description",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            _buildProductDescription(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "Plan Features",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < planFeatures.length; i++) ...[
                        PlanFeatureCard(
                          title: planFeatures[i]["title"],
                          content: List<Map<String, dynamic>>.from(
                            planFeatures[i]["content"],
                          ),
                        ),
                        if (i != planFeatures.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "How Your Money Converts",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double spacing = 10;

                  // 4 cards fit across the screen, but never narrower than 95
                  final double cardWidth =
                      ((constraints.maxWidth - spacing * 3) / 4).clamp(
                        95.0,
                        200.0,
                      );

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (
                            int i = 0;
                            i < investmentOptions.length;
                            i++
                          ) ...[
                            InvestmentOptionCard(
                              width: cardWidth,
                              price: investmentOptions[i]["price"]!,
                              sgd: investmentOptions[i]["sgd"]!,
                              gold: investmentOptions[i]["gold"]!,
                            ),
                            if (i != investmentOptions.length - 1)
                              const SizedBox(width: spacing),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "Why Choose Our Investment",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AudienceAccordion(items: audienceItems),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: const TranslatedText(
                "GSP Benefits for Customers",
                // textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            BenefitsCarousel(items: planBenefits),
            const SizedBox(height: 16),
          ],
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

  Widget _buildProductDescription() {
    final features = [
      {
        'icon': "assets/gsp1.png",
        'title': 'Start Saving From As Little As S\$20',
      },
      {
        'icon': "assets/gsp2.png",
        'title': 'Accumulate Gold Regularly Without A Large Initial Investment',
      },
      {
        'icon': "assets/gsp3.png",
        'title': 'Build A Long-Term Savings Portfolio Backed By Gold',
      },
      {
        'icon': "assets/gsp4.png",
        'title': 'Enjoy A Flexible And Convenient Savings Approach',
      },
      {
        'icon': "assets/gsp5.png",
        'title': 'Monitor Their Growing Gold Holdings Over Time',
      },
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryRed, width: 1),
            ),
            child: Column(
              children: [
                for (int i = 0; i < features.length; i++) ...[
                  _buildFeatureItem(
                    icon: features[i]['icon'] as String,
                    title: features[i]['title'] as String,
                  ),

                  if (i != features.length - 1) const SizedBox(height: 15),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({required String icon, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(icon, width: 24, height: 24),

          const SizedBox(width: 16),

          Expanded(
            child: TranslatedText(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionFeature({
    required IconData icon,
    required String title,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),

              CustomPaint(
                size: const Size(110, 110),
                painter: _DashedCirclePainter(),
              ),

              Icon(icon, color: Colors.white, size: 42),
            ],
          ),
        ),

        const SizedBox(height: 18),

        TranslatedText(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double radius = size.width / 2;

    final Path path = Path();

    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius - 2,
    );

    const int dashCount = 32;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = (2 * 3.141592653589793 / dashCount) * i;

      final double sweepAngle = (2 * 3.141592653589793 / dashCount) * 0.55;

      path.addArc(rect, startAngle, sweepAngle);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _GspProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const _GspProductCard({required this.product});

  static const String imageBaseUrl = 'https://junubullion.com/storage/';

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

  @override
  Widget build(BuildContext context) {
    log("productproduct/// $product");
    final int productId = int.tryParse('${product['id']}') ?? 0;

    final String productName = product['name']?.toString() ?? 'GSP Product';

    final String imagePath = product['image_path']?.toString() ?? '';

    final String imageUrl = imagePath.isNotEmpty
        ? '$imageBaseUrl$imagePath'
        : '';

    final String priceText =
        product['live_price']?.toString() ??
        product['formatted_price']?.toString() ??
        (product['price'] != null ? '\$${product['price']}' : '\$0.00');

    final String stockStatus =
        product['stock_status']?.toString().toLowerCase() ?? 'out_of_stock';

    final bool isInStock = stockStatus == 'in_stock';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.BgGradient,
          borderRadius: BorderRadius.circular(25),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(.18),
          //     blurRadius: 14,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
        ),
        padding: const EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image takes whatever height is left, so nothing overflows
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SizedBox(
                    width: double.infinity,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 20,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TranslatedText(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 4),

              TranslatedText(
                priceText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 6),

              // smaller button
              SizedBox(
                width: double.infinity,
                height: 32,
                child: Consumer2<CartProvider, PhysicalConversionProvider>(
                  builder: (context, cartProvider, physicalProvider, child) {
                    return _buildCartButton(
                      context: context,
                      cartProvider: cartProvider,
                      physicalProvider: physicalProvider,
                      productId: productId,
                      isInStock: isInStock,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton({
    required BuildContext context,
    required CartProvider cartProvider,
    required PhysicalConversionProvider physicalProvider,
    required int productId,
    required bool isInStock,
  }) {
    if (!isInStock) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
          foregroundColor: Colors.black54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const TranslatedText(
          "OUT OF STOCK",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    if (physicalProvider.isActive) {
      return ElevatedButton(
        onPressed: () {
          _showMessage(
            "Digital products cannot be added during physical conversion.",
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Cart.png', height: 18),
            const SizedBox(width: 4),
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TranslatedText("ADD TO CART", maxLines: 1),
              ),
            ),
          ],
        ),
      );
    }

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
    final bool isAdding = cartProvider.isAdding(productId);

    return ElevatedButton(
      onPressed: isAdding
          ? null
          : () async {
              final bool alreadyInCart = isInCart && cartQuantity > 0;

              final bool success = alreadyInCart
                  // Same product again -> only bump the quantity
                  ? await cartProvider.updateCartQuantity(
                      productId: productId,
                      quantity: cartQuantity + 1,
                    )
                  // First time -> add to cart
                  : await cartProvider.addToCart(
                      productId: productId,
                      quantity: 1,
                    );

              if (!context.mounted) return;

              _showMessage(
                success
                    ? (alreadyInCart
                          ? "Cart quantity updated"
                          : "Added to Cart")
                    : "Failed to add product",
              );
              if (success) {
                MainScreen.switchTab(context, MainScreen.cartTabIndex);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: isAdding
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Cart.png', height: 18),
                const SizedBox(width: 4),
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: TranslatedText("ADD TO CART", maxLines: 1),
                  ),
                ),
              ],
            ),
    );
  }
}

class PlanFeatureCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> content;

  const PlanFeatureCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      width: (width * 0.8).clamp(260.0, 340.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: AppColors.redGradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffD4A017), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TranslatedText(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          Text.rich(
            TextSpan(
              children: content.map((segment) {
                final bool highlight = segment["highlight"] == true;

                return TextSpan(
                  text: segment["text"],
                  style: TextStyle(
                    color: highlight ? const Color(0xffFFD166) : Colors.white,
                  ),
                );
              }).toList(),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class InvestmentOptionCard extends StatelessWidget {
  final double width;
  final String price;
  final String sgd;
  final String gold;

  const InvestmentOptionCard({
    super.key,
    required this.width,
    required this.price,
    required this.sgd,
    required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff8B1E1E), Color(0xff1A0A0A)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // INR price (scales down if it's too long for the card)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              price,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xffE8C45A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // SGD amount
          Text(
            sgd,
            style: const TextStyle(
              color: Color(0xffD4A017),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          const Icon(
            Icons.arrow_downward_rounded,
            color: Color(0xffD4A017),
            size: 16,
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: TranslatedText(
              gold,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BenefitsCarousel extends StatefulWidget {
  final List<Map<String, String>> items;

  const BenefitsCarousel({super.key, required this.items});

  @override
  State<BenefitsCarousel> createState() => _BenefitsCarouselState();
}

class _BenefitsCarouselState extends State<BenefitsCarousel> {
  static const int _perPage = 2;
  static const double _gap = 12;

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final int pageCount = (items.length / _perPage).ceil();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double pageWidth = constraints.maxWidth;

          return Column(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.horizontal) {
                    return false;
                  }

                  final int page =
                      (notification.metrics.pixels /
                              notification.metrics.viewportDimension)
                          .round()
                          .clamp(0, pageCount - 1);

                  if (page != _currentPage) {
                    setState(() => _currentPage = page);
                  }

                  return false;
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // Snaps one page (2 cards) at a time
                  physics: const PageScrollPhysics(),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int p = 0; p < pageCount; p++)
                          SizedBox(
                            width: pageWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _gap / 2,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int c = 0; c < _perPage; c++) ...[
                                    if (c > 0) const SizedBox(width: _gap),
                                    Expanded(
                                      child: p * _perPage + c < items.length
                                          ? _BenefitCard(
                                              title:
                                                  items[p * _perPage +
                                                      c]["title"]!,
                                              description:
                                                  items[p * _perPage +
                                                      c]["description"]!,
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // DOTS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageCount, (index) {
                  final bool active = _currentPage == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xffB22222)
                          : const Color(0xffB22222).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String title;
  final String description;

  const _BenefitCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff8B1E1E), Color(0xff1A0A0A)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TranslatedText(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xffFFE08A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 14),

          TranslatedText(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AudienceAccordion extends StatefulWidget {
  final List<Map<String, String>> items;

  const AudienceAccordion({super.key, required this.items});

  @override
  State<AudienceAccordion> createState() => _AudienceAccordionState();
}

class _AudienceAccordionState extends State<AudienceAccordion> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: const Color(0xff8B1E1E),
        child: Column(
          children: [
            for (int i = 0; i < widget.items.length; i++) ...[
              _buildRow(i),
              if (i != widget.items.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int index) {
    final item = widget.items[index];
    final bool isOpen = _expandedIndex == index;

    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () {
          setState(() {
            _expandedIndex = isOpen ? null : index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADING
              Row(
                children: [
                  Expanded(
                    child: TranslatedText(
                      item["title"]!,
                      style: const TextStyle(
                        color: Color(0xffFBE69D),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xffFBE69D),
                      size: 22,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TranslatedText(
                          item["description"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
