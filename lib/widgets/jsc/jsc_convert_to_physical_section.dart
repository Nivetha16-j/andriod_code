import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:provider/provider.dart';

class JscConvertPhysicalSection extends StatefulWidget {
  final bool? isUnlocked;

  const JscConvertPhysicalSection({super.key, this.isUnlocked});

  @override
  State<JscConvertPhysicalSection> createState() =>
      _JscConvertPhysicalSectionState();
}

class _JscConvertPhysicalSectionState extends State<JscConvertPhysicalSection> {
  Timer? _timer;

  Map<String, dynamic>? gold;
  Map<String, dynamic>? silver;

  bool isLoading = false;

  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();

    _initializeConvert();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  void _initializeConvert() {
    if (widget.isUnlocked != null) {
      _isUnlocked = widget.isUnlocked!;

      debugPrint('🟢 CONVERT INIT -> isUnlocked = $_isUnlocked');

      if (_isUnlocked) {
        _startConvertRefresh();
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ============================================================
  // WIDGET UPDATE
  // ============================================================

  @override
  void didUpdateWidget(covariant JscConvertPhysicalSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked != null &&
        oldWidget.isUnlocked != widget.isUnlocked) {
      _isUnlocked = widget.isUnlocked!;

      debugPrint('🔄 CONVERT UNLOCK CHANGED -> $_isUnlocked');

      if (_isUnlocked) {
        _startConvertRefresh();
      } else {
        _stopConvertRefresh();

        setState(() {
          gold = null;
          silver = null;
        });
      }
    }
  }

  // ============================================================
  // START REFRESH
  // ============================================================

  void _startConvertRefresh() {
    _stopConvertRefresh();

    debugPrint('🚀 STARTING CONVERT PHYSICAL REFRESH');

    // First call immediately
    fetchConvertPhysical();

    // Then every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      fetchConvertPhysical();
    });
  }

  // ============================================================
  // STOP REFRESH
  // ============================================================

  void _stopConvertRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  // ============================================================
  // FETCH CONVERT PHYSICAL
  // ============================================================

  Future<void> fetchConvertPhysical() async {
    if (!_isUnlocked) return;

    // Prevent overlapping API calls
    if (isLoading) return;

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      log('Fetching convert physical with currency: $currency');

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final response = await JscService.fetchConvertPhysicalDetails(
        currency: currency,
      );

      debugPrint('🔥 CONVERT API RESPONSE = $response');

      final data = response['data'] as Map<String, dynamic>?;

      final summary = data?['summary'] as Map<String, dynamic>?;

      final fetchedGold = summary?['gold'] as Map<String, dynamic>?;

      final fetchedSilver = summary?['silver'] as Map<String, dynamic>?;

      debugPrint('🔥 GOLD = $fetchedGold');

      debugPrint('🔥 SILVER = $fetchedSilver');

      if (!mounted) return;

      setState(() {
        gold = fetchedGold;
        silver = fetchedSilver;
      });
    } catch (e) {
      debugPrint('❌ Convert Physical Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🟢 CONVERT BUILD -> '
      'unlocked=$_isUnlocked '
      'loading=$isLoading '
      'gold=$gold '
      'silver=$silver',
    );

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Convert to Physical',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.13),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: Text(
              _isUnlocked
                  ? 'Convert part or all of your digital holdings '
                        'into physical products. Minimum balance to '
                        'convert: $_goldThresholdLabel of gold or '
                        '$_silverThresholdLabel of silver.'
                  : 'Convert part or all of your digital holdings '
                        'into physical products. Minimum balance to '
                        'convert: 50 g of gold or 1 kg of silver.',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ),

          const SizedBox(height: 9),

          // ======================================================
          // LOCKED
          // ======================================================
          if (!_isUnlocked) ...[
            _convertRow(
              metal: 'Gold',
              available: 'Available: .... · Min: 50 g',
              buttonText:
                  'Unlock your balances to check physical '
                  'conversion eligibility.',
              enabled: false,
              onPressed: null,
            ),

            const SizedBox(height: 8),

            _convertRow(
              metal: 'Silver',
              available: 'Available: .... · Min: 1 kg',
              buttonText:
                  'Unlock your balances to check physical '
                  'conversion eligibility.',
              enabled: false,
              onPressed: null,
            ),
          ]
          // ======================================================
          // LOADING
          // ======================================================
          else if (isLoading && gold == null && silver == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          // ======================================================
          // DATA
          // ======================================================
          else ...[
            _convertRow(
              metal: 'Gold',
              available:
                  'Available: $_goldAvailableText · '
                  'Min: $_goldThresholdLabel',
              buttonText: _canConvertGold
                  ? 'Convert to physical gold'
                  : 'Reach $_goldThresholdLabel '
                        'to unlock physical conversion.',
              enabled: _canConvertGold,
              onPressed: _canConvertGold ? _openGoldConversion : null,
            ),

            const SizedBox(height: 8),

            _convertRow(
              metal: 'Silver',
              available:
                  'Available: $_silverAvailableText · '
                  'Min: $_silverThresholdLabel',
              buttonText: _canConvertSilver
                  ? 'Convert to physical silver'
                  : 'Reach $_silverThresholdLabel '
                        'to unlock physical conversion.',
              enabled: _canConvertSilver,
              onPressed: _canConvertSilver ? _openSilverConversion : null,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // GOLD
  // ============================================================

  String get _goldAvailableText {
    final value = gold?['balance'];

    if (value == null) {
      return '0 g';
    }

    return '$value g';
  }

  // ============================================================
  // SILVER
  // ============================================================

  String get _silverAvailableText {
    final value = silver?['balance'];

    if (value == null) {
      return '0 g';
    }

    return '$value g';
  }

  // ============================================================
  // GOLD THRESHOLD
  // ============================================================

  String get _goldThresholdLabel {
    final value = gold?['minimum_balance'];

    if (value == null) {
      return '50 g';
    }

    return '$value g';
  }

  // ============================================================
  // SILVER THRESHOLD
  // ============================================================

  String get _silverThresholdLabel {
    final value = silver?['minimum_balance'];

    if (value == null) {
      return '1 kg';
    }

    return '$value g';
  }

  // ============================================================
  // GOLD ELIGIBILITY
  // ============================================================

  bool get _canConvertGold {
    final balance = double.tryParse('${gold?['balance'] ?? 0}') ?? 0;

    final minimum = double.tryParse('${gold?['minimum_balance'] ?? 50}') ?? 50;

    return balance >= minimum;
  }

  // ============================================================
  // SILVER ELIGIBILITY
  // ============================================================

  bool get _canConvertSilver {
    final balance = double.tryParse('${silver?['balance'] ?? 0}') ?? 0;

    final minimum =
        double.tryParse('${silver?['minimum_balance'] ?? 1000}') ?? 1000;

    return balance >= minimum;
  }

  // ============================================================
  // CONTAINER
  // ============================================================

  Widget _buildContainer({required Widget child}) {
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
      child: child,
    );
  }

  // ============================================================
  // ROW
  // ============================================================

  Widget _convertRow({
    required String metal,
    required String available,
    required String buttonText,
    required bool enabled,
    VoidCallback? onPressed,
  }) {
    final bool isGold = metal == 'Gold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metal,
              style: TextStyle(
                fontSize: 10,
                color: isGold
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                fontWeight: FontWeight.w600,
              ),
            ),

            Flexible(
              child: Text(
                available,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(120, 112, 112, 1),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          height: 27,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: const Color(0xFFFFFBF0),
              side: BorderSide(
                color: isGold
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openGoldConversion() {
    // TODO
  }

  void _openSilverConversion() {
    // TODO
  }
}
