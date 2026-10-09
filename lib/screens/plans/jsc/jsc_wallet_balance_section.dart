import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class JscWalletBalanceSection extends StatefulWidget {
  final String jscGoldBalance;
  final String jscGoldUnit;

  final String jscSilverBalance;
  final String jscSilverUnit;

  final String gspGoldBalance;
  final String gspGoldUnit;

  final String gspSilverBalance;
  final String gspSilverUnit;

  const JscWalletBalanceSection({
    super.key,
    required this.jscGoldBalance,
    required this.jscGoldUnit,
    required this.jscSilverBalance,
    required this.jscSilverUnit,
    required this.gspGoldBalance,
    required this.gspGoldUnit,
    required this.gspSilverBalance,
    required this.gspSilverUnit,
  });

  @override
  State<JscWalletBalanceSection> createState() =>
      _JscWalletBalanceSectionState();
}

class _JscWalletBalanceSectionState extends State<JscWalletBalanceSection> {
  bool isJscSelected = true;

  @override
  Widget build(BuildContext context) {
    final goldBalance = isJscSelected
        ? widget.jscGoldBalance
        : widget.gspGoldBalance;

    final goldUnit = isJscSelected ? widget.jscGoldUnit : widget.gspGoldUnit;

    final silverBalance = isJscSelected
        ? widget.jscSilverBalance
        : widget.gspSilverBalance;

    final silverUnit = isJscSelected
        ? widget.jscSilverUnit
        : widget.gspSilverUnit;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.BgGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isJscSelected = true;
                    });
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isJscSelected
                          ? AppColors.mustard
                          : AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: TranslatedText(
                        'JSC Bullion Wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isJscSelected
                              ? AppColors.black
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isJscSelected = false;
                    });
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: !isJscSelected
                          ? AppColors.mustard
                          : AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: TranslatedText(
                        'GSP Savings Wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: !isJscSelected
                              ? AppColors.black
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _MetalCard(
                  title: "GOLD BALANCE",
                  value: goldBalance,
                  unit: goldUnit,
                  borderColor: AppColors.yellow,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _MetalCard(
                  title: "SILVER BALANCE",
                  value: silverBalance,
                  unit: silverUnit,
                  borderColor: AppColors.lightBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetalCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color borderColor;

  const _MetalCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.BgGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'market value',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
