import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

class JscTransactionHistoryScreen extends StatefulWidget {
  final bool? isUnlocked;

  const JscTransactionHistoryScreen({super.key, this.isUnlocked});

  @override
  State<JscTransactionHistoryScreen> createState() =>
      _JscTransactionHistoryScreenState();
}

class _JscTransactionHistoryScreenState
    extends State<JscTransactionHistoryScreen> {
  int currentIndex = 0;
  bool _isUnlocked = false;
  Timer? _timer;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPage = 1;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    initializeTransactionHistory();
  }

  @override
  void dispose() {
    _stopTransactionRefresh();
    super.dispose();
  }

  Future<void> initializeTransactionHistory() async {
    if (widget.isUnlocked != null) {
      _isUnlocked = widget.isUnlocked!;

      if (_isUnlocked) {
        _fetchTransactions();
      } else {
        setState(() {
          isLoading = false;
          transactions = [];
        });
      }

      if (mounted) {
        setState(() {});
      }

      return;
    }

    try {
      final unlocked = await SessionManager.isJscBalanceUnlocked();

      if (!mounted) return;

      setState(() {
        _isUnlocked = unlocked;
      });

      if (unlocked) {
        await _fetchTransactions();
      }
    } catch (e) {
      log('Transaction unlock status error: $e');
    }
  }

  @override
  void didUpdateWidget(covariant JscTransactionHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isUnlocked != null &&
        oldWidget.isUnlocked != widget.isUnlocked) {
      _isUnlocked = widget.isUnlocked!;

      if (_isUnlocked) {
        _fetchTransactions();
      } else {
        setState(() {
          isLoading = false;
          transactions = [];
        });
      }
    }
  }

  void _stopTransactionRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  bool isLoading = true;

  List<Map<String, dynamic>> transactions = [];

  String? errorMessage;

  String currency = 'USD';

  String currencySymbol = '\$';

  Future<void> _fetchTransactions() async {
    if (!_isUnlocked) {
      if (mounted) {
        setState(() {
          isLoading = false;
          transactions = [];
        });
      }
      return;
    }

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

        List<Map<String, dynamic>> parsedTransactions = [];

        // API response:
        // data: {
        //   currency: USD,
        //   transactions: [...]
        // }
        if (data is Map) {
          final transactionList = data['transactions'];

          if (transactionList is List) {
            parsedTransactions = transactionList
                .whereType<Map>()
                .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item),
                )
                .toList();
          }

          // Use currency returned by API if available
          final responseCurrency = data['currency']?.toString();

          if (responseCurrency != null && responseCurrency.isNotEmpty) {
            currency = responseCurrency;
            currencySymbol = _getCurrencySymbol(currency);
          }
        }

        setState(() {
          transactions = parsedTransactions;
          currentPage = 1;
          isLoading = false;
        });

        log('Parsed JSC transactions: $transactions');
      } else {
        setState(() {
          transactions = [];
          currentPage = 1;
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
        currentPage = 1;
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

  List<Map<String, dynamic>> get paginatedTransactions {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, transactions.length);

    return transactions.sublist(start, end);
  }

  int get totalPages {
    if (transactions.isEmpty) return 1;
    return (transactions.length / itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      // padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 15),

          // const TranslatedText(
          //   'Transaction History',
          //   style: TextStyle(
          //     fontSize: 13,
          //     fontWeight: FontWeight.w500,
          //     color: Colors.black,
          //   ),
          // ),

          // const SizedBox(height: 12),
          if (!_isUnlocked)
            _buildLockedState()
          else if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryRed,
                ),
              ),
            )
          else if (errorMessage != null)
            _buildErrorState()
          else if (transactions.isEmpty)
            _buildEmptyState()
          else ...[
            _buildTransactionTable(),
            const SizedBox(height: 16),
            _buildPagination(),
          ],
        ],
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

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 700,

          // decoration: BoxDecoration(
          //   color: const Color(0xFFFFFEF9),

          //   // border: Border.all(color: const Color(0xFFE6E0D2), width: 0.7),
          // ),
          child: Column(
            children: [
              Container(
                width: 700,

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),

                // color: const Color(0xFFF7F7F5),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 85,
                      child: TranslatedText('DATE', style: _headerStyle),
                    ),
                    SizedBox(
                      width: 85,
                      child: TranslatedText('PLAN', style: _headerStyle),
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

              Divider(height: 0, color: AppColors.grey),

              ...paginatedTransactions.map((transaction) {
                log('transactionsssss $transaction');

                return _TransactionRow(
                  transaction: transaction,
                  currencySymbol: currencySymbol,
                );
              }),
              // const SizedBox(height: 10),

              // _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),

        Text(
          'Page $currentPage of $totalPages',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        IconButton(
          onPressed: currentPage < totalPages
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildLockedState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: TranslatedText(
          'Unlock balance to view transaction history.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
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

    final plan =
        transaction['plan']?.toString() ??
        transaction['purchase_subtype']?.toString() ??
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

    final isSellBack = transactionType == 'sell_back';

    return Container(
      width: 700,

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

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
          SizedBox(
            width: 45,

            child: TranslatedText(
              plan,

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
