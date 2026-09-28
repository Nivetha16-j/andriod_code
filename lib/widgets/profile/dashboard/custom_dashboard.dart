import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/kyc_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/profile/dashboard/quickaction.dart';
import 'package:junubullion/widgets/profile/dashboard/wallet.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
import 'package:junubullion/widgets/profile/recentorders.dart';
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
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KycProvider>().fetchKycDetails();
    });
  }

  Future<void> _loadUser() async {
    user = (await SessionManager.getUser())!;
    log("User Data: $user");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final kycProvider = context.watch<KycProvider>();
    final kycLabel = kycProvider.kycApproved ? "KYC Approved" : "KYC Required";

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.BgGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: AppColors.BgGradient,
                border: Border.all(color: AppColors.primaryRed, width: 1.5),
                boxShadow: const [
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
                  TranslatedText(
                    "Welcome Back, ${user['name'] ?? 'User'}",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const TranslatedText(
                    "Your Personal Hub For Orders, Account Settings, And Verification — All In One Place.",
                    style: TextStyle(
                      color: AppColors.white,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoButton(
                          image: "assets/order.png",
                          title: "${ordersProvider.totalOrders} Orders",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoButton(
                          image: "assets/kyc.png",
                          title: kycLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!kycProvider.kycApproved) ...[
              const SizedBox(height: 16),
              _KycRequiredBanner(
                onComplete: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const KycVerificationCard(),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 16),
            const WalletSection(),
            const SizedBox(height: 18),
            const QuickActionsSection(),
            const SizedBox(height: 18),
            const RecentOrdersSection(showAll: false),
          ],
        ),
      ),
    );
  }
}

class _KycRequiredBanner extends StatelessWidget {
  final VoidCallback onComplete;

  const _KycRequiredBanner({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.pinkGradient,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: AppColors.mustard.withValues(alpha: .55)),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.mustard.withValues(alpha: .18),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/verification.png"),
              const SizedBox(width: 10),
              const Expanded(
                child: TranslatedText(
                  "KYC Verification Required",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const TranslatedText(
            "KYC verification is required before you can access certain services or complete transactions. Please upload valid identification documents for verification. The review process may take 1-3 business days. You will be notified once your KYC has been reviewed and approved.",
            style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.red),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onComplete,

              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset("assets/complete.png"),
                  SizedBox(width: 5),
                  const TranslatedText(
                    "Complete KYC Now",
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.white.withValues(alpha: .18),
        border: Border.all(color: AppColors.white.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 18, width: 18, color: AppColors.white),
          const SizedBox(width: 6),
          Flexible(
            child: TranslatedText(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
