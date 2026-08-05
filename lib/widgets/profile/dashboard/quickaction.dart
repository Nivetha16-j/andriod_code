import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/theme/app_colors.dart';
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
            Icon(Icons.bolt, color: AppColors.primaryRed),
            SizedBox(width: 6),
            Text(
              "Quick actions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),

        const SizedBox(height: 18),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: .9,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()),
                );
              },
              child: ActionTile(
                "assets/orders.png",
                "Orders",
                "View order history and payment status.",
                gradientColors: [Color(0xff991E1E), Color(0xffEA7676)],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressSection()),
                );
              },
              child: ActionTile(
                "assets/addresses.png",
                "Addresses",
                "Update your shipping address.",
                gradientColors: [Color(0xff2563EB), Color(0xffEBF0FC)],
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
              child: ActionTile(
                "assets/acc_details.png",
                "Account details",
                "Edit your profile and password.",
                gradientColors: [Color(0xff7C3AED), Color(0xffC8B1F1)],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                // );
              },
              child: ActionTile(
                "assets/payment_methods.png",
                "Payment methods",
                "Manage saved payment options",
                gradientColors: [Color(0xff059669), Color(0xffBAFBE7)],
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
              child: ActionTile(
                "assets/kyc_required.png",
                "KYC Verification",
                "Upload identification documents for verification",
                gradientColors: [Color(0xffD97706), Color(0xffFFDBB1)],
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
              child: ActionTile(
                "assets/shop_products.png",
                "Shop products",
                "Browse gold, silver, and bullion products.",
                gradientColors: [Color(0xffC2410C), Color(0xffFCB091)],
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
  final List<Color> gradientColors;

  const ActionTile(
    this.image,
    this.title,
    this.description, {
    super.key,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Center(
                child: Image.asset(
                  image,
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
              ),
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),

            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
