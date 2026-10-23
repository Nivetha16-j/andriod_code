import 'package:flutter/material.dart';
import 'package:junubullion/screens/plans/gsp/gsp_monthly_investment_plan.dart';
import 'package:junubullion/screens/plans/jsc/jsc_convert_to_physical.dart';
import 'package:junubullion/screens/plans/jsc/jsc_purchases.dart';
import 'package:junubullion/screens/plans/jsc/jsc_sellback.dart';
import 'package:junubullion/screens/plans/jsc/jsc_transaction.dart';
import 'package:junubullion/screens/plans/jsc/jsc_wallet.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/profile/dashboard/wallet.dart';

class QuickActions extends StatefulWidget {
  const QuickActions({super.key});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 10),
          ActionContainers(),
        ],
      ),
    );
  }
}

class ActionContainers extends StatelessWidget {
  const ActionContainers({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        "icon": "assets/ac1.png",
        "title": "View All Balances",
        "route": JscWalletScreen(),
      },
      {
        "icon": "assets/ac2.png",
        "title": "Your Purchases",
        "route": const JscPurchasesScreen(),
      },
      {
        "icon": "assets/ac3.png",
        "title": "Transaction History",
        "route": const JscTransactionSection(),
      },
      {
        "icon": "assets/ac4.png",
        "title": "Convert To Physical",
        "route": const JscConvertToPhysicalScreen(),
      },
      {
        "icon": "assets/ac5.png",
        "title": "Sell Back Request",
        "route": const JscSellBackScreen(),
      },
      {
        "icon": "assets/ac6.png",
        "title": "Gsp Monthly Plan",
        "route": const GspMonthlyInvestmentPlan(),
      },
    ];

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = actions[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item["route"] as Widget),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9A9A), width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(item["icon"] as String, width: 40, height: 40),
                  Spacer(),
                  // const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      item["title"] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
