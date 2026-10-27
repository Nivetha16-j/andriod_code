import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class BankTransferSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final Map<String, dynamic> summary;
  final String currencySymbol;
  final String bankName;

  const BankTransferSuccessScreen({
    super.key,
    required this.order,
    required this.summary,
    required this.currencySymbol,
    required this.bankName,
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
  }

  Future<void> loadUser() async {
    final user = await SessionManager.getUser();
    log("uuuuuuu $user");

    setState(() {
      email = user?["email"] ?? "";
    });
  }

  String? _getBankUrl(String bank) {
    const bankUrls = {
      "ICICI Bank": "https://www.icicibank.com/internet-banking",
      "HDFC Bank": "https://netbanking.hdfcbank.com/netbanking/",
      "Axis Bank": "https://www.axis.bank.in/bank-smart/internet-banking",
      "Federal Bank": "https://www.federalbank.co.in/fednet",
      "Canara Bank": "https://www.canarabank.bank.in/pages/net-banking",
      "State Bank Of India": "https://retail.onlinesbi.sbi/retail/login.html",
      "Central Bank Of India":
          "https://centralbank.bank.in/en/internet-banking",
      "CIMB Bank Berhad": "https://www.cimbclicks.com.sg/",
      "United Overseas Bank": "https://pib.uob.com.sg/auth/login",
      "Maybank":
          "https://sslsecure.maybank.com.sg/cgi-bin/mbs/scripts/mbb_login.jsp",
      "OCBC Bank":
          "https://internet.ocbc.com/internet-banking/digital/web/sg/cfo/login/login",
      "DBS Bank": "https://internet-banking.dbs.bank.in/login",
      "HSBC Bank":
          "https://www.us.hsbc.com/auth/?returnUrl=https://www.us.hsbc.com/bin/epep/postback.html?url=/online/dashboard",
      "Canadian Imperial Bank Of Commerce": "https://secure.cibc.com",
      "Royal Bank Of Canada": "https://www.rbcroyalbank.com/personal.html",
    };

    return bankUrls[bank];
  }

  Future<void> _openBankUrl() async {
    // if (widget.bankName == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please select a bank"),
    //     ),
    //   );
    //   return;
    // }

    final url = _getBankUrl(widget.bankName);

    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bank URL not available")));
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid bank website URL")));
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to open bank website")),
        );
      }
    } catch (e, stackTrace) {
      log("OPEN BANK URL ERROR: $e", stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open bank website")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = widget.order['created_at'] != null
        ? DateFormat(
            "MMMM dd, yyyy",
          ).format(DateTime.parse(widget.order['created_at']))
        : "";
    final total = widget.order['grand_total'];
    final items = widget.summary["items"] ?? [];

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
              const TranslatedText(
                "Thank you. Your order has been received.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              orderDetailsCard(
                order_no: widget.order['order_number'] ?? "",
                date: date,
                email: widget.order['customer_email'],
                total: "${widget.currencySymbol}${total ?? ""}",
                paymentMethod: widget.order['payment_method'] ?? '',
              ),

              const SizedBox(height: 20),

              orderItemsCard(items, widget.currencySymbol),

              const SizedBox(height: 20),

              widget.order['payment_method'] == 'upi'
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TranslatedText(
                            "If you have any questions or need assistance, feel free to contact us.",
                            style: TextStyle(height: 1.5),
                          ),

                          const SizedBox(height: 16),
                          const TranslatedText(
                            "After payment, please email your transfer receipt to ",
                            style: TextStyle(height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          const TranslatedText(
                            "customer@junubullion.com.",
                            style: TextStyle(
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : bankTransferCard(
                      context,
                      widget.bankName,
                      widget.order['order_number'] ?? '',
                      _openBankUrl,
                    ),
              const SizedBox(height: 20),
              SizedBox(
                // width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8B1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  child: const TranslatedText(
                    "Continue Shopping",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
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
      color: AppColors.lightRed,
      // border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _orderInfoRow('Order number', order_no),

        const SizedBox(height: 18),

        _orderInfoRow('Date', date, translateValue: true),

        const SizedBox(height: 18),

        _orderInfoRow('Email', email),

        const SizedBox(height: 18),

        _orderInfoRow('Total', total),

        const SizedBox(height: 18),

        _orderInfoRow('Payment method', paymentMethod, translateValue: true),
      ],
    ),
  );
}

Widget _orderInfoRow(
  String label,
  String value, {
  bool translateValue = false,
}) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      TranslatedText(
        '$label : ',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),

      translateValue
          ? TranslatedText(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            )
          : Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
    ],
  );
}

Widget orderItemsCard(List<dynamic> items, String currencySymbol) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Order items",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 16),

        const Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                "Product",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                "Qty",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Total",
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const Divider(),

        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(item["name"] ?? "")),

                Expanded(
                  child: Text(
                    "${item["quantity"]}",
                    textAlign: TextAlign.center,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    item["formatted_line_total"] ??
                        "$currencySymbol ${item["line_total"]}",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );
}

Widget bankTransferCard(
  BuildContext context,
  String bankName,
  String orderNumber,
  Future<void> Function() onOpenBankUrl,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.sandal,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              "Complete your payment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          "You selected $bankName. Log in to your net banking and transfer the order total to our account using the details below. Use order $orderNumber as the payment reference.",
          style: const TextStyle(height: 1.5),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: onOpenBankUrl,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Open $bankName net banking",
            style: const TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 16),

        const TranslatedText(
          "If you have any questions or need assistance, feel free to contact us.",
          style: TextStyle(height: 1.5),
        ),

        const SizedBox(height: 16),

        const TranslatedText(
          "Our Bank Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        const SizedBox(height: 16),

        const TranslatedText(
          "JUNU SG PTE LTD\n"
          "Bank : CIMB BANK BERHAD\n"
          "Account Number : 2001093941\n"
          "BIC : CIBBSGSGXXX",
          style: TextStyle(height: 1.6),
        ),
        const SizedBox(height: 16),

        const TranslatedText(
          "After payment, please email your transfer receipt to ",
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: 8),
        const TranslatedText(
          "customer@junubullion.com.",
          style: TextStyle(height: 1.5, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),
      ],
    ),
  );
}
