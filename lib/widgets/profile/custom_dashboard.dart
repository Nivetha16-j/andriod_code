import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
import 'package:junubullion/widgets/profile/quickaction.dart';
import 'package:junubullion/widgets/profile/recentorders.dart';
import 'package:junubullion/widgets/profile/wallet.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryRed),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 10,
                      bottom: 10,
                    ),
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
                      border: Border.all(
                        color: const Color(0xff7F0D16),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back, Nivi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Your Personal Hub For Orders, Account Settings,\nAnd Verification — All In One Place.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoButton(
                                image: "assets/order_count.png",
                                title: "4 Orders",
                              ),
                            ),
                            SizedBox(width: 5),
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
                  SizedBox(height: 18),
                  KycVerificationCard(),
                  SizedBox(height: 18),
                  WalletSection(),
                  SizedBox(height: 18),
                  QuickActionsSection(),
                  SizedBox(height: 18),
                  RecentOrdersSection(),
                  SizedBox(height: 18),

                  // Wallet
                  // Shop
                  // Quick Actions
                  // Recent Orders
                ],
              ),
            ),
          ),
        ),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(image, height: 20, width: 20, color: Colors.white),
          // const SizedBox(width: 5),
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
