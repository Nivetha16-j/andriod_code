import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/gsp_balance_provider.dart';
import 'package:junubullion/services/gsp_service.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:provider/provider.dart';

final ValueNotifier<bool> balanceUnlockedNotifier = ValueNotifier<bool>(false);

class GspBalanceSection extends StatefulWidget {
  final Future<void> Function()? onUnlocked;

  final bool showBalances;
  const GspBalanceSection({
    super.key,
    this.onUnlocked,
    this.showBalances = true,
  });

  @override
  State<GspBalanceSection> createState() => _GspBalanceSectionState();
}

class _GspBalanceSectionState extends State<GspBalanceSection> {
  String goldBalance = '...';
  String goldUnit = 'grams';
  String goldMarketValue = '...';

  String silverBalance = '...';
  String silverUnit = 'oz';
  String silverMarketValue = '...';

  String currencySymbol = '';

  bool isBalanceUnlocked = false;
  bool isCheckingUnlockState = true;
  bool isFetchingWallet = false;

  @override
  void initState() {
    super.initState();
    balanceUnlockedNotifier.addListener(_onBalanceStateChanged);
    _initializeBalanceState();
  }

  @override
  void dispose() {
    balanceUnlockedNotifier.removeListener(_onBalanceStateChanged);
    super.dispose();
  }

  Future<void> _initializeBalanceState() async {
    try {
      final bool unlocked = await SessionManager.isGspBalanceUnlocked();

      log('Gsp BALANCE -> Saved unlock state: $unlocked');

      if (!mounted) return;

      balanceUnlockedNotifier.value = unlocked;

      if (!unlocked) {
        _clearWalletDisplay();

        if (mounted) {
          context.read<GspBalanceProvider>().setUnlocked(false);
        }
      } else {
        setState(() {
          isBalanceUnlocked = true;
        });

        context.read<GspBalanceProvider>().setUnlocked(true);

        await _fetchAllBackendData();
      }
    } catch (e, stackTrace) {
      log('JSC BALANCE -> Initialization error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isBalanceUnlocked = false;
      });

      balanceUnlockedNotifier.value = false;

      context.read<GspBalanceProvider>().setUnlocked(false);

      _clearWalletDisplay();
    } finally {
      if (!mounted) return;

      setState(() {
        isCheckingUnlockState = false;
      });
    }
  }

  void _onBalanceStateChanged() {
    if (!mounted) return;

    final bool unlocked = balanceUnlockedNotifier.value;

    if (isBalanceUnlocked == unlocked) {
      return;
    }

    setState(() {
      isBalanceUnlocked = unlocked;
    });

    if (!unlocked) {
      _clearWalletDisplay();
      context.read<GspBalanceProvider>().setUnlocked(false);
    }
  }

  void _clearWalletDisplay() {
    if (!mounted) return;

    setState(() {
      goldBalance = '...';
      goldUnit = 'grams';
      goldMarketValue = '...';

      silverBalance = '...';
      silverUnit = 'oz';
      silverMarketValue = '...';

      currencySymbol = '';
    });
  }

  Future<void> _fetchAllBackendData() async {
    if (!mounted) return;

    if (isFetchingWallet) {
      return;
    }

    if (!isBalanceUnlocked) {
      return;
    }

    setState(() {
      isFetchingWallet = true;
    });

    try {
      final currencyProvider = context.read<CurrencyProvider>();

      final String currency = currencyProvider.selectedCurrency;

      log('Gsp BALANCE -> Fetching backend wallet data');

      log('Gsp BALANCE -> Currency: $currency');

      // await _fetchWallet(currency);

      // try {
      //   final transactionsResult = await JscService.getTransactions(
      //     currency: currency,
      //   );

      //   log(
      //     'JSC BALANCE -> Transactions: '
      //     '$transactionsResult',
      //   );
      // } catch (e, stackTrace) {
      //   log('JSC BALANCE -> Transactions error: $e', stackTrace: stackTrace);
      // }

      // try {
      //   final sellBackResult = await JscService.getSellBackDetails(
      //     currency: currency,
      //   );

      //   log(
      //     'JSC BALANCE -> Sell Back: '
      //     '$sellBackResult',
      //   );
      // } catch (e, stackTrace) {
      //   log('JSC BALANCE -> Sell Back error: $e', stackTrace: stackTrace);
      // }

      if (mounted) {
        await widget.onUnlocked?.call();
      }
    } catch (e, stackTrace) {
      log('Gsp BALANCE -> Backend fetch error: $e', stackTrace: stackTrace);
    } finally {
      if (!mounted) return;

      setState(() {
        isFetchingWallet = false;
      });
    }
  }

  // Future<void> _fetchWallet(String currency) async {
  //   try {
  //     log('JSC WALLET -> Calling fetchWallet()');

  //     final result = await GspService.fetchWallet(currency: currency);

  //     log('JSC WALLET RESPONSE -> $result');

  //     if (!mounted) return;

  //     if (result['status'] != true) {
  //       log('JSC WALLET -> Backend returned status false');
  //       return;
  //     }

  //     final Map<String, dynamic> data = result['data'] is Map
  //         ? Map<String, dynamic>.from(result['data'])
  //         : <String, dynamic>{};

  //     log('JSC WALLET DATA -> $data');

  //     // ============================================================
  //     // RESPONSE STRUCTURE:
  //     //
  //     // data
  //     //   -> summary
  //     //       -> symbol
  //     //       -> metals
  //     //           -> gold
  //     //           -> silver
  //     // ============================================================

  //     final Map<String, dynamic> summary = data['summary'] is Map
  //         ? Map<String, dynamic>.from(data['summary'])
  //         : <String, dynamic>{};

  //     final Map<String, dynamic> metals = summary['metals'] is Map
  //         ? Map<String, dynamic>.from(summary['metals'])
  //         : <String, dynamic>{};

  //     final Map<String, dynamic> gold = metals['gold'] is Map
  //         ? Map<String, dynamic>.from(metals['gold'])
  //         : <String, dynamic>{};

  //     final Map<String, dynamic> silver = metals['silver'] is Map
  //         ? Map<String, dynamic>.from(metals['silver'])
  //         : <String, dynamic>{};

  //     log('JSC WALLET SUMMARY -> $summary');
  //     log('JSC WALLET METALS -> $metals');
  //     log('JSC WALLET GOLD -> $gold');
  //     log('JSC WALLET SILVER -> $silver');

  //     // ============================================================
  //     // GOLD
  //     // ============================================================

  //     final String newGoldBalance = gold['balance']?.toString() ?? '0.0000';

  //     final String newGoldUnit =
  //         gold['unit_label']?.toString() ?? gold['unit']?.toString() ?? 'grams';

  //     final String newGoldMarketValue =
  //         gold['formatted_value']?.toString() ??
  //         gold['value']?.toString() ??
  //         '0.00';

  //     // ============================================================
  //     // SILVER
  //     // ============================================================

  //     final String newSilverBalance = silver['balance']?.toString() ?? '0.0000';

  //     final String newSilverUnit =
  //         silver['unit_label']?.toString() ??
  //         silver['unit']?.toString() ??
  //         'grams';

  //     final String newSilverMarketValue =
  //         silver['formatted_value']?.toString() ??
  //         silver['value']?.toString() ??
  //         '0.00';

  //     // ============================================================
  //     // CURRENCY
  //     // ============================================================

  //     final String newCurrencySymbol =
  //         summary['symbol']?.toString() ??
  //         data['currency_symbol']?.toString() ??
  //         '';

  //     log(
  //       'JSC WALLET FINAL -> '
  //       'Gold: $newGoldBalance $newGoldUnit | $newGoldMarketValue | '
  //       'Silver: $newSilverBalance $newSilverUnit | $newSilverMarketValue | '
  //       'Symbol: $newCurrencySymbol',
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       goldBalance = newGoldBalance;
  //       goldUnit = newGoldUnit;
  //       goldMarketValue = newGoldMarketValue;

  //       silverBalance = newSilverBalance;
  //       silverUnit = newSilverUnit;
  //       silverMarketValue = newSilverMarketValue;

  //       currencySymbol = newCurrencySymbol;
  //     });
  //   } catch (e, stackTrace) {
  //     log('JSC WALLET -> Fetch error: $e', stackTrace: stackTrace);
  //   }
  // }

  Future<void> _onBalancesUnlocked(Map<String, dynamic> unlockData) async {
    try {
      log(
        'JSC UNLOCK -> Backend unlock response: '
        '$unlockData',
      );

      // ========================================================
      // STEP 1
      // SAVE ONLY UNLOCK STATE
      // ========================================================

      await SessionManager.saveBalanceUnlocked();

      log('JSC UNLOCK -> Unlock state saved');

      // ========================================================
      // STEP 2
      // UPDATE GLOBAL NOTIFIER
      // ========================================================

      balanceUnlockedNotifier.value = true;

      // ========================================================
      // STEP 3
      // UPDATE PROVIDER
      // ========================================================

      if (mounted) {
        context.read<GspBalanceProvider>().setUnlocked(true);
      }

      if (!mounted) return;

      setState(() {
        isBalanceUnlocked = true;
      });

      // ========================================================
      // STEP 4
      //
      // DO NOT DISPLAY unlockData AS THE FINAL WALLET STATE.
      //
      // Fetch wallet again from backend.
      // ========================================================

      await _fetchAllBackendData();

      log('JSC UNLOCK -> All backend data fetched successfully');
    } catch (e, stackTrace) {
      log('JSC UNLOCK -> Error after unlock: $e', stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCheckingUnlockState) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // UNLOCK CARD
        // ========================================================
        if (!isBalanceUnlocked)
          UnlockBalanceCard(onUnlocked: _onBalancesUnlocked),

        if (!isBalanceUnlocked) const SizedBox(height: 20),

        // ========================================================
        // WALLET BALANCES
        // ========================================================
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
  final Future<void> Function(Map<String, dynamic> data) onUnlocked;

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
    final String password = controller.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your unlock password.')),
      );

      return;
    }

    setState(() {
      isUnlocking = true;
    });

    final currencyProvider = context.read<CurrencyProvider>();

    final String currency = currencyProvider.selectedCurrency;

    try {
      log('JSC UNLOCK -> Currency: $currency');

      final result = await GspService.unlockWallet(
        unlockPassword: password,
        currency: currency,
      );

      log('JSC UNLOCK RESPONSE -> $result');

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

      final Map<String, dynamic> data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'])
          : <String, dynamic>{};

      log('JSC UNLOCK DATA -> $data');

      await widget.onUnlocked(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Balances unlocked successfully.',
          ),
        ),
      );
    } catch (e, stackTrace) {
      log('JSC UNLOCK ERROR -> $e', stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
            ),
          ),

          const Text(
            'Please enter your unlock password (first 4 characters of your registered email ID + last 4 digits of your registered phone number) to view your balance.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
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
                disabledBackgroundColor: const Color(0xFFD20D2D),
                foregroundColor: Colors.white,
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

              const SizedBox(width: 2),

              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          Text(
            marketValue == '...'
                ? '... market value'
                : '$marketValue market value',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(178, 186, 205, 1),
            ),
          ),

          Image.asset(image, height: 35, width: 35),
        ],
      ),
    );
  }
}
