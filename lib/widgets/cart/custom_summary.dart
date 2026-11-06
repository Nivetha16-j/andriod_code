import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/screens/checkout/checkout.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

class SummaryWidget extends StatelessWidget {
  final String subtotal;
  final String courier_fee;
  final String transaction_fee;
  final String total;
  final String deliveryMethod;
  final String gst;
  final String currency;
  final bool isPhysicalActive;
  final Map<String, dynamic>? coupon;
  final String discount;
  final String discountPrice;

  const SummaryWidget({
    super.key,
    required this.subtotal,
    required this.courier_fee,
    required this.transaction_fee,
    required this.total,
    required this.deliveryMethod,
    required this.gst,
    required this.currency,
    this.coupon,
    required this.discount,
    required this.discountPrice,
    required this.isPhysicalActive,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    log(
      "SummaryWidget: Building widget with subtotal=$subtotal, courier_fee=$courier_fee, transaction_fee=$transaction_fee, total=$total, deliveryMethod=$deliveryMethod, gst=$gst, currency=$currency, coupon=${coupon?.toString() ?? 'null'}, discount=$discount, discountPrice=$discountPrice, isPhysicalActive=$isPhysicalActive",
    );
    final bool isPickup =
        provider.selectedDeliveryMethod.toLowerCase() == 'pickup';

    double subtotalValue = _toDouble(subtotal);

    double courierValue = _toDouble(courier_fee);

    // double displayTotal = isPickup
    //     ? subtotalValue
    //     : subtotalValue + courierValue;

    double gstValue = provider.showTax ? _toDouble(gst) : 0.0;

    double displayTotal =
        (isPickup ? subtotalValue : subtotalValue + courierValue) + gstValue;

    final bool showDeliveryDetails = _shouldShowDeliveryMethod(provider);

    // "$2.17" -> "$", "₹1,200.00" -> "₹"
    String _symbolPrefix(String formatted) {
      final match = RegExp(r'^[^\d]*').firstMatch(formatted.trim());
      return match?.group(0) ?? '';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _row("Subtotal Product", _formatCurrency(subtotal)),

            const SizedBox(height: 15),

            if (showDeliveryDetails && !isPickup) ...[
              _row(
                "Courier charge (${deliveryMethod} delivery)",
                "+ ${_formatCurrency(courier_fee)}",
              ),

              if (coupon != null) ...[
                const SizedBox(height: 15),
                _row(
                  "Discount (${coupon!["code"]})",
                  "- ${_formatCurrency(discount)}",
                ),
                const SizedBox(height: 15),
                _row("Discount Price", _formatCurrency(discountPrice)),
              ],
            ],

            // GST shows whenever the backend says tax applies (INR), pickup or delivery
            if (provider.showTax) ...[
              const SizedBox(height: 15),
              _row("Tax (21%)", "${_formatCurrency(gst)}"),
            ],

            const SizedBox(height: 20),

            CustomPaint(
              painter: DottedLinePainter(),
              child: const SizedBox(height: 1, width: double.infinity),
            ),

            const SizedBox(height: 20),

            // _row(
            //   "Total",
            //   _formatCurrency(displayTotal.toStringAsFixed(2)),
            //   bold: true,
            // ),
            _row(
              "Total",
              isPhysicalActive
                  ? _formatCurrency(displayTotal.toStringAsFixed(2))
                  : _symbolPrefix(subtotal).isEmpty
                  ? _formatCurrency(displayTotal.toStringAsFixed(2))
                  : '${_symbolPrefix(subtotal)}${displayTotal.toStringAsFixed(2)}',
              bold: true,
            ),
            const SizedBox(height: 25),

            SizedBox(
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
                child: TranslatedText(
                  isPhysicalActive ? 'Send Order' : 'CheckOut',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDeliveryMethod(CartProvider cartProvider) {
    if (cartProvider.cartItems.isEmpty) {
      return false;
    }

    final bool allDigitalPlans = cartProvider.cartItems.every((item) {
      return item["is_digital_plan"] == true;
    });

    return !allDigitalPlans;
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'INR':
        return '₹';
      case 'SGD':
        return 'S\$';
      case 'CAD':
        return 'C\$';
      case 'EUR':
        return '€';
      case 'AED':
        return 'د.إ';
      case 'CNY':
        return '¥';
      default:
        return currency;
    }
  }

  // String _formatCurrency(String value) {
  //   final String trimmedValue = value.trim();

  //   if (trimmedValue.isEmpty) {
  //     return '$currency 0.00';
  //   }

  //   if (_hasCurrency(trimmedValue)) {
  //     return trimmedValue;
  //   }
  //   log("Formatting currency: $currency $trimmedValue");
  //   return '$currency $trimmedValue';
  // }

  String _formatCurrency(String value) {
    final String trimmedValue = value.trim();

    if (isPhysicalActive) {
      final String symbol = _getCurrencySymbol(currency);
      final String amount = trimmedValue.isEmpty
          ? '0.00'
          : _toDouble(trimmedValue).toStringAsFixed(2);

      return '$symbol $amount';
    }

    // Existing normal cart formatting — unchanged
    if (trimmedValue.isEmpty) {
      return '$currency 0.00';
    }

    if (_hasCurrency(trimmedValue)) {
      return trimmedValue;
    }

    log("Formatting currency: $currency $trimmedValue");
    return '$currency $trimmedValue';
  }

  bool _hasCurrency(String value) {
    final String upperValue = value.toUpperCase();

    final List<String> currencyCodes = [
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

    final List<String> currencySymbols = [
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

  double _toDouble(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  Widget _row(
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
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: bold ? 15 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),

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
}

class DottedLinePainter extends CustomPainter {
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;
  final Color color;

  DottedLinePainter({
    this.dashWidth = 5,
    this.dashSpace = 5,
    this.strokeWidth = 1,
    this.color = AppColors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DottedLinePainter oldDelegate) {
    return false;
  }
}
