import 'package:flutter/material.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/jsc/jsc_purchases.dart';
import 'package:junubullion/screens/jsc/jsc_sidemenu.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class JscDashboardScreen extends StatefulWidget {
  const JscDashboardScreen({super.key});

  @override
  State<JscDashboardScreen> createState() => _JscDashboardScreenState();
}

class _JscDashboardScreenState extends State<JscDashboardScreen> {
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
        selectedMenu: 'Dashboard',

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const _DashboardContent(),
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
// SIDEBAR
// ============================================================

// class _Sidebar extends StatelessWidget {
//   const _Sidebar();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.3,
//       // margin: const EdgeInsets.only(left: 27, bottom: 330),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFDFCF6),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.18),
//             blurRadius: 3,
//             offset: const Offset(1, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 8, right: 6, top: 14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'JSC',
//               style: TextStyle(fontSize: 14, color: Colors.black87),
//             ),

//             const SizedBox(height: 10),

//             _sideItem('Dashboard', selected: true),
//             _sideItem('My Wallet'),
//             _sideItem('Your Purchases'),
//             _sideItem('Account Details'),
//             _sideItem('Transaction History'),
//             _sideItem('Sell Back Request'),
//             _sideItem('Lost Password'),
//             _sideItem('Logout'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sideItem(String title, {bool selected = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 12,
//           color: selected ? const Color(0xFFC5142D) : Colors.black87,
//         ),
//       ),
//     );
//   }
// }

// ============================================================
// DASHBOARD CONTENT
// ============================================================

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bullion Dashboard',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        const Text(
          'Your accumulated digital gold and silver holdings.',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 7),

        // JSC APPLICATION FORM
        _redButton(text: 'Jsc Application Form', onTap: () {}),

        const SizedBox(height: 20),

        // NOMINEE CARD
        const _NomineeCard(),

        const SizedBox(height: 20),

        // UNLOCK BALANCE CARD
        const _UnlockBalanceCard(),

        const SizedBox(height: 20),

        // GOLD / SILVER BALANCES
        const Row(
          children: [
            Expanded(
              child: _BalanceCard(
                title: 'Gold Balance',
                grams: '... grams',
                marketValue: '....market value',
                isGold: true,
                image: "assets/g_balance.png",
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: _BalanceCard(
                title: 'Silver Balance',
                grams: '... oz',
                marketValue: '....market value',
                isGold: false,
                image: "assets/s_balance.png",
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // YOUR PURCHASES
        const _PurchasesCard(),

        const SizedBox(height: 20),

        // CONVERT TO PHYSICAL
        const _ConvertPhysicalCard(),
      ],
    );
  }
}

// ============================================================
// RED BUTTON
// ============================================================

Widget _redButton({required String text, required VoidCallback onTap}) {
  return SizedBox(
    width: double.infinity,
    height: 30,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD20D2D),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

// ============================================================
// NOMINEE CARD
// ============================================================

class _NomineeCard extends StatelessWidget {
  const _NomineeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            'Nominee details missing.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Please add a nominee to your JSC application to secure your holdings.',
            style: TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(168, 136, 22, 1),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 22,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(200, 157, 8, 1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Add Nominee',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// UNLOCK BALANCE
// ============================================================

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

// ============================================================
// BALANCE CARD
// ============================================================

class _BalanceCard extends StatelessWidget {
  final String title;
  final String grams;
  final String marketValue;
  final bool isGold;
  final String image;

  const _BalanceCard({
    required this.title,
    required this.grams,
    required this.marketValue,
    required this.isGold,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isGold
        ? const Color.fromRGBO(232, 190, 46, 1)
        : const Color.fromRGBO(178, 186, 205, 1);

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 248, 230, 1),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(131, 126, 126, 1),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            grams,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 5),

          const Text(
            '.....market value',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(178, 186, 205, 1),
            ),
          ),

          const SizedBox(height: 5),

          Image.asset(image, height: 25, width: 25),
        ],
      ),
    );
  }
}

// ============================================================
// YOUR PURCHASES
// ============================================================

class _PurchasesCard extends StatelessWidget {
  const _PurchasesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF9),
        border: Border.all(color: const Color(0xFFD20D2D), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Purchases',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: const Text(
              "Track each digital purchase against today's market price.",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 8),
          // const Spacer(),
          const Center(
            child: Text(
              'No digital gold or silver purchases yet.',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONVERT TO PHYSICAL
// ============================================================

class _ConvertPhysicalCard extends StatelessWidget {
  const _ConvertPhysicalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF9),
        border: Border.all(color: const Color(0xFFD20D2D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Convert to Physical',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.13),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
            child: const Text(
              'Convert part or all of your digital holdings into physical products. Minimum balance to convert: 50 g of gold or 1 kg of silver.',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ),

          const SizedBox(height: 9),

          // GOLD
          _convertRow(
            metal: 'Gold',
            available: 'Available: .. Min: 50 g',
            buttonText: 'Reach 50 g to unlock physical conversion.',
            enabled: false,
          ),

          const SizedBox(height: 8),

          // SILVER
          _convertRow(
            metal: 'Silver',
            available: 'Available: .. Min: 1 kg',
            buttonText: 'Reach 1 kg to unlock physical conversion.',
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _convertRow({
    required String metal,
    required String available,
    required String buttonText,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metal,
              style: TextStyle(
                fontSize: 10,
                color: metal == 'Gold'
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              available,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(120, 112, 112, 1),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: double.infinity,
          height: 27,
          child: OutlinedButton(
            onPressed: enabled ? () {} : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              backgroundColor: const Color(0xFFFFFBF0),
              side: BorderSide(
                color: metal == 'Gold'
                    ? const Color.fromRGBO(200, 157, 8, 1)
                    : const Color.fromRGBO(149, 152, 154, 1),
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
