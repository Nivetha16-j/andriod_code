import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/jsc/jsc_convert_to_physical_section.dart';
import 'package:provider/provider.dart';

class JscConvertToPhysicalScreen extends StatefulWidget {
  const JscConvertToPhysicalScreen({super.key});

  @override
  State<JscConvertToPhysicalScreen> createState() =>
      _JscConvertToPhysicalScreenState();
}

class _JscConvertToPhysicalScreenState
    extends State<JscConvertToPhysicalScreen> {
  @override
  Widget build(BuildContext context) {
    const int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      body: PlansLayout(
        plans: Plans.jsc,
        selectedMenu: 'Convert To Physical',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscConvertToPhysicalContent(),
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

class JscConvertToPhysicalContent extends StatefulWidget {
  const JscConvertToPhysicalContent({super.key});

  @override
  State<JscConvertToPhysicalContent> createState() =>
      _JscConvertToPhysicalContentState();
}

class _JscConvertToPhysicalContentState
    extends State<JscConvertToPhysicalContent> {
  bool isBalancesUnlocked = false;

  @override
  void initState() {
    super.initState();

    _loadUnlockStatus();
  }

  Future<void> _loadUnlockStatus() async {
    final provider = context.read<JscBalanceProvider>();

    await provider.loadUnlockStatus();

    if (!mounted) return;

    setState(() {
      isBalancesUnlocked = provider.isBalancesUnlocked;
    });
  }

  Future<void> _handleUnlocked() async {
    if (!mounted) return;

    debugPrint('CONVERT TO PHYSICAL -> Wallet unlocked.');

    final provider = context.read<JscBalanceProvider>();

    // Reload the persisted unlock state after successful unlock.
    await provider.loadUnlockStatus();

    if (!mounted) return;

    setState(() {
      isBalancesUnlocked = provider.isBalancesUnlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JscBalanceProvider>();

    final isUnlocked = provider.isBalancesUnlocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Convert To Physical',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Convert your digital gold or silver holdings into physical bullion products.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        // ------------------------------------------------------------
        // JSC BALANCE UNLOCK SECTION
        // ------------------------------------------------------------
        JscBalanceSection(
          showBalances: false,

          /// Called after successful wallet unlock.
          onUnlocked: () async {
            await _handleUnlocked();
          },
        ),

        const SizedBox(height: 20),

        // ------------------------------------------------------------
        // CONVERT TO PHYSICAL
        // ------------------------------------------------------------
        JscConvertPhysicalSection(isUnlocked: isUnlocked),
      ],
    );
  }
}
