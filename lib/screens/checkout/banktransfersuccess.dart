import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class BankTransferSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final String currencySymbol;

  const BankTransferSuccessScreen({
    super.key,
    required this.order,
    required this.currencySymbol,
  });

  @override
  State<BankTransferSuccessScreen> createState() =>
      _BankTransferSuccessScreenState();
}

class _BankTransferSuccessScreenState extends State<BankTransferSuccessScreen> {
  String email = "";
  String total = '';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    log("widdddddddddd ${widget.order}");
    // loadUser();
    // total = widget.order["grand_total"]?.toString() ?? "";
    // paymentMethod = widget.order["payment_method"]?.toString() ?? "";
    // address = widget.order["shipping_address"]?.toString() ?? "";
    // createdAt = widget.order["created_at"]?.toString() ?? "";
  }

  Future<void> loadUser() async {
    final user = await SessionManager.getUser();
    log("uuuuuuu $user");

    setState(() {
      email = user?["email"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    String date = widget.order['created_at'] != null
        ? DateFormat(
            "MMMM dd, yyyy",
          ).format(DateTime.parse(widget.order['created_at']))
        : "";
    final cartProvider = context.watch<CartProvider>();
    final total = widget.order['grand_total'];

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFFAFAFA),
      resizeToAvoidBottomInset: false,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: const Text(
                  "Thank you. Your order has been received.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),

              orderDetailsCard(
                order_no: widget.order['order_number'],
                date: date,
                email: widget.order['customer_email'],
                total: "${widget.currencySymbol}${total ?? ""}",
                paymentMethod: widget.order['payment_method'] ?? '',
              ),

              const SizedBox(height: 20),

              bankTransferCard(context),
            ],
          ),
        ),
      ),
    );
  }
}

Widget orderDetailsCard({
  required String order_no,
  required String date,
  required String email,
  required String total,
  required String paymentMethod,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: [
              const TextSpan(
                text: "Order number : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: order_no),
            ],
          ),
        ),

        const SizedBox(height: 18),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: [
              const TextSpan(
                text: "Date : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: date),
            ],
          ),
        ),

        const SizedBox(height: 18),

        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: [
              const TextSpan(
                text: "Email : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: email),
            ],
          ),
        ),

        const SizedBox(height: 18),

        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: [
              const TextSpan(
                text: "Total : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: total),
            ],
          ),
        ),

        const SizedBox(height: 18),

        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: [
              const TextSpan(
                text: "Payment method : ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: paymentMethod),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget bankTransferCard(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How to complete Your Bank Transfer",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        const Text(
          "Please use the provided bank account details to complete your payment. Follow the steps below based on your location.",
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),

        const SizedBox(height: 20),

        const Text(
          "If You Are In Singapore (Domestic Transfer):",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 10),

        const Text(
          "1. Log in to your bank's online banking or mobile app\n"
          "2. Navigate to payment transfers (depending on your bank)\n"
          "3. Enter the payment details we have provided\n"
          "4. Confirm and complete the transfer",
          style: TextStyle(height: 1.6),
        ),

        const SizedBox(height: 20),

        const Text(
          "If You Are Outside Singapore (International Transfer):",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 10),

        const Text(
          "1. Log in to your bank's online banking platform\n"
          "2. Go to international transfers/wire transfers\n"
          "3. Enter the recipient account details we have shared with you.\n"
          "4. Confirm and complete the transfer",
          style: TextStyle(height: 1.6),
        ),

        const SizedBox(height: 20),

        const Text(
          "Processing Time",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 8),

        const Text(
          "Bank transfers may take 3–5 business days depending on your bank location.",
          style: TextStyle(height: 1.5),
        ),

        const SizedBox(height: 20),

        const Text(
          "If you have any questions or need assistance, feel free to contact us.",
          style: TextStyle(height: 1.5),
        ),

        const SizedBox(height: 20),

        const Text(
          "Our Bank Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 12),

        const Text(
          "JUNU SG PTE LTD\n"
          "Bank : CIMB BANK BERHAD\n"
          "Account Number : 2001093941\n"
          "BIC : CIBBSGSGXXX",
          style: TextStyle(height: 1.6),
        ),
        const SizedBox(height: 20),

        const Text(
          "After payment, please email your transfer receipt to info@junubullion.com.",
          style: TextStyle(height: 1.5),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: 180,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8B1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
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
              "Continue Shopping",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
