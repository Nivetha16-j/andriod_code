import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/gsp_service.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
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

  Map<String, dynamic>? jscGold;
  Map<String, dynamic>? jscSilver;

  Map<String, dynamic>? gspGold;
  Map<String, dynamic>? gspSilver;

  bool isLoading = false;
  bool isStartingOrder = false;
  bool _isUnlocked = false;
  int selectedTab = 0; // 0 = JSC, 1 = GSP

  // Keeps track of which metal is currently being converted.
  String? _startingMetal;

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
          jscGold = null;
          jscSilver = null;

          gspGold = null;
          gspSilver = null;

          _goldAmountError = null;
          _silverAmountError = null;

          _startingMetal = null;
          isStartingOrder = false;
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

  // ============================================================
  // REFRESH
  // ============================================================

  void _startConvertRefresh() {
    _stopConvertRefresh();

    debugPrint('🚀 STARTING CONVERT PHYSICAL REFRESH');

    // Fetch immediately.
    fetchConvertPhysical();

    // Refresh every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      fetchConvertPhysical();
    });
  }

  void _stopConvertRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  Map<String, dynamic>? get gold {
    return selectedTab == 0 ? jscGold : gspGold;
  }

  Map<String, dynamic>? get silver {
    return selectedTab == 0 ? jscSilver : gspSilver;
  }

  Future<void> fetchConvertPhysical() async {
    if (!_isUnlocked) return;

    if (isLoading) return;

    try {
      setState(() {
        isLoading = true;
      });

      final currencyProvider = context.read<CurrencyProvider>();

      final currency = currencyProvider.selectedCurrency;

      await _fetchJscConvertPhysical(currency);

      await _fetchGspConvertPhysical(currency);

      _setDefaultAmounts();

      if (!mounted) return;

      setState(() {});
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

  Future<void> _fetchJscConvertPhysical(String currency) async {
    final response = await JscService.fetchConvertPhysicalDetails(
      currency: currency,
    );

    final data = response['data'] as Map<String, dynamic>?;

    final summary = data?['summary'] as Map<String, dynamic>?;

    jscGold = summary?['gold'] as Map<String, dynamic>?;

    jscSilver = summary?['silver'] as Map<String, dynamic>?;
  }

  Future<void> _fetchGspConvertPhysical(String currency) async {
    final response = await GspService.fetchConvertPhysicalDetails(
      currency: currency,
    );

    final data = response['data'] as Map<String, dynamic>?;

    final summary = data?['summary'] as Map<String, dynamic>?;

    gspGold = summary?['gold'] as Map<String, dynamic>?;

    gspSilver = summary?['silver'] as Map<String, dynamic>?;
  }

  void _setDefaultAmounts() {
    final goldBalance = double.tryParse('${gold?['balance'] ?? 0}') ?? 0;

    final goldMinimum =
        double.tryParse('${gold?['minimum_balance'] ?? 50}') ?? 50;

    final silverBalance = double.tryParse('${silver?['balance'] ?? 0}') ?? 0;

    final silverMinimum =
        double.tryParse('${silver?['minimum_balance'] ?? 1000}') ?? 1000;

    if (_goldAmountController.text.isEmpty && goldBalance >= goldMinimum) {
      _goldAmountController.text = goldMinimum.toStringAsFixed(4);
    }

    if (_silverAmountController.text.isEmpty &&
        silverBalance >= silverMinimum) {
      _silverAmountController.text = silverMinimum.toStringAsFixed(4);
    }
  }
  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = 0;

                    _goldAmountController.clear();
                    _silverAmountController.clear();

                    _goldAmountError = null;
                    _silverAmountError = null;
                  });

                  _setDefaultAmounts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selectedTab == 0
                        ? AppColors.primaryRed
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: TranslatedText(
                    'JSC Conversion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTab = 1;

                    _goldAmountController.clear();
                    _silverAmountController.clear();

                    _goldAmountError = null;
                    _silverAmountError = null;
                  });

                  _setDefaultAmounts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selectedTab == 1
                        ? AppColors.primaryRed
                        : const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: TranslatedText(
                    'GSP Conversion',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selectedTab == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TranslatedText(
                  'Convert to Physical',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: TranslatedText(
                    _isUnlocked
                        ? 'Convert part or all of your digital holdings '
                              'into physical products. Minimum balance to '
                              'convert: $_goldThresholdLabel of gold or '
                              '$_silverThresholdLabel of silver.'
                        : 'Convert part or all of your digital holdings '
                              'into physical products. Minimum balance to '
                              'convert: 50 g of gold or 1 kg of silver.',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                // ========================================================
                // LOCKED
                // ========================================================
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
                ]
                // ========================================================
                // FIRST LOAD
                // ========================================================
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
                // ========================================================
                // UNLOCKED
                // ========================================================
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
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AVAILABLE BALANCES
  // ============================================================

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

  // ============================================================
  // MINIMUM THRESHOLDS
  // ============================================================

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

  // ============================================================
  // ELIGIBILITY
  // ============================================================

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

  // ============================================================
  // MAIN CONTAINER
  // ============================================================

  Widget _buildContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: AppColors.BgGradient,
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }

  // ============================================================
  // CONVERSION ROW
  // ============================================================

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

    // Only the currently selected metal shows Starting...
    final bool isThisMetalStarting = _startingMetal == metal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TranslatedText(
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
              child: TranslatedText(
                available,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // ========================================================
        // ENABLED
        // ========================================================
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
                  style: const TextStyle(fontSize: 11, color: AppColors.white),
                  decoration: InputDecoration(
                    label: const TranslatedText(
                      'AMOUNT TO CONVERT (g)',
                      style: TextStyle(fontSize: 10, color: AppColors.white),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: AppColors.white,
                        width: 0.7,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: AppColors.white,
                        width: 0.7,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: AppColors.white,
                        width: 0.7,
                      ),
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
                  onPressed: isThisMetalStarting
                      ? null
                      : errorText == null
                      ? onPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF168A3D),
                    foregroundColor: Colors.white,

                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    disabledForegroundColor: const Color(0xFFE0E0E0),

                    elevation: 0,

                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: TranslatedText(
                    isThisMetalStarting ? 'Starting...' : 'Start Order',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        // ========================================================
        // NOT ELIGIBLE
        // ========================================================
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
                child: TranslatedText(
                  'Reach '
                  '${isGold ? _goldThresholdLabel : _silverThresholdLabel} '
                  'to unlock physical conversion.',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // GOLD
  // ============================================================

  Future<void> _openGoldConversion() async {
    final amount = double.tryParse(_goldAmountController.text);

    if (amount == null) {
      return;
    }

    if (!_canConvertGold) {
      return;
    }

    await _showStartConversionDialog(metal: 'Gold', amount: amount);
  }

  // ============================================================
  // SILVER
  // ============================================================

  Future<void> _openSilverConversion() async {
    final amount = double.tryParse(_silverAmountController.text);

    if (amount == null) {
      return;
    }

    if (!_canConvertSilver) {
      return;
    }

    await _showStartConversionDialog(metal: 'Silver', amount: amount);
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<void> _showStartConversionDialog({
    required String metal,
    required double amount,
  }) async {
    final currencyProvider = context.read<CurrencyProvider>();

    final currency = currencyProvider.selectedCurrency;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFEF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const TranslatedText(
            'Start Physical Conversion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: TranslatedText(
            'Start a physical conversion order with '
            '${amount.toStringAsFixed(4)} g of $metal?',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const TranslatedText(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF168A3D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const TranslatedText('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _startPhysicalConversion(
      metal: metal,
      amount: amount,
      currency: currency,
    );
  }

  // ============================================================
  // START PHYSICAL CONVERSION
  // ============================================================

  Future<void> _startPhysicalConversion({
    required String metal,
    required double amount,
    required String currency,
  }) async {
    if (!mounted) return;

    setState(() {
      isStartingOrder = true;
      _startingMetal = metal;
    });

    try {
      log(
        '🚀 START PHYSICAL CONVERSION -> '
        'metal=$metal '
        'amount=$amount '
        'currency=$currency',
      );

      // ==========================================================
      // STEP 1: CALL CONVERT API
      // ==========================================================

      final convertResponse = selectedTab == 0
          ? await JscService.convertToPhysical(
              metal: metal,
              amount: amount,
              currency: currency,
            )
          : await GspService.convertToPhysical(
              metal: metal,
              amount: amount,
              currency: currency,
            );

      log(
        '🔥 JSC CONVERT RESPONSE: '
        '$convertResponse',
      );

      if (!mounted) return;

      // ==========================================================
      // STEP 2: READ API RESPONSE
      // ==========================================================

      final bool apiStatus = convertResponse['status'] == true;

      final data = convertResponse['data'];

      final String? conversionStatus = data is Map
          ? data['status']?.toString().trim().toLowerCase()
          : null;

      final String responseMetal = data is Map
          ? data['metal']?.toString() ?? metal
          : metal;

      final double responseAmount = data is Map
          ? double.tryParse(
                  '${data['amount_grams'] ?? data['amount'] ?? amount}',
                ) ??
                amount
          : amount;

      final String message =
          convertResponse['message']?.toString() ??
          'Unable to start physical conversion.';

      log(
        'CONVERT RESULT -> '
        'apiStatus=$apiStatus '
        'conversionStatus=$conversionStatus '
        'metal=$responseMetal '
        'amount=$responseAmount',
      );

      // ==========================================================
      // STEP 3: CONVERSION MUST BE ACTIVE
      // ==========================================================

      if (!apiStatus || conversionStatus != 'active') {
        log(
          '❌ PHYSICAL CONVERSION NOT ACTIVE -> '
          'apiStatus=$apiStatus '
          'status=$conversionStatus',
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: TranslatedText(message)));

        return;
      }

      log('✅ PHYSICAL CONVERSION API SUCCESS');

      log('✅ Conversion status = ACTIVE');

      // ==========================================================
      // STEP 4: MOVE NORMAL CART TO PHYSICAL
      // ==========================================================

      log('➡️ Moving normal cart to physical order');

      final cartProvider = context.read<CartProvider>();

      final cartSuccess = await cartProvider.moveCartToPhysicalOrder();

      if (!cartSuccess) {
        if (!mounted) return;

        log('❌ Failed to move normal cart');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TranslatedText(
              'Conversion started, but the cart could not be moved.',
            ),
          ),
        );

        return;
      }

      log('✅ NORMAL CART MOVED SUCCESSFULLY');

      // ==========================================================
      // STEP 5: UPDATE PHYSICAL PROVIDER
      // ==========================================================

      final physicalProvider = context.read<PhysicalConversionProvider>();

      physicalProvider.setConversionPlan('jsc');

      await physicalProvider.fetchConversionStatus();

      log(
        '✅ PHYSICAL PROVIDER UPDATED FROM API -> '
        'status=$conversionStatus '
        'metal=$responseMetal '
        'amount=$responseAmount',
      );

      if (!mounted) return;

      // ==========================================================
      // STEP 6: NAVIGATE TO CART
      // ==========================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 2)),
      );
    } catch (e, stackTrace) {
      log('❌ START PHYSICAL CONVERSION ERROR: $e', stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText(
            'Something went wrong while starting the conversion.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isStartingOrder = false;
          _startingMetal = null;
        });
      }
    }
  }

  // ============================================================
  // GOLD AMOUNT VALIDATION
  // ============================================================

  void _onGoldAmountChanged(String value) {
    final entered = double.tryParse(value);

    final balance = double.tryParse('${gold?['balance'] ?? 0}') ?? 0;

    final minimum = double.tryParse('${gold?['minimum_balance'] ?? 50}') ?? 50;

    setState(() {
      if (entered == null) {
        _goldAmountError = 'Enter a valid amount.';
      } else if (entered < minimum) {
        _goldAmountError =
            'Value must be at least '
            '${minimum.toStringAsFixed(4)} g.';
      } else if (entered > balance) {
        _goldAmountError =
            'Value must be less than or equal to '
            '${balance.toStringAsFixed(4)}.';
      } else {
        _goldAmountError = null;
      }
    });
  }

  // ============================================================
  // SILVER AMOUNT VALIDATION
  // ============================================================

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
            'Value must be at least '
            '${minimum.toStringAsFixed(4)} g.';
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
