import 'package:flutter/material.dart';

class RecentOrdersSection extends StatelessWidget {
  const RecentOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        "order": "#JB-20260701-M2FU5Z",
        "date": "Jul 01, 2026",
        "status": "Pending",
        "total": "1,472.20",
      },
      {
        "order": "#JB-20260701-M2FU5Z",
        "date": "Jul 01, 2026",
        "status": "Pending",
        "total": "1,472.20",
      },
      {
        "order": "#JB-20260701-M2FU5Z",
        "date": "Jul 01, 2026",
        "status": "Pending",
        "total": "1,472.20",
      },
      {
        "order": "#JB-20260701-M2FU5Z",
        "date": "Jul 01, 2026",
        "status": "Pending",
        "total": "1,472.20",
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Recent orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                child: const Text(
                  "View all",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Header
          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  "Order",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Date",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Status",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Total",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              // Expanded(
              //   child: Text(
              //     "Actions",
              //     textAlign: TextAlign.end,
              //     style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final order = orders[index];

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          order["order"]!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          order["date"]!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order["status"]!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          order["total"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      // Expanded(
                      //   child: Align(
                      //     alignment: Alignment.centerRight,
                      //     child: TextButton(
                      //       onPressed: () {},
                      //       child: const Text(
                      //         "View",
                      //         style: TextStyle(color: Colors.black),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
