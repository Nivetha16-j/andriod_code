import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class LeftMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const LeftMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  final List<String> menus = const [
    "Dashboard",
    "KYC Verification",
    "Orders",
    "Downloads",
    "Addresses",
    "Payment Methods",
    "Account Details",
    "Logout",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "My Account",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),

        // const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: menus.length,
            itemBuilder: (context, index) {
              return ListTile(
                selected: selectedIndex == index,
                title: Text(
                  menus[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedIndex == index
                        ? AppColors.primaryRed
                        : Colors.black,
                    fontWeight: selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () => onItemSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
