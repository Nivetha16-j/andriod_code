import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';

class PhysicalOrderSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String currencySymbol;

  const PhysicalOrderSuccessScreen({
    super.key,
    required this.order,
    required this.currencySymbol,
  });

  String _getOrderNumber() {
    return order["order_number"]?.toString() ??
        order["number"]?.toString() ??
        order["order_no"]?.toString() ??
        "-";
  }

  String _getDate() {
    return order["date"]?.toString() ?? order["created_at"]?.toString() ?? "-";
  }

  String _getEmail() {
    return order["email"]?.toString() ?? "-";
  }

  String _getTotal() {
    final total = order["total"] ?? order["order_total"] ?? order["amount"];

    if (total == null) {
      return "$currencySymbol 0.00";
    }

    return "$currencySymbol ${total.toString()}";
  }

  String _getPaymentMethod() {
    return order["payment_method"]?.toString() ??
        order["payment_type"]?.toString() ??
        "Wallet";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thank you. Your order has been received.',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('Order number:', _getOrderNumber()),

                          const SizedBox(height: 16),

                          _infoRow('Date:', _getDate()),

                          const SizedBox(height: 16),

                          _infoRow('Email:', _getEmail()),

                          const SizedBox(height: 16),

                          _infoRow('Total:', '${_getTotal()} INR'),

                          const SizedBox(height: 16),

                          _infoRow('Payment method:', _getPaymentMethod()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialIndex: 0),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Continue shopping',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
