import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/screens/profile/profile.dart';
import 'package:provider/provider.dart';

class RecentOrdersSection extends StatefulWidget {
  final bool showAll;
  final List<dynamic>? orders;

  const RecentOrdersSection({super.key, this.showAll = false, this.orders});

  @override
  State<RecentOrdersSection> createState() => _RecentOrdersSectionState();
}

class _RecentOrdersSectionState extends State<RecentOrdersSection> {
  static const int ordersPerPage = 15;

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    final allOrders =
        widget.orders ??
        (widget.showAll ? provider.orders : provider.orders.take(4).toList());

    final totalPages = allOrders.isEmpty
        ? 1
        : (allOrders.length / ordersPerPage).ceil();

    if (currentPage >= totalPages) {
      currentPage = totalPages - 1;
    }

    final startIndex = currentPage * ordersPerPage;

    final endIndex = (startIndex + ordersPerPage > allOrders.length)
        ? allOrders.length
        : startIndex + ordersPerPage;

    final displayOrders = allOrders.isEmpty
        ? <dynamic>[]
        : allOrders.sublist(startIndex, endIndex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.showAll ? "Orders" : "Recent Orders",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                if (!widget.showAll)
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (allOrders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text("No orders found"),
                ),
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

              const SizedBox(height: 12),

              const Divider(),

              ...displayOrders.map((order) {
                final orderNumber = order["order_number"]?.toString() ?? "-";

                final status = order["status"]?.toString() ?? "-";

                final createdAt = order["created_at"]?.toString();

                String date = "-";

                if (createdAt != null && createdAt.isNotEmpty) {
                  try {
                    date = DateFormat(
                      "dd MMM yyyy",
                    ).format(DateTime.parse(createdAt));
                  } catch (_) {
                    date = "-";
                  }
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ORDER NUMBER
                          Expanded(
                            flex: 3,
                            child: Text(
                              orderNumber,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // DATE
                          Expanded(
                            flex: 3,
                            child: Text(
                              date,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),

                          // STATUS
                          Expanded(
                            flex: 2,
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: status.toLowerCase() == "pending"
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // TOTAL
                          Expanded(
                            flex: 2,
                            child: Text(
                              order["grand_total"]?.toString() ?? "0.00",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xffEEEEEE)),
                  ],
                );
              }),

              const SizedBox(height: 20),

              if (totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PREVIOUS
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: currentPage > 0
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          side: const BorderSide(color: Color(0xffA90020)),
                        ),
                        child: const Text(
                          "Previous",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // PAGE NUMBER
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xffA90020),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "${currentPage + 1} / $totalPages",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // NEXT
                    SizedBox(
                      height: 38,
                      child: OutlinedButton(
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          side: const BorderSide(color: Color(0xffA90020)),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              if (totalPages > 1)
                Center(
                  child: Text(
                    "Showing ${startIndex + 1}–$endIndex "
                    "of ${allOrders.length} orders",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff777777),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
