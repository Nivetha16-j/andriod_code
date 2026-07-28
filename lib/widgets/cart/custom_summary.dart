import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  final double subtotal;

  const SummaryWidget({super.key, required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row("Subtotal Product", "\$${subtotal.toStringAsFixed(2)}"),

        const SizedBox(height: 15),

        _row("Transaction fee", "+ \$0.00"),

        const Divider(height: 35),

        _row(
          "Order Total",
          "\$${subtotal.toStringAsFixed(2)}",
          valueColor: Colors.red,
          bold: true,
        ),
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
