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
  bool _isClearingConversion = false;
  final TextEditingController couponController = TextEditingController();

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currencyProvider = context.watch<CurrencyProvider>();
    final physicalProvider = context.read<PhysicalConversionProvider>();

    if (_lastCurrency == currencyProvider.selectedCurrency &&
        _lastUnit == currencyProvider.selectedUnit) {
      return;
    }

    _lastCurrency = currencyProvider.selectedCurrency;
    _lastUnit = currencyProvider.selectedUnit;

    log(
      'Cart currency=${currencyProvider.selectedCurrency}, '
      'unit=${currencyProvider.selectedUnit}, '
      'physicalActive=${physicalProvider.isActive}',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final cartProvider = context.read<CartProvider>();

      cartProvider.updateSelection(
        currency: currencyProvider.selectedCurrency,
        unit: currencyProvider.selectedUnit,
      );

      await cartProvider.fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: Consumer2<CartProvider, PhysicalConversionProvider>(
        builder: (context, cartProvider, physicalProvider, child) {
          return _buildCartScreen(cartProvider, physicalProvider);
        },
      ),
    );
  }

  Widget _buildCartScreen(
    CartProvider cartProvider,
    PhysicalConversionProvider physicalProvider,
  ) {
    final bool isPhysicalActive = physicalProvider.isActive;

    // Both normal cart and physical conversion use CartProvider.cartItems.
    final bool hasItems = cartProvider.cartItems.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isPhysicalActive) ...[
            _buildPhysicalConversionHeader(physicalProvider),
            const SizedBox(height: 20),
          ],

          const Text(
            'Your cart',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          if (!hasItems)
            _buildEmptyCart()
          else
            _buildCartProducts(cartProvider, isPhysicalActive),

          if (hasItems) ...[
            const SizedBox(height: 30),

            const Text(
              'Cart Summary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _buildCouponSection(provider: cartProvider),

            const SizedBox(height: 20),

            const DeliveryMethodWidget(),

            const SizedBox(height: 20),

            SummaryWidget(
              subtotal: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedSubtotal,

              courier_fee: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedCourierFee,

              transaction_fee: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedTransactionFee,

              total: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedOrderTotal,

              deliveryMethod: isPhysicalActive
                  ? 'Standard'
                  : cartProvider.selectedDeliveryMethod,

              coupon: cartProvider.coupon,

              discount: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedDiscount,

              discountPrice: isPhysicalActive
                  ? '0.00'
                  : cartProvider.formattedDiscountPrice,

              gst: isPhysicalActive ? '0.00' : cartProvider.formattedGST,

              currency: cartProvider.currency,
            ),

            const SizedBox(height: 30),

            if (isPhysicalActive)
              _buildPhysicalOrderButton()
            else
              _buildCheckoutButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildPhysicalConversionHeader(PhysicalConversionProvider provider) {
    final String metal = provider.metal ?? '';
    final String amount = provider.formattedAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5C76B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
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
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _isClearingConversion
                    ? null
                    : () async {
                        log('Clicked cancel conversion');

                        setState(() {
                          _isClearingConversion = true;
                        });

                        try {
                          final cartProvider = context.read<CartProvider>();
                          final currencyProvider = context
                              .read<CurrencyProvider>();

                          final success = await provider.cancelConversion(
                            cartProvider: cartProvider,
                            currencyProvider: currencyProvider,
                          );

                          if (!mounted) return;

                          setState(() {
                            _isClearingConversion = false;
                          });

                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to cancel physical conversion. Please try again.',
                                ),
                              ),
                            );
                          }
                        } catch (e, stackTrace) {
                          log(
                            'Error clearing conversion: $e',
                            stackTrace: stackTrace,
                          );

                          if (!mounted) return;

                          setState(() {
                            _isClearingConversion = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to cancel physical conversion. Please try again.',
                              ),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF981B1B),
                  disabledForegroundColor: Colors.grey,
                  side: BorderSide(
                    color: _isClearingConversion
                        ? Colors.grey
                        : const Color(0xFF981B1B),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isClearingConversion
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
                            Text('Clearing...', style: TextStyle(fontSize: 11)),
                          ],
                        )
                      : const Text(
                          'Cancel conversion',
                          key: ValueKey('cancel'),
                          style: TextStyle(fontSize: 11),
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
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Image.asset('assets/no_product.png', height: 80, width: 80),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF981B1B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartProducts(CartProvider provider, bool isPhysicalConversion) {
    if (couponController.text != (provider.coupon?['code'] ?? '')) {
      couponController.text = provider.coupon?['code'] ?? '';
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.cartItems.length,
      itemBuilder: (context, index) {
        return CartItemCard(
          item: provider.cartItems[index],
          isPhysicalConversion: isPhysicalConversion,
        );
      },
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
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
    );
  }

  Widget _buildPhysicalOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Send Order',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponSection({required CartProvider provider}) {
    final bool couponApplied = provider.coupon != null;
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: couponController,
              decoration: const InputDecoration(
                hintText: 'Enter coupon code',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (provider.coupon == null) {
                } else {
                  provider.removeCouponLocally();
                  couponController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text(
                couponApplied ? 'Remove' : 'Apply',
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
    );
  }
}
