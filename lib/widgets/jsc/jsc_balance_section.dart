import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/gsp_balance_provider.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/services/gsp_service.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

final ValueNotifier<bool> balanceUnlockedNotifier = ValueNotifier<bool>(false);

class JscBalanceSection extends StatefulWidget {
  final Future<void> Function()? onUnlocked;

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
  String jscGoldBalance = '...';
  String jscGoldUnit = '';
  String jscGoldMarketValue = '...';
  String jscSilverBalance = '...';
  String jscSilverUnit = '';
  String jscSilverMarketValue = '...';
  String jscCurrencySymbol = '';

  String gspGoldBalance = '...';
  String gspGoldUnit = '';
  String gspGoldMarketValue = '...';
  String gspSilverBalance = '...';
  String gspSilverUnit = '';
  String gspSilverMarketValue = '...';
  String gspCurrencySymbol = '';
  String? gspCurrency;

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
      final bool unlocked = await SessionManager.isJscBalanceUnlocked();

      log('JSC BALANCE -> Saved unlock state: $unlocked');

      if (!mounted) return;

      balanceUnlockedNotifier.value = unlocked;

      if (!unlocked) {
        _clearWalletDisplay();

        if (mounted) {
          context.read<JscBalanceProvider>().setUnlocked(false);
        }
      } else {
        setState(() {
          isBalanceUnlocked = true;
        });

        context.read<JscBalanceProvider>().setUnlocked(true);

        await _fetchAllBackendData();
      }
    } catch (e, stackTrace) {
      log('JSC BALANCE -> Initialization error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isBalanceUnlocked = false;
      });

      balanceUnlockedNotifier.value = false;

      context.read<JscBalanceProvider>().setUnlocked(false);

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
      context.read<JscBalanceProvider>().setUnlocked(false);
    }
  }

  void _clearWalletDisplay() {
    if (!mounted) return;

    setState(() {
      jscGoldBalance = '...';
      jscGoldUnit = '';
      jscGoldMarketValue = '...';

      jscSilverBalance = '...';
      jscSilverUnit = '';
      jscSilverMarketValue = '...';

      jscCurrencySymbol = '';
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

      log('JSC BALANCE -> Fetching backend wallet data');

      log('JSC BALANCE -> Currency: $currency');

      await _fetchJscWallet(currency);
      await _fetchGspWallet(currency);

      try {
        final transactionsResult = await JscService.getTransactions(
          currency: currency,
        );

        log(
          'JSC BALANCE -> Transactions: '
          '$transactionsResult',
        );
      } catch (e, stackTrace) {
        log('JSC BALANCE -> Transactions error: $e', stackTrace: stackTrace);
      }

      try {
        final sellBackResult = await JscService.getSellBackDetails(
          currency: currency,
        );

        log(
          'JSC BALANCE -> Sell Back: '
          '$sellBackResult',
        );
      } catch (e, stackTrace) {
        log('JSC BALANCE -> Sell Back error: $e', stackTrace: stackTrace);
      }

      if (mounted) {
        await widget.onUnlocked?.call();
      }
    } catch (e, stackTrace) {
      log('JSC BALANCE -> Backend fetch error: $e', stackTrace: stackTrace);
    } finally {
      if (!mounted) return;

      setState(() {
        isFetchingWallet = false;
      });
    }
  }

  Future<void> _fetchJscWallet(String currency) async {
    try {
      log('JSC WALLET -> Calling fetchWallet()');

      final result = await JscService.fetchWallet(currency: currency);

      log('JSC WALLET RESPONSE -> $result');

      if (!mounted) return;

      if (result['status'] != true) {
        log('JSC WALLET -> Backend returned status false');
        return;
      }

      final Map<String, dynamic> data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'])
          : <String, dynamic>{};

      log('JSC WALLET DATA -> $data');

      // ============================================================
      // RESPONSE STRUCTURE:
      //
      // data
      //   -> summary
      //       -> symbol
      //       -> metals
      //           -> gold
      //           -> silver
      // ============================================================

      final Map<String, dynamic> summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'])
          : <String, dynamic>{};

      final Map<String, dynamic> metals = summary['metals'] is Map
          ? Map<String, dynamic>.from(summary['metals'])
          : <String, dynamic>{};

      final Map<String, dynamic> gold = metals['gold'] is Map
          ? Map<String, dynamic>.from(metals['gold'])
          : <String, dynamic>{};

      final Map<String, dynamic> silver = metals['silver'] is Map
          ? Map<String, dynamic>.from(metals['silver'])
          : <String, dynamic>{};

      log('JSC WALLET SUMMARY -> $summary');
      log('JSC WALLET METALS -> $metals');
      log('JSC WALLET GOLD -> $gold');
      log('JSC WALLET SILVER -> $silver');

      // ============================================================
      // GOLD
      // ============================================================

      final String newGoldBalance = gold['balance']?.toString() ?? '0.0000';

      final String newGoldUnit =
          gold['unit_label']?.toString() ?? gold['unit']?.toString() ?? 'grams';

      final String newGoldMarketValue =
          gold['formatted_value']?.toString() ??
          gold['value']?.toString() ??
          '0.00';

      // ============================================================
      // SILVER
      // ============================================================

      final String newSilverBalance = silver['balance']?.toString() ?? '0.0000';

      final String newSilverUnit =
          silver['unit_label']?.toString() ??
          silver['unit']?.toString() ??
          'grams';

      final String newSilverMarketValue =
          silver['formatted_value']?.toString() ??
          silver['value']?.toString() ??
          '0.00';

      // ============================================================
      // CURRENCY
      // ============================================================

      final String newCurrencySymbol =
          summary['symbol']?.toString() ??
          data['currency_symbol']?.toString() ??
          '';

      log(
        'JSC WALLET FINAL -> '
        'Gold: $newGoldBalance $newGoldUnit | $newGoldMarketValue | '
        'Silver: $newSilverBalance $newSilverUnit | $newSilverMarketValue | '
        'Symbol: $newCurrencySymbol',
      );

      if (!mounted) return;

      setState(() {
        jscGoldBalance = newGoldBalance;
        jscGoldUnit = newGoldUnit;
        jscGoldMarketValue = newGoldMarketValue;

        jscSilverBalance = newSilverBalance;
        jscSilverUnit = newSilverUnit;
        jscSilverMarketValue = newSilverMarketValue;

        jscCurrencySymbol = newCurrencySymbol;
      });
    } catch (e, stackTrace) {
      log('JSC WALLET -> Fetch error: $e', stackTrace: stackTrace);
    }
  }

  Future<void> _fetchGspWallet(String currency) async {
    try {
      log('GSP WALLET -> Calling fetchWallet()');
      log('GSP WALLET -> Currency: $currency');

      final result = await GspService.fetchWallet(currency: currency);

      log('GSP WALLET RESPONSE -> $result');

      if (!mounted) return;

      if (result['status'] != true) {
        log(
          'GSP WALLET -> Backend returned status false: '
          '${result['message']}',
        );
        return;
      }

      // ==========================================================
      // DATA
      // ==========================================================

      final Map<String, dynamic> data = result['data'] is Map
          ? Map<String, dynamic>.from(result['data'])
          : <String, dynamic>{};

      // ==========================================================
      // WALLET ONLY
      // ==========================================================

      final Map<String, dynamic> wallet = data['wallet'] is Map
          ? Map<String, dynamic>.from(data['wallet'])
          : <String, dynamic>{};

      log('GSP WALLET ONLY -> $wallet');

      // ==========================================================
      // WALLET SUMMARY
      // ==========================================================

      final Map<String, dynamic> summary = wallet['summary'] is Map
          ? Map<String, dynamic>.from(wallet['summary'])
          : <String, dynamic>{};

      // ==========================================================
      // METALS
      // ==========================================================

      final Map<String, dynamic> metals = summary['metals'] is Map
          ? Map<String, dynamic>.from(summary['metals'])
          : <String, dynamic>{};

      // ==========================================================
      // GOLD
      // ==========================================================

      final Map<String, dynamic> gold = metals['gold'] is Map
          ? Map<String, dynamic>.from(metals['gold'])
          : <String, dynamic>{};

      // ==========================================================
      // SILVER
      // ==========================================================

      final Map<String, dynamic> silver = metals['silver'] is Map
          ? Map<String, dynamic>.from(metals['silver'])
          : <String, dynamic>{};

      log('GSP WALLET GOLD -> $gold');
      log('GSP WALLET SILVER -> $silver');

      // ==========================================================
      // GOLD VALUES
      // ==========================================================

      final String goldBalance = gold['balance']?.toString() ?? '0.0000';

      final String goldUnit =
          gold['unit_label']?.toString() ?? gold['unit']?.toString() ?? 'grams';

      final String goldMarketValue =
          gold['formatted_value']?.toString() ??
          gold['value']?.toString() ??
          '0.00';

      // ==========================================================
      // SILVER VALUES
      // ==========================================================

      final String silverBalance = silver['balance']?.toString() ?? '0.0000';

      final String silverUnit =
          silver['unit_label']?.toString() ??
          silver['unit']?.toString() ??
          'grams';

      final String silverMarketValue =
          silver['formatted_value']?.toString() ??
          silver['value']?.toString() ??
          '0.00';

      // ==========================================================
      // CURRENCY FROM WALLET SUMMARY
      // ==========================================================

      final String walletCurrency = summary['currency']?.toString() ?? currency;

      final String currencySymbol = summary['symbol']?.toString() ?? '';

      log(
        'GSP WALLET FINAL -> '
        'Gold: $goldBalance $goldUnit | '
        'Value: $goldMarketValue | '
        'Silver: $silverBalance $silverUnit | '
        'Value: $silverMarketValue | '
        'Currency: $walletCurrency | '
        'Symbol: $currencySymbol',
      );

      // ==========================================================
      // UPDATE PROVIDER
      // ==========================================================

      // final provider = context.read<GspBalanceProvider>();

      // provider.setUnlocked(true);

      // provider.setWalletData({
      //   'GspGoldBalance': goldBalance,
      //   'GspGoldUnit': goldUnit,
      //   'GspGoldMarketValue': goldMarketValue,

      //   'GspSilverBalance': silverBalance,
      //   'GspSilverUnit': silverUnit,
      //   'GspSilverMarketValue': silverMarketValue,

      //   'GspCurrency': walletCurrency,
      //   'GspCurrencySymbol': currencySymbol,
      // });

      if (!mounted) return;

      setState(() {
        gspGoldBalance = goldBalance;
        gspGoldUnit = goldUnit;
        gspGoldMarketValue = goldMarketValue;

        gspSilverBalance = silverBalance;
        gspSilverUnit = silverUnit;
        gspSilverMarketValue = silverMarketValue;

        gspCurrencySymbol = currencySymbol;
      });
      log('GSP WALLET -> Provider updated successfully');
    } catch (e, stackTrace) {
      log('GSP WALLET -> Fetch error: $e', stackTrace: stackTrace);
    }
  }

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
        context.read<JscBalanceProvider>().setUnlocked(true);
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BalanceCard(
                    title: 'JSC Gold',
                    balanceValue: jscGoldBalance,
                    unit: jscGoldUnit,
                    // marketValue: jsgoldMarketValue,
                    // currencySymbol: jscCurrencySymbol,
                    // isGold: true,
                    // image: 'assets/g_balance.png',
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: _BalanceCard(
                    title: 'JSC Silver',
                    balanceValue: jscSilverBalance,
                    unit: jscSilverUnit,
                    // marketValue: jssilverMarketValue,
                    // currencySymbol: jscCurrencySymbol,
                    // isGold: false,
                    // image: 'assets/s_balance.png',
                  ),
                ),
              ],
            ),
          if (widget.showBalances) const SizedBox(height: 20),
          if (widget.showBalances)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BalanceCard(
                    title: 'GSP Gold',
                    balanceValue: gspGoldBalance,
                    unit: gspGoldUnit,
                    // marketValue: goldMarketValue,
                    // currencySymbol: currencySymbol,
                    // isGold: true,
                    // image: 'assets/g_balance.png',
                  ),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: _BalanceCard(
                    title: 'GSP Silver',
                    balanceValue: gspSilverBalance,
                    unit: gspSilverUnit,
                    // marketValue: gspSilverMarketValue,
                    // currencySymbol: gspCurrencySymbol,
                    // isGold: false,
                    // image: 'assets/s_balance.png',
                  ),
                ),
              ],
            ),
          if (widget.showBalances) const SizedBox(height: 20),
          if (widget.showBalances)
            Column(
              children: [
                _SavingsPlanCard(
                  title: 'JSC Bullion',
                  tag: 'JSC',
                  tagColor: AppColors.mustard,
                  borderColor: AppColors.yellow,

                  goldBalance: jscGoldBalance,
                  goldUnit: jscGoldUnit,

                  silverBalance: jscSilverBalance,
                  silverUnit: jscSilverUnit,

                  onInvestTap: () {},
                  onViewApplicationTap: () {},
                ),

                const SizedBox(height: 16),

                _SavingsPlanCard(
                  title: 'GSP Bullion',
                  tag: 'GSP',
                  tagColor: AppColors.mustard,
                  borderColor: AppColors.yellow,

                  goldBalance: gspGoldBalance,
                  goldUnit: gspGoldUnit,

                  silverBalance: gspSilverBalance,
                  silverUnit: gspSilverUnit,

                  onInvestTap: () {},
                  onViewApplicationTap: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SavingsPlanCard extends StatelessWidget {
  final String title;
  final String tag;
  final Color tagColor;
  final Color borderColor;

  final String goldBalance;
  final String goldUnit;

  final String silverBalance;
  final String silverUnit;

  final VoidCallback onInvestTap;
  final VoidCallback onViewApplicationTap;

  const _SavingsPlanCard({
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.borderColor,
    required this.goldBalance,
    required this.goldUnit,
    required this.silverBalance,
    required this.silverUnit,
    required this.onInvestTap,
    required this.onViewApplicationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.sandal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey, width: 1),
      ),
      child: Column(
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TranslatedText(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _metalBox(
                  title: 'GOLD BALANCE',
                  value: goldBalance,
                  unit: goldUnit,
                  color: AppColors.yellow.alpha == 255
                      ? AppColors.yellow.withOpacity(0.12)
                      : AppColors.yellow,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _metalBox(
                  title: 'SILVER BALANCE',
                  value: silverBalance,
                  unit: silverUnit,
                  color: AppColors.lightBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 42,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onInvestTap,
              icon: const Icon(
                Icons.savings_outlined,
                color: Colors.white,
                size: 16,
              ),
              label: const TranslatedText(
                "Monthly Investment Plan",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 42,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onViewApplicationTap,
              icon: const Icon(
                Icons.description_outlined,
                size: 16,
                color: Color(0xff0F2744),
              ),
              label: const TranslatedText(
                "View Application",
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.yellow.withOpacity(0.12),
                side: const BorderSide(color: AppColors.yellow),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metalBox({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff8A8A8A),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: Color(0xff0F2744),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(
                    color: Color(0xff0F2744),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
        SnackBar(content: TranslatedText('Please enter your unlock password.')),
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

      // final result = await JscService.unlockWallet(
      //   unlockPassword: password,
      //   currency: currency,
      // );

      // log('JSC UNLOCK RESPONSE -> $result');

      // if (!mounted) return;

      // if (result['status'] != true) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: TranslatedText(
      //         result['message']?.toString() ?? 'Unable to unlock balances.',
      //       ),
      //     ),
      //   );

      //   return;
      // }

      // final Map<String, dynamic> data = result['data'] is Map
      //     ? Map<String, dynamic>.from(result['data'])
      //     : <String, dynamic>{};

      // log('JSC UNLOCK DATA -> $data');

      // await widget.onUnlocked(data);

      // if (!mounted) return;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: TranslatedText(
      //       result['message']?.toString() ?? 'Balances unlocked successfully.',
      //     ),
      //   ),
      // );
      // ========================================================
      // JSC UNLOCK
      // ========================================================

      final result = await JscService.unlockWallet(
        unlockPassword: password,
        currency: currency,
      );

      log('JSC UNLOCK RESPONSE -> $result');

      if (!mounted) return;

      if (result['status'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TranslatedText(
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
          content: TranslatedText(
            result['message']?.toString() ?? 'Balances unlocked successfully.',
          ),
        ),
      );

      // ========================================================
      // GSP UNLOCK
      // ========================================================

      try {
        final gspResult = await GspService.unlockWallet(
          unlockPassword: password,
          currency: currency,
        );

        log('GSP UNLOCK RESPONSE -> $gspResult');

        if (gspResult['status'] == true) {
          await SessionManager.saveGspBalanceUnlocked();

          context.read<GspBalanceProvider>().setUnlocked(true);

          log('GSP UNLOCK -> Success');

          final Map<String, dynamic> data = result['data'] is Map
              ? Map<String, dynamic>.from(result['data'])
              : <String, dynamic>{};

          log('GSP UNLOCK DATA -> $data');

          // ========================================================
          // SEND API RESPONSE DATA TO PARENT
          // ========================================================

          await widget.onUnlocked(data);

          if (!mounted) return;

          // ========================================================
          // SUCCESS MESSAGE
          // ========================================================

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: TranslatedText(
                result['message']?.toString() ??
                    'Balances unlocked successfully.',
              ),
            ),
          );
        } else {
          log(
            'GSP UNLOCK -> Failed: '
            '${gspResult['message']}',
          );
        }
      } catch (e, stackTrace) {
        log('GSP UNLOCK ERROR -> $e', stackTrace: stackTrace);
      }
    } catch (e, stackTrace) {
      log('JSC UNLOCK ERROR -> $e', stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatedText(e.toString().replaceFirst('Exception: ', '')),
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sandal,
        border: Border.all(color: AppColors.mustard),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'Your Gold and Silver balances are protected.',
            style: TextStyle(fontSize: 12, color: AppColors.mustard),
          ),

          const TranslatedText(
            'Please enter your unlock password (first 4 characters of your registered email ID + last 4 digits of your registered phone number) to view your balance.',
            style: TextStyle(fontSize: 12, color: AppColors.mustard),
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
                  borderSide: const BorderSide(
                    color: AppColors.mustard,
                    width: 1.5,
                  ),
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
                  : const TranslatedText(
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
  // final String marketValue;
  // final String currencySymbol;
  // final bool isGold;
  // final String image;

  const _BalanceCard({
    required this.title,
    required this.balanceValue,
    required this.unit,
    // required this.marketValue,
    // required this.currencySymbol,
    // required this.isGold,
    // required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // final borderColor = isGold
    //     ? const Color.fromRGBO(232, 190, 46, 1)
    //     : const Color.fromRGBO(178, 186, 205, 1);

    return Container(
      // ❌ NO FIXED HEIGHT
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.sandal,
        border: Border.all(color: AppColors.grey, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================
          // TITLE
          // ============================
          TranslatedText(
            title.toUpperCase(),
            softWrap: true,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Color.fromRGBO(131, 126, 126, 1),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          // ============================
          // BALANCE + UNIT
          // ============================
          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   crossAxisAlignment: CrossAxisAlignment.baseline,
          //   textBaseline: TextBaseline.alphabetic,
          // children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TranslatedText(
                "$balanceValue ",
                softWrap: true,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TranslatedText(
                unit,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 12,
                  // height: 1.15,
                  color: AppColors.grey,
                  // fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // const SizedBox(width: 3),
          // TranslatedText(
          //   unit,
          //   softWrap: true,
          //   style: const TextStyle(
          //     fontSize: 10,
          //     height: 1.2,
          //     fontWeight: FontWeight.w600,
          //   ),
          //     // ),
          //   ],
          // ),
          // const SizedBox(height: 6),

          // // ============================
          // // MARKET VALUE
          // // ============================
          // TranslatedText(
          //   marketValue == '...'
          //       ? '... market value'
          //       : '$marketValue market value',
          //   softWrap: true,
          //   style: const TextStyle(
          //     fontSize: 10,
          //     height: 1.3,
          //     fontWeight: FontWeight.w600,
          //     color: Color.fromRGBO(178, 186, 205, 1),
          //   ),
          // ),

          // const SizedBox(height: 6),

          // ============================
          // IMAGE
          // ============================
          // Align(
          //   alignment: Alignment.centerLeft,
          //   child: Image.asset(
          //     image,
          //     height: 35,
          //     width: 35,
          //     fit: BoxFit.contain,
          //   ),
          // ),
        ],
      ),
    );
  }
}
