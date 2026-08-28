import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/checkout/banktransfersuccess.dart';
import 'package:junubullion/screens/checkout/physical_ordersuccess.dart';
import 'package:junubullion/screens/checkout/success.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/checkout_service.dart';
import 'package:junubullion/services/stripe_service.dart';
import 'package:junubullion/theme/app_colors.dart';
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
  bool _isCancellingConversion = false;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  Future<void> _sendPhysicalOrder() async {
    final addressProvider = context.read<AddressProvider>();
    final cartProvider = context.read<CartProvider>();
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

    if (!physicalProvider.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Physical conversion is no longer active"),
        ),
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
        "cartItems=${cartProvider.cartItems} "
        "metal=${physicalProvider.metal} "
        "amount=${physicalProvider.amount}"
        "length = ${cartProvider.cartItems.length}",
      );

      final response = await CheckoutService.placePhysicalOrder(
        shippingAddress: shippingAddress,
        terms: true,
      );

      log("PHYSICAL ORDER RESPONSE -> $response");

      if (!mounted) return;

      if (response["status"] == true) {
        final Map<String, dynamic> orderData =
            response["data"] is Map<String, dynamic>
            ? response["data"] as Map<String, dynamic>
            : <String, dynamic>{};

        final String currency = context
            .read<CurrencyProvider>()
            .selectedCurrency;

        setState(() {
          _isPlacingOrder = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => PhysicalOrderSuccessScreen(
              order: orderData,
              currencySymbol: currency,
            ),
          ),
          (route) => false,
        );

        return;
      }

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

    final savedAddress = prefs.getString("checkout_address");

    if (!mounted) return;

    setState(() {
      localAddress = savedAddress;

      if (savedAddress != null) {
        addressController.text = savedAddress;
      }
    });
  }

  Future<void> _saveAddress() async {
    final address = addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a shipping address")),
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

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final physicalProvider = context.watch<PhysicalConversionProvider>();

    final bool isCancelling = _isCancellingConversion;

    final bool isPhysicalConversion = physicalProvider.isActive;

    final String currencySymbol = currencyProvider.selectedCurrency;

    final bool isDigital = delivery.toLowerCase() == "digital";

    final double courierAmount = isDigital ? 0.0 : cartProvider.courierAmount;

    final double transactionAmount = isDigital
        ? 0.0
        : cartProvider.transactionFeeAmount;

    final double gstAmount = isDigital ? 0.0 : cartProvider.gstAmount;

    final double orderTotal =
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shipping address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 12),

                _buildShippingAddress(),

                const SizedBox(height: 14),

                if (isPhysicalConversion) ...[
                  _buildConversionInfo(physicalProvider),

                  const SizedBox(height: 18),

                  _buildDeliverySection(isPhysicalConversion: true),

                  const SizedBox(height: 20),

                  _buildTerms(),

                  const SizedBox(height: 18),

                  _buildPhysicalOrderSummary(cartProvider, currencySymbol),

                  const SizedBox(height: 25),

                  _buildActionButtons(currencySymbol, true),
                ] else ...[
                  _buildDeliverySection(),

                  const SizedBox(height: 20),

                  if (isDigital) ...[
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
          ),

          if (_isPlacingOrder || _isCancellingConversion)
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

  Widget _buildDeliverySection({bool isPhysicalConversion = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            // =========================================================
            // PHYSICAL
            // =========================================================
            Radio<String>(
              activeColor: AppColors.primaryRed,
              value: "physical",

              // When physical conversion is active,
              // physical MUST always be selected.
              groupValue: isPhysicalConversion ? "physical" : delivery,

              onChanged: isPhysicalConversion
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        delivery = value;
                      });
                    },
            ),

            Text(
              "Physical",
              style: TextStyle(
                fontWeight: isPhysicalConversion
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isPhysicalConversion ? Colors.black : Colors.black87,
              ),
            ),

            const SizedBox(width: 20),

            // =========================================================
            // DIGITAL
            // =========================================================
            Radio<String>(
              activeColor: AppColors.primaryRed,
              value: "Digital",
              groupValue: isPhysicalConversion ? "physical" : delivery,

              // Disable Digital during physical conversion.
              onChanged: isPhysicalConversion
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        delivery = value;
                      });
                    },
            ),

            Text(
              "Digital",
              style: TextStyle(
                color: isPhysicalConversion ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),

        // =========================================================
        // DESCRIPTION
        // =========================================================
        Text(
          isPhysicalConversion
              ? "Physical delivery is required for physical conversion orders."
              : "Digital orders are charged at the product price only — no tax, shipping, or transaction fees.",
          style: TextStyle(
            fontSize: 12,
            color: isPhysicalConversion ? Colors.black54 : Colors.black54,
          ),
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

          // =========================================================
          // CART PRODUCTS
          // =========================================================
          ...provider.cartItems.map((item) {
            final String name = item["name"]?.toString() ?? "Product";

            final int quantity =
                int.tryParse(item["quantity"]?.toString() ?? "1") ?? 1;

            final String productPrice =
                item["formatted_effective_unit_price"]?.toString() ??
                item["formatted_unit_price"]?.toString() ??
                item["formatted_compare_price"]?.toString() ??
                "0.00";

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name + quantity
                  Expanded(
                    child: Text(
                      "$name × $quantity",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Product price
                  Text(
                    productPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 30),

          // =========================================================
          // SUBTOTAL
          // =========================================================
          _summaryRow("Subtotal Product", provider.formattedSubtotal),

          const SizedBox(height: 15),

          // =========================================================
          // COURIER
          // =========================================================
          _summaryRow(
            "Courier Charges",
            isDigital
                ? "${provider.currencySymbol}0.00"
                : "+ ${provider.formattedCourierFee}",
          ),

          const SizedBox(height: 15),

          // =========================================================
          // TRANSACTION FEE
          // =========================================================
          _summaryRow(
            "Transaction Fee",
            isDigital
                ? "${provider.currencySymbol}0.00"
                : "+ ${provider.formattedTransactionFee}",
          ),

          // =========================================================
          // GST
          // =========================================================
          if (!isDigital && provider.gstAmount > 0) ...[
            const SizedBox(height: 15),

            _summaryRow("GST", provider.formattedGST),
          ],

          const Divider(height: 35),

          // =========================================================
          // TOTAL
          // =========================================================
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

    // final bool isCancelling = physicalProvider.isCancellingConversion;

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
                onPressed: (_isPlacingOrder || _isCancellingConversion)
                    ? null
                    : () async {
                        if (_isCancellingConversion) return;

                        // IMPORTANT:
                        // Set this BEFORE the API call so the loader
                        // appears immediately.
                        setState(() {
                          _isCancellingConversion = true;
                        });

                        try {
                          log("CHECKOUT -> Cancelling physical conversion...");

                          final cartProvider = context.read<CartProvider>();

                          final physicalProvider = context
                              .read<PhysicalConversionProvider>();

                          await physicalProvider.cancelConversion(
                            cartProvider: cartProvider,
                          );

                          log(
                            "CHECKOUT -> Physical conversion cancelled successfully",
                          );

                          if (!mounted) return;

                          // Refresh normal cart after cancellation.
                          await cartProvider.fetchCart();

                          if (!mounted) return;

                          setState(() {
                            _isCancellingConversion = false;
                          });
                        } catch (e, stackTrace) {
                          log(
                            "CHECKOUT -> Cancel conversion error: $e",
                            stackTrace: stackTrace,
                          );

                          if (!mounted) return;

                          setState(() {
                            _isCancellingConversion = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceFirst("Exception: ", ""),
                              ),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF981B1B),
                  disabledForegroundColor: Colors.grey,
                  side: BorderSide(
                    color: _isCancellingConversion
                        ? Colors.grey
                        : const Color(0xFF981B1B),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isCancellingConversion
                      ? const Row(
                          key: ValueKey('clearing'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Clearing...', style: TextStyle(fontSize: 12)),
                          ],
                        )
                      : const Text(
                          'Cancel conversion',
                          key: ValueKey('cancel'),
                          style: TextStyle(fontSize: 12),
                        ),
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
    CartProvider cartProvider,
    String currencySymbol,
  ) {
    if (cartProvider.cartItems.isEmpty) {
      return const Text("No items in cart");
    }

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

          // =========================================================
          // CART PRODUCTS
          // =========================================================
          ...cartProvider.cartItems.map((item) {
            final String name = item["name"]?.toString() ?? "Product";

            final int quantity =
                int.tryParse(item["quantity"]?.toString() ?? "1") ?? 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "$name × $quantity",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Physical conversion has no monetary charge.
                  Text(
                    "$currencySymbol 0.00",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 28),

          // =========================================================
          // CHARGES
          // =========================================================
          _summaryRow(
            "Courier charge (Standard delivery)",
            "$currencySymbol 0.00",
          ),

          const SizedBox(height: 18),

          _summaryRow("Total (ex tax)", "$currencySymbol 0.00"),

          const SizedBox(height: 18),

          _summaryRow("Tax (21%)", "$currencySymbol 0.00"),

          const SizedBox(height: 18),

          _summaryRow("Transaction Fee (4%)", "$currencySymbol 0.00"),

          const Divider(height: 30),

          _summaryRow(
            "Order Total",
            "$currencySymbol 0.00",
            bold: true,
            valueColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String currencySymbol, bool isPhysicalConversion) {
    // final physicalProvider = context.watch<PhysicalConversionProvider>();

    // final bool isCancelling = physicalProvider.isCancellingConversion;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: (_isPlacingOrder || _isCancellingConversion)
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

        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: (_isPlacingOrder || _isCancellingConversion)
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
