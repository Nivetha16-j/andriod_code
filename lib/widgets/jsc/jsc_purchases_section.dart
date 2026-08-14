import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:provider/provider.dart';

class JscPurchasesSection extends StatefulWidget {
  final bool? isUnlocked;

  const JscPurchasesSection({super.key, this.isUnlocked});

  @override
  State<JscPurchasesSection> createState() => _JscPurchasesSectionState();
}

class _JscPurchasesSectionState extends State<JscPurchasesSection> {
  Timer? _timer;

  List<Map<String, dynamic>> purchases = [];

  bool isLoading = false;

  // This is the actual unlock state used by this widget
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();

    _initializePurchases();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializePurchases() async {
    // If parent explicitly gives the unlock state,
    // use that.
    if (widget.isUnlocked != null) {
      _isUnlocked = widget.isUnlocked!;

      if (_isUnlocked) {
        _startPurchasesRefresh();
      }

      if (mounted) {
        setState(() {});
      }

      return;
    }

    // Otherwise check saved unlock status
    // from SessionManager.
    try {
      final unlocked = await SessionManager.isBalanceUnlocked();

      if (!mounted) return;

      setState(() {
        _isUnlocked = unlocked;
      });

      if (unlocked) {
        _startPurchasesRefresh();
      }
    } catch (e) {
      log('Purchase unlock status error: $e');
    }
  }

  // ============================================================
  // WIDGET UPDATE
  // ============================================================

  @override
  void didUpdateWidget(covariant JscPurchasesSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only react when parent actually provides
    // an unlock value.
    if (widget.isUnlocked != null &&
        oldWidget.isUnlocked != widget.isUnlocked) {
      _isUnlocked = widget.isUnlocked!;

      if (_isUnlocked) {
        _startPurchasesRefresh();
      } else {
        _stopPurchasesRefresh();
      }
    }
  }

  // ============================================================
  // START PURCHASE REFRESH
  // ============================================================

  void _startPurchasesRefresh() {
    _stopPurchasesRefresh();

    // Call immediately
    _fetchPurchases();

    // Then every second
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
    if (!_isUnlocked) return;

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      log('Fetching purchases with currency: $currency');

      final result = await JscService.getPurchases(currency: currency);

      if (!mounted) return;

      log('Purchases response: $result');

      if (result['status'] == true) {
        final data = result['data'];

        setState(() {
          purchases = data is List ? List<Map<String, dynamic>>.from(data) : [];
        });
      }
    } catch (e) {
      log('Purchases API error: $e');
    }
  }

  @override
  void dispose() {
    _stopPurchasesRefresh();
    super.dispose();
  }

  // ============================================================
  // UI
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
          width: 820, // keeps the table readable
          child: Column(
            children: [
              // ================================
              // TABLE HEADER
              // ================================
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

              // ================================
              // PURCHASE ROWS
              // ================================
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

    // Format date
    String formattedDate = date;

    try {
      final parsedDate = DateTime.parse(date).toLocal();

      formattedDate =
          '${_monthName(parsedDate.month)} '
          '${parsedDate.day}, '
          '${parsedDate.year}';
    } catch (_) {}

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
          // ==========================
          // DATE
          // ==========================
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

          // ==========================
          // METAL
          // ==========================
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

          // ==========================
          // PRODUCT NAME
          // ==========================
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

          // ==========================
          // PURCHASED AMOUNT
          // ==========================
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

          // ==========================
          // TODAY PRICE
          // ==========================
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

          // ==========================
          // MARKET STATUS
          // ==========================
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$priceDiff',
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
                      '$priceDiffPercent',
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

// ============================================================================
// STRING CAPITALIZE
// ============================================================================

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;

    return '${this[0].toUpperCase()}'
        '${substring(1)}';
  }
}
