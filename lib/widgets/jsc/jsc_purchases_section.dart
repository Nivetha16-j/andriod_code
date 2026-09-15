import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
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
      final unlocked = await SessionManager.isJscBalanceUnlocked();

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
          const TranslatedText(
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
            child: const TranslatedText(
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
              child: TranslatedText(
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
              child: TranslatedText(
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
          width: 870,
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
                      child: TranslatedText(
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
                      child: TranslatedText(
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
                      child: TranslatedText(
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
                      child: TranslatedText(
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
                      child: TranslatedText(
                        "TODAY'S MARKET PRICE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 160,
                      child: TranslatedText(
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

    final status = marketStatus.toLowerCase();

    final isUp = status == 'up';
    final isDown = status == 'down';
    final isFlat = status == 'flat';

    final statusColor = isUp
        ? const Color(0xFF168B3A)
        : isDown
        ? const Color(0xFFD20D2D)
        : const Color(0xFF777777);

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
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
            child: TranslatedText(
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

                TranslatedText(
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
                TranslatedText(
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
                  child: TranslatedText(
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
                TranslatedText(
                  '${double.tryParse(quantity)?.toStringAsFixed(4) ?? quantity} $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                TranslatedText(
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
            child: TranslatedText(
              '$todayPrice/$unit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          // ==========================
          // MARKET STATUS
          // ==========================
          SizedBox(
            width: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ======================================================
                // GRAPH + PRICE DIFFERENCE
                // ======================================================
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MarketTrendGraph(
                        status: marketStatus,
                        color: statusColor,
                      ),

                      const SizedBox(height: 4),

                      TranslatedText(
                        priceDiff,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),

                      const SizedBox(height: 2),

                      TranslatedText(
                        priceDiffPercent,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // const SizedBox(width: 4),

                // ======================================================
                // STATUS BADGE
                // ======================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUp
                        ? const Color(0xFFE4F4EA)
                        : isDown
                        ? const Color(0xFFFBE5E5)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp
                            ? Icons.arrow_upward
                            : isDown
                            ? Icons.arrow_downward
                            : Icons.arrow_forward,
                        size: 10,
                        color: statusColor,
                      ),

                      const SizedBox(width: 3),

                      TranslatedText(
                        marketStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
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
// MARKET TREND GRAPH
// ============================================================================

class _MarketTrendGraph extends StatelessWidget {
  final String status;
  final Color color;

  const _MarketTrendGraph({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 30,
      child: CustomPaint(
        painter: _MarketTrendPainter(status: status, color: color),
      ),
    );
  }
}

// ============================================================================
// MARKET TREND PAINTER
// ============================================================================

class _MarketTrendPainter extends CustomPainter {
  final String status;
  final Color color;

  _MarketTrendPainter({required this.status, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final normalizedStatus = status.trim().toLowerCase();

    final paint = Paint()
      ..color = normalizedStatus == 'flat' ? const Color(0xFF999999) : color
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    if (normalizedStatus == 'up') {
      // Rising green trend
      path.moveTo(2, 23);
      path.lineTo(14, 17);
      path.lineTo(25, 19);
      path.lineTo(36, 12);
      path.lineTo(48, 14);
      path.lineTo(60, 5);
    } else if (normalizedStatus == 'down') {
      // Falling red trend
      path.moveTo(2, 5);
      path.lineTo(14, 11);
      path.lineTo(25, 9);
      path.lineTo(36, 16);
      path.lineTo(48, 18);
      path.lineTo(60, 25);
    } else {
      // Flat grey trend
      final y = size.height / 2;

      path.moveTo(2, y);
      path.lineTo(size.width - 2, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MarketTrendPainter oldDelegate) {
    return oldDelegate.status != status || oldDelegate.color != color;
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
