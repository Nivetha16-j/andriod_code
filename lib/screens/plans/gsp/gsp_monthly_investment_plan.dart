import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/gsp_monthly_plan_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class GspMonthlyInvestmentPlan extends StatefulWidget {
  const GspMonthlyInvestmentPlan({super.key});

  @override
  State<GspMonthlyInvestmentPlan> createState() =>
      _GspMonthlyInvestmentPlanState();
}

class _GspMonthlyInvestmentPlanState extends State<GspMonthlyInvestmentPlan> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: PlansLayout(
        plans: Plans.gsp,
        selectedMenu: 'Monthly Investment Plan',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const GspMonthlyInvestmentPlanContent(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class GspMonthlyInvestmentPlanContent extends StatefulWidget {
  const GspMonthlyInvestmentPlanContent({super.key});

  @override
  State<GspMonthlyInvestmentPlanContent> createState() =>
      _GspMonthlyInvestmentPlanContentState();
}

class _GspMonthlyInvestmentPlanContentState
    extends State<GspMonthlyInvestmentPlanContent> {
  final TextEditingController _amountController = TextEditingController();

  double get minimumInvestment {
    return context
            .read<GspMonthlyPlanProvider>()
            .monthlyPlan
            ?.gspMinimumAmount ??
        0;
  }

  String get currencySymbol {
    return context.read<GspMonthlyPlanProvider>().monthlyPlan?.currencySymbol ??
        '\$';
  }

  double get goldPricePerGram {
    return context.read<GspMonthlyPlanProvider>().monthlyPlan?.pricePerGram ??
        0;
  }

  double get investmentAmount {
    return double.tryParse(_amountController.text) ?? 0;
  }

  double get estimatedGold {
    if (goldPricePerGram <= 0) {
      return 0;
    }

    return investmentAmount / goldPricePerGram;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<GspMonthlyPlanProvider>();
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      await provider.fetchMonthlyPlan(currency: currency);

      if (!mounted) return;

      final minimum = provider.monthlyPlan?.gspMinimumAmount;

      if (minimum != null) {
        _amountController.text = minimum.toStringAsFixed(2);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() {});
  }

  void _payWithStripe() {
    final amount = investmentAmount;

    if (amount < minimumInvestment) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Minimum investment is '
              '$currencySymbol${minimumInvestment.toStringAsFixed(2)}.',
            ),
          ),
        );

      return;
    }

    // TODO: Connect your existing Stripe payment flow here.
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GspMonthlyPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.monthlyPlan == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xffA90020)),
            ),
          );
        }

        if (provider.errorMessage != null && provider.monthlyPlan == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xffA90020),
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff555555),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      final currencyProvider = context.read<CurrencyProvider>();

                      provider.fetchMonthlyPlan(
                        currency: currencyProvider.selectedCurrency,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffA90020),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // TITLE
            // ============================================================
            const Text(
              'Monthly Investment Plan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // ============================================================
            // DESCRIPTION
            // ============================================================
            const Text(
              'Build your GSP gold savings with optional monthly investment. '
              'Payments are not mandatory, but help you grow your holdings over time.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xff555555),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // ============================================================
            // PAYMENT CARD
            // ============================================================
            _buildCardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Make a Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9B001B),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // INFO MESSAGE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xfffff3f3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xffffd2d2)),
                    ),
                    child: Text(
                      'Enter your investment amount and pay securely with '
                      'Stripe. Minimum investment: '
                      '$currencySymbol${minimumInvestment.toStringAsFixed(2)}.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff4A1D1D),
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // AMOUNT LABEL
                  const Text(
                    'Investment amount (USD)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff333333),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // AMOUNT INPUT
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: _onAmountChanged,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xffD5D9E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xffD5D9E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xff9B001B),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // GOLD CALCULATION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE0E3E7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff333333),
                            ),
                            children: [
                              const TextSpan(text: 'Gold price: '),
                              TextSpan(
                                text:
                                    '$currencySymbol${goldPricePerGram.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' / g'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff333333),
                            ),
                            children: [
                              const TextSpan(text: 'Estimated gold: '),
                              TextSpan(
                                text: '${estimatedGold.toStringAsFixed(4)} g',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 13),

                  // PAY WITH STRIPE BUTTON
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _payWithStripe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffA90020),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.credit_card, size: 18),
                      label: const Text(
                        'Pay with Stripe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 1. YOUR GSP PLAN CARD
            // ============================================================
            _buildCardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your GSP Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9B001B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlanDetailRow(
                    'Plan status',
                    widget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF7E6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xffD48806),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xffF0F0F0), height: 20),
                  _buildPlanDetailRow(
                    'Plan activated',
                    value: _formatDate(provider.monthlyPlan?.planActivatedAt),
                  ),

                  const Divider(color: Color(0xffF0F0F0), height: 20),

                  _buildPlanDetailRow('Monthly payment', value: 'Optional'),

                  const Divider(color: Color(0xffF0F0F0), height: 20),

                  _buildPlanDetailRow(
                    'Minimum investment',
                    value: provider.monthlyPlan?.gspMinimumFormatted ?? '-',
                  ),

                  const Divider(color: Color(0xffF0F0F0), height: 20),

                  _buildPlanDetailRow(
                    'Next reminder',
                    value: _formatDate(provider.monthlyPlan?.nextReminderDate),
                  ),

                  const Divider(color: Color(0xffF0F0F0), height: 20),

                  _buildPlanDetailRow(
                    'Email reminders',
                    value: provider.monthlyPlan?.remindersEnabled == true
                        ? 'Enabled'
                        : 'Disabled',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 2. SUGGESTED MONTHLY TIERS CARD
            // ============================================================
            _buildCardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggested Monthly Tiers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9B001B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Banner box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffFDE8E8)),
                    ),
                    child: const Text(
                      'Choose any amount at or above the minimum. You can investment monthly, or whenever it suits you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff4A1D1D),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: const Color(0xffF8F9FA),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TIER (SGD)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff666666),
                          ),
                        ),
                        Text(
                          'APPROX. AMOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...List.generate(provider.monthlyPlan?.gspTiers.length ?? 0, (
                    index,
                  ) {
                    final tier = provider.monthlyPlan!.gspTiers[index];

                    return Column(
                      children: [
                        _buildTierRow(
                          'S\$ ${_formatNumber(tier.sgd)}',
                          tier.formatted,
                        ),

                        if (index < provider.monthlyPlan!.gspTiers.length - 1)
                          const Divider(color: Color(0xffF0F0F0), height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 3. HOW MONTHLY GSP WORKS CARD
            // ============================================================
            _buildCardWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How Monthly GSP Works',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9B001B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                    'Start with a one-time GSP purchase of at least $currencySymbol${minimumInvestment.toStringAsFixed(2)}.',
                  ),
                  _buildBulletPoint(
                    'Each month on your plan anniversary date, we email a reminder to make an optional payment.',
                  ),
                  _buildBulletPoint(
                    'There is no automatic charge — you decide when to investment.',
                  ),
                  _buildBulletPoint(
                    'Every payment adds digital gold to your GSP wallet.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        );
      },
    );
  }

  // Card Container Wrapper with the Gold/Red top bar indicator
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffF0CFCF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffB00020), Color(0xffF4B400)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }

  // Row layout helper for GSP Details
  Widget _buildPlanDetailRow(String label, {String? value, Widget? widget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff333333),
          ),
        ),
        if (value != null)
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: Color(0xff555555)),
            ),
          ),
        if (widget != null) widget,
      ],
    );
  }

  // Row layout helper for Tiers Table
  Widget _buildTierRow(String tier, String approxAmount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tier,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xff9B001B),
              decoration: TextDecoration.underline,
            ),
          ),
          Text(
            approxAmount,
            style: const TextStyle(fontSize: 13, color: Color(0xff333333)),
          ),
        ],
      ),
    );
  }

  // Bullet point list item builder
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff555555),
              height: 1.2,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xff555555),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
