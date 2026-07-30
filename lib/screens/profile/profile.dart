import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/profile/custom_dashboard.dart';
import 'package:junubullion/widgets/profile/kyc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ProfileHeader(),

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
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.download,
              title: "Downloads",
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: "Addresses",
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.credit_card,
              title: "Payment Methods",
              onTap: () {},
            ),

            ProfileMenuTile(
              icon: Icons.person_outline,
              title: "Account Details",
              onTap: () {},
            ),

            ProfileMenuTile(icon: Icons.logout, title: "Logout", onTap: () {}),
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
    int _currentIndex = 3;

    void _switchToTab(int index) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
        (route) => false,
      );
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: const Dashboard(), // Your existing Dashboard widget
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SessionManager.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        log("rrrrrrr $user");

        final String name = user?["name"]?.toString() ?? "Guest";
        final String email = user?["email"]?.toString() ?? "";

        return Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

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
