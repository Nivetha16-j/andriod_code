import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:junubullion/providers/convert_physical_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/jsc/jsc_convert_to_physical.dart';
import 'package:junubullion/screens/jsc/jsc_dashboard.dart';
import 'package:junubullion/screens/jsc/jsc_purchases.dart';
import 'package:junubullion/screens/jsc/jsc_sellback.dart';
import 'package:junubullion/screens/jsc/jsc_sidemenu.dart';
import 'package:junubullion/screens/jsc/jsc_transaction.dart';
import 'package:junubullion/screens/jsc/jsc_wallet.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/jsc/jsc_convert_to_physical_section.dart';
import 'package:junubullion/widgets/profile/account_details.dart';
import 'package:provider/provider.dart';

class JscLayout extends StatelessWidget {
  final String selectedMenu;
  final Widget child;

  const JscLayout({super.key, required this.selectedMenu, required this.child});

  Future<void> _handleMenuTap(BuildContext context, String menu) async {
    // Don't navigate if already on the same screen
    if (menu == selectedMenu) {
      return;
    }

    switch (menu) {
      case 'Dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JscDashboardScreen()),
        );
        break;

      case 'My Wallet':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JscWalletScreen()),
        );
        break;

      case 'Your Purchases':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JscPurchasesScreen()),
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
            builder: (_) => const JscTransactionHistoryScreen(),
          ),
        );
        break;

      case 'Convert to Physical':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JscConvertToPhysicalScreen()),
        );
        break;

      case 'Sell Back Request':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JscSellBackScreen()),
        );
        // Navigate to Sell Back Request
        break;

      case 'Lost Password':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
        );
        // Navigate to Lost Password
        break;

      case 'Logout':
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
                child: Text(
                  "Yes",
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ),
            ],
          ),
        );

        if (shouldLogout == true) {
          context.read<ConvertPhysicalProvider>().clear();
          await SessionManager.logout();

          // Reset the in-memory state for all JSC balance sections
          balanceUnlockedNotifier.value = false;

          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        }
        break;
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
            JscSidebar(
              selectedMenu: selectedMenu,
              onMenuTap: (menu) {
                _handleMenuTap(context, menu);
              },
            ),

            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
