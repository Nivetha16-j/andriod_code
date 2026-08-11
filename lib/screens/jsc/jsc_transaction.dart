import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'jsc_layout.dart';

class JscTransactionHistoryScreen extends StatefulWidget {
  const JscTransactionHistoryScreen({super.key});

  @override
  State<JscTransactionHistoryScreen> createState() =>
      _JscTransactionHistoryScreenState();
}

class _JscTransactionHistoryScreenState
    extends State<JscTransactionHistoryScreen> {
  int currentIndex = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: JscLayout(
        selectedMenu: 'Transaction History',
        child: const JscTransactionHistoryContent(),
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
// TRANSACTION HISTORY CONTENT
// ============================================================

class JscTransactionHistoryContent extends StatelessWidget {
  const JscTransactionHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // PAGE TITLE
          // ==================================================
          const Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // DESCRIPTION
          // ==================================================
          const Text(
            'Review purchases, conversions, and sell back activity on your JSC wallet.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.25,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // INNER TITLE
          // ==================================================
          const Text(
            'Transaction History',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 52),

          // ==================================================
          // EMPTY STATE
          // ==================================================
          const Center(
            child: Text(
              'No wallet transactions yet. Buy digital gold or silver to start building your holdings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
