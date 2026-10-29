import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/checkout/banktransfersuccess.dart';
import 'package:junubullion/screens/checkout/physical_ordersuccess.dart';
import 'package:junubullion/screens/checkout/stripe_otp_dialog.dart';
import 'package:junubullion/screens/checkout/success.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/checkout_service.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/stripe_service.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? delivery;
  // String payment = "Card";
  String? fulfillment;
  int _currentIndex = 3;
  String? digitalSubtype;
  final TextEditingController addressController = TextEditingController();

  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  bool isTermsAccepted = false;
  bool _isPlacingOrder = false;
  bool showAddressForm = false;
  // String? localAddress;
  // String? selectedCard;
  bool _isCancellingConversion = false;
  bool _isRemovingItem = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  // bool _initialAddressLoaded = false;
  String paymentMethod = "Bank";
  String? selectedCard;
  String? selectedBank;
  String? upiQrUrl;
  bool _isGeneratingUpiQr = false;
  String? upiQrCode;
  String? upiId;
  double? upiAmount;
  bool upiQrGenerated = false;

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

      final addressProvider = context.read<AddressProvider>();

      // Fetch the latest address from API.
      await addressProvider.fetchAddress();

      if (!mounted) return;

      // Put API address into the editable field once.
      if (addressProvider.hasAddress &&
          addressProvider.address != null &&
          addressProvider.address!.trim().isNotEmpty) {
        addressController.text = addressProvider.address!.trim();
      }

      final cartProvider = context.read<CartProvider>();
      await cartProvider.fetchCart();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AccountProvider>();

      await provider.fetchAccountDetails();

      if (!mounted) return;

      contactPersonController.text = provider.name;
      emailController.text = provider.email;
      phoneController.text = provider.phone;

      setState(() {});
    });
  }

  List<String> getPaymentMethods(String currency) {
    switch (currency.toUpperCase()) {
      case "SGD":
        return ["Card", "paynow", "Bank"];

      case "INR":
        return ["Card", "upi", "Bank"];

      case "CAD":
      case "USD":
      case "EUR":
      case "AED":
      case "CNY":
        return ["Card", "Bank"];

      default:
        return ["Card"];
    }
  }

  List<String> getBanks(String currency) {
    switch (currency.toUpperCase()) {
      case "SGD":
        return [
          "CIMB Bank Berhad",
          "United Overseas Bank",
          "DBS Bank",
          "OCBC Bank",
          "HSBC Bank",
          "Maybank",
        ];

      case "CAD":
        return [
          "CIMB Bank Berhad",
          "Canadian Imperial Bank Of Commerce",
          "Royal Bank Of Canada",
          "HSBC Bank",
        ];

      case "INR":
        return [
          "ICICI Bank",
          "HDFC Bank",
          "Axis Bank",
          "Federal Bank",
          "Canara Bank",
          "State Bank Of India",
          "Central Bank Of India",
        ];

      case "USD":
      case "EUR":
      case "AED":
      case "CNY":
        return ["CIMB Bank Berhad"];

      default:
        return [];
    }
  }

  // String? _getBankUrl(String bank) {
  //   const bankUrls = {
  //     "ICICI Bank": "https://www.icicibank.com/internet-banking",
  //     "HDFC Bank": "https://netbanking.hdfcbank.com/netbanking/",
  //     "Axis Bank": "https://www.axis.bank.in/bank-smart/internet-banking",
  //     "Federal Bank": "https://www.federalbank.co.in/fednet",
  //     "Canara Bank": "https://www.canarabank.bank.in/pages/net-banking",
  //     "State Bank Of India": "https://retail.onlinesbi.sbi/retail/login.htm",
  //     "Central Bank Of India":
  //         "https://centralbank.bank.in/en/internet-banking",
  //     "CIMB Bank Berhad": "https://www.cimbclicks.com.sg/",
  //     "United Overseas Bank": "https://pib.uob.com.sg/auth/login",
  //     "Maybank":
  //         "https://sslsecure.maybank.com.sg/cgi-bin/mbs/scripts/mbb_login.jsp",
  //     "OCBC Bank":
  //         "https://internet.ocbc.com/internet-banking/digital/web/sg/cfo/login/login",
  //     "DBS Bank": "https://internet-banking.dbs.bank.in/login",
  //     "HSBC Bank":
  //         "https://www.us.hsbc.com/auth/?returnUrl=https://www.us.hsbc.com/bin/epep/postback.html?url=/online/dashboard",
  //     "Canadian Imperial Bank Of Commerce": "https://secure.cibc.com",
  //     "Royal Bank Of Canada": "https://www.rbcroyalbank.com/personal.html",
  //   };

  //   return bankUrls[bank];
  // }

  // Future<void> _openBankUrl() async {
  //   if (selectedBank == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Please select a bank")));
  //     return;
  //   }

  //   final url = _getBankUrl(selectedBank!);

  //   if (url == null || url.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Bank URL not available")));
  //     return;
  //   }

  //   final uri = Uri.tryParse(url);

  //   if (uri == null ||
  //       (uri.scheme != 'https' && uri.scheme != 'http') ||
  //       uri.host.isEmpty) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Invalid bank website URL")));
  //     return;
  //   }

  //   try {
  //     final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

  //     if (!opened && mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Unable to open bank website")),
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     log("OPEN BANK URL ERROR: $e", stackTrace: stackTrace);

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Unable to open bank website")),
  //     );
  //   }
  // }

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    contactPersonController.dispose();
    emailController.dispose();
    phoneController.dispose();
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

    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == 'pickup';
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
                if (!isPickup) ...[
                  const TranslatedText(
                    'Shipping To',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  _buildShippingAddress(),

                  const SizedBox(height: 14),
                ],
                if (isPhysicalConversion) ...[
                  _buildConversionInfo(physicalProvider),
                  const SizedBox(height: 18),
                  _buildDeliverySection(isPhysicalConversion: true),
                  const SizedBox(height: 20),
                  _buildTerms(),
                  const SizedBox(height: 18),
                  _buildPhysicalOrderSummary(cartProvider, currencySymbol),
                  // const SizedBox(height: 25),

                  // _buildBackButton(),
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
                ],
              ],
            ),
          ),
          if (_isPlacingOrder || _isCancellingConversion || _isRemovingItem)
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

  Future<void> _removeCartItem(dynamic productId) async {
    if (_isRemovingItem || _isPlacingOrder) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xffF7F7F7),
        title: const TranslatedText("Remove Item"),
        content: const TranslatedText(
          "Are you sure you want to remove this product from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TranslatedText("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const TranslatedText(
              "Remove",
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isRemovingItem = true);

    try {
      final cartProvider = context.read<CartProvider>();
      final bool success = await cartProvider.removeFromCart(productId);

      if (!mounted) return;

      setState(() => _isRemovingItem = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TranslatedText(
              "Unable to remove product. Please try again.",
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText("Product removed from cart")),
      );

      // Last product removed -> cart is empty -> go to Home
      if (cartProvider.cartItems.isEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      log("CHECKOUT -> Remove item error: $e", stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isRemovingItem = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText(
            "Unable to remove product. Please try again.",
          ),
        ),
      );
    }
  }

  Future<void> _sendPhysicalOrder({required String plan}) async {
    final cartProvider = context.read<CartProvider>();
    final physicalProvider = context.read<PhysicalConversionProvider>();
    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == 'pickup';

    final String shippingAddress = isPickup
        ? ''
        : addressController.text.trim();

    final String city = isPickup ? '' : cityController.text.trim();

    final String state = isPickup ? '' : stateController.text.trim();

    final String pin = isPickup ? '' : zipController.text.trim();

    final String contactPerson = isPickup
        ? ''
        : contactPersonController.text.trim();

    final String contactEmail = isPickup ? '' : emailController.text.trim();

    final String contactPhone = isPickup ? '' : phoneController.text.trim();

    if (!isPickup && shippingAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please add your shipping address"),
        ),
      );
      return;
    }

    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please agree to the Terms & Conditions"),
        ),
      );
      return;
    }

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText("Your cart is empty")),
      );
      return;
    }

    if (!physicalProvider.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Physical conversion is no longer active"),
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
            content: TranslatedText(
              'Unable to determine the physical conversion plan.',
            ),
          ),
        );
        return;
      }

      final response = await CheckoutService.placePhysicalOrder(
        shippingAddress: shippingAddress,
        city: city,
        state: state,
        pin: pin,
        contactPerson: contactPerson,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        terms: true,
        digitalType: plan,
      );

      log("PHYSICAL ORDER RESPONSE -> $response");

      if (!mounted) return;

      if (response["status"] == true) {
        final Map<String, dynamic> orderData = response["data"] is Map
            ? Map<String, dynamic>.from(response["data"])
            : <String, dynamic>{};

        final String currency = context
            .read<CurrencyProvider>()
            .selectedCurrency;

        log("PHYSICAL ORDER SUCCESS -> Order created");
        log("PHYSICAL ORDER SUCCESS -> Cancelling physical conversion...");

        try {
          final physicalProvider = context.read<PhysicalConversionProvider>();

          final currencyProvider = context.read<CurrencyProvider>();

          final success = await physicalProvider.cancelConversion(
            cartProvider: cartProvider,
            currencyProvider: currencyProvider,
          );

          log("PHYSICAL ORDER -> Conversion cancelled: $success");
        } catch (e, stackTrace) {
          log(
            "PHYSICAL ORDER -> Error cancelling conversion after success: $e",
            stackTrace: stackTrace,
          );
        }

        if (!mounted) return;

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
          content: TranslatedText(
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
        SnackBar(
          content: TranslatedText(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  Widget _buildBankSelection(String currency) {
    final banks = getBanks(currency);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE9D7D7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance, color: AppColors.primaryRed),
              SizedBox(width: 10),
              Text(
                "Select your bank",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            "Choose your bank, then pay directly from your net banking or mobile app to our account below.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: banks.map((bank) {
              final bool isSelected = selectedBank == bank;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedBank = bank;
                  });
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryRed
                          : const Color(0xffE9D7D7),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: bank,
                        groupValue: selectedBank,
                        activeColor: AppColors.primaryRed,
                        onChanged: (value) {
                          setState(() {
                            selectedBank = value;
                          });
                        },
                      ),

                      Expanded(
                        child: Text(
                          bank,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          if (selectedBank != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffD9D9D9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transfer to our account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "JUNU SG PTE LTD",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Bank: $selectedBank",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff5B6B84),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Account number: 2001093941",
                    style: TextStyle(fontSize: 14, color: Color(0xff5B6B84)),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "BIC / SWIFT: CIBBSGSGXXX",
                    style: TextStyle(fontSize: 14, color: Color(0xff5B6B84)),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Use your order number as payment reference after you place the order.",
                    style: TextStyle(fontSize: 14, color: Color(0xff5B6B84)),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "1. Confirm your shipping address and agree to the Terms & Conditions.\n"
                    "2. Click the button below. Your order is placed and you are taken to the thank-you page while net banking opens in a new tab.\n"
                    "3. Log in at your bank, transfer the exact order total using the details on the thank-you page, then email your receipt to us.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xff394150),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: (_isPlacingOrder || selectedBank == null)
                          ? null
                          : () async {
                              await _placeNormalOrder();
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                      label: Text(
                        "Open $selectedBank net banking",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _generateUpiQr() async {
    final cartProvider = context.read<CartProvider>();
    final currencyProvider = context.read<CurrencyProvider>();

    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == "pickup";

    Map<String, dynamic> payload;

    if (isPickup) {
      payload = {
        "courier_service": "pickup",
        "terms": true,
        "payment_type": "upi",
        "delivery_option": "digital",
        "digital_type": "jsc",
        "currency": "INR",
      };
    } else {
      payload = {
        "courier_service": "standard",
        "terms": true,
        "payment_type": "upi",
        "street_address": addressController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "pin": zipController.text.trim(),
        "contact_person": contactPersonController.text.trim(),
        "contact_email": emailController.text.trim(),
        "contact_number": phoneController.text.trim(),
        "currency": "INR",
      };
    }

    setState(() {
      _isGeneratingUpiQr = true;
    });

    try {
      final response = await CheckoutService.generateUpiQr(payload: payload);

      log("UPI PREVIEW RESPONSE => $response");

      if (response["status"] == true) {
        setState(() {
          upiQrGenerated = true;

          upiQrCode = response["qr_code"];
          upiId = response["upi_id"];

          upiAmount = (response["amount"] as num?)?.toDouble();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Unable to generate QR code"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isGeneratingUpiQr = false;
      });
    }
  }

  void _showUpiQrDialog() {
    if (upiQrCode == null) return;

    final svgBase64 = upiQrCode!.replaceFirst('data:image/svg+xml;base64,', '');

    final svgString = utf8.decode(base64Decode(svgBase64));

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Scan UPI QR"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.string(svgString, width: 250, height: 250),

                const SizedBox(height: 16),

                Text(
                  "Amount: ₹${upiAmount?.toStringAsFixed(2) ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                SelectableText(
                  upiId ?? "",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Scan this QR using Google Pay, PhonePe, Paytm or any UPI app.",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
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
            content: TranslatedText(
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
        SnackBar(
          content: TranslatedText(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  Widget _buildDeliverySection({bool isPhysicalConversion = false}) {
    final cartProvider = context.watch<CartProvider>();

    fulfillment = cartProvider.fulfillment?.toLowerCase().trim() ?? "";

    digitalSubtype = cartProvider.digitalSubtype?.toLowerCase().trim();

    log("CHECKOUT -> Cart fulfillment: $cartProvider");

    final bool isPhysical = fulfillment == "physical";
    final bool isDigital = fulfillment == "digital";
    final bool isMixed = fulfillment == "mixed";

    if (isMixed) {
      return _buildMixedFulfillmentInfo(digitalSubtype);
    }

    final effectiveDelivery = isPhysical
        ? "physical"
        : isDigital
        ? "digital"
        : delivery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          "Delivery option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          // padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE9D7D7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
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

                  TranslatedText("Physical"),

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

                  TranslatedText("Digital"),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 18,
                  top: 8,
                  bottom: 18,
                ),
                child: TranslatedText(
                  isPhysical
                      ? "Physical delivery is required for the products in your cart. Digital JSC is only available for JSC plan products."
                      : isDigital
                      ? "Your cart contains ${digitalSubtype?.toUpperCase()} plan products, which are digital only and credited to your wallet."
                      : "Select your preferred delivery option.",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _shouldShowDeliveryMethod(CartProvider cartProvider) {
    if (cartProvider.cartItems.isEmpty) {
      return false;
    }

    // If ALL products are digital plans (JSC/GSP),
    // hide delivery-related details.
    final bool allDigitalPlans = cartProvider.cartItems.every((item) {
      return item["is_digital_plan"] == true;
    });

    // Show delivery details when at least one physical
    // product exists in the cart.
    return !allDigitalPlans;
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

  String _getBankCode(String bank) {
    switch (bank) {
      case "ICICI Bank":
        return "icici";

      case "HDFC Bank":
        return "hdfc";

      case "Axis Bank":
        return "axis";

      case "Federal Bank":
        return "federal";

      case "Canara Bank":
        return "canara";

      case "State Bank Of India":
        return "sbi";

      case "Central Bank Of India":
        return "cbi";

      case "CIMB Bank Berhad":
        return "cimb";

      case "United Overseas Bank":
        return "uob";

      case "DBS Bank":
        return "dbs";

      case "OCBC Bank":
        return "ocbc";

      case "HSBC Bank":
        return "hsbc";

      case "Maybank":
        return "maybank";

      case "Canadian Imperial Bank Of Commerce":
        return "cibc";

      case "Royal Bank Of Canada":
        return "rbc";

      default:
        return "";
    }
  }

  Widget _buildDigitalSubtype() {
    final cartProvider = context.watch<CartProvider>();

    final String? subtype = cartProvider.digitalSubtype;

    log("CHECKOUT -> Cart digital subtype: $subtype");

    final String selectedSubtype = subtype?.toLowerCase() == "gsp"
        ? "Gsp"
        : "Jsc";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
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

            const TranslatedText("JSC"),

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

            const TranslatedText("GSP"),
          ],
        ),

        TranslatedText(
          subtype != null
              ? "${subtype.toUpperCase()} plan products in this cart are digital-only, so ${subtype.toUpperCase()} remains selected for this order."
              : "Choose JSC or GSP for your digital gold purchase.",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Future<void> _placeNormalOrder() async {
    // final addressProvider = context.read<AddressProvider>();
    final cartProvider = context.read<CartProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == 'pickup';

    final String shippingAddress = isPickup
        ? ''
        : addressController.text.trim();

    final String city = isPickup ? '' : cityController.text.trim();

    final String state = isPickup ? '' : stateController.text.trim();

    final String pin = isPickup ? '' : zipController.text.trim();

    final String contactPerson = isPickup
        ? ''
        : contactPersonController.text.trim();

    final String contactEmail = isPickup ? '' : emailController.text.trim();

    final String contactPhone = isPickup ? '' : phoneController.text.trim();

    if (!isPickup && shippingAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please add your shipping address"),
        ),
      );
      return;
    }

    if (!isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please agree to the Terms & Conditions"),
        ),
      );
      return;
    }

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TranslatedText("Your cart is empty")),
      );
      return;
    }

    if (paymentMethod == "Card" && selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please select a payment method"),
        ),
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
        "delivery=$fulfillment "
        "digitalType=$digitalSubtype "
        "payment=$paymentMethod"
        "isDigital=$isDigital "
        "courierService=$courierService ",
      );

      if (paymentMethod == "Bank") {
        final response = await CheckoutService.placeOrder(
          // shippingAddress: shippingAddress.trim(),
          shippingAddress: shippingAddress.trim(),

          city: city.trim(),

          state: state.trim(),

          pin: pin.trim(),

          contactPerson: contactPerson.trim(),

          contactEmail: contactEmail.trim(),

          contactPhone: contactPhone.trim(),

          deliveryOption: fulfillment!.toLowerCase().trim(),

          digitalType: isDigital ? digitalSubtype : null,

          courierService: isDigital ? null : courierService,

          terms: true,

          paymentType: "bank_transfer",

          customerBank: _getBankCode(selectedBank!),

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
                summary: response["summary"],
                currencySymbol:
                    response["summary"]?["symbol"] ??
                    currencyProvider.selectedCurrency,
                bankName: selectedBank!,
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
              content: TranslatedText(
                response["message"] ?? "Order is not placed. Please try again.",
              ),
            ),
          );
        }

        return;
      }

      if (paymentMethod == "Card") {
        final String stripePaymentMethod = _getStripePaymentMethod(
          selectedCard!,
        );

        log(
          "CHECKOUT -> Stripe payment method: "
          "$shippingAddress "
          "$fulfillment "
          "$isDigital ? null : ${cartProvider.selectedDeliveryMethod} "
          "${currencyProvider.selectedCurrency} "
          "$digitalSubtype "
          "$stripePaymentMethod",
        );

        final stripeResponse = await StripeService.createStripeSession(
          shippingAddress: shippingAddress.trim(),
          city: city,
          state: state,
          pin: pin,
          contactPerson: contactPerson,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          fulfillmentType: fulfillment!.toLowerCase().trim(),
          courierService: isDigital
              ? null
              : cartProvider.selectedDeliveryMethod,
          currency: currencyProvider.selectedCurrency,
          digitalSubtype: digitalSubtype,
          terms: true,
          paymentMethod: stripePaymentMethod,
        );

        log("STRIPE RESPONSE -> $stripeResponse");

        if (stripeResponse["status"] == false) {
          throw Exception(
            stripeResponse["message"] ?? "Unable to create payment session",
          );
        }

        // final clientSecret = stripeResponse["data"]?["client_secret"];

        // // Get payment intent ID from create session response
        // final paymentIntentId = stripeResponse["data"]?["payment_intent_id"];

        // log("STRIPE CLIENT SECRET -> $clientSecret");
        // log("STRIPE PAYMENT INTENT ID -> $paymentIntentId");

        // if (clientSecret == null || clientSecret.toString().trim().isEmpty) {
        //   throw Exception("Stripe client secret not received");
        // }

        // if (paymentIntentId == null ||
        //     paymentIntentId.toString().trim().isEmpty) {
        //   throw Exception("Stripe payment intent ID not received");
        // }

        final Map<String, dynamic> stripeData = Map<String, dynamic>.from(
          stripeResponse["data"] ?? {},
        );

        String? clientSecret = stripeData["client_secret"]?.toString();
        final paymentIntentId = stripeData["payment_intent_id"];
        final bool otpRequired = stripeData["otp_required"] == true;

        if (paymentIntentId == null ||
            paymentIntentId.toString().trim().isEmpty) {
          throw Exception("Stripe payment intent ID not received");
        }

        final String otpEmail =
            (stripeData["default_email"]?.toString().trim().isNotEmpty ?? false)
            ? stripeData["default_email"].toString().trim()
            : contactEmail;

        final String stripeCurrency =
            (stripeData["currency"] ?? currencyProvider.selectedCurrency)
                .toString();

        final int amountMinor =
            ((double.tryParse(stripeData["amount"].toString()) ?? 0) * 100)
                .round();

        bool paymentSuccess;

        if (clientSecret != null && clientSecret.trim().isNotEmpty) {
          // normal flow: backend already gave a secret
          paymentSuccess = await StripeService.makePayment(clientSecret);
        } else if (otpRequired) {
          // Stripe sheet first -> then email OTP -> then confirm
          paymentSuccess = await StripeService.payWithDeferredIntent(
            currency: stripeCurrency,
            amountMinor: amountMinor,
            email: otpEmail,
            otpStep: () async {
              // Stripe details are done -> NOW trigger the email OTP
              await StripeService.sendPaymentOtp(
                paymentIntentId: paymentIntentId.toString(),
                email: otpEmail,
              );

              try {
                await StripeService.paymentOtpStatus(
                  paymentIntentId: paymentIntentId.toString(),
                );
              } catch (e) {
                log("STRIPE OTP STATUS ERROR -> $e");
              }

              if (!mounted) return null;

              setState(
                () => _isPlacingOrder = false,
              ); // hide page loader for dialog

              final secret = await showStripeOtpDialog(
                context,
                paymentIntentId: paymentIntentId.toString(),
                email: otpEmail,
              );

              if (mounted && secret != null) {
                setState(() => _isPlacingOrder = true);
              }
              return secret;
            },
          );
        } else {
          throw Exception("Stripe client secret not received");
        }
        log("PAYMENT SUCCESS -> $paymentSuccess");

        if (!mounted) return;

        if (!paymentSuccess) {
          setState(() {
            _isPlacingOrder = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: TranslatedText("Payment was not completed."),
            ),
          );

          return;
        }

        log(
          "STRIPE PAYMENT COMPLETED -> "
          "Calling /checkout/stripe/success "
          "with payment_intent_id: $paymentIntentId",
        );

        final successResponse = await StripeService.stripePaymentSuccess(
          paymentIntentId: paymentIntentId.toString(),
        );

        log("STRIPE SUCCESS RESPONSE -> $successResponse");

        if (successResponse["status"] == false) {
          throw Exception(
            successResponse["message"] ?? "Unable to confirm Stripe payment",
          );
        }

        log("STRIPE SUCCESS API COMPLETED -> Clearing cart...");

        cartProvider.clearCart();

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
        SnackBar(
          content: TranslatedText(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    }
  }

  Widget _buildShippingAddress() {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE9D7D7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ADDRESS DETAILS",
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Street Address",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: addressController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  hintText: "House no., street, area",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "City",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: cityController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  hintText: "Enter city",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "State / Province / Region",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: stateController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  hintText: "Enter state / province / region",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Postal / ZIP Code",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: zipController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  hintText: "Enter postal / zip code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "CONTACT PERSON DETAILS",
                style: TextStyle(
                  color: AppColors.primaryRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Contact Person",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: contactPersonController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Email",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: emailController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Contact Number",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: phoneController,
                maxLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF7EEEA),
                  hintText: "+91XXXXXXXXXX",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
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
    final currencyProvider = context.read<CurrencyProvider>();
    final String currencySymbol = currencyProvider.selectedCurrency;

    final paymentMethods = getPaymentMethods(currencySymbol);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          "Payment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          // padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffE9D7D7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              ...paymentMethods.map((method) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      value: method,
                      groupValue: paymentMethod,
                      title: Text(
                        method == "Card"
                            ? "Card payment"
                            : method == "paynow"
                            ? "PayNow"
                            : method == "upi"
                            ? "UPI Payment"
                            : "Direct bank transfer",
                      ),
                      onChanged: (value) async {
                        if (value == "Card") {
                          await _showCardPaymentInfo();
                        }

                        setState(() {
                          paymentMethod = value!;
                        });
                      },
                    ),

                    // CARD OPTIONS DIRECTLY BELOW CARD
                    if (method == "Card" && paymentMethod == "Card")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            paymentBox("assets/visa.png"),
                            paymentBox("assets/mastercard.png"),
                            paymentBox("assets/googlepay.png"),
                            paymentBox("assets/applepay.png"),
                          ],
                        ),
                      ),

                    // PAYNOW OPTIONS DIRECTLY BELOW PAYNOW
                    if (method == "paynow" && paymentMethod == "paynow")
                      _buildPayNowSection(),

                    if (method == "upi" && paymentMethod == "upi")
                      upiQrGenerated && upiQrCode != null
                          ? _buildGeneratedQrSection()
                          : _buildUpiSection(),
                    // _buildUpiSection(),

                    // BANK OPTIONS DIRECTLY BELOW BANK
                    if (method == "Bank" && paymentMethod == "Bank")
                      _buildBankSelection(currencySymbol),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _buildUpiPaymentPayload() {
    final cartProvider = context.read<CartProvider>();

    final String selectedDelivery =
        (delivery ?? cartProvider.fulfillment ?? "physical").toLowerCase();

    if (selectedDelivery == "digital") {
      return {
        "payment_type": "upi",
        "delivery_option": "digital",
        "digital_type": (digitalSubtype ?? cartProvider.digitalSubtype ?? "jsc")
            .toLowerCase(),
        "currency": "INR",
        "terms": true,
      };
    }

    return {
      "payment_type": "upi",
      "delivery_option": "physical",
      "currency": "INR",
      "courier_service": cartProvider.selectedDeliveryMethod.toLowerCase(),
      "terms": true,
      "street_address": addressController.text.trim(),
      "city": cityController.text.trim(),
      "state": stateController.text.trim(),
      "pin": zipController.text.trim(),
      "contact_person": contactPersonController.text.trim(),
      "contact_email": emailController.text.trim(),
      "contact_number": phoneController.text.trim(),
    };
  }

  Future<void> _completeUpiPayment() async {
    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final payload = _buildUpiPaymentPayload();

      final response = await CheckoutService.placeOrderUpi(payload: payload);

      log("UPI PAYMENT RESPONSE => $response");

      if (!mounted) return;

      if (response["status"] == true) {
        final cartProvider = context.read<CartProvider>();

        cartProvider.clearCart();

        await cartProvider.fetchCart();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => BankTransferSuccessScreen(
              order: response["data"] ?? {},
              summary: response["summary"] ?? {},
              currencySymbol: response["summary"]?["symbol"] ?? "INR",
              bankName: "UPI",
            ),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Unable to place order"),
          ),
        );
      }
    } catch (e, stackTrace) {
      log("UPI PAYMENT ERROR => $e");
      log("STACKTRACE => $stackTrace");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  Widget _buildGeneratedQrSection() {
    final svgBase64 = upiQrCode!.replaceFirst('data:image/svg+xml;base64,', '');

    final svgString = utf8.decode(base64Decode(svgBase64));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE0E0E0)),
      ),
      child: Column(
        children: [
          const Text(
            "Scan & Pay",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            "Scan this QR code using Google Pay,\nPhonePe, Paytm or any UPI app.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.string(svgString, width: 220, height: 220),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Amount:", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    "₹${upiAmount?.toStringAsFixed(2) ?? ''}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              //
              const SizedBox(height: 8),

              const Text(
                "After complete the payment please click the button below.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isPlacingOrder
                      ? null
                      : () async {
                          await _completeUpiPayment();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                  ),
                  child: const Text(
                    "Payment Completed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // const SizedBox(height: 12),

              // Text(
              //   "UPI ID: ${upiId ?? ''}",
              //   style: const TextStyle(fontWeight: FontWeight.w500),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiSection() {
    final cartProvider = context.watch<CartProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == "pickup";

    final String currency = currencyProvider.selectedCurrency.toUpperCase();

    final String symbol = currency == "INR" ? "₹" : "$currency ";

    final double subtotalValue = cartProvider.subtotalAmount;

    final double courierValue = isPickup ? 0.0 : cartProvider.courierAmount;

    final double displayTotal = subtotalValue + courierValue;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border.all(color: const Color(0xFFDADDE1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Pay using UPI",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Image.asset(
                "assets/googlepay.png",
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              // const SizedBox(width: 10),
              // Image.asset(
              //   "assets/phonepe.png",
              //   width: 28,
              //   height: 28,
              //   fit: BoxFit.contain,
              //   errorBuilder: (_, __, ___) =>
              //       const Icon(Icons.account_balance_wallet, size: 26),
              // ),
              // const SizedBox(width: 10),
              // Image.asset(
              //   "assets/paytm.png",
              //   width: 38,
              //   height: 28,
              //   fit: BoxFit.contain,
              //   errorBuilder: (_, __, ___) =>
              //       const Icon(Icons.payment, size: 26),
              // ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Click Pay Now to generate your UPI payment QR code.",
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF5B6B84),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Text(
                  "$symbol${displayTotal.toStringAsFixed(2)}",
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(width: 18),

              SizedBox(
                height: 44,
                width: 112,
                child: ElevatedButton(
                  onPressed: (_isPlacingOrder || _isGeneratingUpiQr)
                      ? null
                      : () async {
                          await _generateUpiQr();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: _isGeneratingUpiQr
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Pay Now",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE9D7D7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Scan to pay with PayNow",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Open your banking app, scan this QR code, "
            "and complete the payment.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // Replace with your actual PayNow QR image path.
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffD9DDE5)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/paynow.jpeg',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(
                    child: Text(
                      'PayNow QR image not found',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "After completing the payment, please click "
            "the button below for your Order Confirmation.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 24),

          SizedBox(
            // width: 180,
            height: 44,
            child: ElevatedButton(
              onPressed: _isPlacingOrder
                  ? null
                  : () async {
                      await _completeUpiPayment();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Payment Completed",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalOrderSummary(
    CartProvider provider,
    String currencySymbol,
    double orderTotal,
    bool isDigital,
  ) {
    log("Proooooooooooo ${provider.cartItems}");
    if (provider.cartItems.isEmpty) {
      return const TranslatedText("No items in cart");
    }

    final String deliveryMethod = isDigital
        ? "Digital"
        : provider.selectedDeliveryMethod;

    final Map<String, dynamic>? coupon = provider.coupon;

    final bool showDeliveryDetails = _shouldShowDeliveryMethod(provider);
    final bool isPickup =
        provider.selectedDeliveryMethod.toLowerCase() == "pickup";

    final double subtotalValue = provider.subtotalAmount;

    final double courierValue = isPickup ? 0.0 : provider.courierAmount;

    // Card payment: use the backend "total" (includes the card processing fee).
    // Any other method: subtotal + courier charge.
    final bool isCardPayment = paymentMethod == "Card";

    final double displayTotal = isCardPayment
        ? provider.totalAmount
        : subtotalValue + courierValue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            "Order Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...provider.cartItems.map((item) {
            log("cartiiiiiiii $item");
            final String name = item["name"]?.toString() ?? "Product";

            final int quantity =
                int.tryParse(item["quantity"]?.toString() ?? "1") ?? 1;

            final String productPrice =
                item["formatted_line_total"]?.toString() ??
                item["line_total"]?.toString() ??
                "0.00";

            return _buildSummaryItem(
              name: name,
              quantity: quantity,
              price: _formatCheckoutCurrency(productPrice, currencySymbol),
              imageUrl: item["image"]?.toString(),
              onDelete: () => _removeCartItem(item["product_id"]),
            );
          }),

          const Divider(height: 30),

          _checkoutSummaryRow(
            "Subtotal Product",
            _formatCheckoutCurrency(provider.formattedSubtotal, currencySymbol),
          ),

          const SizedBox(height: 15),

          if (showDeliveryDetails && !isPickup) ...[
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

            if (provider.showTax) ...[
              const SizedBox(height: 15),

              _checkoutSummaryRow(
                "GST (21%)",
                "+ ${_formatCheckoutCurrency(isDigital ? "0.00" : provider.formattedGST, currencySymbol)}",
              ),
            ],
          ],
          const Divider(height: 35),

          _checkoutSummaryRow(
            "Total",
            "$currencySymbol ${displayTotal.toStringAsFixed(2)}",
            bold: true,
            valueColor: AppColors.primaryRed,
          ),

          const SizedBox(height: 20),

          if (paymentMethod == "Card")
            _buildProceedButton(currencySymbol, false),
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
          child: TranslatedText(
            title,
            style: TextStyle(
              fontSize: bold ? 15 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),

        const SizedBox(width: 12),

        TranslatedText(
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
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5C76B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF981B1B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TranslatedText(
                        'PHYSICAL CONVERSION ACTIVE',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              GestureDetector(
                onTap: (_isPlacingOrder || _isCancellingConversion)
                    ? null
                    : _cancelPhysicalConversion,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                            TranslatedText(
                              'Clearing...',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        )
                      : const TranslatedText(
                          'Cancel conversion',
                          key: ValueKey('cancel'),
                          style: TextStyle(fontSize: 11),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const TranslatedText(
                'Add ',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 5),
              TranslatedText(
                metal,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF981B1B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),

              const TranslatedText(
                ' products up to ',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 5),

              TranslatedText(
                '$amount g.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF981B1B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const TranslatedText(
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
          child: TranslatedText(
            'I agree to the Terms & Conditions',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String name,
    required int quantity,
    required String price,
    String? imageUrl,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- product image ----
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE6E6E6)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: (imageUrl == null || imageUrl.isEmpty)
                  ? const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // ---- name, qty, price ----
          Expanded(
            child: SizedBox(
              height: 84,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TranslatedText(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  color: Color(0xff1F1F1F),
                                ),
                              ),
                            ),
                            if (onDelete != null) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: onDelete,
                                child: Image.asset(
                                  "assets/delete.png",
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Qty: $quantity",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff8A94A6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalOrderSummary(
    CartProvider cartProvider,
    String currencySymbol,
  ) {
    if (cartProvider.cartItems.isEmpty) {
      return const TranslatedText("No items in cart");
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
          const TranslatedText(
            'Order Summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 20),

          ...cartProvider.cartItems.map((item) {
            final String name = item["name"]?.toString() ?? "Product";

            final int quantity =
                int.tryParse(item["quantity"]?.toString() ?? "1") ?? 1;

            // Physical conversion has no monetary charge
            return _buildSummaryItem(
              name: name,
              quantity: quantity,
              price: "$currencySymbol 0.00",
              imageUrl: item["image"]?.toString(),
              onDelete: () => _removeCartItem(item["product_id"]),
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

          const Divider(height: 30),

          _summaryRow(
            "Order Total",
            "$currencySymbol 0.00",
            bold: true,
            valueColor: AppColors.primaryRed,
          ),

          const SizedBox(height: 20),

          _buildProceedButton(currencySymbol, true),
        ],
      ),
    );
  }

  Future<void> _showCardPaymentInfo() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 70,
                color: Color(0xFF42B6E6),
              ),

              const SizedBox(height: 20),

              const Text(
                "Card payment",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              const Text(
                "When you pay by card, an additional processing charge applies and your order total will be higher than with other payment methods.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: 90,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    setState(() {
                      paymentMethod = "Card";
                    });
                  },
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProceedButton(String currencySymbol, bool isPhysicalConversion) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isPlacingOrder || _isCancellingConversion)
            ? null
            : () async {
                try {
                  dynamic plan;

                  final res = await JscService.fetchConvertDetails();

                  log("fetchConvertPhysicalDetails response: $res");

                  log(
                    "fetchConvertPhysicalDetails data: "
                    "${res['data']}",
                  );

                  if (res['data'] != null) {
                    final data = Map<String, dynamic>.from(res['data']);

                    log("Convert Physical Data: $data");

                    log("Golddd: ${data['purchase_subtype']}");

                    plan = data['purchase_subtype'];
                  }

                  log("Plannn: $plan");

                  if (isPhysicalConversion) {
                    await _sendPhysicalOrder(plan: plan);
                  } else {
                    await _placeNormalOrder();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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
            : TranslatedText(
                isPhysicalConversion
                    ? 'Send Order $currencySymbol 0.00'
                    : 'Proceed to pay',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
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
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(title, height: 50, width: 65),
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
        child: TranslatedText(
          title,
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),

      const SizedBox(width: 12),

      TranslatedText(
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
