import 'package:flutter/material.dart';
import 'package:junubullion/providers/gsp_monthly_plan_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:provider/provider.dart';

class GspInvestmentList extends StatefulWidget {
  const GspInvestmentList({super.key});

  @override
  State<GspInvestmentList> createState() => _GspInvestmentListState();
}

class _GspInvestmentListState extends State<GspInvestmentList> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<GspMonthlyPlanProvider>().getGspMonthlyPlan(
        currency: 'USD',
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
        child: const GspInvestmentListContent(),
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

class GspInvestmentListContent extends StatefulWidget {
  const GspInvestmentListContent({super.key});

  @override
  State<GspInvestmentListContent> createState() =>
      _GspInvestmentListContentState();
}

class _GspInvestmentListContentState extends State<GspInvestmentListContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(gradient: AppColors.BgGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'GSP Investments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),

          const TranslatedText(
            'Build your GSP gold savings with investment. Payments are not mandatory, but help you grow your holdings over time.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 24),
          _buildInvestmentTable(),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String date,
    required String plan,
    required String description,
    required String amount,
    required String value,
    bool isHeader = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCell(date, flex: 2, isHeader: isHeader),
        _buildCell(plan, flex: 2, isHeader: isHeader),
        _buildCell(description, flex: 3, isHeader: isHeader),
        _buildCell(amount, flex: 2, isHeader: isHeader),
        _buildCell(
          value,
          flex: 2,
          isHeader: isHeader,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildCell(
    String text, {
    required int flex,
    bool isHeader = false,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: TranslatedText(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: isHeader ? 12 : 10,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  String _formatInvestmentDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[parsedDate.month - 1]} '
          '${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Widget _buildInvestmentTable() {
    return Consumer<GspMonthlyPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isInvestmentsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          );
        }

        if (provider.investmentsErrorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TranslatedText(
                provider.investmentsErrorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.gspInvestments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: TranslatedText(
                'No GSP investments found.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildTableRow(
                date: 'Date',
                plan: 'Plan',
                description: 'Description',
                amount: 'Amount',
                value: 'Value',
                isHeader: true,
              ),
              const Divider(color: Colors.black26),

              ...provider.gspInvestments.map((investment) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _buildTableRow(
                    date: _formatInvestmentDate(investment.investmentDate),
                    plan: investment.source,
                    description: investment.description,
                    amount: '${investment.amount} ${investment.unit}',
                    value: '₹${investment.value}',
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
