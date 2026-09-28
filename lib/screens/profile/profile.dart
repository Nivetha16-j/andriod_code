import 'package:flutter/material.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:junubullion/providers/order_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/profile/account_details.dart';
import 'package:junubullion/widgets/profile/addresses.dart';
import 'package:junubullion/widgets/profile/dashboard/custom_dashboard.dart';
import 'package:junubullion/widgets/profile/kyc.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProfileData();
    });
  }

  Future<void> _refreshProfileData() async {
    if (!mounted) return;

    final ordersProvider = context.read<OrdersProvider>();
    final accountProvider = context.read<AccountProvider>();

    try {
      // Always refresh orders whenever Profile is opened.
      await ordersProvider.fetchOrders();

      if (!mounted) return;

      // Always refresh account details.
      await accountProvider.fetchAccountDetails();

      if (!mounted) return;

      setState(() {
        name = accountProvider.name;
        email = accountProvider.email;
      });
    } catch (e) {
      debugPrint("PROFILE REFRESH ERROR -> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.BgGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ProfileHeader(name, email),

              const SizedBox(height: 25),

              // Account Overview
              ProfileSection(
                heading: "Account Overview",
                children: [
                  MenuList(
                    image: "assets/dashboard.png",
                    title: "Dashboard",
                    description: "Vault metrics, profits & monthly streaks",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  MenuList(
                    image: "assets/kyc.png",
                    title: "KYC Verification",
                    description: "ID proof, PAN registration & compliance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KycVerificationCard(),
                        ),
                      );
                    },
                  ),

                  MenuList(
                    image: "assets/acc.png",
                    title: "Account Details",
                    description: "Personal Info, nominee & phone number",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountDetailsScreen(),
                        ),
                      );
                    },
                  ),

                  MenuList(
                    image: "assets/add.png",
                    title: "Addresses",
                    description: "Saved bullion doorstep delivery addresses",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddressSection(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Orders
              ProfileSection(
                heading: "Orders",
                children: [
                  MenuList(
                    image: "assets/order.png",
                    title: "Orders",
                    description: "Delivery track, gram purchases & sales",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Logout
              ProfileSection(
                heading: "Account",
                children: [
                  MenuList(
                    image: "assets/logout.png",
                    title: "Logout",
                    description: "",
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.pinkGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TranslatedText(
                                  "Log Out",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                const TranslatedText(
                                  "Are you sure you want to Log out?",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.lightGrey,
                                        foregroundColor: AppColors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const TranslatedText(
                                        "No",
                                        style: TextStyle(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryRed,
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const TranslatedText(
                                        "Yes",
                                        style: TextStyle(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (shouldLogout == true) {
                        await SessionManager.logout();

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
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String heading;
  final List<Widget> children;

  const ProfileSection({
    super.key,
    required this.heading,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mustard, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            heading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 8),

          const Divider(color: AppColors.mustard, thickness: 0.8, height: 1),

          const SizedBox(height: 8),

          ...List.generate(
            children.length,
            (index) => Column(
              children: [
                children[index],

                if (index != children.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
              ],
            ),
          ),
        ],
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
      // backgroundColor: AppColors.sandal,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: const Dashboard(),
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: RecentOrdersSection(showAll: true),
        ),
      ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mustard),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
            // const SizedBox(height: 12),
            TranslatedText(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),
            TranslatedText(
              email,
              style: const TextStyle(fontSize: 15, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class MainDiv extends StatelessWidget {
  final String heading;
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;

  const MainDiv({
    super.key,
    required this.heading,
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mustard),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 45)),
            // const SizedBox(height: 12),
            TranslatedText(
              heading,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            Divider(),
            MenuList(
              image: image,
              title: title,
              description: description,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onTap;

  const MenuList({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(image),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    TranslatedText(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            const Icon(Icons.chevron_right, color: AppColors.mustard, size: 24),
          ],
        ),
      ),
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
  final String description;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
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
        title: TranslatedText(title),
        subtitle: TranslatedText(description),
        trailing: Icon(Icons.chevron_right, color: AppColors.primaryRed),
        onTap: onTap,
      ),
    );
  }
}
