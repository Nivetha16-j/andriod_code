import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/checkout/checkout.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/cart/custom_cartitem.dart';
import 'package:junubullion/widgets/cart/custom_summary.dart';
import 'package:junubullion/widgets/cart/custom_deliverymethod.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _lastCurrency;
  String? _lastUnit;

  final TextEditingController couponController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final physicalProvider = context.read<PhysicalConversionProvider>();

      physicalProvider.addListener(_physicalConversionChanged);
    });
  }

  @override
  void dispose() {
    context.read<PhysicalConversionProvider>().removeListener(
      _physicalConversionChanged,
    );

    couponController.dispose();

    super.dispose();
  }

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

  void _physicalConversionChanged() {
    if (!mounted) return;

    final physicalProvider = context.read<PhysicalConversionProvider>();

    if (!physicalProvider.isActive) {
      return;
    }

    final cartProvider = context.read<CartProvider>();

    if (cartProvider.cartItems.isNotEmpty) {
      log("Physical conversion activated -> clearing normal cart");

      cartProvider.clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: Consumer<CartProvider>(
        builder: (context, provider, child) {
          final physicalProvider = context.watch<PhysicalConversionProvider>();

          log("Couponnnnnnns: ${provider.coupon}");
          log("Discount: ${provider.formattedDiscount}");

          if (couponController.text != (provider.coupon?["code"] ?? "")) {
            couponController.text = provider.coupon?["code"] ?? "";
          }

          if (physicalProvider.isActive) {
            return _buildPhysicalConversionCart(physicalProvider);
          }
          if (provider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/no_product.png",
                    height: 80,
                    width: 80,
                    // color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E2323),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "CONTINUE SHOPPING",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
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
                    Expanded(
                      child: TextField(
                        controller: couponController,
                        decoration: const InputDecoration(
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
                          if (provider.coupon == null) {
                            // Apply coupon
                          } else {
                            provider.removeCouponLocally();
                            couponController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: Text(
                          provider.coupon == null ? "Apply" : "Remove",
                          style: const TextStyle(
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

              DeliveryMethodWidget(),

              const SizedBox(height: 20),

              SummaryWidget(
                subtotal: provider.formattedSubtotal,
                courier_fee: provider.formattedCourierFee,
                transaction_fee: provider.formattedTransactionFee,
                total: provider.formattedOrderTotal,
                deliveryMethod: provider.selectedDeliveryMethod,
                coupon: provider.coupon,
                discount: provider.formattedDiscount,
                discountPrice: provider.formattedDiscountPrice,
                gst: provider.formattedGST,
                currency: provider.currency,
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
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

  Widget _buildPhysicalConversionCart(
    PhysicalConversionProvider physicalProvider,
  ) {
    final metal = physicalProvider.metal ?? '';
    final amount = physicalProvider.formattedAmount;

    log("retrieve provider $metal $amount");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5C76B), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF981B1B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync, size: 15, color: Colors.white),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
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

                    OutlinedButton(
                      onPressed: () {
                        physicalProvider.cancelConversion();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF981B1B),
                        side: const BorderSide(color: Color(0xFF981B1B)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
          ),

          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/no_product.png", height: 80, width: 80),

                    const SizedBox(height: 20),

                    const Text(
                      "Your cart is empty",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 52,
                      width: 280,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF981B1B),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'CONTINUE SHOPPING',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
