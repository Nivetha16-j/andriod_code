import 'dart:async';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:provider/provider.dart';

class JscWalletScreen extends StatefulWidget {
  const JscWalletScreen({super.key});

  @override
  State<JscWalletScreen> createState() => _JscWalletScreenState();
}

class _JscWalletScreenState extends State<JscWalletScreen> {
  @override
  Widget build(BuildContext context) {
    const int currentIndex = 0;

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

class JscWallet extends StatefulWidget {
  const JscWallet({super.key});

  @override
  State<JscWallet> createState() => _JscWalletState();
}

class _JscWalletState extends State<JscWallet> {
  Timer? _walletTimer;

  bool isLoading = true;

  String goldPrice = '...';
  String goldUnit = 'g';

  String silverPrice = '...';
  String silverUnit = 'g';

  String currencySymbol = '\$';

  @override
  void initState() {
    super.initState();

    _fetchWallet();

    // Refresh live spot prices every 10 seconds.
    _walletTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchWallet();
    });
  }

  @override
  void dispose() {
    _walletTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchWallet() async {
    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      final result = await JscService.fetchWallet(currency: currency);

      if (!mounted) return;

      if (result['status'] == true) {
        final data = result['data'] as Map<String, dynamic>? ?? {};

        final summary = data['summary'] as Map<String, dynamic>? ?? {};

        final symbol = summary['symbol']?.toString() ?? '\$';

        final metals = summary['metals'] as Map<String, dynamic>? ?? {};

        final gold =
            (metals['gold'] ?? summary['gold']) as Map<String, dynamic>? ?? {};

        final silver =
            (metals['silver'] ?? summary['silver']) as Map<String, dynamic>? ??
            {};

        setState(() {
          currencySymbol = symbol;

          goldPrice = _formatPrice(gold['spot_price']);
          goldUnit =
              gold['unit_short']?.toString() ?? gold['unit']?.toString() ?? 'g';

          silverPrice = _formatPrice(silver['spot_price']);
          silverUnit =
              silver['unit_short']?.toString() ??
              silver['unit']?.toString() ??
              'g';

          isLoading = false;
        });
      } else {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('JSC Wallet API error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatPrice(dynamic value) {
    if (value == null) {
      return '...';
    }

    final number = double.tryParse(value.toString());

    if (number == null) {
      return '...';
    }

    return number.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Wallet',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 14),

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

        const JscBalanceSection(),

        const SizedBox(height: 20),

        _LiveSpotPrices(
          goldPrice: goldPrice,
          goldUnit: goldUnit,
          silverPrice: silverPrice,
          silverUnit: silverUnit,
          currencySymbol: currencySymbol,
          isLoading: isLoading,
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

  final String currencySymbol;

  final bool isLoading;

  const _LiveSpotPrices({
    required this.goldPrice,
    required this.goldUnit,
    required this.silverPrice,
    required this.silverUnit,
    required this.currencySymbol,
    required this.isLoading,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 6,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0xFFD5162A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    SizedBox(width: 5),

                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD5162A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // GOLD
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
                isLoading ? '...' : '$currencySymbol$goldPrice',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA52525),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '/ $goldUnit',
                style: const TextStyle(fontSize: 15, color: Color(0xFF9E4A4A)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(height: 1, color: const Color(0xFFE8B9B9)),

          const SizedBox(height: 11),

          // SILVER
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
                isLoading ? '...' : '$currencySymbol$silverPrice',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA52525),
                ),
              ),

              const SizedBox(width: 5),

              Text(
                '/ $silverUnit',
                style: const TextStyle(fontSize: 15, color: Color(0xFF9E4A4A)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(height: 1, color: const Color(0xFFE8B9B9)),

          const SizedBox(height: 9),

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
