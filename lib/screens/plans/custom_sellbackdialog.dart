import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/sell_back_services.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:junubullion/services/home_services.dart';
import 'dart:developer';

class SellBackDialog extends StatefulWidget {
  final String metal;
  final String balance;
  final String unit;
  final String spotPrice;
  final String currency;

  // NEW
  final Plans plan;

  const SellBackDialog({
    super.key,
    required this.metal,
    required this.balance,
    required this.unit,
    required this.spotPrice,
    this.currency = 'USD',
    required this.plan,
  });

  @override
  State<SellBackDialog> createState() => _SellBackDialogState();
}

class _SellBackDialogState extends State<SellBackDialog> {
  int currentStep = 1;

  bool isSubmitting = false;

  // Controllers
  final nameController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final swiftController = TextEditingController();
  final branchController = TextEditingController();
  final quantityController = TextEditingController();

  // Price & Timer state
  double? ouncePrice;
  bool isLoadingOuncePrice = false;
  Timer? _priceTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AccountProvider>();
      await provider.fetchAccountDetails();
      if (!mounted) return;
      nameController.text = provider.name;
      setState(() {});
    });

    // Fetch immediately on open
    _fetchOuncePrice();

    // Setup periodic polling every 1 second for live updates
    _priceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchOuncePrice(isBackgroundRefresh: true);
    });
  }

  Future<void> _fetchOuncePrice({bool isBackgroundRefresh = false}) async {
    final currencyProvider = context.read<CurrencyProvider>();

    log('SELL BACK REQUEST CURRENCY: ${currencyProvider.selectedCurrency}');
    log('SELL BACK REQUEST UNIT: ounce');

    if (!isBackgroundRefresh && ouncePrice == null) {
      setState(() => isLoadingOuncePrice = true);
    }

    try {
      final spotPrices = await ApiService.fetchSpotPrice(
        currency: currencyProvider.selectedCurrency,
        unit: 'gram',
      );

      log('SELL BACK API RESPONSE: $spotPrices');

      final metalKey = widget.metal.toLowerCase();

      if (spotPrices.containsKey('metals') &&
          spotPrices['metals'].containsKey(metalKey)) {
        final priceVal = spotPrices['metals'][metalKey]['price'];

        final parsedPrice = double.tryParse(priceVal.toString()) ?? 0.0;

        log(
          'SELL BACK METAL: $metalKey | '
          'PRICE: $parsedPrice | '
          'CURRENCY: ${currencyProvider.selectedCurrency}',
        );

        if (mounted && ouncePrice != parsedPrice) {
          setState(() {
            ouncePrice = parsedPrice;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching live spot price: $e');
    } finally {
      if (mounted && isLoadingOuncePrice) {
        setState(() => isLoadingOuncePrice = false);
      }
    }
  }

  Future<void> _submitSellBackRequest() async {
    FocusScope.of(context).unfocus();

    final currencyProvider = context.read<CurrencyProvider>();

    final quantity = double.tryParse(quantityController.text.trim());

    // Validate quantity
    if (quantity == null || quantity <= 0) {
      _showToast('Please enter a valid amount to sell.');
      return;
    }

    // Validate against available balance
    final availableBalance = double.tryParse(widget.balance) ?? 0.0;

    if (quantity > availableBalance) {
      _showToast(
        'Amount cannot be greater than your available balance '
        'of ${widget.balance} ${widget.unit}.',
      );
      return;
    }

    // Validate bank details
    if (nameController.text.trim().isEmpty) {
      _showToast('Please enter account holder name.');
      return;
    }

    if (bankNameController.text.trim().isEmpty) {
      _showToast('Please enter bank name.');
      return;
    }

    if (accountNumberController.text.trim().isEmpty) {
      _showToast('Please enter account number.');
      return;
    }

    if (ifscController.text.trim().isEmpty) {
      _showToast('Please enter IFSC / Routing Code.');
      return;
    }

    if (branchController.text.trim().isEmpty) {
      _showToast('Please enter bank branch.');
      return;
    }

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final currency = currencyProvider.selectedCurrency;

      log('========== SELL BACK REQUEST ==========');
      log('METAL: ${widget.metal.toLowerCase()}');
      log('AMOUNT: $quantity');
      log('ACCOUNT HOLDER: ${nameController.text.trim()}');
      log('BANK NAME: ${bankNameController.text.trim()}');
      log('ACCOUNT NUMBER: ${accountNumberController.text.trim()}');
      log('IFSC: ${ifscController.text.trim()}');
      log('SWIFT: ${swiftController.text.trim()}');
      log('BRANCH: ${branchController.text.trim()}');
      log('CURRENCY: $currency');

      final response = await SellBackServices.submitSellBack(
        plan: widget.plan.name,
        metal: widget.metal.toLowerCase(),
        amount: quantity,
        accountHolderName: nameController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscController.text.trim().isEmpty
            ? null
            : ifscController.text.trim(),
        swiftCode: swiftController.text.trim().isEmpty
            ? null
            : swiftController.text.trim(),
        bankBranch: branchController.text.trim(),
        currency: currency,
      );

      log('SELL BACK SUCCESS RESPONSE: $response');

      if (!mounted) return;

      final success = response['status'] == true;

      if (success) {
        _showToast(
          response['message'] ?? 'Sell back request submitted successfully.',
        );

        Navigator.of(context).pop(true);
      } else {
        _showToast(
          response['message'] ?? 'Failed to submit sell back request.',
        );
      }
    } catch (e) {
      log('❌ SELL BACK SUBMIT ERROR: $e');

      if (!mounted) return;

      _showToast('Sell back failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  void dispose() {
    // Always cancel the periodic timer when the dialog closes
    _priceTimer?.cancel();
    nameController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    swiftController.dispose();
    branchController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Container(
                color: const Color(0xFFB00D28),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sell Back — Bank Transfer',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Step Indicators
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: currentStep == 1
                                  ? const Color(0xFFFFEAEA)
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '1. BANK DETAILS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: currentStep == 1
                                    ? const Color(0xFFD20D2D)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: currentStep == 2
                                  ? const Color(0xFFFFEAEA)
                                  : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '2. AMOUNT & CONFIRM',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: currentStep == 2
                                    ? const Color(0xFFD20D2D)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (currentStep == 1) _buildStepOne() else _buildStepTwo(),

                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (currentStep == 2) {
                              setState(() => currentStep = 1);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            currentStep == 2 ? 'Back' : 'Cancel',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  if (currentStep == 1) {
                                    setState(() => currentStep = 2);
                                  } else {
                                    _submitSellBackRequest();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD20D2D),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  currentStep == 1
                                      ? 'Continue'
                                      : 'Submit Request',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputField('Account Holder Name', nameController),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildInputField('Bank Name', bankNameController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                'Account Number',
                accountNumberController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField('IFSC / Routing Code', ifscController),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                'SWIFT / BIC Code',
                swiftController,
                hint: 'For international transfers',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildInputField('Bank Branch', branchController)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    final double quantity = double.tryParse(quantityController.text) ?? 0.0;
    final double effectiveRate = ouncePrice ?? 0.0;

    final double rawPayout = quantity * effectiveRate;

    // 2% sell-back fee
    final double sellBackFee = rawPayout * 0.02;

    // Net payout after 2% deduction
    final double estimatedPayout = rawPayout - sellBackFee;
    log(
      'quantity:-- $quantity | '
      'ouncePrice: $effectiveRate | '
      'rawPayout: $rawPayout | '
      '2% fee: $sellBackFee | '
      'netPayout: $estimatedPayout',
    );

    final String symbol = widget.spotPrice.replaceAll(RegExp(r'[0-9.,\s]'), '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            children: [
              const TextSpan(text: 'Selling: '),
              TextSpan(
                text: widget.metal,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' · Available: '),
              TextSpan(
                text: '${widget.balance} ${widget.unit}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Amount to sell (${widget.unit})',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF800000),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 42,
          child: TextField(
            controller: quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 13),
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF82B1FF),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF82B1FF),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF2979FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (isLoadingOuncePrice)
          const Text(
            'Fetching live market rates...',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          )
        else
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                  children: [
                    const TextSpan(text: 'Estimated payout: '),
                    TextSpan(
                      text: '$symbol${estimatedPayout.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD20D2D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.circle,
                size: 8,
                color: Colors.green,
              ), // Live indicator dot
            ],
          ),

        const SizedBox(height: 8),
        const Text(
          'A 2% sell-back deduction applies to JSC payouts. The estimate above shows the net amount after deduction.',
          style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.3),
        ),
        const SizedBox(height: 12),
        const Text(
          'Payment will be credited to your bank account within up to 24 hours.',
          style: TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF800000),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 38,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
