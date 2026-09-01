import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/plans/gsp/gsp_convert_to_physical.dart';
import 'package:junubullion/screens/plans/gsp/gsp_dashboard.dart';
import 'package:junubullion/screens/plans/gsp/gsp_purchases.dart';
import 'package:junubullion/screens/plans/gsp/gsp_sellback.dart';
import 'package:junubullion/screens/plans/gsp/gsp_transaction.dart';
import 'package:junubullion/screens/plans/gsp/gsp_wallet.dart';
import 'package:junubullion/screens/plans/jsc/jsc_convert_to_physical.dart';
import 'package:junubullion/screens/plans/jsc/jsc_dashboard.dart';
import 'package:junubullion/screens/plans/jsc/jsc_purchases.dart';
import 'package:junubullion/screens/plans/jsc/jsc_sellback.dart';
import 'package:junubullion/screens/plans/sidemenu.dart';
import 'package:junubullion/screens/plans/jsc/jsc_transaction.dart';
import 'package:junubullion/screens/plans/jsc/jsc_wallet.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/profile/account_details.dart';
import 'package:provider/provider.dart';

class PlansLayout extends StatelessWidget {
  final Plans plans;
  final String selectedMenu;
  final Widget child;

  const PlansLayout({
    super.key,
    required this.plans,
    required this.selectedMenu,
    required this.child,
  });

  bool get isJsc => plans == Plans.jsc;
  bool get isGsp => plans == Plans.gsp;

  Future<void> _handleMenuTap(BuildContext context, String menu) async {
    if (menu == selectedMenu) {
      return;
    }

    switch (menu) {
      case 'Dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isJsc ? const JscDashboardScreen() : const GspDashboardScreen(),
          ),
        );
        break;

      case 'My Wallet':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isJsc ? const JscWalletScreen() : const GspWalletScreen(),
          ),
        );
        break;

      case 'Your Purchases':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isJsc ? const JscPurchasesScreen() : const GspPurchasesScreen(),
          ),
        );
        break;

      case 'Account Details':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
        );
        break;

      case 'Transaction History':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isJsc
                ? const JscTransactionHistoryScreen()
                : const GspTransactionHistoryScreen(),
          ),
        );
        break;

      case 'Convert to Physical':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isJsc
                ? const JscConvertToPhysicalScreen()
                : const GspConvertToPhysicalScreen(),
          ),
        );
        break;

      case 'Monthly Investment Plan':
        if (isGsp) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GspDashboardScreen()),
          );
        }
        break;

      case 'Sell Back Request':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isJsc ? const JscSellBackScreen() : const GspSellBackScreen(),
          ),
        );
        break;

      case 'Lost Password':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
        );
        break;

      case 'Logout':
        await _logout(context);
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xffF7F7F7),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to Log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes", style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    if (context.mounted) {
      context.read<JscBalanceProvider>().clearUnlockStatus();
    }

    await SessionManager.logout();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F0),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlansSidebar(
              selectedMenu: selectedMenu,
              onMenuTap: (menu) {
                _handleMenuTap(context, menu);
              },
              plans: plans,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
