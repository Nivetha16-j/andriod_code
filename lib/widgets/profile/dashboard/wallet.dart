import 'package:flutter/material.dart';
import 'package:junubullion/providers/kyc_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
import 'package:provider/provider.dart';

class WalletSection extends StatelessWidget {
  const WalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final kycProvider = context.watch<KycProvider>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderScreen()),
                  );
                },
                child: DashboardCard(
                  image: "assets/orders.png",
                  title: "${ordersProvider.totalOrders}",
                  subtitle: "Total orders",
                  description: "View orders",
                  gradient: AppColors.pinkGradient,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KycVerificationCard(),
                    ),
                  );
                },
                child: DashboardCard(
                  image: "assets/kyc_required.png",
                  title: kycProvider.kycApproved
                      ? "KYC Approved"
                      : "KYC Required",
                  subtitle: "Verification status",
                  description: "Manage KYC",
                  gradient: AppColors.gspGradient,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const ShopCard(),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final Gradient gradient;

  const DashboardCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(image, height: 35, width: 35),
          const SizedBox(height: 12),
          TranslatedText(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          TranslatedText(
            subtitle,
            style: const TextStyle(color: AppColors.black, fontSize: 12),
          ),
          const SizedBox(height: 2),
          TranslatedText(
            description,
            style: TextStyle(
              color: AppColors.black.withValues(alpha: .75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  const ShopCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)),
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.blueGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset("assets/shop.png"),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TranslatedText(
                    "Shop",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const TranslatedText(
                    "Gold, silver & bullion",
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  TranslatedText(
                    "Browse products",
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: .75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
