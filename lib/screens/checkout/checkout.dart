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
import 'package:junubullion/services/gsp_service.dart';
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
  String? digitalSubtype;
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;

      await context.read<AddressProvider>().fetchAddress();

      if (!mounted) return;

      final cartProvider = context.read<CartProvider>();

      await cartProvider.fetchCart();
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

    final bool isPhysicalConversion = physicalProvider.isActive;
    final String currencySymbol = currencyProvider.selectedCurrency;
    final String fulfillment =
        cartProvider.fulfillment?.toLowerCase() ?? "physical";

    final bool isDigital = fulfillment == "digital";
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

  Future<void> _sendPhysicalOrder({required String plan}) async {
    final addressProvider = context.read<AddressProvider>();
    final cartProvider = context.read<CartProvider>();
    final physicalProvider = context.read<PhysicalConversionProvider>();
    final String shippingAddress =
        addressProvider.hasAddress &&
            addressProvider.address != null &&
            addressProvider.address!.trim().isNotEmpty
        ? addressProvider.address!.trim()
        : (localAddress ?? '').trim();
    log("CHECKOUT SHIPPING ADDRESS -> $shippingAddress");

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
        "metal=${physicalProvider.metal} "
        "amount=${physicalProvider.amount}",
      );

      log("plannnnn $plan");

      if (plan.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to determine the physical conversion plan.'),
          ),
        );
        return;
      }

      final response = await CheckoutService.placePhysicalOrder(
        shippingAddress: shippingAddress,
        terms: true,
        digitalType: plan,
      );

      log("PHYSICAL ORDER RESPONSE -> $response");

      if (!mounted) return;

      if (response["status"] == true) {
        await cartProvider.fetchCart();
        if (!mounted) return;

        final Map<String, dynamic> orderData = response["data"] is Map
            ? Map<String, dynamic>.from(response["data"])
            : <String, dynamic>{};

        final String currency = context
            .read<CurrencyProvider>()
            .selectedCurrency;

        setState(() {
          _isPlacingOrder = false;
        });

        await _cancelPhysicalConversion();

        if (!mounted) return;

        log("Cancelling conversion after placing order");

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

  Future<void> _cancelPhysicalConversion() async {
    if (_isCancellingConversion || _isPlacingOrder) {
      return;
    }

    setState(() {
      _isCancellingConversion = true;
    });

    try {
      log("CHECKOUT -> Cancelling physical conversion...");

      final cartProvider = context.read<CartProvider>();
      final currencyProvider = context.read<CurrencyProvider>();
      final physicalProvider = context.read<PhysicalConversionProvider>();

      final bool success = await physicalProvider.cancelConversion(
        cartProvider: cartProvider,
        currencyProvider: currencyProvider,
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _isCancellingConversion = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to cancel physical conversion. Please try again.",
            ),
          ),
        );

        return;
      }

      log("CHECKOUT -> Physical conversion cancelled successfully");
      setState(() {
        _isCancellingConversion = false;
      });
      log("CHECKOUT -> Cart and physical conversion status refreshed");
    } catch (e, stackTrace) {
      log("CHECKOUT -> Cancel conversion error: $e", stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _isCancellingConversion = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  Widget _buildDeliverySection({bool isPhysicalConversion = false}) {
    final cartProvider = context.watch<CartProvider>();

    final String fulfillment =
        cartProvider.fulfillment?.toLowerCase().trim() ?? "";

    digitalSubtype = cartProvider.digitalSubtype?.toLowerCase().trim();

    final bool isPhysical = fulfillment == "physical";
    final bool isDigital = fulfillment == "digital";
    final bool isMixed = fulfillment == "mixed";

    // Mixed cart:
    // Do not show Physical/Digital radio buttons.
    if (isMixed) {
      return _buildMixedFulfillmentInfo(digitalSubtype);
    }

    final String effectiveDelivery = isPhysical
        ? "physical"
        : isDigital
        ? "digital"
        : delivery;

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
            Radio<String>(
              activeColor: AppColors.primaryRed,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryRed;
                }

                return Colors.black;
              }),
              value: "physical",
              groupValue: effectiveDelivery,
              onChanged: isPhysical || isDigital
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
              // style: TextStyle(
              //   fontWeight: effectiveDelivery == "physical"
              //       ? FontWeight.w600
              //       : FontWeight.normal,
              //   color: isDigital ? Colors.grey : Colors.black87,
              // ),
            ),

            const SizedBox(width: 20),

            Radio<String>(
              activeColor: AppColors.primaryRed,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryRed;
                }

                return Colors.black;
              }),
              value: "digital",
              groupValue: effectiveDelivery,
              onChanged: isPhysical || isDigital
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
              // style: TextStyle(
              //   fontWeight: effectiveDelivery == "digital"
              //       ? FontWeight.w600
              //       : FontWeight.normal,
              //   color: isPhysical ? Colors.grey : Colors.black87,
              // ),
            ),
          ],
        ),

        Text(
          isPhysical
              ? "Physical delivery is required for the products in your cart. Digital JSC is only available for JSC plan products."
              : isDigital
              ? "Your cart contains ${digitalSubtype?.toUpperCase()} plan products, which are digital only and credited to your wallet."
              : "Select your preferred delivery option.",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMixedFulfillmentInfo(String? digitalSubtype) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5C76B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9A7200), size: 22),

          const SizedBox(width: 10),

          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(
                    text: "Heads up: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A5B00),
                    ),
                  ),
                  const TextSpan(
                    text:
                        "Your cart includes JSC digital plan products together with regular physical products. Digital items will be credited to your wallet after payment. Physical items will be shipped to your address after KYC verification is approved.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalSubtype() {
    final cartProvider = context.watch<CartProvider>();

    final String? subtype = cartProvider.digitalSubtype;

    final String selectedSubtype = subtype?.toLowerCase() == "gsp"
        ? "Gsp"
        : "Jsc";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Digital subtype",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Radio<String>(
              value: "Jsc",
              groupValue: selectedSubtype,
              activeColor: AppColors.primaryRed,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryRed;
                }

                return Colors.black;
              }),
              onChanged: subtype != null
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        digitalSubtype = value;
                      });
                    },
            ),

            const Text("JSC"),

            const SizedBox(width: 20),

            Radio<String>(
              value: "Gsp",
              groupValue: selectedSubtype,
              activeColor: AppColors.primaryRed,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primaryRed;
                }

                return Colors.black;
              }),
              onChanged: subtype != null
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        digitalSubtype = value;
                      });
                    },
            ),

            const Text("GSP"),
          ],
        ),

        Text(
          subtype != null
              ? "${subtype.toUpperCase()} plan products in this cart are digital-only, so ${subtype.toUpperCase()} remains selected for this order."
              : "Choose JSC or GSP for your digital gold purchase.",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
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

    if (shippingAddress == null || shippingAddress.trim().isEmpty) {
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
      final cartProvider = context.read<CartProvider>();

      final bool isDigital =
          cartProvider.fulfillment?.toLowerCase().trim() == "digital";

      final String courierService = cartProvider.selectedDeliveryMethod
          .toLowerCase();

      log(
        "CHECKOUT -> Placing normal order: "
        "address=$shippingAddress "
        "delivery=$delivery "
        "digitalType=$digitalSubtype "
        "payment=$payment"
        "isDigital=$isDigital "
        "courierService=$courierService ",
      );

      if (payment == "Bank") {
        final response = await CheckoutService.placeOrder(
          shippingAddress: shippingAddress.trim(),

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

      if (payment == "Card") {
        final String stripePaymentMethod = _getStripePaymentMethod(
          selectedCard!,
        );

        log(
          "CHECKOUT -> Stripe payment method: $shippingAddress $delivery $isDigital- ${cartProvider.selectedDeliveryMethod} ${currencyProvider.selectedCurrency} ${isDigital ? digitalSubtype : null} $stripePaymentMethod",
        );

        final stripeResponse = await StripeService.createStripeSession(
          shippingAddress: shippingAddress.trim(),

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

        // Payment successful -> clear cart
        log("STRIPE PAYMENT SUCCESS -> Clearing cart...");

        cartProvider.clearCart();

        // Refresh cart from backend to make sure it is empty
        await cartProvider.fetchCart();

        if (!mounted) return;

        log(
          "STRIPE PAYMENT SUCCESS -> Cart cleared. "
          "Cart count: ${cartProvider.cartCount}",
        );

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
    BoxDecoration cardDecoration() {
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
            decoration: cardDecoration(),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final String? displayAddress = addressProvider.hasAddress
            ? addressProvider.address
            : localAddress;

        if (displayAddress == null && !showAddressForm) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
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

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(),
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
            Radio<String>(
              activeColor: AppColors.primaryRed,
              value: "Card",
              groupValue: payment,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  payment = value;
                });
              },
            ),

            const Text("Card"),

            Radio<String>(
              activeColor: AppColors.primaryRed,
              value: "Bank",
              groupValue: payment,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  payment = value;
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

    final String deliveryMethod = isDigital
        ? "Digital"
        : provider.selectedDeliveryMethod;

    final Map<String, dynamic>? coupon = provider.coupon;

    return Container(
      width: double.infinity,
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
                  Expanded(
                    child: Text(
                      "$name × $quantity",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    _formatCheckoutCurrency(productPrice, currencySymbol),
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

          _checkoutSummaryRow(
            "Subtotal Product",
            _formatCheckoutCurrency(provider.formattedSubtotal, currencySymbol),
          ),

          const SizedBox(height: 15),

          _checkoutSummaryRow(
            "Courier charge (${deliveryMethod} delivery)",
            "+ ${_formatCheckoutCurrency(isDigital ? "0.00" : provider.formattedCourierFee, currencySymbol)}",
          ),

          if (coupon != null) ...[
            const SizedBox(height: 15),

            _checkoutSummaryRow(
              "Discount (${coupon["code"] ?? ""})",
              "- ${_formatCheckoutCurrency(provider.formattedDiscount, currencySymbol)}",
            ),

            const SizedBox(height: 15),

            _checkoutSummaryRow(
              "Discount Price",
              _formatCheckoutCurrency(
                provider.formattedDiscountPrice,
                currencySymbol,
              ),
            ),
          ],

          const SizedBox(height: 15),

          _checkoutSummaryRow(
            "Transaction fee (4%)",
            "+ ${_formatCheckoutCurrency(isDigital ? "0.00" : provider.formattedTransactionFee, currencySymbol)}",
          ),

          if (provider.showTax) ...[
            const SizedBox(height: 15),

            _checkoutSummaryRow(
              "GST (21%)",
              "+ ${_formatCheckoutCurrency(isDigital ? "0.00" : provider.formattedGST, currencySymbol)}",
            ),
          ],

          const Divider(height: 35),

          _checkoutSummaryRow(
            "Total",
            _formatCheckoutCurrency(
              isDigital
                  ? provider.formattedSubtotal
                  : provider.formattedOrderTotal,
              currencySymbol,
            ),
            bold: true,
            valueColor: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }

  String _formatCheckoutCurrency(String value, String currency) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return '$currency 0.00';
    }

    if (_hasCheckoutCurrency(trimmedValue)) {
      return trimmedValue;
    }

    return '$currency $trimmedValue';
  }

  bool _hasCheckoutCurrency(String value) {
    final String upperValue = value.toUpperCase();

    const List<String> currencyCodes = [
      'USD',
      'INR',
      'EUR',
      'GBP',
      'SGD',
      'AED',
      'SAR',
      'QAR',
      'AUD',
      'CAD',
      'JPY',
      'CNY',
    ];

    for (final code in currencyCodes) {
      if (upperValue.contains(code)) {
        return true;
      }
    }

    const List<String> currencySymbols = [
      '₹',
      '\$',
      '€',
      '£',
      '¥',
      '₩',
      '₽',
      '₺',
      '฿',
      '₫',
      '₦',
      '₱',
    ];

    for (final symbol in currencySymbols) {
      if (value.contains(symbol)) {
        return true;
      }
    }

    return false;
  }

  Widget _checkoutSummaryRow(
    String title,
    String value, {
    bool bold = false,
    Color valueColor = Colors.black,
  }) {
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

        const SizedBox(width: 12),

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
                    : _cancelPhysicalConversion,
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

                  // Physical conversion
                  // has NO monetary charge.
                  Text(
                    "$currencySymbol 0.00",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 28),

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
                : () async {
                    try {
                      final currencyProvider = context.read<CurrencyProvider>();

                      dynamic plan;

                      final res = await GspService.fetchConvertPhysicalDetails(
                        currency: currencyProvider.selectedCurrency,
                      );

                      log("fetchConvertPhysicalDetails response: $res");

                      log(
                        "fetchConvertPhysicalDetails data: "
                        "${res['data']}",
                      );

                      // If you want to print individual values:
                      if (res['data'] != null) {
                        final data = Map<String, dynamic>.from(res['data']);

                        log("Convert Physical Data: $data");

                        log("Golddd: ${data['wallet_section']}");

                        plan = data['wallet_section'];
                      }

                      if (isPhysicalConversion) {
                        _sendPhysicalOrder(plan: plan);
                      } else {
                        _placeNormalOrder();
                      }
                    } catch (e, stackTrace) {
                      log("fetchConvertPhysicalDetails error: $e");

                      log("StackTrace: $stackTrace");
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
      onTap: () {
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
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),

      const SizedBox(width: 12),

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
