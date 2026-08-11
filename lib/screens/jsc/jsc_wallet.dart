import 'package:flutter/material.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class JscWalletScreen extends StatefulWidget {
  const JscWalletScreen({super.key});

  @override
  State<JscWalletScreen> createState() => _JscWalletScreenState();
}

class _JscWalletScreenState extends State<JscWalletScreen> {
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
        selectedMenu: 'My Wallet',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscWallet(),
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

class JscWallet extends StatelessWidget {
  const JscWallet({super.key});

  @override
  Widget build(BuildContext context) {
    const String goldPrice = '\$134.69';
    const String goldUnit = '/ g';

    const String silverPrice = '\$63.14';
    const String silverUnit = '/ oz';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==================================================
        // PAGE TITLE
        // ==================================================
        const Text(
          'My Wallet',
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
          'View your digital gold and silver balances and live market prices.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.25,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        // ==================================================
        // UNLOCK BALANCE
        // ==================================================
        const _UnlockBalanceCard(),

        const SizedBox(height: 25),

        // ==================================================
        // GOLD + SILVER BALANCE
        // ==================================================
        const Row(
          children: [
            Expanded(
              child: _BalanceCard(
                title: 'Gold Balance',
                grams: '... grams',
                marketValue: '.....market value',
                isGold: true,
                image: 'assets/g_balance.png',
              ),
            ),

            SizedBox(width: 5),

            Expanded(
              child: _BalanceCard(
                title: 'Silver Balance',
                grams: '... oz',
                marketValue: '.....market value',
                isGold: false,
                image: 'assets/s_balance.png',
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ==================================================
        // LIVE SPOT PRICES
        // ==================================================
        _LiveSpotPrices(
          goldPrice: goldPrice,
          goldUnit: goldUnit,
          silverPrice: silverPrice,
          silverUnit: silverUnit,
        ),
      ],
    );
  }
}

class _LiveSpotPrices extends StatelessWidget {
  final String goldPrice;
  final String goldUnit;
  final String silverPrice;
  final String silverUnit;

  const _LiveSpotPrices({
    required this.goldPrice,
    required this.goldUnit,
    required this.silverPrice,
    required this.silverUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 10, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9D9),
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 5,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================
          // TITLE + LIVE
          // ============================================
          Row(
            children: [
              const Text(
                'Live Spot Prices',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E2424),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB7BD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFD5162A),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // GOLD
          // ============================================
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6A900),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Gold',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              Text(
                goldPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA52525),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                goldUnit,
                style: const TextStyle(fontSize: 15, color: Color(0xFF9E4A4A)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // DIVIDER
          // ============================================
          Container(height: 1, color: const Color(0xFFE8B9B9)),

          const SizedBox(height: 11),

          // ============================================
          // SILVER
          // ============================================
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFB8C2D0),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'Silver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              Text(
                silverPrice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA52525),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                silverUnit,
                style: const TextStyle(fontSize: 15, color: Color(0xFF9E4A4A)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ============================================
          // DIVIDER
          // ============================================
          Container(height: 1, color: const Color(0xFFE8B9B9)),

          const SizedBox(height: 9),

          // ============================================
          // FOOTER
          // ============================================
          const Text(
            'Updated in real time from the live market.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFAD6262),
            ),
          ),
        ],
      ),
    );
  }
}

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
