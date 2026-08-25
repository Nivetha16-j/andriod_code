import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/checkout/checkout.dart';
import 'package:junubullion/screens/checkout/physical_ordersuccess.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/checkout_service.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhysicalCheckoutScreen extends StatefulWidget {
  const PhysicalCheckoutScreen({super.key});

  @override
  State<PhysicalCheckoutScreen> createState() => _PhysicalCheckoutScreenState();
}

class _PhysicalCheckoutScreenState extends State<PhysicalCheckoutScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController addressController = TextEditingController();

  String? localAddress;

  bool showAddressForm = false;
  bool isTermsAccepted = false;
  bool _isPlacingOrder = false;

  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      context.read<AddressProvider>().fetchAddress();
    });

    _loadLocalAddress();
  }

  // ============================================================
  // LOAD SAVED ADDRESS
  // ============================================================

  Future<void> _loadLocalAddress() async {
    final prefs = await SharedPreferences.getInstance();

    final savedAddress = prefs.getString("checkout_address");

    if (!mounted) return;

    setState(() {
      localAddress = savedAddress;

      if (savedAddress != null && savedAddress.trim().isNotEmpty) {
        addressController.text = savedAddress;
      }
    });
  }

  // ============================================================
  // SAVE ADDRESS
  // ============================================================

  Future<void> _saveAddress() async {
    final address = addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shipping address')),
      );

      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("checkout_address", address);

    if (!mounted) return;

    setState(() {
      localAddress = address;
      showAddressForm = false;
    });
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _buildShippingAddress() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        if (addressProvider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final String? displayAddress = addressProvider.hasAddress
            ? addressProvider.address
            : localAddress;

        // ======================================================
        // ADD ADDRESS
        // ======================================================

        if (displayAddress == null && !showAddressForm) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'No shipping address added',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        showAddressForm = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('ADD SHIPPING ADDRESS'),
                  ),
                ),
              ],
            ),
          );
        }

        // ======================================================
        // ADDRESS FORM
        // ======================================================

        if (showAddressForm) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: addressController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your complete shipping address',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          showAddressForm = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Address'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        // ======================================================
        // EXISTING ADDRESS
        // ======================================================

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryRed,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (addressProvider.hasAddress &&
                        addressProvider.name != null &&
                        addressProvider.name!.isNotEmpty)
                      Text(
                        addressProvider.name!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    if (addressProvider.hasAddress) const SizedBox(height: 6),

                    Text(
                      displayAddress!,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    showAddressForm = true;
                    addressController.text = displayAddress;
                  });
                },
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // PHYSICAL DELIVERY
  // ============================================================

  // ============================================================
  // PHYSICAL CONVERSION ACTIVE CARD
  // ============================================================

  Widget _buildConversionInfo(PhysicalConversionProvider physicalProvider) {
    final String metal = physicalProvider.metal ?? '';

    final String amount = physicalProvider.formattedAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5C76B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF981B1B),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    '⟳  PHYSICAL CONVERSION ACTIVE',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: () async {
                  await physicalProvider.cancelConversion();

                  if (!mounted) return;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF981B1B),
                  side: const BorderSide(color: Color(0xFF981B1B)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Cancel conversion',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                const TextSpan(text: 'Add '),

                TextSpan(
                  text: metal,
                  style: const TextStyle(
                    color: Color(0xFF981B1B),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const TextSpan(text: ' products up to '),

                TextSpan(
                  text: '$amount g',
                  style: const TextStyle(
                    color: Color(0xFF981B1B),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const TextSpan(text: '.'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'No payment will be required at checkout.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _buildOrderSummary(
    PhysicalConversionProvider provider,
    String currencySymbol,
  ) {
    final items = provider.physicalCart;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 20),

          // Products
          ...items.map((item) {
            final name = item['name']?.toString() ?? 'Product';
            final quantity = int.tryParse('${item['quantity'] ?? 1}') ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '$name × $quantity',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    '$currencySymbol 0.00',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 28),

          _summaryRow(
            'Courier charge (Standard delivery)',
            '$currencySymbol 0.00',
          ),

          const SizedBox(height: 18),

          _summaryRow('Total (ex tax)', '$currencySymbol 0.00'),

          const SizedBox(height: 18),

          _summaryRow('Tax (21%)', '$currencySymbol 0.00'),

          const SizedBox(height: 18),

          _summaryRow('Transaction Fee (4%)', '$currencySymbol 0.00'),

          const Divider(height: 30),

          _summaryRow('Order Total', '$currencySymbol 0.00', bold: true),
        ],
      ),
    );
  }
  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: bold ? 15 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),

        const SizedBox(width: 15),

        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: isTermsAccepted,
          activeColor: AppColors.primaryRed,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (value) {
            setState(() {
              isTermsAccepted = value ?? false;
            });
          },
        ),

        const Expanded(
          child: Text(
            'I agree to the Terms & Conditions',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEND ORDER
  // ============================================================

  Future<void> _sendPhysicalOrder() async {
    final addressProvider = context.read<AddressProvider>();
    final physicalProvider = context.read<PhysicalConversionProvider>();

    final currencyProvider = context.read<CurrencyProvider>();

    final String shippingAddress =
        addressProvider.hasAddress && addressProvider.address != null
        ? addressProvider.address!.trim()
        : (localAddress ?? '').trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (shippingAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add your shipping address")),
      );
      return;
    }

    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Terms & Conditions")),
      );
      return;
    }

    if (physicalProvider.physicalCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your physical conversion cart is empty")),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      log(
        "PHYSICAL ORDER -> "
        "address=$shippingAddress "
        "items=${physicalProvider.physicalCart.length}",
      );

      // ----------------------------------------------------------
      // PLACE PHYSICAL ORDER
      // ----------------------------------------------------------

      final response = await CheckoutService.placePhysicalOrder(
        shippingAddress: shippingAddress,
        terms: true,
      );

      log("PHYSICAL ORDER RESPONSE -> $response");

      if (!mounted) return;

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response["status"] == true) {
        // Clear physical conversion cart only after
        // successful order placement.
        await physicalProvider.clearPhysicalCart();

        setState(() {
          _isPlacingOrder = false;
        });

        final orderData =
            response["data"] as Map<String, dynamic>? ?? <String, dynamic>{};

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PhysicalOrderSuccessScreen(
              order: orderData,
              currencySymbol: currencyProvider.selectedCurrency,
            ),
          ),
          (route) => false,
        );

        return;
      }

      // ----------------------------------------------------------
      // API RETURNED FAILURE
      // ----------------------------------------------------------

      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response["message"]?.toString() ??
                "Order could not be placed. Please try again.",
          ),
        ),
      );
    } catch (e, stackTrace) {
      log("PHYSICAL ORDER ERROR -> $e", stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
      ],
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final physicalProvider = context.watch<PhysicalConversionProvider>();
    String delivery = "physical";

    final String currencySymbol = currencyProvider.selectedCurrency;

    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),

      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),

      backgroundColor: Colors.grey.shade100,

      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth >= 900;

              if (isDesktop) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =================================================
                      // LEFT SIDE
                      // =================================================
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SHIPPING ADDRESS
                            const Text(
                              'Shipping addresss',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildShippingAddress(),

                            const SizedBox(height: 2),

                            // PHYSICAL CONVERSION
                            _buildConversionInfo(physicalProvider),

                            const SizedBox(height: 18),

                            // TERMS
                            _buildTerms(),

                            const SizedBox(height: 5),

                            // ACTIONS
                            _buildActionButtons(currencySymbol),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      // =================================================
                      // RIGHT SIDE - ORDER SUMMARY
                      // =================================================
                      Expanded(
                        flex: 1,
                        child: _buildOrderSummary(
                          physicalProvider,
                          currencySymbol,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // =========================================================
              // MOBILE / SMALL SCREEN
              // =========================================================
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shipping address',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // _buildShippingAddress(),
                    Consumer<AddressProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Prefer backend address. If unavailable, use local address.
                        final String? displayAddress = provider.hasAddress
                            ? provider.address
                            : localAddress;

                        /// No address
                        if (displayAddress == null && !showAddressForm) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "NO ADDRESS",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showAddressForm = true;
                                  });
                                },
                                child: const Text("ADD ADDRESS"),
                              ),
                            ],
                          );
                        }

                        /// Address form
                        if (showAddressForm) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: addressController,
                                  // maxLines: 4,
                                  decoration: const InputDecoration(
                                    // labelText: "Shipping Address",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 15),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: _saveAddress,
                                  child: const Text("SAVE ADDRESS"),
                                ),
                              ),
                            ],
                          );
                        }

                        /// Show saved/backend address
                        return Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (provider.hasAddress)
                                      Text(
                                        provider.name ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    if (provider.hasAddress)
                                      const SizedBox(height: 5),

                                    Text(displayAddress!),
                                  ],
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    showAddressForm = true;
                                    addressController.text = displayAddress;
                                  });
                                },
                                child: const Text(
                                  "Change",
                                  style: TextStyle(color: AppColors.primaryRed),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildConversionInfo(physicalProvider),

                    const SizedBox(height: 18),

                    const Text(
                      "Delivery option",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    Row(
                      children: [
                        Radio(
                          activeColor: AppColors.primaryRed,
                          value: "physical",
                          groupValue: delivery,
                          onChanged: (value) {
                            setState(() {
                              delivery = value!;
                            });
                          },
                        ),
                        const Text("Physical"),

                        Radio(
                          activeColor: AppColors.primaryRed,
                          value: "Digital",
                          groupValue: delivery,
                          onChanged: (value) {
                            // setState(() {
                            //   delivery = value!;
                            // });
                          },
                        ),
                        const Text("Digital"),
                      ],
                    ),
                    const Text(
                      "Physical delivery is required for the products in your cart. Digital JSC is only available for JSC plan products.",
                      style: TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 5),

                    _buildTerms(),

                    const SizedBox(height: 18),

                    _buildOrderSummary(physicalProvider, currencySymbol),

                    const SizedBox(height: 25),

                    _buildActionButtons(currencySymbol),
                  ],
                ),
              );
            },
          ),

          // =============================================================
          // LOADING
          // =============================================================
          if (_isPlacingOrder)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String currencySymbol) {
    return Row(
      children: [
        // ============================================================
        // BACK
        // ============================================================
        Expanded(
          child: ElevatedButton(
            onPressed: _isPlacingOrder
                ? null
                : () {
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.black45,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text('Back', style: TextStyle(fontSize: 14)),
          ),
        ),

        const SizedBox(width: 15),

        // ============================================================
        // SEND ORDER
        // ============================================================
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _sendPhysicalOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: _isPlacingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Send Orderrrrrrrr $currencySymbol 0.00',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }
}
