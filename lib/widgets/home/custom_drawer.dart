import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/menu/aboutus.dart';
import 'package:junubullion/screens/menu/contactus.dart';
import 'package:junubullion/screens/menu/faq.dart';
import 'package:junubullion/screens/menu/privacy.dart';
import 'package:junubullion/screens/menu/testimonials.dart';
import 'package:junubullion/screens/plans/form.dart';
import 'package:junubullion/screens/plans/gsp/gsp_dashboard.dart';
import 'package:junubullion/screens/plans/gsp/gsp_details.dart';
import 'package:junubullion/screens/plans/jsc/jsc_dashboard.dart';
import 'package:junubullion/screens/plans/jsc/jsc_details.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  static const Color accentGold = Color(0xFFE4B42D);

  bool isJscExpanded = false;
  bool isGspExpanded = false;

  bool hasJscRegistration = false;
  bool hasGspRegistration = false;
  bool isLoadingApplication = true;

  @override
  initState() {
    super.initState();
    _checkJscRegistration();
    _checkGspRegistration();
  }

  Future<void> _checkJscRegistration() async {
    try {
      final result = await JscService.getApplication(applicationType: 'JSC');

      if (!mounted) return;

      setState(() {
        hasJscRegistration = result["hasRegistration"] == true;
        isLoadingApplication = false;
      });
    } catch (e) {
      debugPrint('JSC registration check error: $e');

      if (!mounted) return;

      setState(() {
        hasJscRegistration = false;
        isLoadingApplication = false;
      });
    }
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
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        color: AppColors.primaryRed,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    // =========================
                    // JSC DROPDOWN
                    // =========================
                    _drawerExpansionTile(
                      icon: Icons.money,
                      title: "JSC",
                      isExpanded: isJscExpanded,
                      onExpansionChanged: (value) {
                        setState(() {
                          isJscExpanded = value;

                          // Close GSP when JSC opens
                          if (value) {
                            isGspExpanded = false;
                          }
                        });
                      },
                      children: [
                        _subMenuTile(
                          title: "Bullion Dashboard",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => JscDashboardScreen(),
                              ),
                            );
                          },
                        ),
                        _subMenuTile(
                          title: "Future With JSC",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => JscScreen()),
                            );
                          },
                        ),
                        _subMenuTile(
                          title: "JSC Application Form",
                          onTap: () {
                            hasJscRegistration
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ApplicationForm(
                                        isEdit: true,
                                        applicationType: 'JSC',
                                      ),
                                    ),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicationForm(
                                        applicationType: 'JSC',
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ],
                    ),

                    // =========================
                    // GSP DROPDOWN
                    // =========================
                    _drawerExpansionTile(
                      icon: Icons.money_outlined,
                      title: "GSP",
                      isExpanded: isGspExpanded,
                      onExpansionChanged: (value) {
                        setState(() {
                          isGspExpanded = value;

                          // Close JSC when GSP opens
                          if (value) {
                            isJscExpanded = false;
                          }
                        });
                      },
                      children: [
                        _subMenuTile(
                          title: "GSP Dashboard",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => GspDashboardScreen(),
                              ),
                            );
                          },
                        ),
                        _subMenuTile(
                          title: "Know More About GSP",
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => GspScreen()),
                            );
                          },
                        ),
                        _subMenuTile(
                          title: "GSP Application Form",
                          onTap: () {
                            hasGspRegistration
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ApplicationForm(
                                        isEdit: true,
                                        applicationType: 'GSP',
                                      ),
                                    ),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicationForm(
                                        applicationType: 'GSP',
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ],
                    ),

                    // =========================
                    // ABOUT US
                    // =========================
                    _drawerTile(
                      context,
                      icon: Icons.info_outline,
                      title: "About us",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutUsScreen(),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // CONTACT US
                    // =========================
                    _drawerTile(
                      context,
                      icon: Icons.call_outlined,
                      title: "Contact Us",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ContactUsScreen()),
                        );
                      },
                    ),

                    // =========================
                    // FAQ
                    // =========================
                    _drawerTile(
                      context,
                      icon: Icons.help_outline,
                      title: "FAQ",
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => FaqScreen()));
                      },
                    ),

                    // =========================
                    // PRIVACY
                    // =========================
                    _drawerTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy & More",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // TESTIMONIAL
                    // =========================
                    _drawerTile(
                      context,
                      icon: Icons.star_border,
                      title: "Testimonial",
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ReviewsScreen()),
                        );
                      },
                    ),

                    // const SizedBox(height: 15),

                    // =========================
                    // CURRENCY
                    // =========================
                    _buildCurrencySelector(context),

                    const SizedBox(height: 30),

                    // =========================
                    // ADDRESS CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(153, 30, 30, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.location_on, color: accentGold, size: 34),
                          SizedBox(height: 12),
                          TranslatedText(
                            "10 Anson Road\n"
                            "02-91A International Plaza\n"
                            "Singapore - 079903",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 20),
                          Icon(Icons.phone, color: accentGold),
                          SizedBox(height: 8),
                          TranslatedText(
                            "+65 83125775",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const TranslatedText(
                      "Connect with Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(height: 1, color: accentGold),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/telegram.png",
                          width: 40,
                          height: 40,
                        ),
                        Image.asset("assets/fb.png", width: 40, height: 40),
                        Image.asset("assets/insta.png", width: 40, height: 40),
                        Image.asset(
                          "assets/youtube.png",
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPANSION TILE - JSC / GSP
  // ============================================================

  Widget _buildCurrencySelector(BuildContext context) {
    const List<String> currencies = [
      'USD',
      'SGD',
      'CAD',
      'INR',
      'EUR',
      'AED',
      'CNY',
    ];

    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Row(
            children: [
              const Icon(Icons.currency_exchange, color: accentGold, size: 20),

              const SizedBox(width: 15),

              const Expanded(
                child: TranslatedText(
                  'Currency',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        currencies.contains(currencyProvider.selectedCurrency)
                        ? currencyProvider.selectedCurrency
                        : currencies.first,

                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                    ),

                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),

                    onChanged: (String? value) {
                      if (value != null) {
                        currencyProvider.changeCurrency(value);

                        debugPrint('Currency changed to: $value');
                      }
                    },

                    items: currencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerExpansionTile({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,

        leading: Icon(icon, color: accentGold),

        title: TranslatedText(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),

        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: accentGold,
        ),

        childrenPadding: const EdgeInsets.only(left: 48, bottom: 8),

        children: children,
      ),
    );
  }

  // ============================================================
  // SUB MENU
  // ============================================================

  Widget _subMenuTile({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: accentGold,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TranslatedText(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL DRAWER TILE
  // ============================================================

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: Icon(icon, color: accentGold),

      title: TranslatedText(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),

      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
