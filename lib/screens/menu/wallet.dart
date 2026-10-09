import 'package:flutter/material.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/form.dart';
import 'package:junubullion/screens/plans/gsp/gsp_monthly_investment_plan.dart';
import 'package:junubullion/screens/plans/jsc/jsc_convert_to_physical.dart';
import 'package:junubullion/screens/plans/jsc/jsc_dashboard.dart';
import 'package:junubullion/screens/plans/jsc/jsc_purchases.dart';
import 'package:junubullion/screens/plans/jsc/jsc_sellback.dart';
import 'package:junubullion/screens/plans/jsc/jsc_transaction.dart';
import 'package:junubullion/screens/plans/jsc/jsc_wallet.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/profile/account_details.dart';

class CustomWallet extends StatefulWidget {
  const CustomWallet({super.key});

  @override
  State<CustomWallet> createState() => _CustomWalletState();
}

class _CustomWalletState extends State<CustomWallet> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;
  bool _isJscExpanded = false;
  bool _isGspExpanded = false;

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.BgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PAGE TITLE
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Wallet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                WalletMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscDashboardScreen(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'My Wallet',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscWalletScreen(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your Purchases',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscPurchasesScreen(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Transaction History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscTransactionSection(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.currency_exchange,
                  title: 'Convert to Physical',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscConvertToPhysicalScreen(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.handshake_outlined,
                  title: 'Sell Back Request',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JscSellBackScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  "INVESTMENT PLANS",
                  style: TextStyle(
                    color: AppColors.mustard,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                WalletMenuItem(
                  icon: Icons.savings_outlined,
                  title: 'Jsc Bullion Plan',
                  trailing: Icon(
                    _isJscExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 26,
                  ),
                  onTap: () {
                    setState(() {
                      _isJscExpanded = !_isJscExpanded;
                    });
                  },
                ),

                if (_isJscExpanded) ...[
                  WalletSubMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Monthly Investment',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JscDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],

                WalletMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Application Form',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationForm(),
                      ),
                    );
                  },
                ),

                WalletMenuItem(
                  icon: Icons.savings_outlined,
                  title: 'Gsp Savings Plan',
                  trailing: Icon(
                    _isGspExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 26,
                  ),
                  onTap: () {
                    setState(() {
                      _isGspExpanded = !_isGspExpanded;
                    });
                  },
                ),

                if (_isGspExpanded) ...[
                  WalletSubMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Monthly Investment',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GspMonthlyInvestmentPlan(),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 12),

                const Text(
                  "ACCOUNT",
                  style: TextStyle(
                    color: AppColors.mustard,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                WalletMenuItem(
                  icon: Icons.person_outline,
                  title: 'Account Details',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailsScreen(),
                      ),
                    );
                  },
                ),

                // WalletMenuItem(
                //   icon: Icons.lock_reset_outlined,
                //   title: 'Lost Password',
                // ),
                WalletMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        content: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.pinkGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TranslatedText(
                                "Log Out",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              const TranslatedText(
                                "Are you sure you want to Log out?",
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightGrey,
                                      foregroundColor: AppColors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const TranslatedText(
                                      "No",
                                      style: TextStyle(color: AppColors.black),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryRed,
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const TranslatedText(
                                      "Yes",
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (shouldLogout == true) {
                      await SessionManager.logout();

                      balanceUnlockedNotifier.value = false;

                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WalletMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const WalletMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class WalletSubMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const WalletSubMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(left: 20, right: 0, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 19),

            const SizedBox(width: 14),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
