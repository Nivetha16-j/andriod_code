import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

enum FulfillmentType { pickup, delivery }

class DeliveryMethodWidget extends StatefulWidget {
  const DeliveryMethodWidget({super.key});

  @override
  State<DeliveryMethodWidget> createState() => _DeliveryMethodWidgetState();
}

class _DeliveryMethodWidgetState extends State<DeliveryMethodWidget> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == "pickup";

    final FulfillmentType selectedType = isPickup
        ? FulfillmentType.pickup
        : FulfillmentType.delivery;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _optionCard(
            title: "Pickup by shop",
            subtitle: "Collect from our shop",
            trailingText: "Free",
            value: FulfillmentType.pickup,
          ),

          const SizedBox(height: 12),

          _optionCard(
            title: "Delivery",
            subtitle: "Courier to your address",
            value: FulfillmentType.delivery,
          ),

          if (selectedType == FulfillmentType.delivery) ...[
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

            TranslatedText(
              "SGD/Singapore and INR/India orders have no courier charge. Other currencies show the selected courier charge converted from USD.",
              style: TextStyle(fontSize: 12, color: AppColors.black),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _changeDelivery(
    BuildContext context,
    CartProvider cartProvider,
    String value,
  ) async {
    if (cartProvider.selectedDeliveryMethod == value) return;

    cartProvider.setDeliveryMethod(value);

    final physicalProvider = context.read<PhysicalConversionProvider>();

    // Physical conversion does not require normal cart recalculation.
    if (physicalProvider.isActive) {
      return;
    }

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
        _changeDelivery(context, cartProvider, value);
      },
      // },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lightRed,
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
                  _changeDelivery(context, cartProvider, value);
                }
              },
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TranslatedText(
                    charge,
                    style: TextStyle(fontSize: 10, color: AppColors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required FulfillmentType value,
    String? trailingText,
  }) {
    final cartProvider = context.watch<CartProvider>();

    final bool isPickup =
        cartProvider.selectedDeliveryMethod.toLowerCase() == 'pickup';

    final FulfillmentType selectedType = isPickup
        ? FulfillmentType.pickup
        : FulfillmentType.delivery;

    final isSelected = selectedType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final cartProvider = context.read<CartProvider>();

        if (value == FulfillmentType.pickup) {
          await _changeDelivery(context, cartProvider, "Pickup");
        } else {
          await _changeDelivery(context, cartProvider, "Standard");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lightRed,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Radio<FulfillmentType>(
              value: value,
              groupValue: selectedType,
              activeColor: AppColors.primaryRed,
              onChanged: (val) async {
                if (val == null) return;

                final cartProvider = context.read<CartProvider>();

                if (val == FulfillmentType.pickup) {
                  await _changeDelivery(context, cartProvider, "Pickup");
                } else {
                  await _changeDelivery(context, cartProvider, "Standard");
                }
              },
            ),

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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.black),
                  ),
                ],
              ),
            ),

            if (trailingText != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffe7f7eb),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  trailingText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
