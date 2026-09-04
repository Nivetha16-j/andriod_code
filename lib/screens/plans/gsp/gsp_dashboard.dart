import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/gsp_balance_provider.dart';
import 'package:junubullion/providers/gsp_monthly_plan_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/form.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';
import 'package:junubullion/widgets/gsp/gsp_convert_to_physical_section.dart';
import 'package:junubullion/widgets/gsp/gsp_purchase_section.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:provider/provider.dart';

class GspDashboardScreen extends StatefulWidget {
  const GspDashboardScreen({super.key});

  @override
  State<GspDashboardScreen> createState() => _GspDashboardScreenState();
}

class _GspDashboardScreenState extends State<GspDashboardScreen> {
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
        plans: Plans.gsp,
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
  bool hasGspRegistration = false;

  @override
  void initState() {
    super.initState();
    _checkGspRegistration();
  }

  Future<void> _checkGspRegistration() async {
    try {
      final result = await JscService.getApplication(applicationType: 'GSP');

      if (!mounted) return;

      setState(() {
        hasGspRegistration = result["hasRegistration"] == true;
        isLoadingApplication = false;
      });
    } catch (e) {
      debugPrint('Gsp registration check error: $e');

      if (!mounted) return;

      setState(() {
        hasGspRegistration = false;
        isLoadingApplication = false;
      });
    }
  }

  double get minimumInvestment {
    return context
            .read<GspMonthlyPlanProvider>()
            .monthlyPlan
            ?.gspMinimumAmount ??
        0;
  }

  String get currencySymbol {
    return context.read<GspMonthlyPlanProvider>().monthlyPlan?.currencySymbol ??
        '\$';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GSP Dashboard',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        Text(
          'Your Gold Savings Plan digital gold holdings. GSP starts from $currencySymbol${minimumInvestment.toStringAsFixed(2)}. (equivalent to SGD 20).',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 7),

        _buildGspApplicationButton(),

        const SizedBox(height: 20),

        const GspBalanceSection(),

        const SizedBox(height: 20),

        GspPurchasesSection(
          isUnlocked: context.watch<GspBalanceProvider>().isBalancesUnlocked,
        ),

        const SizedBox(height: 20),

        GspConvertPhysicalSection(
          isUnlocked: context.watch<GspBalanceProvider>().isBalancesUnlocked,
        ),
      ],
    );
  }

  Widget _buildGspApplicationButton() {
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

    if (hasGspRegistration) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ApplicationForm(isEdit: true, applicationType: 'GSP'),
              ),
            );
          },
          icon: const Icon(Icons.description_outlined, size: 16),
          label: const Text(
            'View GSP Application',
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
      text: 'Gsp Application Form',
      onTap: () async {
        await _checkGspRegistration();
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
