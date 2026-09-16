import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
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

      log('Fetching JSC transactions with currency: $currency');

      final result = await JscService.getTransactions(currency: currency);

      log('JSC Transaction History Response: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        final data = result['data'];

        setState(() {
          transactions = data is List
              ? data
                    .whereType<Map>()
                    .map<Map<String, dynamic>>(
                      (item) => Map<String, dynamic>.from(item),
                    )
                    .toList()
              : [];

          isLoading = false;
        });

        log('Parsed JSC transactions: $transactions');
      } else {
        setState(() {
          transactions = [];

          errorMessage =
              result['message']?.toString() ?? 'Unable to fetch transactions.';

          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      log('JSC transaction history error: $e', stackTrace: stackTrace);

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
            const TranslatedText(
              'Transaction History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 14),

            const TranslatedText(
              'Review purchases, conversions, and sell back activity on your JSC wallet.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 25),

            const TranslatedText(
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
            TranslatedText(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: _fetchTransactions,
              child: const TranslatedText(
                'Retry',
                style: TextStyle(fontSize: 11),
              ),
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
        child: TranslatedText(
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
                  SizedBox(
                    width: 85,
                    child: TranslatedText('DATE', style: _headerStyle),
                  ),

                  SizedBox(
                    width: 75,
                    child: TranslatedText('METAL', style: _headerStyle),
                  ),

                  SizedBox(
                    width: 150,
                    child: TranslatedText('DESCRIPTION', style: _headerStyle),
                  ),

                  SizedBox(
                    width: 100,
                    child: TranslatedText(
                      'AMOUNT',
                      textAlign: TextAlign.right,
                      style: _headerStyle,
                    ),
                  ),

                  SizedBox(
                    width: 100,
                    child: TranslatedText(
                      'VALUE',
                      textAlign: TextAlign.right,
                      style: _headerStyle,
                    ),
                  ),
                ],
              ),
            ),

            ...transactions.map((transaction) {
              log('transactionsssss $transaction');

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
        transaction['unit_short']?.toString() ??
        transaction['unit']?.toString() ??
        '';

    final amount = _formatAmount(
      transaction['amount'] ?? transaction['quantity'] ?? 0,
    );

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

    final transactionType =
        transaction['type']?.toString().toLowerCase() ?? 'credit';

    final isCredit = transactionType == 'credit';

    // JSC sell-back transactions use:
    // type: sell_back
    final isSellBack = transactionType == 'sell_back';

    return Container(
      width: 560,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8), width: 0.7)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          // =========================
          // DATE
          // =========================
          SizedBox(
            width: 85,

            child: TranslatedText(
              date,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ),

          // =========================
          // METAL + SELL BACK
          // =========================
          SizedBox(
            width: 75,

            child: Align(
              alignment: Alignment.centerLeft,

              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // METAL BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: isGold
                          ? const Color(0xFFFFF1C9)
                          : const Color(0xFFEDEFF2),

                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: TranslatedText(
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

                  // SELL BACK BADGE
                  if (isSellBack) ...[
                    const SizedBox(height: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE1E6),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const TranslatedText(
                        'Sell Back',

                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB3261E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // =========================
          // DESCRIPTION
          // =========================
          SizedBox(
            width: 150,

            child: TranslatedText(
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

          // =========================
          // AMOUNT
          // =========================
          SizedBox(
            width: 100,

            child: TranslatedText(
              '${isCredit ? '+' : '-'}$amount $unit',

              textAlign: TextAlign.right,

              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
          ),

          // =========================
          // VALUE
          // =========================
          SizedBox(
            width: 100,

            child: TranslatedText(
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

  // =========================
  // AMOUNT FORMAT
  // =========================
  static String _formatAmount(dynamic value) {
    final number = double.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');
  }

  // =========================
  // DATE FORMAT
  // =========================
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

  // =========================
  // VALUE FORMAT
  // =========================
  String _formatValue(String value) {
    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('\$') ||
        value.startsWith('₹') ||
        value.startsWith('€') ||
        value.startsWith('£') ||
        value.startsWith('S\$') ||
        value.startsWith('A\$') ||
        value.startsWith('C\$') ||
        value.startsWith('د.إ') ||
        value.startsWith('¥')) {
      return value;
    }

    final number = double.tryParse(value);

    if (number != null) {
      return '$currencySymbol${number.toStringAsFixed(2)}';
    }

    return '$currencySymbol$value';
  }

  // =========================
  // CAPITALIZE
  // =========================
  static String _capitalize(String value) {
    if (value.isEmpty) {
      return '';
    }

    return value[0].toUpperCase() + value.substring(1);
  }
}
