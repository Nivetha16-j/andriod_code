import 'package:flutter/material.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class SellBackScreen extends StatefulWidget {
  const SellBackScreen({super.key});

  @override
  State<SellBackScreen> createState() => _SellBackScreenState();
}

class _SellBackScreenState extends State<SellBackScreen> {
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
        selectedMenu: 'Sell Back Request',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscSellBackContent(),
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

class JscSellBackContent extends StatelessWidget {
  const JscSellBackContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==================================================
        // PAGE TITLE
        // ==================================================
        const Text(
          'Sell Back Request',
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
          'Sell your digital holdings and track bank transfer payouts.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.25,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        _UnlockBalanceCard(),
        const SizedBox(height: 25),
        Container(
          // margin: const EdgeInsets.only(top: 20, right: 16),
          padding: const EdgeInsets.all(10),
          // constraints: const BoxConstraints(minHeight: 264),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFFF202E), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 5,
                offset: const Offset(1, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================================================
              // TITLE
              // ================================================
              Text(
                'Sell Back for Cash',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E2828),
                ),
              ),

              const SizedBox(height: 4),

              // ================================================
              // DESCRIPTION BOX
              // ================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 17, 10, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  border: Border.all(
                    color: const Color(0xFFFFB52E),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Sell your digital holdings back to Junu Bullion at the live spot price. Enter your bank details and confirm the amount — we will transfer the payout to your account.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ================================================
              // UNLOCK BALANCE BOX
              // ================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  border: Border.all(
                    color: const Color(0xFFFFB52E),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Unlock your balances to sell back holdings.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFD99A12),
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

class _UnlockBalanceCard extends StatefulWidget {
  const _UnlockBalanceCard();

  @override
  State<_UnlockBalanceCard> createState() => _UnlockBalanceCardState();
}

class _UnlockBalanceCardState extends State<_UnlockBalanceCard> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 248, 230, 1),
        border: Border.all(color: const Color(0xFFE9C65A), width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 2,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Gold and Silver balances are protected.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w400,
            ),
          ),

          const Text(
            'Please enter your unlock password (first 4 characters of your registered email ID + last 4 digits of your registered phone number) to view your balance.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 30,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Email Prefix + Phone Suffix',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD20D2D),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Unlock Balances',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
