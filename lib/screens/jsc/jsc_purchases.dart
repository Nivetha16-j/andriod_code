import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'jsc_layout.dart';

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
      body: JscLayout(
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

// ============================================================
// PURCHASE CONTENT
// ============================================================

class JscPurchasesContent extends StatelessWidget {
  const JscPurchasesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================================================
        // PAGE TITLE
        // ================================================
        const Text(
          'Your Purchases',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        // ================================================
        // DESCRIPTION
        // ================================================
        const Text(
          "Track each digital purchase against today's market price.",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        // ================================================
        // PURCHASE BOX
        // ================================================
        Container(
          width: double.infinity,
          // constraints: const BoxConstraints(minHeight: 245),
          padding: const EdgeInsets.fromLTRB(20, 17, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color.fromRGBO(240, 58, 58, 1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 4,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // INNER TITLE
              // ==========================================
              const Text(
                'Your Purchases',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E2828),
                ),
              ),

              const SizedBox(height: 23),

              // ==========================================
              // INFORMATION BOX
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 11, 20, 11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 4,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
                child: const Text(
                  "Track each digital purchase against today's market price.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // ==========================================
              // EMPTY STATE
              // ==========================================
              const Center(
                child: Text(
                  'No digital gold or silver purchases yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
