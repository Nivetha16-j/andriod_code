import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/cart/custom_cartitem.dart';
import 'package:junubullion/widgets/cart/custom_summary.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _lastCurrency;
  String? _lastUnit;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   Future.microtask(() {
  //     // context.read<CartProvider>().fetchCart();
  //     final currency = context.read<CurrencyProvider>();
  //     final cartProvider = context.read<CartProvider>();

  //     cartProvider.updateSelection(
  //       currency: currency.selectedCurrency,
  //       unit: currency.selectedUnit,
  //     );

  //     log(
  //       "ppppppppppppppp// ${currency.selectedCurrency}......${currency.selectedUnit}",
  //     );

  //     cartProvider.fetchCart();
  //   });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currency = context.watch<CurrencyProvider>();

    if (_lastCurrency == currency.selectedCurrency &&
        _lastUnit == currency.selectedUnit) {
      return;
    }

    _lastCurrency = currency.selectedCurrency;
    _lastUnit = currency.selectedUnit;

    log(
      "cartProvider ${currency.selectedCurrency}.....${currency.selectedUnit}",
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cartProvider = context.read<CartProvider>();

      cartProvider.updateSelection(
        currency: currency.selectedCurrency,
        unit: currency.selectedUnit,
      );

      cartProvider.fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          if (provider.cartItems.isEmpty) {
            return const Center(child: Text("No products in cart"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Your cart",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemCard(item: provider.cartItems[index]);
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Cart Summary",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),
              Container(
                height: 50,
                padding: EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Apply coupon
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          "Apply",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SummaryWidget(subtotal: provider.subtotal),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply coupon
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      // padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    child: const Text(
                      "CheckOut",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
