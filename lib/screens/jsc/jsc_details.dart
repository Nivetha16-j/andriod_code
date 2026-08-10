import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junubullion/screens/jsc/jsc_form.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/custom_featurecard.dart';

class JscScreen extends StatefulWidget {
  const JscScreen({super.key});

  @override
  State<JscScreen> createState() => _JscScreenState();
}

class _JscScreenState extends State<JscScreen> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final products = [
    {
      "image": "assets/gold_coin.png",
      "title": "1 Gram Digital Gold (JSC)",
      "price": "\$145.39",
    },
    {
      "image": "assets/silver_coin.png",
      "title": "1 oz Gram Digital Silver (JSC)",
      "price": "\$71.63",
    },
  ];

  final List<Map<String, dynamic>> features = [
    {
      "image": "assets/images/start_small.png",
      "title": "Start Small",
      "description": [
        "Begin investing from as little as 1 gram of gold or 1oz Silver.",
        "Suitable for first-time investors, families, and young savers.",
      ],
    },
    {
      "image": "assets/images/flexible_saving.png",
      "title": "Flexible Saving",
      "description": [
        "Buy additional grams whenever convenient.",
        "No need for large upfront investments.",
      ],
    },
    {
      "image": "assets/images/physical_asset.png",
      "title": "Physical Asset Backing",
      "description": [
        "Every gram is backed by real bullion.",
        "Provides transparency and confidence in ownership.",
      ],
    },
    {
      "image": "assets/images/live_market.png",
      "title": "Live Market Pricing",
      "description": [
        "Holdings reflect current gold and silver market values.",
        "Customers can track value growth over time.",
      ],
    },
    {
      "image": "assets/images/liquidity.png",
      "title": "Liquidity",
      "description": [
        "Sell back holdings when cash is needed.",
        "Option to convert digital holdings into physical bullion.",
      ],
    },
  ];

  final benefits = [
    {
      "title": "For Children's Future",
      "points": [
        "Build an education fund",
        "Create a long-term wealth inheritance.",
        "Protect savings against inflation.",
      ],
      "image": "assets/emergency_safety.png",
    },
    {
      "title": "For Retirement Planning",
      "points": [
        "Accumulate tangible assets over time.",
        "Diversify retirement savings beyond cash deposits.",
        "Benefit from gold's historical role as a store of value.",
      ],
      "image": "assets/emergency_safety.png",
    },
    {
      "title": "For Emergency Funds",
      "points": [
        "Gold and silver can serve as a financial safety net.",
        "Assets can be sold when needed.",
      ],
      "image": "assets/emergency_safety.png",
    },
  ];
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Hero Section
            Container(
              width: double.infinity,
              color: const Color(0xff6B0404),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B0000),
                      border: Border.all(
                        color: const Color(0xFFFFC107),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withOpacity(0.45),
                          blurRadius: 18,
                          spreadRadius: 6,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '"Save Smart.Own Gold.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffFFCC19),
                          ),
                        ),
                        const Text(
                          'Build Your Future."',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Your Wealth, Backed by Real Gold & Silver",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      // height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Start building your future with the Junu Savings Capital — own digital gold and silver, starting from just 1 gram.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      // height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFFBA49),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JscApplicationForm(),
                          ),
                        );
                      },
                      child: const Text(
                        "Open Your Jsc Account",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("assets/jsc_1.png"),
                      Image.asset("assets/jsc_2.png"),
                      Image.asset("assets/jsc_1.png"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// White Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.25),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Junu Savings Capital (JSC) Plan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff9A1B1B),
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    "Junu Savings Capital (JSC) is a precious metals savings program offered by Junu Bullion that allows customers to accumulate gold or silver gradually through digital ownership backed by physical bullion. Investors can start with small amounts and build long-term wealth through regular savings.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "What is JSC?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff9A1B1B),
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    "JSC is designed as a flexible savings and wealth-building solution where every gram purchased is backed by real physical gold or silver. Customers can buy digital grams, monitor their holdings online, and later sell, withdraw, or convert their holdings into physical bullion products.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const Text(
              "Start Small, Grow Big\nStart Your Wealth Journey Today",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xffA51E22),
                fontWeight: FontWeight.w600,
                fontSize: 20,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(18),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 18,
                  childAspectRatio: .60,
                ),
                itemBuilder: (_, index) {
                  final product = products[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            product["image"]!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          product["title"]!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          product["price"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffA51E22),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "ADD TO CART",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Container(
              color: const Color(0xffF8F6F0),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Key Features",
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: features.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final feature = features[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: FeatureCard(
                            image: "assets/feature.png",
                            title: feature["title"],
                            descriptions: List<String>.from(
                              feature["description"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(features.length, (index) {
                      final isSelected = _currentPage == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xffA51E22)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    color: const Color(0xffF8F6F0),
                    // padding: const EdgeInsets.symmetric(
                    //   horizontal: 30,
                    //   vertical: 30,
                    // ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 5, child: _buildImage()),

                            const SizedBox(width: 25),

                            Expanded(flex: 5, child: _buildContent()),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  howJscWorksSection(),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "JSC Benefits for Customers",
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffB00000),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        height: 450,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          // padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: benefits.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 18);
                          },
                          itemBuilder: (context, index) {
                            final benefit = benefits[index];

                            return _benefitCard(
                              title: benefit["title"] as String,
                              points: List<String>.from(
                                benefit["points"] as List,
                              ),
                              image: benefit["image"] as String,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
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

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.asset(
        "assets/emergency_safety.png",
        width: MediaQuery.of(context).size.width * 0.5,
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Emergency Safety Net",
          style: TextStyle(
            color: Color(0xffA51E22),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          "Gold and silver bought today grows with the market. Whether it’s for emergencies, future plans, or peace of mind — your savings are always there when you need them.",
          style: TextStyle(fontSize: 10, color: Colors.black),
        ),

        const SizedBox(height: 5),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xffFFF5A8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            "With just SGD 1 gram, you can begin building a safety net that grows while you sleep.",
            style: TextStyle(
              color: Color(0xff245C45),
              fontSize: 10,
              height: 1.3,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget howJscWorksSection() {
    final steps = [
      "Join JSC",
      "Purchase digital gold or silver grams",
      "Track holdings through your account",
      "Add more grams regularly",
      "Withdraw physical bullion or sell holdings when required",
    ];

    return Column(
      children: [
        const Text(
          "How JSC Works",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xffB00000),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        Column(
          children: List.generate(steps.length, (index) {
            return Column(
              children: [
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),

                if (index != steps.length - 1) ...[
                  const SizedBox(height: 12),

                  const Icon(
                    Icons.arrow_downward,
                    color: Color(0xffD49A00),
                    size: 30,
                  ),

                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _benefitCard({
    required String title,
    required List<String> points,
    required String image,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffB5161A), Color(0xff452020), Color(0xff003B35)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 18),

          /// Bullet points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: points.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "•",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 225,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
