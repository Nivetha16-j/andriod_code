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

  final TextEditingController couponController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    debugPrint('🔥 CartScreen dispose called');

    couponController.dispose();

    super.dispose();
  }

  // ============================================================
  // CURRENCY / UNIT CHANGES
  // ============================================================

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
      'cartProvider '
      '${currency.selectedCurrency}'
      '.....'
      '${currency.selectedUnit}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cartProvider = context.read<CartProvider>();

      cartProvider.updateSelection(
        currency: currency.selectedCurrency,
        unit: currency.selectedUnit,
      );

      // IMPORTANT:
      // This only fetches the NORMAL cart.
      // It does NOT affect physicalProvider.physicalCart.
      cartProvider.fetchCart();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      body: Consumer2<CartProvider, PhysicalConversionProvider>(
        builder: (
          context,
          cartProvider,
          physicalProvider,
          child,
        ) {
          log(
            'Cart -> '
            'physicalActive=${physicalProvider.isActive} '
            'normalCartCount=${cartProvider.cartItems.length} '
            'physicalCartCount=${physicalProvider.physicalCart.length}',
          );

          // ========================================================
          // PHYSICAL CONVERSION MODE
          // ========================================================
          //
          // IMPORTANT:
          //
          // We DO NOT use cartProvider.cartItems here.
          //
          // Existing normal cart products remain inside
          // cartProvider.cartItems untouched.
          //
          // They are simply hidden while conversion is active.
          //
          // Only physicalProvider.physicalCart is displayed.
          // ========================================================

          if (physicalProvider.isActive) {
            return _buildPhysicalConversionCart(
              physicalProvider,
            );
          }

          // ========================================================
          // NORMAL CART MODE
          // ========================================================

          if (cartProvider.cartItems.isEmpty) {
            return _buildNormalEmptyCart();
          }

          return _buildNormalCart(cartProvider);
        },
      ),
    );
  }

  // ============================================================
  // NORMAL EMPTY CART
  // ============================================================

  Widget _buildNormalEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/no_product.png',
            height: 80,
            width: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 50),

          Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              right: 30,
            ),
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
                  'CONTINUE SHOPPING',
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

  // ============================================================
  // NORMAL CART
  // ============================================================

  Widget _buildNormalCart(
    CartProvider provider,
  ) {
    log(
      '🛒 BUILDING NORMAL CART -> '
      '${provider.cartItems.length} items',
    );

    if (couponController.text !=
        (provider.coupon?['code'] ?? '')) {
      couponController.text =
          provider.coupon?['code'] ?? '';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Your cart',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 15),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.cartItems.length,
          itemBuilder: (context, index) {
            return CartItemCard(
              item: provider.cartItems[index],
            );
          },
        ),

        const SizedBox(height: 30),

        const Text(
          'Cart Summary',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ========================================================
        // COUPON
        // ========================================================

        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: const InputDecoration(
                    hintText: 'Enter coupon code',
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
                    backgroundColor:
                        AppColors.primaryRed,
                    shape:
                        const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                  ),
                  child: Text(
                    provider.coupon == null
                        ? 'Apply'
                        : 'Remove',
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

        const DeliveryMethodWidget(),

        const SizedBox(height: 20),

        SummaryWidget(
          subtotal: provider.formattedSubtotal,
          courier_fee: provider.formattedCourierFee,
          transaction_fee:
              provider.formattedTransactionFee,
          total: provider.formattedOrderTotal,
          deliveryMethod:
              provider.selectedDeliveryMethod,
          coupon: provider.coupon,
          discount: provider.formattedDiscount,
          discountPrice:
              provider.formattedDiscountPrice,
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
                    builder: (_) =>
                        const CheckoutScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'CheckOut',
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
  }

  // ============================================================
  // PHYSICAL CONVERSION CART
  // ============================================================

  Widget _buildPhysicalConversionCart(
    PhysicalConversionProvider physicalProvider,
  ) {
    final String metal =
        physicalProvider.metal ?? '';

    final String amount =
        physicalProvider.formattedAmount;

    // ==========================================================
    // IMPORTANT
    //
    // ONLY physicalCart is used here.
    //
    // cartProvider.cartItems is intentionally NOT used.
    // ==========================================================

    final List<Map<String, dynamic>> physicalCart =
        physicalProvider.physicalCart;

    log(
      '🟢 PHYSICAL CART UI -> '
      'items=${physicalCart.length} '
      'metal=$metal '
      'amount=$amount',
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ====================================================
            // CONVERSION HEADER
            // ====================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5C76B),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF981B1B),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync,
                                size: 15,
                                color: Colors.white,
                              ),

                              SizedBox(width: 6),

                              Flexible(
                                child: Text(
                                  'PHYSICAL CONVERSION ACTIVE',
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      OutlinedButton(
                        onPressed: () async {
                          await physicalProvider
                              .cancelConversion();
                        },
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(
                            0xFF981B1B,
                          ),
                          side:
                              const BorderSide(
                            color:
                                Color(0xFF981B1B),
                          ),
                        ),
                        child: const Text(
                          'Cancel conversion',
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Add ',
                        ),

                        TextSpan(
                          text: metal,
                          style: const TextStyle(
                            color:
                                Color(0xFF981B1B),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const TextSpan(
                          text: ' products up to ',
                        ),

                        TextSpan(
                          text: '$amount g',
                          style: const TextStyle(
                            color:
                                Color(0xFF981B1B),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const TextSpan(
                          text: '.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'No payment will be required at checkout.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ====================================================
            // PHYSICAL CART
            // ====================================================

            Expanded(
              child: physicalCart.isEmpty
                  ? _buildPhysicalEmptyCart()
                  : ListView.builder(
                      itemCount:
                          physicalCart.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            physicalCart[index];

                        return _buildPhysicalCartItem(
                          context,
                          physicalProvider,
                          item,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PHYSICAL EMPTY CART
  // ============================================================

  Widget _buildPhysicalEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/no_product.png',
            height: 80,
            width: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'Your physical conversion cart is empty',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 52,
            width: 280,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/home',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF981B1B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHYSICAL CART ITEM
  // ============================================================

  Widget _buildPhysicalCartItem(
    BuildContext context,
    PhysicalConversionProvider provider,
    Map<String, dynamic> item,
  ) {
    final String name =
        item['name']?.toString() ?? 'Product';

    final int quantity =
        int.tryParse(
              '${item['quantity'] ?? 1}',
            ) ??
            1;

    final String? imageUrl =
        item['image_url']?.toString();

    final String? imagePath =
        item['image_path']?.toString();

    String image = '';

    if (imageUrl != null &&
        imageUrl.isNotEmpty) {
      image = imageUrl;
    } else if (imagePath != null &&
        imagePath.isNotEmpty) {
      image =
          'https://staging.junubullion.com/storage/$imagePath';
    }

    final dynamic productId =
        item['product_id'];

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // ======================================================
          // IMAGE
          // ======================================================

          Container(
            height: 110,
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            padding:
                const EdgeInsets.all(8),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      );
                    },
                  )
                : const Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
          ),

          const SizedBox(width: 14),

          // ======================================================
          // DETAILS
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Physical conversion',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 6),

                // ==================================================
                // ALWAYS ZERO FOR PHYSICAL CONVERSION
                // ==================================================

                const Text(
                  '0.00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // ======================================================
          // QUANTITY + DELETE
          // ======================================================

          Column(
            children: [
              IconButton(
                onPressed: () async {
                  await provider
                      .removePhysicalProduct(
                    productId,
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Colors.grey.shade300,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    // ==================================================
                    // MINUS
                    // ==================================================

                    IconButton(
                      visualDensity:
                          VisualDensity.compact,
                      onPressed: () async {
                        if (quantity <= 1) {
                          await provider
                              .removePhysicalProduct(
                            productId,
                          );
                        } else {
                          await provider
                              .updatePhysicalQuantity(
                            productId:
                                productId,
                            quantity:
                                quantity - 1,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.remove,
                        size: 16,
                      ),
                    ),

                    // ==================================================
                    // QUANTITY
                    // ==================================================

                    Text(
                      '$quantity',
                      style:
                          const TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    // ==================================================
                    // PLUS
                    // ==================================================

                    IconButton(
                      visualDensity:
                          VisualDensity.compact,
                      onPressed: () async {
                        await provider
                            .updatePhysicalQuantity(
                          productId:
                              productId,
                          quantity:
                              quantity + 1,
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}