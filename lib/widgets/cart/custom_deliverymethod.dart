import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:provider/provider.dart';

class DeliveryMethodWidget extends StatelessWidget {
  const DeliveryMethodWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Delivery Method",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _deliveryCard(
                  context: context,
                  title: "Standard\ndelivery",
                  charge: "USD 50 outside\nSingapore",
                  value: "Standard",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _deliveryCard(
                  context: context,
                  title: "Express\ndelivery",
                  charge: "USD 75 outside\nSingapore",
                  value: "Express",
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "SGD/Singapore and INR/India orders have no courier charge. Other currencies show the selected courier charge converted from USD.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _changeDelivery(CartProvider cartProvider, String value) async {
    if (cartProvider.selectedDeliveryMethod == value) return;

    cartProvider.setDeliveryMethod(value);
    await cartProvider.fetchCart();
  }

  Widget _deliveryCard({
    required BuildContext context,
    required String title,
    required String charge,
    required String value,
  }) {
    final cartProvider = Provider.of<CartProvider>(context);

    final bool isSelected = cartProvider.selectedDeliveryMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      // onTap: () {
      // cartProvider.setDeliveryMethod(value);
      // cartProvider.updateCourier(
      //   currency: cartProvider.currency,
      //   service: value,
      // );
      onTap: () async {
        _changeDelivery(cartProvider, value);
      },
      // },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: value,
              groupValue: cartProvider.selectedDeliveryMethod,
              activeColor: AppColors.primaryRed,
              visualDensity: VisualDensity.compact,
              onChanged: (val) async {
                if (val != null) {
                  _changeDelivery(cartProvider, value);
                }
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    charge,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
