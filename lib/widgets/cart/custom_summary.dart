import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  final String subtotal;
  final String courier_fee;
  final String transaction_fee;
  final String total;

  const SummaryWidget({
    super.key,
    required this.subtotal,
    required this.courier_fee,
    required this.transaction_fee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row("Subtotal Product", "${subtotal}"),

        const SizedBox(height: 15),

        _row("Courier Charges", "+ ${courier_fee}"),

        const SizedBox(height: 15),

        _row("Transaction fee", "+ ${transaction_fee}"),

        const Divider(height: 35),

        _row("Order Total", "${total}", valueColor: Colors.red, bold: true),
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
