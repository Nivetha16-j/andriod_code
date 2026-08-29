import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/exclusive_product_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/screens/plans/jsc/jsc_form.dart';

class GspScreen extends StatefulWidget {
  const GspScreen({super.key});

  @override
  State<GspScreen> createState() => _GspScreenState();
}

class _GspScreenState extends State<GspScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedUserType;

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
            // ---------------------------------------------------------
            // HERO SECTION
            // ---------------------------------------------------------
            Container(
              width: double.infinity,
              color: const Color(0xFF790000),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Trusted Insurance\nConsulting Partner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'They analyze existing insurance policies or help clients select the most suitable policies for health, life, property, liability, and auto insurance.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Open GSP Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JscApplicationForm(
                              applicationType: 'GSP',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB83F),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Open Your GSP Account',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------
                  // QUOTE BOX 1
                  // ---------------------------------------------------
                  _quoteBox('"Start with ₹1,475.69. Build a Golden Future"'),

                  const SizedBox(height: 12),

                  // ---------------------------------------------------
                  // QUOTE BOX 2
                  // ---------------------------------------------------
                  _quoteBox(
                    '"Small Savings Today, Golden Opportunities Tomorrow."',
                  ),

                  const SizedBox(height: 12),

                  // ---------------------------------------------------
                  // QUOTE BOX 3
                  // ---------------------------------------------------
                  _quoteBox(
                    '"Junu Bullion GSP – Making Gold Ownership Simple and Affordable."',
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------------
            // GSP INFORMATION CARD
            // ---------------------------------------------------------
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 16, 14, 20),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFCF6),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Junu Bullion Gold Savings Plan',
                    style: TextStyle(
                      color: Color(0xFF981B1B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'The Junu Bullion Gold Savings Plan (GSP) is a smart and affordable savings program that allows customers to accumulate gold gradually through regular savings. Starting from only ₹1,475.69 (equivalent to S\$20.00), GSP helps individuals and families build long-term wealth, protect their savings from inflation, and achieve important financial goals.',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Whether you are planning for your child\'s education, retirement, wealth preservation, or future investments, GSP provides a simple and disciplined way to own gold over time.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Start Small, Grow Big\nStart Your Gold Savings Journey Today',
              style: TextStyle(color: AppColors.primaryRed, fontSize: 20),
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
                      child: Text(
                        "No GSP products available.",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gspProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 18,
                          childAspectRatio: .60,
                        ),
                    itemBuilder: (context, index) {
                      final product = gspProducts[index];
                      log(
                        "gspProducts $gspProducts..............///..........${gspProducts.length}",
                      );

                      return _GspProductCard(product: product);
                    },
                  ),
                );
              },
            ),
            _buildProductDescription(),
            _buildCustomerBenefits(),
            _buildWhoItUseFor(),
            _buildPlanFeatures(),
            _buildHowMoneyConverts(),
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

  Widget _buildHowMoneyConverts() {
    final conversions = [
      {'amount': '₹1,501.48', 'sgd': 'SGD 20', 'gold': '≈ 0.1g gold'},
      {'amount': '₹7,507.41', 'sgd': 'SGD 100', 'gold': '≈ 0.5g gold'},
      {'amount': '₹37,537.04', 'sgd': 'SGD 500', 'gold': '≈ 2.5g gold'},
      {'amount': '₹375,370.39', 'sgd': 'SGD 5,000', 'gold': '≈ 25g gold'},
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 45),
      child: Column(
        children: [
          const Text(
            'How Your Money Converts',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 25),

          // -------------------------------------------------------
          // CONVERSION CARDS
          // -------------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (int i = 0; i < conversions.length; i++) ...[
                  _buildConversionCard(
                    amount: conversions[i]['amount']!,
                    sgd: conversions[i]['sgd']!,
                    gold: conversions[i]['gold']!,
                  ),

                  if (i != conversions.length - 1) const SizedBox(width: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionCard({
    required String amount,
    required String sgd,
    required String gold,
  }) {
    return Container(
      width: 228,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFA90000),
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // -------------------------------------------------------
          // INR AMOUNT
          // -------------------------------------------------------
          Text(
            amount,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFD33D),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),

          // -------------------------------------------------------
          // SGD AMOUNT
          // -------------------------------------------------------
          Text(
            sgd,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFD33D),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),

          // -------------------------------------------------------
          // DOWN ARROW
          // -------------------------------------------------------
          const Icon(Icons.arrow_downward, color: Color(0xFFFFD33D), size: 23),

          // -------------------------------------------------------
          // GOLD VALUE
          // -------------------------------------------------------
          Text(
            gold,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeatures() {
    final features = [
      {'title': 'Minimum Start', 'value': 'SGD 20'},
      {'title': 'Currency Input', 'value': 'INR (based on SGD 20)'},
      {'title': 'Gold Conversion', 'value': 'Live market rate, per gram'},
      {
        'title': 'Physical Withdrawal',
        'value': 'Available from 50g accumulated',
      },
      {'title': 'Sell Back to Junu', 'value': 'Available from 50g accumulated'},
      {'title': 'Storage', 'value': 'Secure Singapore vault — fully insured'},
      {'title': 'Platform Access', 'value': 'Online, 24/7 worldwide access'},
      {'title': 'Gold Purity', 'value': '999.9 fine gold (24-karat)'},
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 45),
      child: Column(
        children: [
          const Text(
            'Plan Features at a Glance',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 25),

          // -------------------------------------------------------
          // FEATURES - ONE BY ONE
          // -------------------------------------------------------
          Column(
            children: [
              for (int i = 0; i < features.length; i++) ...[
                _buildPlanFeatureItem(
                  title: features[i]['title']!,
                  value: features[i]['value']!,
                ),

                if (i != features.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeatureItem({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E3D5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------
          // GOLD DOT
          // -------------------------------------------------------
          Container(
            width: 13,
            height: 13,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD3AA21),
            ),
          ),

          const SizedBox(width: 12),

          // -------------------------------------------------------
          // TEXT
          // -------------------------------------------------------
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhoItUseFor() {
    final users = [
      {
        'title': 'Young professionals',
        'description':
            "Add gold savings to your monthly budget with no commitment. Each contribution compounds with gold's long-term appreciation.",
      },
      {
        'title': "Parents saving for children's future",
        'description':
            "Start building real wealth before you graduate. ₹1,501.48 is less than a meal out — with GSP, it becomes a fraction of gold that grows over time.",
      },
      {
        'title': 'Families seeking wealth protection',
        'description':
            "Save in gold for your children's education or family milestones. Gold is a stable, multi-generational store of value.",
      },
      {
        'title': 'First-time gold investors',
        'description':
            'GSP removes investing complexity. No ETFs or futures needed just save in SGD and receive fractional gold. Simple and transparent.',
      },
      {
        'title': 'Individuals planning for retirement',
        'description':
            "Save in gold for your children's education or family milestones. Gold is a stable, multi-generational store of value.",
      },
      {
        'title': 'Anyone looking to accumulate physical gold gradually.',
        'description':
            'Protect income against currency fluctuations. Gold transcends borders — your savings remain globally relevant and transferable.',
      },
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who It Use For',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              // Desktop/tablet: two columns
              if (constraints.maxWidth >= 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 0; i < 3; i++)
                            _buildUserTypeItem(
                              index: i,
                              title: users[i]['title']!,
                              description: users[i]['description']!,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 3; i < 6; i++)
                            _buildUserTypeItem(
                              index: i,
                              title: users[i]['title']!,
                              description: users[i]['description']!,
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Mobile: one column
              return Column(
                children: [
                  for (int i = 0; i < users.length; i++)
                    _buildUserTypeItem(
                      index: i,
                      title: users[i]['title']!,
                      description: users[i]['description']!,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeItem({
    required int index,
    required String title,
    required String description,
  }) {
    final bool isSelected = _selectedUserType == index;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              // Clicking the currently open item closes it.
              // Clicking another item closes the previous one
              // and opens the new one.
              _selectedUserType = isSelected ? null : index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.favorite_border,
                  color: AppColors.primaryRed,
                  size: 22,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---------------------------------------------------------
        // DESCRIPTION
        // ---------------------------------------------------------
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 10, 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                description,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ),
          ),
          crossFadeState: isSelected
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        // ---------------------------------------------------------
        // DIVIDER
        // ---------------------------------------------------------
        Container(height: 1, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildCustomerBenefits() {
    final benefits = [
      {
        'icon': Icons.savings_outlined,
        'title': 'Affordable Start',
        'description':
            'Begin your gold savings journey with only S\$20, making gold ownership accessible to everyone.',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Protection Against Inflation',
        'description':
            'Gold has traditionally been considered a store of value, helping preserve purchasing power over the long term.',
      },
      {
        'icon': Icons.family_restroom_outlined,
        'title': "Children's Education Fund",
        'description':
            'Build a dedicated savings plan to support future education expenses and important life milestones.',
      },
      {
        'icon': Icons.elderly_outlined,
        'title': 'Retirement Planning',
        'description':
            'Create a gold-based retirement reserve through consistent monthly savings.',
      },
      {
        'icon': Icons.business_center_outlined,
        'title': 'Disciplined Wealth Building',
        'description':
            'Regular savings encourage good financial habits and long-term wealth accumulation.',
      },
      {
        'icon': Icons.trending_up_outlined,
        'title': 'Flexible Investment',
        'description':
            'Increase your monthly savings amount whenever your financial situation allows.',
      },
      {
        'icon': Icons.eco_outlined,
        'title': 'Long-Term Asset Growth',
        'description':
            'Gradually accumulate gold and build a tangible asset for the future.',
      },
      {
        'icon': Icons.home_outlined,
        'title': 'Family Financial Security',
        'description':
            'Gradually accumulate gold and build a tangible asset for the future.',
      },
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFAF8),
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 45),
      child: Column(
        children: [
          const Text(
            'Customer Benefits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryRed,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 285,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < benefits.length; i++) ...[
                    _buildBenefitCard(
                      icon: benefits[i]['icon'] as IconData,
                      title: benefits[i]['title'] as String,
                      description: benefits[i]['description'] as String,
                    ),

                    if (i != benefits.length - 1) const SizedBox(width: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 215,
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryRed, width: 1),
      ),
      child: Column(
        children: [
          // -------------------------------------------------------
          // ICON CIRCLE
          // -------------------------------------------------------
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF9E9E7),
            ),
            child: Icon(icon, size: 42, color: Colors.black),
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------
          // TITLE
          // -------------------------------------------------------
          SizedBox(
            height: 44,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // -------------------------------------------------------
          // DESCRIPTION
          // -------------------------------------------------------
          Expanded(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quoteBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF850000),
        border: Border.all(color: const Color(0xFFFFB800), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withOpacity(0.45),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: Color(0xFFFFC400),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
      ),
    );
  }

  Widget _buildProductDescription() {
    final features = [
      {
        'icon': Icons.touch_app_outlined,
        'title': 'Start saving from as little as SGD 20',
      },
      {
        'icon': Icons.code,
        'title': 'Accumulate gold regularly without a large initial investment',
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Build a long-term savings portfolio backed by gold',
      },
      {
        'icon': Icons.desktop_windows_outlined,
        'title': 'Enjoy a flexible and convenient savings approach',
      },
      {
        'icon': Icons.headset_mic_outlined,
        'title': 'Monitor their growing gold holdings over time',
      },
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF951B1F),
      padding: const EdgeInsets.fromLTRB(30, 50, 30, 45),
      child: Column(
        children: [
          const Text(
            'Product Description',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'With Junu Bullion GSP, customers can:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'GSP is designed for anyone who wants to convert small regular savings into a valuable long-term asset.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------
          // HORIZONTAL SCROLLABLE FEATURES
          // -------------------------------------------------------
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < features.length; i++) ...[
                    SizedBox(
                      width: 100,
                      child: _buildDescriptionFeature(
                        icon: features[i]['icon'] as IconData,
                        title: features[i]['title'] as String,
                      ),
                    ),

                    if (i != features.length - 1) const SizedBox(width: 18),
                  ],
                ],
              ),
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

        Text(
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

  static const String imageBaseUrl = 'https://staging.junubullion.com/storage/';

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
          // ==========================================================
          // IMAGE
          // ==========================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(height: 10),

          // ==========================================================
          // PRODUCT NAME
          // ==========================================================
          Text(
            productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 5),

          // ==========================================================
          // PRICE
          // ==========================================================
          Text(
            priceText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          // ==========================================================
          // STOCK STATUS
          // ==========================================================
          Text(
            isInStock ? "In Stock" : "Out of Stock",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isInStock ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(height: 5),

          // ==========================================================
          // CART BUTTON
          // ==========================================================
          SizedBox(
            width: double.infinity,
            height: 45,
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
    );
  }

  Widget _buildCartButton({
    required BuildContext context,
    required CartProvider cartProvider,
    required PhysicalConversionProvider physicalProvider,
    required int productId,
    required bool isInStock,
  }) {
    // ================================================================
    // OUT OF STOCK
    // ================================================================

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
        child: const Text(
          "OUT OF STOCK",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
    }

    // ================================================================
    // PHYSICAL CONVERSION ACTIVE
    //
    // JSC products are digital products.
    // They must NOT be added while physical conversion is active.
    //
    // IMPORTANT:
    // We are NOT using physicalCart here.
    // ================================================================

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
        child: const Text(
          "ADD TO CART",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // ================================================================
    // NORMAL CART
    // ================================================================

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

    // ================================================================
    // ALREADY IN NORMAL CART
    // ================================================================

    if (isInCart && cartQuantity > 0) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --------------------------------------------------------
            // MINUS
            // --------------------------------------------------------
            InkWell(
              onTap: () async {
                if (cartQuantity <= 1) {
                  await cartProvider.removeFromCart(productId);
                } else {
                  await cartProvider.updateCartQuantity(
                    productId: productId,
                    quantity: cartQuantity - 1,
                  );
                }
              },
              child: const SizedBox(
                width: 40,
                height: 45,
                child: Center(
                  child: Icon(Icons.remove, color: Colors.white, size: 20),
                ),
              ),
            ),

            // --------------------------------------------------------
            // QUANTITY
            // --------------------------------------------------------
            Text(
              "$cartQuantity",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            // --------------------------------------------------------
            // PLUS
            // --------------------------------------------------------
            InkWell(
              onTap: () async {
                await cartProvider.updateCartQuantity(
                  productId: productId,
                  quantity: cartQuantity + 1,
                );
              },
              child: const SizedBox(
                width: 40,
                height: 45,
                child: Center(
                  child: Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ================================================================
    // ADD TO NORMAL CART
    // ================================================================

    final bool isAdding = cartProvider.isAdding(productId);

    return ElevatedButton(
      onPressed: isAdding
          ? null
          : () async {
              final bool success = await cartProvider.addToCart(
                productId: productId,
                quantity: 1,
              );

              if (!context.mounted) {
                return;
              }

              _showMessage(success ? "Added to Cart" : "Failed to add product");
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
          : const Text(
              "ADD TO CART",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
