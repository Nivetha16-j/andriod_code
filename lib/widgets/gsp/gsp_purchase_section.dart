import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/gsp_service.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';
import 'package:provider/provider.dart';

class GspPurchasesSection extends StatefulWidget {
  final bool? isUnlocked;

  const GspPurchasesSection({super.key, this.isUnlocked});

  @override
  State<GspPurchasesSection> createState() => _GspPurchasesSectionState();
}

class _GspPurchasesSectionState extends State<GspPurchasesSection> {
  Timer? _timer;

  List<Map<String, dynamic>> purchases = [];

  bool isLoading = false;

  // Actual unlock state used by this widget.
  bool _isUnlocked = false;

  // Prevent multiple API calls at the same time.
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();

    // Listen to the same global unlock state used by GspBalanceSection.
    balanceUnlockedNotifier.addListener(_onUnlockStateChanged);

    _initializePurchases();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializePurchases() async {
    try {
      bool unlocked;

      // If parent explicitly provides unlock state, use it.
      if (widget.isUnlocked != null) {
        unlocked = widget.isUnlocked!;
      } else {
        // Otherwise read the saved state.
        unlocked = await SessionManager.isGspBalanceUnlocked();
      }

      if (!mounted) return;

      log('GSP PURCHASES -> Unlock state: $unlocked');

      setState(() {
        _isUnlocked = unlocked;
      });

      if (unlocked) {
        _startPurchasesRefresh();
      } else {
        _stopPurchasesRefresh();

        setState(() {
          purchases = [];
        });
      }
    } catch (e, stackTrace) {
      log('GSP PURCHASES -> Initialization error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isUnlocked = false;
        purchases = [];
      });
    }
  }

  // ============================================================
  // GLOBAL UNLOCK STATE CHANGED
  // ============================================================

  void _onUnlockStateChanged() {
    if (!mounted) return;

    final unlocked = balanceUnlockedNotifier.value;

    log('GSP PURCHASES -> Global unlock changed: $unlocked');

    if (_isUnlocked == unlocked) {
      return;
    }

    setState(() {
      _isUnlocked = unlocked;
    });

    if (unlocked) {
      // Balance has just been unlocked.
      // Start fetching purchases immediately.
      _startPurchasesRefresh();
    } else {
      // Logout/reset.
      _stopPurchasesRefresh();

      setState(() {
        purchases = [];
      });
    }
  }

  // ============================================================
  // WIDGET UPDATE
  // ============================================================

  @override
  void didUpdateWidget(covariant GspPurchasesSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked != null &&
        oldWidget.isUnlocked != widget.isUnlocked) {
      final unlocked = widget.isUnlocked!;

      log('GSP PURCHASES -> Parent unlock changed: $unlocked');

      setState(() {
        _isUnlocked = unlocked;
      });

      if (unlocked) {
        _startPurchasesRefresh();
      } else {
        _stopPurchasesRefresh();

        setState(() {
          purchases = [];
        });
      }
    }
  }

  // ============================================================
  // START PURCHASE REFRESH
  // ============================================================

  void _startPurchasesRefresh() {
    _stopPurchasesRefresh();

    if (!_isUnlocked) {
      return;
    }

    // Fetch immediately.
    _fetchPurchases();

    // Keep refreshing.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchPurchases();
    });
  }

  // ============================================================
  // STOP PURCHASE REFRESH
  // ============================================================

  void _stopPurchasesRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  // ============================================================
  // FETCH PURCHASES
  // ============================================================

  Future<void> _fetchPurchases() async {
    if (!_isUnlocked) {
      return;
    }

    if (_isFetching) {
      return;
    }

    _isFetching = true;

    try {
      final currencyProvider = context.read<CurrencyProvider>();

      final String currency = currencyProvider.selectedCurrency;

      log('GSP PURCHASES -> Fetching purchases with currency: $currency');

      final result = await GspService.getPurchases(currency: currency);

      if (!mounted) return;

      log('GSP PURCHASES -> Full response: $result');

      // ========================================================
      // CHECK API STATUS
      // ========================================================

      if (result['status'] != true) {
        log(
          'GSP PURCHASES -> API returned false status: '
          '${result['message']}',
        );

        return;
      }

      // ========================================================
      // GET DATA
      // ========================================================

      final dynamic rawData = result['data'];

      if (rawData is! Map) {
        log(
          'GSP PURCHASES -> Invalid data structure: '
          '${rawData.runtimeType}',
        );

        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

      // ========================================================
      // IMPORTANT:
      //
      // purchases is INSIDE data
      //
      // data:
      // {
      //   summary: {...},
      //   purchases: [...],
      //   transactions: [...],
      //   ...
      // }
      // ========================================================

      final dynamic rawPurchases = data['purchases'];

      if (rawPurchases is! List) {
        log(
          'GSP PURCHASES -> purchases is not a List: '
          '${rawPurchases.runtimeType}',
        );

        if (mounted) {
          setState(() {
            purchases = [];
          });
        }

        return;
      }

      final List<Map<String, dynamic>> parsedPurchases = rawPurchases
          .where((item) => item is Map)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      log('GSP PURCHASES -> Parsed ${parsedPurchases.length} purchases');

      // ========================================================
      // UPDATE UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        purchases = parsedPurchases;
      });
    } catch (e, stackTrace) {
      log('GSP PURCHASES -> API error: $e', stackTrace: stackTrace);
    } finally {
      _isFetching = false;
    }
  }

  @override
  void dispose() {
    _stopPurchasesRefresh();

    balanceUnlockedNotifier.removeListener(_onUnlockStateChanged);

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF9),
        border: Border.all(color: const Color(0xFFD20D2D), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Purchases',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: const Text(
              "Track each digital purchase against today's market price.",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ),

          const SizedBox(height: 8),

          // ======================================================
          // LOCKED
          // ======================================================
          if (!_isUnlocked)
            const Center(
              child: Text(
                'Unlock your balances to view your purchases.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            )
          // ======================================================
          // NO PURCHASES
          // ======================================================
          else if (purchases.isEmpty)
            const Center(
              child: Text(
                'No digital gold or silver purchases yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            )
          // ======================================================
          // PURCHASE TABLE
          // ======================================================
          else
            _PurchaseTable(purchases: purchases),
        ],
      ),
    );
  }
}

// ============================================================================
// PURCHASE TABLE
// ============================================================================

class _PurchaseTable extends StatelessWidget {
  final List<Map<String, dynamic>> purchases;

  const _PurchaseTable({required this.purchases});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E4), width: 0.7),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: 820,
          child: Column(
            children: [
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: const Color(0xFFF5F6F8),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        'PURCHASE DATE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 75,
                      child: Text(
                        'METAL',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: Text(
                        'PRODUCT NAME',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        'PURCHASED AMOUNT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        "TODAY'S MARKET PRICE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: Text(
                        'MARKET STATUS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              ...purchases.map(
                (purchase) => _PurchaseTableRow(purchase: purchase),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PURCHASE TABLE ROW
// ============================================================================

class _PurchaseTableRow extends StatelessWidget {
  final Map<String, dynamic> purchase;

  const _PurchaseTableRow({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final productName = purchase['product_name']?.toString() ?? '';

    final date = purchase['date']?.toString() ?? '';

    final metal = purchase['metal']?.toString() ?? '';

    final quantity = purchase['quantity']?.toString() ?? '0';

    final unit =
        purchase['unit_short']?.toString() ??
        purchase['unit']?.toString() ??
        '';

    final purchasePrice =
        purchase['formatted_purchase_price']?.toString() ?? '';

    final todayPrice = purchase['formatted_today_price']?.toString() ?? '';

    final priceDiff = purchase['formatted_price_diff']?.toString() ?? '';

    final priceDiffPercent =
        purchase['formatted_price_diff_percent']?.toString() ?? '';

    final marketStatus = purchase['market_status']?.toString() ?? '';

    // ============================================================
    // DATE
    // ============================================================

    String formattedDate = date;

    try {
      final parsedDate = DateTime.parse(date).toLocal();

      formattedDate =
          '${_monthName(parsedDate.month)} '
          '${parsedDate.day}, '
          '${parsedDate.year}';
    } catch (_) {}

    // ============================================================
    // MARKET STATUS
    // ============================================================

    final isUp = marketStatus.toLowerCase() == 'up';

    return Container(
      constraints: const BoxConstraints(minHeight: 95),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFEFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DATE
          SizedBox(
            width: 110,
            child: Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
          ),

          // METAL
          SizedBox(
            width: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  metal.toLowerCase() == 'gold'
                      ? 'assets/g_balance.png'
                      : 'assets/s_balance.png',
                  height: 25,
                  width: 25,
                ),

                const SizedBox(height: 3),

                Text(
                  metal.isEmpty
                      ? ''
                      : metal[0].toUpperCase() +
                            metal.substring(1).toLowerCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // PRODUCT NAME
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    purchase['purchase_subtype']?.toString().toUpperCase() ??
                        '',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PURCHASED AMOUNT
          SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${double.tryParse(quantity)?.toStringAsFixed(4) ?? quantity} $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '@ $purchasePrice/$unit',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF777777)),
                ),
              ],
            ),
          ),

          // TODAY PRICE
          SizedBox(
            width: 150,
            child: Text(
              '$todayPrice/$unit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUp ? const Color(0xFF168B3A) : const Color(0xFFD20D2D),
              ),
            ),
          ),

          // MARKET STATUS
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceDiff,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUp
                            ? const Color(0xFF168B3A)
                            : const Color(0xFFD20D2D),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      priceDiffPercent,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUp
                            ? const Color(0xFF168B3A)
                            : const Color(0xFFD20D2D),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUp
                        ? const Color(0xFFE4F4EA)
                        : const Color(0xFFFBE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: isUp
                            ? const Color(0xFF168B3A)
                            : const Color(0xFFD20D2D),
                      ),

                      const SizedBox(width: 3),

                      Text(
                        marketStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isUp
                              ? const Color(0xFF168B3A)
                              : const Color(0xFFD20D2D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }
}
