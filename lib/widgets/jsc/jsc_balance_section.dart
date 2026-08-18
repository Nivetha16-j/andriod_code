import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:provider/provider.dart';

final ValueNotifier<bool> balanceUnlockedNotifier = ValueNotifier<bool>(false);

class JscBalanceSection extends StatefulWidget {
  final VoidCallback? onUnlocked;

  // true = show Gold/Silver balances
  // false = only show UnlockBalanceCard
  final bool showBalances;

  const JscBalanceSection({
    super.key,
    this.onUnlocked,
    this.showBalances = true,
  });

  @override
  State<JscBalanceSection> createState() => _JscBalanceSectionState();
}

class _JscBalanceSectionState extends State<JscBalanceSection> {
  String goldBalance = '...';
  String goldUnit = 'grams';
  String goldMarketValue = '...';

  String silverBalance = '...';
  String silverUnit = 'oz';
  String silverMarketValue = '...';

  String currencySymbol = '';

  bool isBalanceUnlocked = false;
  bool isCheckingBalanceUnlock = true;

  @override
  void initState() {
    super.initState();

    balanceUnlockedNotifier.addListener(_onBalanceStateChanged);

    _checkBalanceUnlockStatus();
  }

  void _onBalanceStateChanged() {
    if (!mounted) return;

    setState(() {
      isBalanceUnlocked = balanceUnlockedNotifier.value;
    });
  }

  @override
  void dispose() {
    balanceUnlockedNotifier.removeListener(_onBalanceStateChanged);
    super.dispose();
  }

  Future<void> _checkBalanceUnlockStatus() async {
    try {
      final unlocked = await SessionManager.isBalanceUnlocked();

      debugPrint(
        'SELL/DASH/WALLET -> isBalanceUnlocked from SessionManager: $unlocked',
      );

      if (!mounted) return;

      // Keep the global state synchronized with SessionManager
      balanceUnlockedNotifier.value = unlocked;

      if (unlocked) {
        final savedData = await SessionManager.getSavedBalanceData();

        if (!mounted) return;

        setState(() {
          isBalanceUnlocked = true;

          goldBalance = savedData['goldBalance'] ?? '...';
          goldUnit = savedData['goldUnit'] ?? 'grams';
          goldMarketValue = savedData['goldMarketValue'] ?? '...';

          silverBalance = savedData['silverBalance'] ?? '...';
          silverUnit = savedData['silverUnit'] ?? 'oz';
          silverMarketValue = savedData['silverMarketValue'] ?? '...';

          currencySymbol = savedData['currencySymbol'] ?? '';
        });

        widget.onUnlocked?.call();
      } else {
        setState(() {
          isBalanceUnlocked = false;
        });
      }
    } catch (e) {
      debugPrint('Balance unlock status error: $e');

      if (!mounted) return;

      setState(() {
        isBalanceUnlocked = false;
      });
    }

    if (!mounted) return;

    setState(() {
      isCheckingBalanceUnlock = false;
    });
  }

  Future<void> _onBalancesUnlocked(Map<String, dynamic> data) async {
    try {
      await SessionManager.saveBalanceUnlocked();

      await SessionManager.saveBalanceData(data);

      balanceUnlockedNotifier.value = true;

      if (!mounted) return;

      final gold = data['gold'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final silver =
          data['silver'] as Map<String, dynamic>? ?? <String, dynamic>{};

      setState(() {
        isBalanceUnlocked = true;

        // GOLD
        goldBalance = gold['balance']?.toString() ?? '0.0000';

        goldUnit = gold['unit']?.toString() ?? 'gram';

        goldMarketValue = gold['market_value']?.toString() ?? '0';

        // SILVER
        silverBalance = silver['balance']?.toString() ?? '0.0000';

        silverUnit = silver['unit']?.toString() ?? 'oz';

        silverMarketValue = silver['market_value']?.toString() ?? '0';

        // CURRENCY
        currencySymbol = data['currency_symbol']?.toString() ?? '';
      });

      widget.onUnlocked?.call();
    } catch (e) {
      debugPrint('Saving balance data error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCheckingBalanceUnlock && !isBalanceUnlocked)
          UnlockBalanceCard(onUnlocked: _onBalancesUnlocked),

        if (!isCheckingBalanceUnlock && !isBalanceUnlocked)
          const SizedBox(height: 20),

        if (widget.showBalances)
          Row(
            children: [
              Expanded(
                child: _BalanceCard(
                  title: 'Gold Balance',
                  balanceValue: goldBalance,
                  unit: goldUnit,
                  marketValue: goldMarketValue,
                  currencySymbol: currencySymbol,
                  isGold: true,
                  image: 'assets/g_balance.png',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _BalanceCard(
                  title: 'Silver Balance',
                  balanceValue: silverBalance,
                  unit: silverUnit,
                  marketValue: silverMarketValue,
                  currencySymbol: currencySymbol,
                  isGold: false,
                  image: 'assets/s_balance.png',
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class UnlockBalanceCard extends StatefulWidget {
  final void Function(Map<String, dynamic>) onUnlocked;
  const UnlockBalanceCard({super.key, required this.onUnlocked});

  @override
  State<UnlockBalanceCard> createState() => UnlockBalanceCardState();
}

class UnlockBalanceCardState extends State<UnlockBalanceCard> {
  final TextEditingController controller = TextEditingController();

  bool isUnlocking = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _unlockBalances() async {
    final password = controller.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your unlock password.')),
      );
      return;
    }

    setState(() {
      isUnlocking = true;
    });

    // IMPORTANT:
    // Get these BEFORE any await.
    final currencyProvider = context.read<CurrencyProvider>();

    final currency = currencyProvider.selectedCurrency;

    try {
      log('Unlock wallet - Currency: $currency');

      // ============================================================
      // 1. UNLOCK BALANCES
      // ============================================================

      final result = await JscService.unlockWallet(
        unlockPassword: password,
        currency: currency,
      );

      if (!mounted) return;

      if (result['status'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Unable to unlock balances.',
            ),
          ),
        );
        return;
      }

      final data = result['data'] as Map<String, dynamic>? ?? {};

      // ============================================================
      // 2. SAVE BALANCE DATA
      // ============================================================

      widget.onUnlocked(data);

      // ============================================================
      // 3. TRANSACTIONS
      // ============================================================

      try {
        final transactionsResult = await JscService.getTransactions(
          currency: currency,
        );

        log(
          'Transactions after unlock: '
          '$transactionsResult',
        );
      } catch (e) {
        log('Failed to fetch transactions after unlock: $e');
      }

      // ============================================================
      // 4. SELL BACK
      // ============================================================

      try {
        final sellBackResult = await JscService.getSellBackDetails(
          currency: currency,
        );

        log(
          'Sell Back after unlock: '
          '$sellBackResult',
        );
      } catch (e) {
        log('Failed to fetch sell back details after unlock: $e');
      }

      // ============================================================
      // 5. CONVERT TO PHYSICAL
      // ============================================================

      log('🔥 ABOUT TO CALL CONVERT PHYSICAL');

      // try {
      //   final convertPhysicalResult =
      //       await JscService.fetchConvertPhysicalDetails(currency: currency);

      //   log('🔥 CONVERT PHYSICAL FETCH COMPLETED $convertPhysicalResult');
      // } catch (e) {
      //   debugPrint('❌ Failed to fetch convert physical: $e');
      // }

      // ============================================================
      // 6. SUCCESS MESSAGE
      // ============================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Balances unlocked successfully.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Unlock balances error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unlock balances: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUnlocking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 230, 1),
        border: Border.all(color: const Color(0xFFE9C65A), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 2,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Gold and Silver balances are protected.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w400,
            ),
          ),

          const Text(
            'Please enter your unlock password (first 4 characters of your registered email ID + last 4 digits of your registered phone number) to view your balance.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 30,
            child: TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Email Prefix + Phone Suffix',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9C65A),
                    width: 0.7,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: isUnlocking ? null : _unlockBalances,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD20D2D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFD20D2D),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: isUnlocking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Unlock Balances',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String balanceValue;
  final String unit;
  final String marketValue;
  final String currencySymbol;
  final bool isGold;
  final String image;

  const _BalanceCard({
    required this.title,
    required this.balanceValue,
    required this.unit,
    required this.marketValue,
    required this.currencySymbol,
    required this.isGold,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isGold
        ? const Color.fromRGBO(232, 190, 46, 1)
        : const Color.fromRGBO(178, 186, 205, 1);

    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 230, 1),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(131, 126, 126, 1),
              fontWeight: FontWeight.w600,
            ),
          ),

          // const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  balanceValue,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // const SizedBox(height: 5),
          Text(
            marketValue == '...'
                ? '... market value'
                : '$currencySymbol$marketValue market value',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(178, 186, 205, 1),
            ),
          ),
          // const SizedBox(height: 5),
          Image.asset(image, height: 35, width: 35),
        ],
      ),
    );
  }
}
