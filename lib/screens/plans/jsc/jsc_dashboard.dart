import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/screens/plans/form.dart';
import 'package:junubullion/screens/plans/jsc/jsc_transaction.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:junubullion/widgets/jsc/jsc_convert_to_physical_section.dart';
import 'package:junubullion/widgets/jsc/jsc_purchases_section.dart';
import 'package:junubullion/widgets/jsc/jsc_transaction_section.dart';
import 'package:junubullion/widgets/jsc/quick_actions.dart';
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

      body: SingleChildScrollView(
        // padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
        child: const _DashboardContent(),
      ),

      // PlansLayout(
      //   plans: Plans.jsc,
      //   selectedMenu: 'Dashboard',
      //   child: SingleChildScrollView(
      //     padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
      //     child: const _DashboardContent(),
      //   ),
      // ),
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
      final result = await JscService.getApplication(applicationType: 'JSC');

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(gradient: AppColors.BgGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(
                'Bullion Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),

              const TranslatedText(
                'Manage your digital gold and silver holdings across JSC Bullion and GSP Savings plans.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),

        // const SizedBox(height: 7),

        // _buildJscApplicationButton(),
        const SizedBox(height: 10),

        const JscBalanceSection(),

        const SizedBox(height: 10),

        QuickActions(),

        const SizedBox(height: 10),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const TranslatedText(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            // const SizedBox(height: 6),
            JscTransactionHistoryScreen(
              isUnlocked: context
                  .watch<JscBalanceProvider>()
                  .isBalancesUnlocked,
            ),
          ],
        ),
        // JscPurchasesSection(
        //   isUnlocked: context.watch<JscBalanceProvider>().isBalancesUnlocked,
        // ),

        // const SizedBox(height: 20),

        // JscConvertPhysicalSection(
        //   isUnlocked: context.watch<JscBalanceProvider>().isBalancesUnlocked,
        // ),
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
                builder: (_) => const ApplicationForm(isEdit: true),
              ),
            );
          },
          icon: const Icon(Icons.description_outlined, size: 16),
          label: const TranslatedText(
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
      text: 'JSC Application Form',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ApplicationForm(isEdit: false),
          ),
        );
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
        child: TranslatedText(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
