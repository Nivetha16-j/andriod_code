import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class SummaryWidget extends StatelessWidget {
  final String subtotal;
  final String courier_fee;
  final String transaction_fee;
  final String total;
  final String deliveryMethod;
  final String gst;
  final String currency;

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
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();

    return Column(
      children: [
        _row("Subtotal Product", _formatCurrency(subtotal)),

        const SizedBox(height: 15),

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

        const SizedBox(height: 15),

        _row("Transaction fee (4%)", "+ ${_formatCurrency(transaction_fee)}"),

        if (provider.showTax) ...[
          const SizedBox(height: 15),

          _row("GST (21%)", "+ ${_formatCurrency(gst)}"),
        ],

        const Divider(height: 35),

        _row("Total", _formatCurrency(total), bold: true),
      ],
    );
  }

  // ============================================================
  // CURRENCY HANDLING
  // ============================================================

  String _formatCurrency(String value) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return '$currency 0.00';
    }

    // Normal cart values already contain the currency.
    //
    // Example:
    // ₹ 100.00
    // $ 100.00
    // USD 100.00
    //
    // In these cases, return the value exactly as it is.
    if (_hasCurrency(trimmedValue)) {
      return trimmedValue;
    }

    // Physical conversion values are plain:
    //
    // 0.00
    //
    // So add the currently selected currency.
    return '$currency $trimmedValue';
  }

  bool _hasCurrency(String value) {
    final String upperValue = value.toUpperCase();

    // Currency codes
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

    // Common currency symbols
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

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _row(
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
}
