import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/jsc/jsc_form.dart';
import 'package:junubullion/screens/jsc/jsc_layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/jsc/jsc_convert_to_physical_section.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/widgets/jsc/jsc_purchases_section.dart';

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

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  bool isLoadingApplication = true;
  bool hasJscRegistration = false;
  bool isBalancesUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkJscRegistration();
  }

  Future<void> _checkJscRegistration() async {
    try {
      final result = await JscService.getJscApplication();

      if (!mounted) return;

      setState(() {
        hasJscRegistration = result["hasRegistration"] == true;
        isLoadingApplication = false;
      });
    } catch (e) {
      debugPrint('JSC registration check error: $e');

      if (!mounted) return;

      setState(() {
        hasJscRegistration = false;
        isLoadingApplication = false;
      });
    }
  }

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

        _buildJscApplicationButton(),

        const SizedBox(height: 20),
        const SizedBox(height: 20),

        JscBalanceSection(
          onUnlocked: () {
            if (!mounted) return;

            setState(() {
              isBalancesUnlocked = true;
            });
          },
        ),

        const SizedBox(height: 20),

        JscPurchasesSection(isUnlocked: isBalancesUnlocked),

        const SizedBox(height: 20),

        const JscConvertPhysicalSection(),
      ],
    );
  }

  Widget _buildJscApplicationButton() {
    if (isLoadingApplication) {
      return const SizedBox(
        width: double.infinity,
        height: 30,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (hasJscRegistration) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const JscApplicationForm(isEdit: true),
              ),
            );
          },
          icon: const Icon(Icons.description_outlined, size: 16),
          label: const Text(
            'View JSC Application',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD20D2D),
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      );
    }

    return _redButton(
      text: 'Jsc Application Form',
      onTap: () async {
        await _checkJscRegistration();
      },
    );
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _UnlockBalanceCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onUnlocked;

  const _UnlockBalanceCard({required this.onUnlocked});

  @override
  State<_UnlockBalanceCard> createState() => _UnlockBalanceCardState();
}

class _UnlockBalanceCardState extends State<_UnlockBalanceCard> {
  final TextEditingController controller = TextEditingController();

  bool isUnlocking = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _unlockBalances() async {
    final password = controller.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your unlock password.')),
      );
      return;
    }

    setState(() {
      isUnlocking = true;
    });

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      log("unnnnnnn ${currencyProvider.selectedCurrency}.......$password");

      final result = await JscService.unlockWallet(
        unlockPassword: password,
        currency: currencyProvider.selectedCurrency,
      );

      if (!mounted) return;

      if (result['status'] == true) {
        final data = result['data'] as Map<String, dynamic>? ?? {};

        // Send balance data to parent
        widget.onUnlocked(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Balances unlocked successfully.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ?? 'Unable to unlock balances.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Unlock balances error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to unlock balances: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isUnlocking = false;
        });
      }
    }
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
              obscureText: true,
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
              onPressed: isUnlocking ? null : _unlockBalances,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD20D2D),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: isUnlocking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Unlock Balances',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

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
