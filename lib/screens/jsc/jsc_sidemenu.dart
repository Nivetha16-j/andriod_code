import 'package:flutter/material.dart';

class JscSidebar extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuTap;

  const JscSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCF6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 3,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 6, top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JSC',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 10),

            _menuItem('Dashboard'),
            _menuItem('My Wallet'),
            _menuItem('Your Purchases'),
            _menuItem('Account Details'),
            _menuItem('Transaction History'),
            _menuItem('Sell Back Request'),
            _menuItem('Lost Password'),
            _menuItem('Logout'),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(String title) {
    final isSelected = selectedMenu == title;

    return InkWell(
      onTap: () {
        onMenuTap(title);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFA52222) : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
