import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:junubullion/providers/convert_physical_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/profile/account_details.dart';
import 'package:junubullion/widgets/profile/addresses.dart';
import 'package:junubullion/widgets/profile/dashboard/custom_dashboard.dart';
import 'package:junubullion/widgets/profile/downloads.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
import 'package:junubullion/widgets/profile/payment_methods.dart';
import 'package:junubullion/widgets/profile/recentorders.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<OrdersProvider>();

      if (provider.orders.isEmpty) {
        await provider.fetchOrders();
      }

      final accountProvider = context.read<AccountProvider>();

      await accountProvider.fetchAccountDetails();

      if (!mounted) return;

      setState(() {
        name = accountProvider.name;
        email = accountProvider.email;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileHeader(name, email),

            const SizedBox(height: 25),

            const Text(
              "General",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ProfileMenuTile(
              icon: Icons.dashboard_outlined,
              title: "Dashboard",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.verified_user_outlined,
              title: "KYC Verification",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KycVerificationCard(),
                  ),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.shopping_cart_outlined,
              title: "Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderScreen()),
                );
              },
            ),

            // ProfileMenuTile(
            //   icon: Icons.download,
            //   title: "Downloads",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const DownloadsScreen()),
            //     );
            //   },
            // ),
            ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: "Addresses",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddressSection()),
                );
              },
            ),

            // ProfileMenuTile(
            //   icon: Icons.credit_card,
            //   title: "Payment Methods",
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const PaymentMethodsScreen(),
            //       ),
            //     );
            //   },
            // ),
            ProfileMenuTile(
              icon: Icons.person_outline,
              title: "Account Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountDetailsScreen(),
                  ),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xffF7F7F7),
                    title: const Text("Log Out"),
                    content: const Text("Are you sure you want to Log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          "Yes",
                          style: TextStyle(color: AppColors.primaryRed),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  context.read<ConvertPhysicalProvider>().clear();
                  await SessionManager.logout();

                  // Reset the in-memory state for all JSC balance sections
                  balanceUnlockedNotifier.value = false;

                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
      body: const Dashboard(), // Your existing Dashboard widget
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

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
      body: const RecentOrdersSection(
        showAll: true,
      ), // Your existing RecentOrdersSection widget
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader(this.name, this.email, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(email, style: const TextStyle(fontSize: 15, color: Colors.grey)),
      ],
    );
  }
}

// builder: (context, snapshot) {
//   if (snapshot.connectionState == ConnectionState.waiting) {
//     return const Center(child: CircularProgressIndicator());
//   }

//   final user = snapshot.data;

//   log("rrrrrrr $user");

//   final String name = user?["name"]?.toString() ?? "Guest";
//   final String email = user?["email"]?.toString() ?? "";

//   return Column(
//     children: [
//       const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
//       const SizedBox(height: 12),
//       Text(
//         name,
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//       ),
//       const SizedBox(height: 10),
//       Text(
//         email,
//         style: const TextStyle(fontSize: 15, color: Colors.grey),
//       ),
//     ],
//   );
// },
// );
// }
// }

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Color.fromRGBO(255, 234, 239, 1),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryRed),
        title: Text(title),
        trailing: Icon(Icons.chevron_right, color: AppColors.primaryRed),
        onTap: onTap,
      ),
    );
  }
}
