import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:provider/provider.dart';

class JscSellBackScreen extends StatefulWidget {
  const JscSellBackScreen({super.key});

  @override
  State<JscSellBackScreen> createState() => _JscSellBackScreenState();
}

class _JscSellBackScreenState extends State<JscSellBackScreen> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: JscLayout(
        selectedMenu: 'Sell Back Request',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscSellBackContent(),
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

class JscSellBackContent extends StatefulWidget {
  const JscSellBackContent({super.key});

  @override
  State<JscSellBackContent> createState() => _JscSellBackContentState();
}

class _JscSellBackContentState extends State<JscSellBackContent> {
  bool isLoadingSellBack = false;

  Map<String, dynamic>? sellBackData;

  bool isBalancesUnlocked = false;

  @override
  void initState() {
    super.initState();

    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    final unlocked = await SessionManager.isBalanceUnlocked();

    if (!mounted) return;

    setState(() {
      isBalancesUnlocked = unlocked;
    });

    // If already unlocked, fetch Sell Back details immediately.
    if (unlocked) {
      await _fetchSellBackDetails();
    }
  }

  Future<void> _fetchSellBackDetails() async {
    if (!mounted) return;

    setState(() {
      isLoadingSellBack = true;
    });

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      debugPrint(
        'SELL BACK -> Fetching sell back details with currency: $currency',
      );

      final result = await JscService.getSellBackDetails(currency: currency);

      debugPrint('SELL BACK -> API RESULT: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        setState(() {
          sellBackData = result['data'] as Map<String, dynamic>? ?? {};
        });
      } else {
        setState(() {
          sellBackData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Unable to fetch sell back details.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('SELL BACK -> API error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch sell back details: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSellBack = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sell Back Request',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Sell your digital holdings and track bank transfer payouts.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.25,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        // IMPORTANT:
        // We don't show the normal Gold/Silver balance cards here.
        JscBalanceSection(
          showBalances: false,

          // This gets called when unlockWallet succeeds.
          onUnlocked: () async {
            if (!mounted) return;

            setState(() {
              isBalancesUnlocked = true;
            });

            // Fetch Sell Back API immediately after unlock.
            await _fetchSellBackDetails();
          },
        ),

        const SizedBox(height: 20),

        _buildSellBackCard(),
      ],
    );
  }

  Widget _buildSellBackCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFF202E), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sell Back for Cash',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E2828),
            ),
          ),

          const SizedBox(height: 4),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 17, 10, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Sell your digital holdings back to Junu Bullion at the live spot price. Enter your bank details and confirm the amount — we will transfer the payout to your account.',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (isLoadingSellBack)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (!isBalancesUnlocked)
            _buildLockedMessage()
          else if (sellBackData != null)
            _buildSellBackDetails()
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildLockedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 17, 10, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Unlock your balances to sell back holdings.',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSellBackDetails() {
    final gold = sellBackData?['gold'] as Map<String, dynamic>? ?? {};

    final silver = sellBackData?['silver'] as Map<String, dynamic>? ?? {};

    final goldBalance = gold['balance']?.toString() ?? '0.0000';

    final goldUnit = gold['unit']?.toString() ?? 'gram';

    final goldMarketRate = gold['market_rate']?.toString() ?? '0';

    final silverBalance = silver['balance']?.toString() ?? '0.0000';

    final silverUnit = silver['unit']?.toString() ?? 'gram';

    final silverMarketRate = silver['market_rate']?.toString() ?? '0';

    final currency = sellBackData?['currency']?.toString() ?? '';

    final currencySymbol = _currencySymbol(currency);

    return Column(
      children: [
        _buildSellBackMetalRow(
          metal: 'Gold',
          balance: goldBalance,
          unit: goldUnit,
          spotPrice: '$currencySymbol$goldMarketRate',
          enabled: _canSellGold(goldBalance, goldUnit),
        ),

        const SizedBox(height: 8),

        _buildSellBackMetalRow(
          metal: 'Silver',
          balance: silverBalance,
          unit: silverUnit,
          spotPrice: '$currencySymbol$silverMarketRate',
          enabled: _canSellSilver(silverBalance, silverUnit),
        ),

        const SizedBox(height: 12),

        _buildMinimumBalanceMessage(
          goldBalance: goldBalance,
          goldUnit: goldUnit,
          silverBalance: silverBalance,
          silverUnit: silverUnit,
        ),
      ],
    );
  }

  Widget _buildSellBackMetalRow({
    required String metal,
    required String balance,
    required String unit,
    required String spotPrice,
    required bool enabled,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metal,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  'Available: $balance $unit',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF807878)),
                ),
                Text(
                  'Spot: $spotPrice / $unit',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF807878)),
                ),
              ],
            ),

            Spacer(),

            SizedBox(
              width: 100,
              height: 35,
              child: ElevatedButton(
                onPressed: enabled
                    ? () {
                        // TODO:
                        // Open Sell Back form for this metal.
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD20D2D),
                  disabledBackgroundColor: const Color(0xFFC9C9C9),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sell Back',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(height: 1, color: const Color(0xFFE8E3E3)),
      ],
    );
  }

  Widget _buildMinimumBalanceMessage({
    required String goldBalance,
    required String goldUnit,
    required String silverBalance,
    required String silverUnit,
  }) {
    final gold = double.tryParse(goldBalance) ?? 0;
    final silver = double.tryParse(silverBalance) ?? 0;

    // Your requirement:
    // Gold minimum = 50 g
    // Silver minimum = 1 kg = 1000 g
    final goldEligible = goldUnit.toLowerCase().contains('kg')
        ? gold >= 0.05
        : gold >= 50;

    final silverEligible = silverUnit.toLowerCase().contains('kg')
        ? silver >= 1
        : silver >= 1000;

    if (goldEligible || silverEligible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        'Minimum balance required for a Sell Back request: 50 g of Gold or 1 kg of Silver. Please increase your balance to become eligible for a Sell Back request.',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: Color(0xFF8A5A00),
        ),
      ),
    );
  }

  bool _canSellGold(String value, String unit) {
    final balance = double.tryParse(value) ?? 0;

    if (unit.toLowerCase().contains('kg')) {
      return balance >= 0.05;
    }

    return balance >= 50;
  }

  bool _canSellSilver(String value, String unit) {
    final balance = double.tryParse(value) ?? 0;

    if (unit.toLowerCase().contains('kg')) {
      return balance >= 1;
    }

    return balance >= 1000;
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'SGD':
        return 'S\$';
      case 'INR':
        return '₹';
      default:
        return '$currency ';
    }
  }
}
