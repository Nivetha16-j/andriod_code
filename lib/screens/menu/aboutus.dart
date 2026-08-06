import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
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

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFDF1C8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "About Us",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Junu Bullion is a precious metals trading company specializing in gold, silver, and other bullion products.",
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  const Text(
                    "The Beginning of Excellence",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 14),

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
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.sandal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Our Core Values",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Wrap(
                  //   spacing: 20,
                  //   runSpacing: 20,
                  //   children: List.generate(values.length, (index) {
                  //     final bool isExpanded = expandedIndex == index;

                  //     return SizedBox(
                  //       width: (MediaQuery.of(context).size.width - 60) / 2,
                  //       child: AnimatedSize(
                  //         duration: const Duration(milliseconds: 300),
                  //         curve: Curves.easeInOut,
                  //         child: Container(
                  //           padding: const EdgeInsets.all(14),
                  //           decoration: BoxDecoration(
                  //             color: AppColors.primaryRed,
                  //             borderRadius: BorderRadius.circular(16),
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.black.withOpacity(.08),
                  //                 blurRadius: 10,
                  //                 offset: const Offset(0, 4),
                  //               ),
                  //             ],
                  //           ),
                  //           child: Column(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Text(
                  //                 values[index]["title"],
                  //                 textAlign: TextAlign.center,
                  //                 style: const TextStyle(
                  //                   fontSize: 18,
                  //                   fontWeight: FontWeight.w600,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),

                  //               const SizedBox(height: 12),

                  //               Text(
                  //                 values[index]["description"],
                  //                 textAlign: TextAlign.center,
                  //                 style: const TextStyle(
                  //                   fontSize: 12,
                  //                   height: 1.5,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),

                  //               if (isExpanded) ...[
                  //                 const SizedBox(height: 12),

                  //                 Text(
                  //                   values[index]["hidden_text"],
                  //                   textAlign: TextAlign.center,
                  //                   style: const TextStyle(
                  //                     fontSize: 12,
                  //                     height: 1.5,
                  //                     color: Colors.white,
                  //                   ),
                  //                 ),
                  //               ],

                  //               const SizedBox(height: 16),

                  //               InkWell(
                  //                 onTap: () {
                  //                   setState(() {
                  //                     expandedIndex = expandedIndex == index
                  //                         ? -1
                  //                         : index;
                  //                   });
                  //                 },
                  //                 child: Text(
                  //                   isExpanded ? "View Less" : "View More",
                  //                   style: const TextStyle(
                  //                     color: AppColors.yellow,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 12,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   }),
                  // ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double cardWidth = (constraints.maxWidth - 20) / 2;

                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: List.generate(values.length, (index) {
                          final bool isExpanded = expandedIndex == index;

                          return SizedBox(
                            width: cardWidth,
                            child: AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      values[index]["title"],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      values[index]["description"],
                                      textAlign: TextAlign.center,
                                      maxLines: isExpanded ? 10 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.6,
                                      ),
                                    ),

                                    if (isExpanded) ...[
                                      const SizedBox(height: 12),

                                      Text(
                                        values[index]["hidden_text"],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],

                                    const SizedBox(height: 16),

                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          expandedIndex = expandedIndex == index
                                              ? -1
                                              : index;
                                        });
                                      },
                                      child: Text(
                                        isExpanded ? "View Less" : "View More",
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
                        }),
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
                    child: Text(
                      "What We Offer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    color: AppColors.yellow,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "1 gram Canadian Gold Maple Leaf Coins",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "The 1g Gold MapleGram Coin from the Royal Canadian Mint offers the perfect blend of quality, security, and investment potential. Struck from 99.99% pure gold, each coin features the iconic maple leaf design and advanced security features.",
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  // Navigate or perform action
                                },
                                child: const Text(
                                  "Discover more ›",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 25),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/gold.png",
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    color: AppColors.grey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "1 Kilogram Royal Canadian Mint Silver Bullion Bar",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                "Invest in purity and prestige with the 1 Kilogram Royal Canadian Mint  (RCM) Silver Bullion Bar. Minted by one of the world’s most respected  sovereign mints,  this silver bar contains 1 kilogram (32.15 troy  ounces) of .9999 fine silver,",
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  // Navigate or perform action
                                },
                                child: const Text(
                                  "Discover more ›",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 25),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/silver.png",
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
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
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        fontSize: 14,
        // height: 1.8,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
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
