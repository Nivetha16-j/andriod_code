import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/address_provider.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/screens/checkout/banktransfersuccess.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/checkout_service.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/cart/custom_summary.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(),

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
                /// Shipping Address
                const Text(
                  "Shipping address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(height: 10),

                Consumer<AddressProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
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
                                BoxShadow(color: Colors.black12, blurRadius: 5),
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

                const SizedBox(height: 20),

                /// Delivery
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

                if (delivery == "Digital") ...[
                  const SizedBox(height: 16),

                  Column(
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
                  ),
                ],

                const SizedBox(height: 20),

                /// Payment
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
                    const Text("Direct Bank Transfer"),
                  ],
                ),

                const SizedBox(height: 10),

                if (payment == "Card") ...[
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

                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: isTermsAccepted,
                      activeColor: AppColors.primaryRed,
                      onChanged: (value) {
                        setState(() {
                          isTermsAccepted = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text("I agree to the Terms & Conditions"),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// Order Summary
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    // if (cartProvider.isLoading) {
                    //   return const Center(child: CircularProgressIndicator());
                    // }

                    if (cartProvider.cartItems.isEmpty) {
                      return const Text("No items in cart");
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffF8EAEA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Consumer<CartProvider>(
                        builder: (context, provider, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Order Summary",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              /// Products
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.cartItems.length,
                                itemBuilder: (context, index) {
                                  final item = provider.cartItems[index];

                                  log("IIIIIIIIII $item");

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "${item["name"]} × ${item["quantity"]}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                },
                              ),

                              const Divider(height: 30),

                              _summaryRow(
                                "Subtotal Product",
                                provider.formattedSubtotal,
                              ),

                              const SizedBox(height: 15),

                              _summaryRow(
                                "Courier Charges",
                                "+ ${provider.formattedCourierFee}",
                              ),

                              const SizedBox(height: 15),

                              _summaryRow(
                                "Transaction Fee",
                                "+ ${provider.formattedTransactionFee}",
                              ),

                              const Divider(height: 35),

                              _summaryRow(
                                "Order Total",
                                provider.formattedOrderTotal,
                                bold: true,
                                valueColor: Colors.red,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Back"),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8B1E1E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          final addressProvider = context
                              .read<AddressProvider>();

                          final hasAddress =
                              addressProvider.hasAddress ||
                              (localAddress != null &&
                                  localAddress!.trim().isNotEmpty);

                          if (!hasAddress) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please add your shipping address",
                                ),
                              ),
                            );
                            return;
                          }

                          if (!isTermsAccepted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please agree to the Terms & Conditions",
                                ),
                              ),
                            );
                            return;
                          }

                          if (payment == "Bank") {
                            setState(() {
                              _isPlacingOrder = true;
                            });

                            try {
                              final response = await CheckoutService.placeOrder(
                                shippingAddress: addressProvider.hasAddress
                                    ? addressProvider.address!
                                    : localAddress!,
                                deliveryOption: delivery,
                                digitalType: delivery.toLowerCase() == "digital"
                                    ? digitalSubtype // e.g. "vault"
                                    : null,
                                courierService:
                                    cartProvider.selectedDeliveryMethod,
                                terms: true,
                                paymentType: "bank_transfer",
                              );

                              if (response["status"] == true) {
                                // Clear cart only after successful order
                                await context.read<CartProvider>().fetchCart();
                                context.read<CartProvider>().clearCart();

                                if (!mounted) return;

                                setState(() {
                                  _isPlacingOrder = false;
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BankTransferSuccessScreen(
                                      order: response["data"],
                                    ),
                                  ),
                                );
                              } else {
                                if (!mounted) return;

                                setState(() {
                                  _isPlacingOrder = false;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Order is not placed. Try again.",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;

                              setState(() {
                                _isPlacingOrder = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Order is not placed. Try again.",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Proceed to pay",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isPlacingOrder)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              ),
            ),
        ],
      ),
    );
  }

  Widget paymentBox(String text) {
    return Container(
      width: 90,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
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
