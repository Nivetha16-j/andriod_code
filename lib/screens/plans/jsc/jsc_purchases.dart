import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import '../layout.dart';
import 'package:junubullion/widgets/jsc/jsc_purchases_section.dart';

class JscPurchasesScreen extends StatefulWidget {
  const JscPurchasesScreen({super.key});

  @override
  State<JscPurchasesScreen> createState() => _JscPurchasesScreenState();
}

class _JscPurchasesScreenState extends State<JscPurchasesScreen> {
  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: PlansLayout(
        plans: Plans.jsc,
        selectedMenu: 'Your Purchases',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscPurchasesContent(),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class JscPurchasesContent extends StatelessWidget {
  const JscPurchasesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Purchases',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Track each digital purchase against today's market price.",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        const JscPurchasesSection(),
      ],
    );
  }
}
