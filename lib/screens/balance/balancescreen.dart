import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.BgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // =========================
                // TOTAL DIGITAL BALANCE
                // =========================
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                    gradient: AppColors.BgGradient,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "TOTAL DIGITAL BALANCE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "\$1000.25",
                        style: TextStyle(
                          color: AppColors.mustard,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      ElevatedButton(
                        onPressed: () {
                          // Start investing
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "START INVESTING",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // =========================
                // OUR SCHEMES
                // =========================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Our Schemes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // GSP
                // =========================
                _SchemeCard(
                  title: "GSP Gold Savings Passbook",
                  balanceLabel: "GSP Balance",
                  balance: "\$21,120.00",
                  profit: "+\$120.86",
                  profitPercentage: "-\$120.86 %",
                  ownedText: "Total Gold Owned: 42.56g",
                  image: "assets/images/gold_bars.png",
                  isGsp: true,

                  onKnowMore: () {
                    // Navigate to GSP
                  },
                ),

                const SizedBox(height: 9),

                // =========================
                // JSC
                // =========================
                _SchemeCard(
                  title: "JSC Junu Saving Capital",
                  balanceLabel: "JSC Balance",
                  balance: "\$21,120.00",
                  profit: "+\$120.86",
                  profitPercentage: "-\$120.86 %",
                  ownedText: "Total Gold Owned: 42.56g",
                  image: "assets/images/silver_bars.png",
                  isGsp: false,
                  onKnowMore: () {
                    // Navigate to JSC
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// SCHEME CARD
// =====================================================

class _SchemeCard extends StatelessWidget {
  final String title;
  final String balanceLabel;
  final String balance;
  final String profit;
  final String profitPercentage;
  final String ownedText;
  final String image;
  final bool isGsp;
  final VoidCallback onKnowMore;

  const _SchemeCard({
    required this.title,
    required this.balanceLabel,
    required this.balance,
    required this.profit,
    required this.profitPercentage,
    required this.ownedText,
    required this.image,
    required this.isGsp,
    required this.onKnowMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 155),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        // border: Border.all(color: Colors.white.withOpacity(0.35), width: 0.7),
        gradient: isGsp ? AppColors.gspGradient : AppColors.jscGradient,
      ),
      child: Stack(
        children: [
          // =========================
          // DECORATIVE CIRCLE
          // // =========================
          // Positioned(
          //   right: -25,
          //   bottom: -25,
          //   child: Container(
          //     width: 120,
          //     height: 120,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.white.withOpacity(0.025),
          //     ),
          //   ),
          // ),

          // =========================
          // MAIN CONTENT
          // =========================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =================================================
                // LEFT SIDE - IMAGE
                // =================================================
                SizedBox(
                  width: 70,
                  child: Center(
                    child: Image.asset(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isGsp ? Icons.view_in_ar : Icons.layers,
                          color: Colors.white70,
                          size: 42,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // RIGHT SIDE - ALL CONTENT
                // =================================================
                Expanded(
                  child: SizedBox(
                    height: 135,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // =========================
                        // TITLE
                        // =========================
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // =========================
                        // BALANCE LABEL + PROFIT
                        // =========================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                balanceLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                            // const SizedBox(width: 8),
                            Text(
                              profit,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // =========================
                        // BALANCE + PROFIT %
                        // =========================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                balance,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // const SizedBox(width: 8),
                            Text(
                              profitPercentage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // =========================
                        // TOTAL GOLD
                        // =========================
                        Text(
                          ownedText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                          ),
                        ),

                        // =========================
                        // KNOW MORE BUTTON
                        // =========================
                        ElevatedButton(
                          onPressed: onKnowMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mustard,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              "Know More",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
