import 'package:flutter/material.dart';
import 'package:junubullion/widgets/profile/custom_dashboard.dart';

class RightMenu extends StatelessWidget {
  final int selectedIndex;

  const RightMenu({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return Dashboard();

      case 1:
        return const Center(child: Text("Orders"));

      case 2:
        return const Center(child: Text("KYC Verification"));

      case 3:
        return const Center(child: Text("Wallet"));

      case 4:
        return const Center(child: Text("Addresses"));

      case 5:
        return const Center(child: Text("Payment Methods"));

      case 6:
        return const Center(child: Text("Account Details"));

      case 7:
        return const Center(child: Text("Logout"));

      default:
        return const SizedBox();
    }
  }
}
