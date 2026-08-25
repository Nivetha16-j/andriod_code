import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/checkout/banktransfersuccess.dart';
import 'package:junubullion/screens/checkout/success.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/checkout_service.dart';
import 'package:junubullion/services/stripe_service.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/cart/custom_summary.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String delivery = "physical";
  String payment = "Card";
  int _currentIndex = 3;
  String digitalSubtype = "Jsc";
  final TextEditingController addressController = TextEditingController();
  bool isTermsAccepted = false;
  bool _isPlacingOrder = false;

  bool showAddressForm = false;
  String? localAddress;
  String? selectedCard;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  Future<void> _sendPhysicalOrder() async {
    log("checkout screen");
    final addressProvider = context.read<AddressProvider>();

    final physicalProvider = context.read<PhysicalConversionProvider>();

    final String shippingAddress =
        addressProvider.hasAddress && addressProvider.address != null
        ? addressProvider.address!.trim()
        : (localAddress ?? '').trim();

    if (shippingAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add your shipping address")),
      );
      return;
    }

    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms & Conditions')),
      );

      return;
    }

    if (physicalProvider.physicalCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your physical conversion cart is empty')),
      );

      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      log(
        'PHYSICAL ORDER -> '
        'address=$shippingAddress '
        'items=${physicalProvider.physicalCart.length}',
      );

      // TODO:
      // Call physical conversion order API here.

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Physical order is ready to be submitted.'),
        ),
      );
    } catch (e) {
      log('PHYSICAL ORDER ERROR -> $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AddressProvider>().fetchAddress();
    });

    _loadLocalAddress();
  }

  Future<void> _loadLocalAddress() async {
    final prefs = await SharedPreferences.getInstance();

    localAddress = prefs.getString("checkout_address");

    if (localAddress != null) {
      addressController.text = localAddress!;
    }

    setState(() {});
  }

  Future<void> _saveAddress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("checkout_address", addressController.text.trim());

    setState(() {
      localAddress = addressController.text.trim();
      showAddressForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    final currencyProvider = context.watch<CurrencyProvider>();

    final physicalProvider = context.watch<PhysicalConversionProvider>();

    final bool isPhysicalConversion = physicalProvider.physicalCart.isNotEmpty;

    final String currencySymbol = currencyProvider.selectedCurrency;

    final isDigital = delivery.toLowerCase() == "digital";

    final courierAmount = isDigital ? 0.0 : cartProvider.courierAmount;

    final transactionAmount = isDigital
        ? 0.0
        : cartProvider.transactionFeeAmount;

    final gstAmount = isDigital ? 0.0 : cartProvider.gstAmount;

    final orderTotal =
        cartProvider.subtotalAmount +
        courierAmount +
        transactionAmount +
        gstAmount;

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

              // =========================================================
              // DESKTOP
              // =========================================================

              if (isDesktop) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shipping address',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildShippingAddress(),

                            const SizedBox(height: 18),

                            // =================================================
                            // PHYSICAL CONVERSION
                            // =================================================
                            if (isPhysicalConversion) ...[
                              _buildConversionInfo(physicalProvider),

                              const SizedBox(height: 18),
                            ],

                            // =================================================
                            // NORMAL DELIVERY
                            // =================================================
                            if (!isPhysicalConversion) ...[
                              _buildDeliverySection(),

                              const SizedBox(height: 20),

                              if (delivery.toLowerCase() == "digital")
                                _buildDigitalSubtype(),

                              const SizedBox(height: 20),

                              _buildPaymentSection(),

                              const SizedBox(height: 20),
                            ],

                            _buildTerms(),

                            const SizedBox(height: 20),

                            _buildActionButtons(
                              currencySymbol,
                              isPhysicalConversion,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 1,
                        child: isPhysicalConversion
                            ? _buildPhysicalOrderSummary(
                                physicalProvider,
                                currencySymbol,
                              )
                            : _buildNormalOrderSummary(
                                cartProvider,
                                currencySymbol,
                                orderTotal,
                                isDigital,
                              ),
                      ),
                    ],
                  ),
                );
              }

              // =========================================================
              // MOBILE
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

                    _buildShippingAddress(),

                    const SizedBox(height: 14),

                    // =====================================================
                    // PHYSICAL CHECKOUT
                    // =====================================================
                    if (isPhysicalConversion) ...[
                      _buildConversionInfo(physicalProvider),

                      const SizedBox(height: 18),

                      _buildTerms(),

                      const SizedBox(height: 18),

                      _buildPhysicalOrderSummary(
                        physicalProvider,
                        currencySymbol,
                      ),

                      const SizedBox(height: 25),

                      _buildActionButtons(currencySymbol, true),
                    ]
                    // =====================================================
                    // NORMAL CHECKOUT
                    // =====================================================
                    else ...[
                      _buildDeliverySection(),

                      const SizedBox(height: 20),

                      if (delivery.toLowerCase() == "digital") ...[
                        _buildDigitalSubtype(),

                        const SizedBox(height: 20),
                      ],

                      _buildPaymentSection(),

                      const SizedBox(height: 20),

                      _buildTerms(),

                      const SizedBox(height: 18),

                      _buildNormalOrderSummary(
                        cartProvider,
                        currencySymbol,
                        orderTotal,
                        isDigital,
                      ),

                      const SizedBox(height: 25),

                      _buildActionButtons(currencySymbol, false),
                    ],
                  ],
                ),
              );
            },
          ),

          if (_isPlacingOrder)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                setState(() {
                  delivery = value!;
                });
              },
            ),

            const Text("Digital"),
          ],
        ),

        const Text(
          "Digital orders are charged at the product price only — no tax, shipping, or transaction fees.",
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDigitalSubtype() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Digital Subtype",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        Row(
          children: [
            Radio(
              value: "Jsc",
              groupValue: digitalSubtype,
              activeColor: AppColors.primaryRed,
              onChanged: (value) {
                setState(() {
                  digitalSubtype = value!;
                });
              },
            ),

            const Text("Jsc"),

            Radio(
              value: "Gsp",
              groupValue: digitalSubtype,
              activeColor: AppColors.primaryRed,
              onChanged: (value) {
                setState(() {
                  digitalSubtype = value!;
                });
              },
            ),

            const Text("Gsp"),
          ],
        ),

        const Text(
          "Choose jsc or gsp for your digital gold purchase",
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _placeNormalOrder() async {
    final addressProvider = context.read<AddressProvider>();
    final cartProvider = context.read<CartProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    final String? shippingAddress = addressProvider.hasAddress
        ? addressProvider.address
        : localAddress;

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (shippingAddress == null || shippingAddress.isEmpty) {
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

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Your cart is empty")));
      return;
    }

    if (payment == "Card" && selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final bool isDigital = delivery.toLowerCase() == "digital";

      final courierService = cartProvider.selectedDeliveryMethod.toLowerCase();

      if (payment == "Bank") {
        final response = await CheckoutService.placeOrder(
          shippingAddress: shippingAddress,
          deliveryOption: delivery,
          digitalType: isDigital ? digitalSubtype : null,
          courierService: isDigital ? null : courierService,
          terms: true,
          paymentType: "bank_transfer",
          currency: currencyProvider.selectedCurrency,
        );

        log("NORMAL BANK ORDER RESPONSE -> $response");

        if (!mounted) return;

        if (response["status"] == true) {
          // Clear local cart only after successful order.
          cartProvider.clearCart();

          setState(() {
            _isPlacingOrder = false;
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => BankTransferSuccessScreen(
                order: response["data"],
                currencySymbol:
                    response["summary"]?["symbol"] ??
                    currencyProvider.selectedCurrency,
              ),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            _isPlacingOrder = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response["message"] ?? "Order is not placed. Please try again.",
              ),
            ),
          );
        }

        return;
      }

      // ==========================================================
      // CARD / STRIPE
      // ==========================================================

      if (payment == "Card") {
        final String stripePaymentMethod = _getStripePaymentMethod(
          selectedCard!,
        );

        final stripeResponse = await StripeService.createStripeSession(
          shippingAddress: shippingAddress,
          fulfillmentType: delivery,
          courierService: isDigital
              ? null
              : cartProvider.selectedDeliveryMethod,
          currency: currencyProvider.selectedCurrency,
          digitalSubtype: isDigital ? digitalSubtype : null,
          terms: true,
          paymentMethod: stripePaymentMethod,
        );

        log("STRIPE RESPONSE -> $stripeResponse");

        if (stripeResponse["status"] == false) {
          throw Exception(
            stripeResponse["message"] ?? "Unable to create payment session",
          );
        }

        final clientSecret = stripeResponse["data"]?["client_secret"];

        if (clientSecret == null || clientSecret.toString().trim().isEmpty) {
          throw Exception("Stripe client secret not received");
        }

        final bool paymentSuccess = await StripeService.makePayment(
          clientSecret.toString(),
        );

        log("PAYMENT SUCCESS -> $paymentSuccess");

        if (!mounted) return;

        if (!paymentSuccess) {
          setState(() {
            _isPlacingOrder = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment was not completed.")),
          );

          return;
        }

        // ----------------------------------------------------------
        // PAYMENT SUCCESSFUL
        // ----------------------------------------------------------

        cartProvider.clearCart();

        setState(() {
          _isPlacingOrder = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
          (route) => false,
        );

        return;
      }

      throw Exception("Invalid payment method selected");
    } catch (e, stackTrace) {
      log("NORMAL ORDER ERROR -> $e", stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  Widget _buildShippingAddress() {
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

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        Row(
          children: [
            Radio(
              activeColor: AppColors.primaryRed,
              value: "Card",
              groupValue: payment,
              onChanged: (value) {
                setState(() {
                  payment = value!;
                });
              },
            ),

            const Text("Card"),

            Radio(
              activeColor: AppColors.primaryRed,
              value: "Bank",
              groupValue: payment,
              onChanged: (value) {
                setState(() {
                  payment = value!;
                });
              },
            ),

            const Expanded(child: Text("Direct Bank Transfer")),
          ],
        ),

        if (payment == "Card") ...[
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              paymentBox("Visa"),
              paymentBox("MasterCard"),
              paymentBox("G Pay"),
              paymentBox("Apple Pay"),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNormalOrderSummary(
    CartProvider provider,
    String currencySymbol,
    double orderTotal,
    bool isDigital,
  ) {
    if (provider.cartItems.isEmpty) {
      return const Text("No items in cart");
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF8EAEA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...provider.cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item["name"]} × ${item["quantity"]}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 30),

          _summaryRow("Subtotal Product", provider.formattedSubtotal),

          const SizedBox(height: 15),

          _summaryRow(
            "Courier Charges",
            isDigital
                ? "${provider.currencySymbol}0.00"
                : "+ ${provider.formattedCourierFee}",
          ),

          const SizedBox(height: 15),

          _summaryRow(
            "Transaction Fee",
            isDigital
                ? "${provider.currencySymbol}0.00"
                : "+ ${provider.formattedTransactionFee}",
          ),

          if (!isDigital && provider.gstAmount > 0) ...[
            const SizedBox(height: 15),

            _summaryRow("GST", provider.formattedGST),
          ],

          const Divider(height: 35),

          _summaryRow(
            "Order Total",
            "${provider.currencySymbol}${orderTotal.toStringAsFixed(2)}",
            bold: true,
            valueColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildConversionInfo(PhysicalConversionProvider physicalProvider) {
    final String metal = physicalProvider.metal ?? '';
    final String amount = physicalProvider.formattedAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5C76B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                onPressed: _isPlacingOrder
                    ? null
                    : () async {
                        await physicalProvider.cancelConversion();

                        if (!mounted) return;

                        setState(() {});
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF981B1B),
                  side: const BorderSide(color: Color(0xFF981B1B)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
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

  Widget _buildPhysicalOrderSummary(
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 20),

          ...items.map((item) {
            final name = item['name']?.toString() ?? 'Product';

            final quantity = int.tryParse('${item['quantity'] ?? 1}') ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$name × $quantity',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  Text(
                    '$currencySymbol 0.00',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 30),

          _summaryRow(
            'Courier charge (Standard delivery)',
            '$currencySymbol 0.00',
          ),

          const SizedBox(height: 16),

          _summaryRow('Total (ex tax)', '$currencySymbol 0.00'),

          const SizedBox(height: 16),

          _summaryRow('Tax (21%)', '$currencySymbol 0.00'),

          const SizedBox(height: 16),

          _summaryRow('Transaction Fee (4%)', '$currencySymbol 0.00'),

          const Divider(height: 30),

          _summaryRow(
            'Order Total',
            '$currencySymbol 0.00',
            bold: true,
            valueColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String currencySymbol, bool isPhysicalConversion) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isPlacingOrder
                ? null
                : () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainScreen(initialIndex: 3),
                        ),
                        (route) => false,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
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

        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isPlacingOrder
                ? null
                : () {
                    if (isPhysicalConversion) {
                      _sendPhysicalOrder();
                    } else {
                      _placeNormalOrder();
                    }
                  },
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
                    isPhysicalConversion
                        ? 'Send Order $currencySymbol 0.00'
                        : 'Proceed to pay',
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

  Widget paymentBox(String title) {
    final bool isSelected = selectedCard == title;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedCard = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(title),
      ),
    );
  }

  Widget summaryRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _summaryRow(
  String title,
  String value, {
  bool bold = false,
  Color valueColor = Colors.black,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: bold ? 15 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: bold ? 15 : 14,
          fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          color: valueColor,
        ),
      ),
    ],
  );
}

String _getStripePaymentMethod(String card) {
  switch (card.toLowerCase()) {
    case "visa":
      return "visa";

    case "mastercard":
      return "mastercard";

    case "g pay":
      return "google_pay";

    case "apple pay":
      return "apple_pay";

    default:
      return "visa";
  }
}
