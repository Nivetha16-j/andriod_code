import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/profile/account_details.dart';
import 'package:junubullion/widgets/profile/addresses.dart';
import 'package:junubullion/widgets/profile/kyc.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            TranslatedText(
              "Quick actions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()),
                );
              },
              child: const ActionTile(
                "assets/orders.png",
                "Orders",
                "View order history and payment status.",
                // gradientColors: [AppColors.primaryRed, AppColors.lightRed],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressSection()),
                );
              },
              child: const ActionTile(
                "assets/blueadd.png",
                "Addresses",
                "Update your shipping address.",
                // gradientColors: [AppColors.red, AppColors.pink],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountDetailsScreen(),
                  ),
                );
              },
              child: const ActionTile(
                "assets/accdet.png",
                "Account details",
                "Edit your profile and password.",
                // gradientColors: [AppColors.primaryRed, AppColors.mustard],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                // );
              },
              child: const ActionTile(
                "assets/pay.png",
                "Payment methods",
                "Manage saved payment options",
                // gradientColors: [AppColors.green, AppColors.offWhite],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KycVerificationCard(),
                  ),
                );
              },
              child: const ActionTile(
                "assets/kyc_verification.png",
                "KYC Verification",
                "Upload identification documents for verification",
                // gradientColors: [AppColors.mustard, AppColors.yellow],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
              child: const ActionTile(
                "assets/prod.png",
                "Shop products",
                "Browse gold, silver, and bullion products.",
                // gradientColors: [AppColors.red, AppColors.mustard],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActionTile extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  // final List<Color> gradientColors;

  const ActionTile(
    this.image,
    this.title,
    this.description, {
    super.key,
    // required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.sandal,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.black.withValues(alpha: .08),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                image,
                width: 24,
                height: 24,
                // color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            TranslatedText(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TranslatedText(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
