import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/screens/plans/jsc/jsc_form.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/jsc/jsc_convert_to_physical_section.dart';
import 'package:junubullion/widgets/jsc/jsc_purchases_section.dart';
import 'package:provider/provider.dart';

class JscDashboardScreen extends StatefulWidget {
  const JscDashboardScreen({super.key});

  @override
  State<JscDashboardScreen> createState() => _JscDashboardScreenState();
}

class _JscDashboardScreenState extends State<JscDashboardScreen> {
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
    // This is now the SINGLE source of truth.
    final isBalancesUnlocked = context
        .watch<JscBalanceProvider>()
        .isBalancesUnlocked;

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

        const JscBalanceSection(),

        const SizedBox(height: 20),

        JscPurchasesSection(
          isUnlocked: context.watch<JscBalanceProvider>().isBalancesUnlocked,
        ),

        const SizedBox(height: 20),

        JscConvertPhysicalSection(
          isUnlocked: context.watch<JscBalanceProvider>().isBalancesUnlocked,
        ),
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
                builder: (_) => const JscApplicationForm(
                  isEdit: true,
                  applicationType: 'JSC',
                ),
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
