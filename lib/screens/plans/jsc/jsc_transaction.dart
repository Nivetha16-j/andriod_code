import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class JscTransactionHistoryScreen extends StatefulWidget {
  const JscTransactionHistoryScreen({super.key});

  @override
  State<JscTransactionHistoryScreen> createState() =>
      _JscTransactionHistoryScreenState();
}

class _JscTransactionHistoryScreenState
    extends State<JscTransactionHistoryScreen> {
  int currentIndex = 0;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,

      drawer: const CustomDrawer(),

      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      body: PlansLayout(
        plans: Plans.jsc,
        selectedMenu: 'Transaction History',
        child: const JscTransactionHistoryContent(),
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

class JscTransactionHistoryContent extends StatefulWidget {
  const JscTransactionHistoryContent({super.key});

  @override
  State<JscTransactionHistoryContent> createState() =>
      _JscTransactionHistoryContentState();
}

class _JscTransactionHistoryContentState
    extends State<JscTransactionHistoryContent> {
  bool isLoading = true;

  List<Map<String, dynamic>> transactions = [];

  String? errorMessage;

  String currency = 'USD';

  String currencySymbol = '\$';

  @override
  void initState() {
    super.initState();

    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      currency = currencyProvider.selectedCurrency;

      currencySymbol = _getCurrencySymbol(currency);

      log('Fetching transactions with currency: $currency');

      final result = await JscService.getTransactions(currency: currency);

      log('Transaction History Response: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        final data = result['data'];

        setState(() {
          transactions = data is List
              ? data
                    .map<Map<String, dynamic>>(
                      (item) => Map<String, dynamic>.from(item),
                    )
                    .toList()
              : [];

          isLoading = false;
        });
      } else {
        setState(() {
          transactions = [];

          errorMessage =
              result['message']?.toString() ?? 'Unable to fetch transactions.';

          isLoading = false;
        });
      }
    } catch (e) {
      log('Transaction history error: $e');

      if (!mounted) return;

      setState(() {
        transactions = [];

        errorMessage = 'Unable to load transaction history.';

        isLoading = false;
      });
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';

      case 'SGD':
        return 'S\$';

      case 'INR':
        return '₹';

      case 'EUR':
        return '€';

      case 'GBP':
        return '£';

      case 'AUD':
        return 'A\$';

      case 'CAD':
        return 'C\$';

      case 'AED':
        return 'د.إ';

      case 'JPY':
        return '¥';

      case 'CNY':
        return '¥';

      default:
        return currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchTransactions,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Review purchases, conversions, and sell back activity on your JSC wallet.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Transaction History',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (errorMessage != null)
              _buildErrorState()
            else if (transactions.isEmpty)
              _buildEmptyState()
            else
              _buildTransactionTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: _fetchTransactions,
              child: const Text('Retry', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'No wallet transactions yet. Buy digital gold or silver to start building your holdings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: Container(
        width: 560,

        decoration: BoxDecoration(
          color: const Color(0xFFFFFEF9),

          border: Border.all(color: const Color(0xFFE6E0D2), width: 0.7),
        ),

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              color: const Color(0xFFF7F7F5),

              child: const Row(
                children: [
                  SizedBox(width: 85, child: Text('DATE', style: _headerStyle)),

                  SizedBox(
                    width: 75,
                    child: Text('METAL', style: _headerStyle),
                  ),

                  SizedBox(
                    width: 150,
                    child: Text('DESCRIPTION', style: _headerStyle),
                  ),

                  SizedBox(
                    width: 100,
                    child: Text(
                      'AMOUNT',
                      textAlign: TextAlign.right,
                      style: _headerStyle,
                    ),
                  ),

                  SizedBox(
                    width: 100,
                    child: Text(
                      'VALUE',
                      textAlign: TextAlign.right,
                      style: _headerStyle,
                    ),
                  ),
                ],
              ),
            ),

            ...transactions.map((transaction) {
              return _TransactionRow(
                transaction: transaction,
                currencySymbol: currencySymbol,
              );
            }),
          ],
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 8,
  fontWeight: FontWeight.w600,
  color: Color(0xFF777777),
);

class _TransactionRow extends StatelessWidget {
  final Map<String, dynamic> transaction;

  final String currencySymbol;

  const _TransactionRow({
    required this.transaction,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final metal =
        transaction['metal_type']?.toString().toLowerCase() ??
        transaction['metal']?.toString().toLowerCase() ??
        '';

    final unit =
        transaction['unit']?.toString() ??
        transaction['unit_short']?.toString() ??
        '';

    final amount =
        transaction['amount']?.toString() ??
        transaction['quantity']?.toString() ??
        '0';

    final value =
        transaction['value']?.toString() ??
        transaction['amount_value']?.toString() ??
        transaction['purchase_price']?.toString() ??
        '0';

    final description =
        transaction['description']?.toString() ??
        transaction['product_name']?.toString() ??
        '';

    final createdAt =
        transaction['created_at']?.toString() ??
        transaction['date']?.toString() ??
        '';

    final date = _formatDate(createdAt);

    final isGold = metal == 'gold';

    return Container(
      width: 560,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 0.7)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          SizedBox(
            width: 85,

            child: Text(
              date,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ),
          SizedBox(
            width: 75,

            child: Align(
              alignment: Alignment.centerLeft,

              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),

                decoration: BoxDecoration(
                  color: isGold
                      ? const Color(0xFFFFF1C9)
                      : const Color(0xFFEDEFF2),

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  _capitalize(metal),

                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,

                    color: isGold
                        ? const Color(0xFF9A7400)
                        : const Color(0xFF62666B),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            width: 150,

            child: Text(
              description,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: Color(0xFF222222),
              ),
            ),
          ),

          SizedBox(
            width: 100,

            child: Text(
              '+$amount $unit',

              textAlign: TextAlign.right,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ),

          SizedBox(
            width: 100,

            child: Text(
              _formatValue(value),

              textAlign: TextAlign.right,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
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

      return '${months[date.month - 1]} '
          '${date.day}, '
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _formatValue(String value) {
    if (value.isEmpty) {
      return '';
    }

    // Avoid adding another symbol if backend
    // already returned one.
    if (value.startsWith('\$') ||
        value.startsWith('₹') ||
        value.startsWith('€') ||
        value.startsWith('£') ||
        value.startsWith('S\$') ||
        value.startsWith('A\$') ||
        value.startsWith('C\$')) {
      return value;
    }

    return '$currencySymbol$value';
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return '';
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
