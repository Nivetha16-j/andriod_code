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
        _row("Subtotal Product", subtotal),

        const SizedBox(height: 15),

        _row("Courier charge (${deliveryMethod} delivery)", "+ $courier_fee"),
        if (coupon != null) ...[
          const SizedBox(height: 15),

          _row("Discount (${coupon!["code"]})", "- $discount"),

          const SizedBox(height: 15),

          _row("Discount Price", discountPrice),
        ],

        const SizedBox(height: 15),

        // _row("Transaction fee (4%)", "+ $transaction_fee"),
        _row("Transaction fee (4%)", "+ $transaction_fee"),

        if (provider.showTax) ...[
          const SizedBox(height: 15),
          _row("GST (21%)", "+ $gst"),
        ],

        const Divider(height: 35),

        _row("Total", total, bold: true),
      ],
    );
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
