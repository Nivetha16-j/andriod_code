import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:provider/provider.dart';

class RecentOrdersSection extends StatelessWidget {
  final bool showAll;

  const RecentOrdersSection({super.key, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    final orders = showAll ? provider.orders : provider.orders.take(4).toList();
    // final provider = context.watch<OrdersProvider>();

    // // Show only the latest 4 orders
    // final orders = provider.orders.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(18),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(.08),
      //       blurRadius: 12,
      //       offset: const Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Row(
            //   children: [
            //     const Text(
            //       "Recent Orders",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //     const Spacer(),
            //     InkWell(
            //       onTap: () {
            //         // Navigate to all orders screen
            //       },
            //       child: const Text(
            //         "View all",
            //         style: TextStyle(
            //           color: Colors.brown,
            //           fontWeight: FontWeight.bold,
            //           decoration: TextDecoration.underline,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              children: [
                Text(
                  showAll ? "Orders" : "Recent Orders",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!showAll)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderScreen()),
                      );
                    },
                    child: const Text(
                      "View all",
                      style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No orders found"),
              )
            else ...[
              Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Order",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Total",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final order = orders[index];

                  log("ordersss// $orders...${orders.length}");

                  final date = DateFormat(
                    "dd MMM yyyy",
                  ).format(DateTime.parse(order["created_at"]));

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          order["order_number"],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(date, style: const TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order["status"].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: order["status"] == "pending"
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order["grand_total"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
