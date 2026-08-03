import 'package:flutter/material.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
import 'package:junubullion/widgets/profile/recentorders.dart';
import 'package:provider/provider.dart';

class WalletSection extends StatelessWidget {
  const WalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

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
                  image: "assets/order.png",
                  title: "${ordersProvider.totalOrders} Orders",
                  subtitle: "Total orders",
                  description: "View orders",
                  colors: const [Color(0xffB5141D), Color(0xffDB2727)],
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
                  title: "KYC Required",
                  subtitle: "Verification status",
                  description: "Manage KYC",
                  colors: const [Color(0xffD47A00), Color(0xffF5B53C)],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 14),

        ShopCard(),
      ],
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> colors;

  const DashboardCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                image,
                color: Colors.white,
                height: 10,
                width: 10,
              ),
            ),
          ),

          // const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),

          const SizedBox(height: 2),

          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        height: 95,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff304E9D), Color(0xff6875E6)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/shop.png",
                  color: Colors.white,
                  height: 10,
                  width: 10,
                ),
              ),
            ),

            const SizedBox(width: 18),

            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Gold, silver & bullion",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Browse products",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
