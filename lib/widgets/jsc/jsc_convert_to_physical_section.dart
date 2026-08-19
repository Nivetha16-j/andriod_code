import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
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

  final TextEditingController _goldAmountController = TextEditingController();
  final TextEditingController _silverAmountController = TextEditingController();

  String? _goldAmountError;
  String? _silverAmountError;

  @override
  void initState() {
    super.initState();

    _initializeConvert();
  }

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

  @override
  void dispose() {
    _timer?.cancel();
    _goldAmountController.dispose();
    _silverAmountController.dispose();
    super.dispose();
  }

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

  void _stopConvertRefresh() {
    _timer?.cancel();
    _timer = null;
  }

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

      // Set default conversion amounts
      final goldBalance =
          double.tryParse('${fetchedGold?['balance'] ?? 0}') ?? 0;

      final goldMinimum =
          double.tryParse('${fetchedGold?['minimum_balance'] ?? 50}') ?? 50;

      final silverBalance =
          double.tryParse('${fetchedSilver?['balance'] ?? 0}') ?? 0;

      final silverMinimum =
          double.tryParse('${fetchedSilver?['minimum_balance'] ?? 1000}') ??
          1000;

      // Gold
      if (_goldAmountController.text.isEmpty) {
        if (goldBalance >= goldMinimum) {
          _goldAmountController.text = goldMinimum.toStringAsFixed(4);
        }
      }

      // Silver
      if (_silverAmountController.text.isEmpty) {
        if (silverBalance >= silverMinimum) {
          _silverAmountController.text = silverMinimum.toStringAsFixed(4);
        }
      }
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

          // if (!_isUnlocked) ...[
          //   _convertRow(
          //     metal: 'Gold',
          //     available: 'Available: .... · Min: 50 g',
          //     buttonText:
          //         'Unlock your balances to check physical '
          //         'conversion eligibility.',
          //     enabled: false,
          //     onPressed: null,
          //   ),

          //   const SizedBox(height: 8),

          //   _convertRow(
          //     metal: 'Silver',
          //     available: 'Available: .... · Min: 1 kg',
          //     buttonText:
          //         'Unlock your balances to check physical '
          //         'conversion eligibility.',
          //     enabled: false,
          //     onPressed: null,
          //   ),
          // ]
          if (!_isUnlocked) ...[
            _convertRow(
              metal: 'Gold',
              available: 'Available: .... · Min: 50 g',
              enabled: false,
              controller: _goldAmountController,
              errorText: null,
              onAmountChanged: (_) {},
              onPressed: null,
            ),

            const SizedBox(height: 8),

            _convertRow(
              metal: 'Silver',
              available: 'Available: .... · Min: 1 kg',
              enabled: false,
              controller: _silverAmountController,
              errorText: null,
              onAmountChanged: (_) {},
              onPressed: null,
            ),
          ] else if (isLoading && gold == null && silver == null)
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
          else ...[
            _convertRow(
              metal: 'Gold',
              available:
                  'Available: $_goldAvailableText · '
                  'Min: $_goldThresholdLabel',
              enabled: _canConvertGold,
              controller: _goldAmountController,
              errorText: _goldAmountError,
              onAmountChanged: _onGoldAmountChanged,
              onPressed: _canConvertGold ? _openGoldConversion : null,
            ),

            const SizedBox(height: 8),

            _convertRow(
              metal: 'Silver',
              available:
                  'Available: $_silverAvailableText · '
                  'Min: $_silverThresholdLabel',
              enabled: _canConvertSilver,
              controller: _silverAmountController,
              errorText: _silverAmountError,
              onAmountChanged: _onSilverAmountChanged,
              onPressed: _canConvertSilver ? _openSilverConversion : null,
            ),
          ],
        ],
      ),
    );
  }

  String get _goldAvailableText {
    final value = gold?['balance'];

    if (value == null) {
      return '0 g';
    }

    return '$value g';
  }

  String get _silverAvailableText {
    final value = silver?['balance'];

    if (value == null) {
      return '0 g';
    }

    return '$value g';
  }

  String get _goldThresholdLabel {
    final value = gold?['minimum_balance'];

    if (value == null) {
      return '50 g';
    }

    return '$value g';
  }

  String get _silverThresholdLabel {
    final value = silver?['minimum_balance'];

    if (value == null) {
      return '1 kg';
    }

    return '$value g';
  }

  bool get _canConvertGold {
    final balance = double.tryParse('${gold?['balance'] ?? 0}') ?? 0;

    final minimum = double.tryParse('${gold?['minimum_balance'] ?? 50}') ?? 50;

    return balance >= minimum;
  }

  bool get _canConvertSilver {
    final balance = double.tryParse('${silver?['balance'] ?? 0}') ?? 0;

    final minimum =
        double.tryParse('${silver?['minimum_balance'] ?? 1000}') ?? 1000;

    return balance >= minimum;
  }

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

  Widget _convertRow({
    required String metal,
    required String available,
    required bool enabled,
    required TextEditingController controller,
    required String? errorText,
    required ValueChanged<String> onAmountChanged,
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

        if (enabled)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    labelText: 'AMOUNT TO CONVERT (G)',
                    labelStyle: const TextStyle(fontSize: 10),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    errorText: errorText,
                  ),
                  onChanged: onAmountChanged,
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: errorText == null ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF168A3D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Start Order',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
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
                  'Reach ${isGold ? _goldThresholdLabel : _silverThresholdLabel} '
                  'to unlock physical conversion.',
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

  Future<void> _openGoldConversion() async {
    final amount = double.tryParse(_goldAmountController.text);

    if (amount == null) {
      return;
    }

    final cartProvider = context.read<CartProvider>();
    final physicalProvider = context.read<PhysicalConversionProvider>();

    // Clear existing normal cart
    cartProvider.clearCart();

    if (!mounted) return;

    // Start Physical Conversion
    physicalProvider.startConversion(metal: 'Gold', amount: amount);

    // Navigate to Cart
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
    );
  }

  Future<void> _openSilverConversion() async {
    final amount = double.tryParse(_silverAmountController.text);

    if (amount == null) {
      return;
    }

    final physicalProvider = context.read<PhysicalConversionProvider>();

    // Clear existing normal cart
    await context.read<CartProvider>().fetchCart();
    context.read<CartProvider>().clearCart();

    if (!mounted) return;

    // Start Physical Conversion
    physicalProvider.startConversion(metal: 'Silver', amount: amount);

    // Navigate to Cart
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
    );
  }

  void _onGoldAmountChanged(String value) {
    final entered = double.tryParse(value);

    final balance = double.tryParse('${gold?['balance'] ?? 0}') ?? 0;

    final minimum = double.tryParse('${gold?['minimum_balance'] ?? 50}') ?? 50;

    setState(() {
      if (entered == null) {
        _goldAmountError = 'Enter a valid amount.';
      } else if (entered < minimum) {
        _goldAmountError =
            'Value must be at least ${minimum.toStringAsFixed(4)} g.';
      } else if (entered > balance) {
        _goldAmountError =
            'Value must be less than or equal to '
            '${balance.toStringAsFixed(4)}.';
      } else {
        _goldAmountError = null;
      }
    });
  }

  void _onSilverAmountChanged(String value) {
    final entered = double.tryParse(value);

    final balance = double.tryParse('${silver?['balance'] ?? 0}') ?? 0;

    final minimum =
        double.tryParse('${silver?['minimum_balance'] ?? 1000}') ?? 1000;

    setState(() {
      if (entered == null) {
        _silverAmountError = 'Enter a valid amount.';
      } else if (entered < minimum) {
        _silverAmountError =
            'Value must be at least ${minimum.toStringAsFixed(4)} g.';
      } else if (entered > balance) {
        _silverAmountError =
            'Value must be less than or equal to '
            '${balance.toStringAsFixed(4)}.';
      } else {
        _silverAmountError = null;
      }
    });
  }
}
