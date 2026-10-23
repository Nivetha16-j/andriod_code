import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // You can access the order details using widget.order
    log('Orderrrrrrrr deetss: ${widget.order}'); // For debugging purposes
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    int _currentIndex = 3;

    void _switchToTab(int index) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
        (route) => false,
      );
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: AppColors.white),
        child: SingleChildScrollView(
          child: OrderDetailsContent(order: widget.order),
        ),
      ),
    );
  }
}

class OrderDetailsContent extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsContent({super.key, required this.order});

  @override
  State<OrderDetailsContent> createState() => _OrderDetailsContentState();
}

class _OrderDetailsContentState extends State<OrderDetailsContent> {
  String getCurrencySymbol(String? currency) {
    switch ((currency ?? '').toUpperCase()) {
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
        return currency ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        widget.order['payments'] != null &&
            (widget.order['payments'] as List).isNotEmpty
        ? widget.order['payments'][0]['currency']
        : '';

    final symbol = getCurrencySymbol(currency);

    String formatDate(String? date) {
      if (date == null || date.isEmpty) return '';

      final parsedDate = DateTime.parse(date).toLocal();

      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number
          TranslatedText(
            "${widget.order['order_number']}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),

          const SizedBox(height: 8),

          TranslatedText(
            formatDate(widget.order['created_at']),
            style: TextStyle(fontSize: 13, color: AppColors.black),
          ),

          const SizedBox(height: 24),

          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.sandal,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.black),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(.15),
              //     blurRadius: 8,
              //     offset: const Offset(3, 4),
              //   ),
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Status : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${widget.order['status']}"),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Payment : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "${widget.order['payment_status']} — ${widget.order['payment_method']}",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Shipping address : ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: "${widget.order['shipping_address']}"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const TranslatedText(
            "Items",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.yellowBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.lightGrey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TranslatedText(
                          "Product",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TranslatedText(
                          "Qty",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TranslatedText(
                          "Unit price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TranslatedText(
                          "Line total",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Item Row
                Column(
                  children: List.generate((widget.order['items'] as List).length, (
                    index,
                  ) {
                    final item = widget.order['items'][index];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      item['product_name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TranslatedText(
                                      "SKU: ${item['sku'] ?? '-'}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TranslatedText(
                                  "${item['quantity']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TranslatedText(
                                  "${getCurrencySymbol(currency)}${item['unit_price']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: TranslatedText(
                                  "${getCurrencySymbol(currency)}${item['line_total'].toString()}",

                                  textAlign: TextAlign.end,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index != (widget.order['items'] as List).length - 1)
                          const Divider(),
                      ],
                    );
                  }),
                ),

                const Divider(),

                // Subtotal
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Spacer(),
                      TranslatedText(
                        "Subtotal",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 30),
                      TranslatedText(
                        "${getCurrencySymbol(currency)}${widget.order['subtotal'].toString()}",

                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if ((double.tryParse(widget.order['tax_total'].toString()) ??
                        0) >
                    0)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            const TranslatedText(
                              "Tax",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 30),
                            TranslatedText(
                              "$symbol${widget.order['tax_total']}",
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),

                if ((double.tryParse(
                          widget.order['shipping_total'].toString(),
                        ) ??
                        0) >
                    0)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),
                            const TranslatedText(
                              "Shipping",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 30),
                            TranslatedText(
                              "$symbol${widget.order['shipping_total']}",
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),

                // Order Total
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Spacer(),
                      TranslatedText(
                        "Order total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 30),
                      TranslatedText(
                        "${getCurrencySymbol(currency)}${widget.order['grand_total'].toString()}",

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
