import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xffFAFAF8),

      drawer: const CustomDrawer(),

      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TOP BANNER
              // --------------------------------------------------
              Container(
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
                        onPressed: () {
                          // TODO: Navigate to brands
                        },
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

              // --------------------------------------------------
              // BRAND LOGOS
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _brandLogo("assets/b1.png"),
                    _brandLogo("assets/b2.png"),
                    _brandLogo("assets/b3.png"),
                    _brandLogo("assets/b4.png"),
                  ],
                ),
              ),

              // --------------------------------------------------
              // TITLE
              // --------------------------------------------------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TranslatedText(
                  "Why Invest In Trusted Brands?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    final double itemWidth = (constraints.maxWidth - 15) / 2;

                    return Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children:
                          const [
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
                              ]
                              .map(
                                (card) =>
                                    SizedBox(width: itemWidth, child: card),
                              )
                              .toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TranslatedText(
                  "Our Gold & Silver Brands",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
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

  Widget _brandLogo(String asset) {
    return SizedBox(
      width: 65,
      height: 55,
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

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
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
