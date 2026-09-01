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

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializeBalanceState() async {
    try {
      final bool unlocked = await SessionManager.isGspBalanceUnlocked();

      log('GSP BALANCE -> Saved unlock state: $unlocked');

      if (!mounted) return;

      balanceUnlockedNotifier.value = unlocked;

      final provider = context.read<GspBalanceProvider>();

      if (!unlocked) {
        provider.setUnlocked(false);
        provider.clearWalletData();
      } else {
        // Same behaviour as JSC
        provider.setUnlocked(true);

        setState(() {
          isBalanceUnlocked = true;
        });

        // IMPORTANT:
        // Restore wallet from backend after app restart.
        await _fetchAllBackendData();
      }
    } catch (e, stackTrace) {
      log('GSP BALANCE -> Initialization error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      balanceUnlockedNotifier.value = false;

      context.read<GspBalanceProvider>().setUnlocked(false);

      context.read<GspBalanceProvider>().clearWalletData();

      setState(() {
        isBalanceUnlocked = false;
      });

      await SessionManager.clearGspBalanceUnlocked();
    } finally {
      if (!mounted) return;

      setState(() {
        isCheckingUnlockState = false;
      });
    }
  }

  // ============================================================
  // GLOBAL UNLOCK STATE CHANGED
  // ============================================================

  void _onBalanceStateChanged() {
    if (!mounted) return;

    final bool unlocked = balanceUnlockedNotifier.value;

    if (isBalanceUnlocked == unlocked) {
      return;
    }

    setState(() {
      isBalanceUnlocked = unlocked;
    });

    final provider = context.read<GspBalanceProvider>();

    if (!unlocked) {
      provider.setUnlocked(false);
      provider.clearWalletData();
    }
  }

  // ============================================================
  // FETCH ALL BACKEND DATA
  // ============================================================

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

      log('GSP BALANCE -> Fetching backend data');

      log('GSP BALANCE -> Currency: $currency');

      await _fetchWallet(currency);

      try {
        final sellBackResult = await GspService.getSellBackDetails(
          currency: currency,
        );

        log(
          'Gsp BALANCE -> Sell Back: '
          '$sellBackResult',
        );
      } catch (e, stackTrace) {
        log('JSC BALANCE -> Sell Back error: $e', stackTrace: stackTrace);
      }

      if (mounted) {
        await widget.onUnlocked?.call();
      }
    } catch (e, stackTrace) {
      log('GSP BALANCE -> Backend fetch error: $e', stackTrace: stackTrace);
    } finally {
      if (!mounted) return;

      setState(() {
        isFetchingWallet = false;
      });
    }
  }

  // ============================================================
  // FETCH GSP WALLET
  // ============================================================

  Future<void> _fetchWallet(String currency) async {
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

      final provider = context.read<GspBalanceProvider>();

      provider.setUnlocked(true);

      provider.setWalletData({
        'goldBalance': goldBalance,
        'goldUnit': goldUnit,
        'goldMarketValue': goldMarketValue,

        'silverBalance': silverBalance,
        'silverUnit': silverUnit,
        'silverMarketValue': silverMarketValue,

        'currency': walletCurrency,
        'currencySymbol': currencySymbol,
      });

      log('GSP WALLET -> Provider updated successfully');
    } catch (e, stackTrace) {
      log('GSP WALLET -> Fetch error: $e', stackTrace: stackTrace);
    }
  }
  // ============================================================
  // UNLOCK SUCCESS
  // ============================================================

  Future<void> _onBalancesUnlocked(Map<String, dynamic> unlockData) async {
    try {
      log(
        'GSP UNLOCK -> Backend unlock response: '
        '$unlockData',
      );

      // ========================================================
      // STEP 1
      // SAVE ONLY UNLOCK STATE
      // ========================================================

      await SessionManager.saveGspBalanceUnlocked();

      log('GSP UNLOCK -> Unlock state saved');

      if (!mounted) return;

      // ========================================================
      // STEP 2
      // GLOBAL NOTIFIER
      // ========================================================

      balanceUnlockedNotifier.value = true;

      // ========================================================
      // STEP 3
      // PROVIDER
      // ========================================================

      context.read<GspBalanceProvider>().setUnlocked(true);

      setState(() {
        isBalanceUnlocked = true;
      });

      // ========================================================
      // STEP 4
      // FETCH ACTUAL WALLET FROM BACKEND
      // ========================================================

      await _fetchAllBackendData();

      log('GSP UNLOCK -> Backend wallet fetched successfully');

      // ========================================================
      // STEP 5
      // CALLBACK
      // ========================================================

      if (mounted) {
        await widget.onUnlocked?.call();
      }
    } catch (e, stackTrace) {
      log('GSP UNLOCK -> Error after unlock: $e', stackTrace: stackTrace);
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

    return Consumer<GspBalanceProvider>(
      builder: (context, gspProvider, child) {
        final bool unlocked = gspProvider.isBalancesUnlocked;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // UNLOCK CARD
            // ======================================================
            if (!unlocked) UnlockBalanceCard(onUnlocked: _onBalancesUnlocked),

            if (!unlocked) const SizedBox(height: 20),

            // ======================================================
            // GOLD
            // ======================================================
            if (widget.showBalances)
              _GoldBalanceCard(
                balanceValue: gspProvider.goldBalance ?? '...',
                unit: gspProvider.goldUnit ?? 'grams',
                marketValue: gspProvider.goldMarketValue ?? '...',
                currencySymbol: gspProvider.currencySymbol ?? '',
              ),

            // ======================================================
            // SILVER
            // ======================================================
            if (widget.showBalances) ...[
              const SizedBox(height: 12),

              _BalanceCard(
                title: 'Silver Balance',
                balanceValue: gspProvider.silverBalance ?? '...',
                unit: gspProvider.silverUnit ?? 'grams',
                marketValue: gspProvider.silverMarketValue ?? '...',
                currencySymbol: gspProvider.currencySymbol ?? '',
                isGold: false,
                image: 'assets/s_balance.png',
              ),
            ],
          ],
        );
      },
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

    try {
      final currencyProvider = context.read<CurrencyProvider>();

      final String currency = currencyProvider.selectedCurrency;

      log('GSP UNLOCK -> Currency: $currency');

      // ========================================================
      // ONLY API CALL
      // ========================================================

      final Map<String, dynamic> result = await GspService.unlockWallet(
        unlockPassword: password,
        currency: currency,
      );

      log('GSP UNLOCK RESPONSE -> $result');

      if (!mounted) return;

      // ========================================================
      // CHECK STATUS
      // ========================================================

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

      // ========================================================
      // GET DATA
      // ========================================================

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
          content: Text(
            result['message']?.toString() ?? 'Balances unlocked successfully.',
          ),
        ),
      );

      // Optional: clear password
      controller.clear();
    } catch (e, stackTrace) {
      log('GSP UNLOCK ERROR -> $e', stackTrace: stackTrace);

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

class _GoldBalanceCard extends StatelessWidget {
  final String balanceValue;
  final String unit;
  final String marketValue;
  final String currencySymbol;

  const _GoldBalanceCard({
    required this.balanceValue,
    required this.unit,
    required this.marketValue,
    required this.currencySymbol,
  });

  String _formatValue(String value) {
    final double? number = double.tryParse(value);

    if (number == null) {
      return value;
    }

    return number.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 137,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFFBFC), Color(0xFFFFF7E7)],
        ),
        border: Border.all(color: const Color(0xFFF5C9D0), width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          // ====================================================
          // TITLE
          // ====================================================
          Positioned(
            left: 0,
            top: 6,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDDB52E),
                    border: Border.all(
                      color: const Color(0xFFF1E5B8),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'GOLD BALANCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF777171),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // GSP BADGE
          // ====================================================
          Positioned(
            right: 3,
            top: 1,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8ED),
                border: Border.all(color: const Color(0xFFF4BFC9), width: 0.8),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Text(
                'GSP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD20D2D),
                ),
              ),
            ),
          ),

          // ====================================================
          // BALANCE
          // ====================================================
          Positioned(
            left: 2,
            bottom: 11,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balanceValue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(width: 4),

                Text(
                  unit.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // CURRENT GOLD VALUE
          // ====================================================
          Positioned(
            right: 3,
            bottom: 1,
            child: Container(
              width: 320,
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                border: Border.all(color: const Color(0xFFF2C9D0), width: 0.8),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CURRENT GOLD VALUE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF986A25),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    marketValue == '...'
                        ? '....'
                        : '${_formatValue(marketValue)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF986A25),
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

  String _formatValue(String value) {
    final double? number = double.tryParse(value);

    if (number == null) {
      return value;
    }

    return number.toStringAsFixed(2);
  }

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
                : '${_formatValue(marketValue)} market value',
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
