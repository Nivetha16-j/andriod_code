import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  List values = [
    {
      "title": "Our Values",
      "description":
          "Integrity and Transparency Customer-centric Service Security and Reliability",
      "hidden_text":
          "Professional Excellence Long-Term Trust and Partnership Innovation and Continuous Improvement Ethical Business Practices Commitment to Quality",
    },
    {
      "title": "Mission",
      "description": "To provide secure, transparent, and reliable",
      "hidden_text":
          "clients preserve and grow their wealth through gold, silver, and other bullion investments. We are committed to delivering exceptional service, competitive pricing, and trusted long- term partnerships.",
    },
    {
      "title": "Vision",
      "description": "To become a leading and trusted bullion company",
      "hidden_text":
          "recognized for excellence, integrity, innovation, and customer satisfaction in the precious metals industry.",
    },
    {
      "title": "Core Values",
      "description": "Integrity – Conduct business with honesty",
      "hidden_text":
          "Trust – Build lasting relationships with clients and partners. Professionalism – Deliver high standards in every transaction. Security – Prioritize the safety of clients’ assets and information. . Excellence - Continuously improve our services and expertise. . Customer Focus - Put clients’ needs at the center of everything we do.",
    },
  ];
  int expandedIndex = -1;
  bool _showMoreAbout = false;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final PageController _valuesPageController = PageController();
  int _currentValuePage = 0;

  final PageController _offerPageController = PageController();

  int _currentOfferPage = 0;

  @override
  void dispose() {
    _valuesPageController.dispose();
    _offerPageController.dispose();
    super.dispose();
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
          children: [
            // Top Yellow Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: AppColors.BgGradient),
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/about.png",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TranslatedText(
                      "About Us",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // About Us content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showMoreAbout
                          ? Column(
                              key: const ValueKey("expanded"),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _paragraph(
                                  "Junu bullion is a precious metals trading company specializing in gold, silver, And other bullion products. We are committed to providing clients with secure, transparent,and reliable precious metals solutions for wealth preservation and investment purposes. Our focus is on building long-term relationships through professionalism, integrity, and exceptional customer service. We strive to offer competitive pricing, efficient transactions, and trusted support to individual investors, businesses and institutional clients.",
                                ),

                                const SizedBox(height: 20),

                                _paragraph(
                                  "Our focus is on building long-term relationships through professionalism, integrity, and exceptional customer service. We strive to offer competitive pricing, efficient transactions, and trusted support to individual investors, businesses and institutional clients.",
                                ),

                                const SizedBox(height: 20),

                                _paragraph(
                                  "At Junu Bullion, we believe that precious metals play an important role in protecting and diversifying wealth. Our mission is to make bullion trading accessible, secure, and straightforward for every client.",
                                ),
                              ],
                            )
                          : TranslatedText(
                              "Junu Bullion is a precious metals trading company specializing in gold, silver, and other bullion products.",
                              key: const ValueKey("collapsed"),
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Learn More / Show Less
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMoreAbout = !_showMoreAbout;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: TranslatedText(
                          _showMoreAbout ? "Show Less" : "Learn More",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // White Content Section
            Container(
              width: double.infinity,
              color: AppColors.sandal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  TranslatedText(
                    "Our Core Values",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 330,
                            child: PageView.builder(
                              controller: _valuesPageController,
                              itemCount: values.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentValuePage = index;

                                  // Close expanded card when swiping
                                  expandedIndex = -1;
                                });
                              },
                              itemBuilder: (context, index) {
                                final bool isExpanded = expandedIndex == index;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.BgGradient,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              .08,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TranslatedText(
                                            values[index]["title"],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const SizedBox(height: 18),

                                          TranslatedText(
                                            values[index]["description"],
                                            textAlign: TextAlign.center,
                                            maxLines: isExpanded ? 10 : 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              height: 1.6,
                                            ),
                                          ),

                                          if (isExpanded) ...[
                                            const SizedBox(height: 12),

                                            TranslatedText(
                                              values[index]["hidden_text"],
                                              textAlign: TextAlign.center,
                                              maxLines: isExpanded ? 6 : 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                height: 1.6,
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 18),

                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                expandedIndex =
                                                    expandedIndex == index
                                                    ? -1
                                                    : index;
                                              });
                                            },
                                            child: TranslatedText(
                                              isExpanded
                                                  ? "View Less"
                                                  : "View More",
                                              style: const TextStyle(
                                                color: AppColors.yellow,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
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

                          const SizedBox(height: 16),

                          // =========================
                          // PAGE INDICATORS
                          // =========================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(values.length, (index) {
                              final bool isActive = _currentValuePage == index;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: isActive ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryRed
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Center(
                    child: TranslatedText(
                      "What We Offer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 430,
                        child: PageView.builder(
                          controller: _offerPageController,
                          itemCount: 2,

                          onPageChanged: (index) {
                            setState(() {
                              _currentOfferPage = index;
                            });
                          },

                          itemBuilder: (context, index) {
                            final bool isGold = index == 0;

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: AppColors.BgGradient,
                                borderRadius: BorderRadius.circular(4),
                              ),

                              child: Stack(
                                children: [
                                  // =========================
                                  // PRODUCT CONTENT
                                  // =========================
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // PRODUCT IMAGE
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            isGold
                                                ? "assets/gold.png"
                                                : "assets/silver.png",
                                            width: 180,
                                            height: 200,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // PRODUCT TITLE
                                      TranslatedText(
                                        isGold
                                            ? "1 Gram Canadian Gold Maple Leaf Coins"
                                            : "1 Kilogram Royal Canadian Mint Silver Bullion Bar",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // PRODUCT DESCRIPTION
                                      TranslatedText(
                                        isGold
                                            ? "The 1g Gold MapleGram Coin from The Royal Canadian Mint Offers The Perfect Blend Of Quality, Security, And Investment Potential.Struck From 99.99% Pure Gold, Each Coin Features The Iconic Maple Leaf Design, Micro-Engraved Security Features."
                                            : "Invest in purity and prestige with the 1 Kilogram Royal Canadian Mint (RCM) Silver Bullion Bar. Minted by one of the world's most respected sovereign mints, this silver bar contains 1 kilogram (32.15 troy ounces) of .9999 fine silver.",
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: AppColors.white,
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      // DISCOVER MORE
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MainScreen(
                                                initialIndex: 3,
                                                productCategoryIndex: isGold
                                                    ? 1
                                                    : 4,
                                              ),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: const TranslatedText(
                                          "Discover More ›",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.yellow,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // =========================
                                  // FORWARD ARROW
                                  // =========================
                                  if (index == 0)
                                    Positioned(
                                      top: 2,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _offerPageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chevron_right,
                                            color: AppColors.primaryRed,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // =========================
                                  // BACK ARROW
                                  // =========================
                                  if (index == 1)
                                    Positioned(
                                      top: 2,
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          _offerPageController.previousPage(
                                            duration: const Duration(
                                              milliseconds: 400,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.chevron_left,
                                            color: AppColors.primaryRed,
                                            size: 22,
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

                      // const SizedBox(height: 12),
                    ],
                  ),
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

  static Widget _paragraph(String text) {
    return TranslatedText(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        fontSize: 14,
        // height: 1.8,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
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
}
