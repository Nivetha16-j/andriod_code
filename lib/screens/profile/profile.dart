import 'package:flutter/material.dart';
import 'package:junubullion/widgets/profile/custom_dashboard.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              onTap: () {},
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
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: const Dashboard(), // Your existing Dashboard widget
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
        SizedBox(height: 12),
        Text(
          "Keerthi S",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text("Customer", style: TextStyle(fontSize: 20, color: Colors.grey)),
      ],
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
