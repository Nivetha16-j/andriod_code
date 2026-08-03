import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/main.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/profile/dashboard/quickaction.dart';
import 'package:junubullion/widgets/profile/recentorders.dart';
import 'package:junubullion/widgets/profile/dashboard/wallet.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    user = (await SessionManager.getUser())!;
    log("User Data: $user");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

    // final int orderCount = ordersProvider.orders.length;
    // log("orderCount $orderCount");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff9E0E19),
                  Color(0xffC23D22),
                  Color(0xffDD842D),
                ],
              ),
              border: Border.all(color: const Color(0xff7F0D16), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back, ${user['name'] ?? 'User'}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Your Personal Hub For Orders, Account Settings,\nAnd Verification — All In One Place.",
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _InfoButton(
                        image: "assets/order_count.png",
                        title: "${ordersProvider.totalOrders} Orders",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoButton(
                        image: "assets/kyc.png",
                        title: "KYC Required",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const WalletSection(),

          const SizedBox(height: 18),

          const QuickActionsSection(),

          const SizedBox(height: 18),

          const RecentOrdersSection(showAll: false),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final String image;
  final String title;

  const _InfoButton({required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.15),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 20, width: 20, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
