import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/jsc_balance_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:junubullion/widgets/jsc/custom_sellbackdialog.dart';
import 'package:junubullion/widgets/jsc/jsc_balance_section.dart';
import 'package:provider/provider.dart';

class JscSellBackScreen extends StatefulWidget {
  const JscSellBackScreen({super.key});

  @override
  State<JscSellBackScreen> createState() => _JscSellBackScreenState();
}

class _JscSellBackScreenState extends State<JscSellBackScreen> {
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
        selectedMenu: 'Sell Back Request',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const JscSellBackContent(),
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

class JscSellBackContent extends StatefulWidget {
  const JscSellBackContent({super.key});

  @override
  State<JscSellBackContent> createState() => _JscSellBackContentState();
}

class _JscSellBackContentState extends State<JscSellBackContent> {
  bool isLoadingSellBack = false;

  Map<String, dynamic>? sellBackData;

  bool isBalancesUnlocked = false;

  @override
  void initState() {
    super.initState();

    _checkUnlockStatus();
  }

  /// ------------------------------------------------------------
  /// CHECK CURRENT SESSION UNLOCK STATUS
  /// ------------------------------------------------------------
  Future<void> _checkUnlockStatus() async {
    final provider = context.read<JscBalanceProvider>();

    await provider.loadUnlockStatus();

    if (!mounted) return;

    final unlocked = provider.isBalancesUnlocked;

    setState(() {
      isBalancesUnlocked = unlocked;
    });

    if (unlocked) {
      await _fetchSellBackDetails();
    }
  }

  /// ------------------------------------------------------------
  /// FETCH SELL BACK DETAILS
  /// ------------------------------------------------------------
  Future<void> _fetchSellBackDetails() async {
    if (!mounted) return;

    // Always verify session unlock state before making the request.
    final unlocked = await SessionManager.isBalanceUnlocked();

    if (!mounted) return;

    if (!unlocked) {
      setState(() {
        isBalancesUnlocked = false;
        sellBackData = null;
        isLoadingSellBack = false;
      });

      debugPrint('SELL BACK -> Fetch cancelled because balances are locked.');

      return;
    }

    setState(() {
      isLoadingSellBack = true;
    });

    try {
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final currency = currencyProvider.selectedCurrency;

      debugPrint('SELL BACK -> Fetching details with currency: $currency');

      final result = await JscService.getSellBackDetails(currency: currency);

      debugPrint('SELL BACK -> API RESULT: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        final dynamic data = result['data'];

        final Map<String, dynamic> parsedData = data is Map<String, dynamic>
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};

        // Verify unlock state again before storing data.
        final stillUnlocked = await SessionManager.isBalanceUnlocked();

        if (!mounted) return;

        if (!stillUnlocked) {
          setState(() {
            isBalancesUnlocked = false;
            sellBackData = null;
          });

          debugPrint('SELL BACK -> Session became locked. Data discarded.');

          return;
        }

        setState(() {
          isBalancesUnlocked = true;
          sellBackData = parsedData;
        });

        debugPrint('SELL BACK -> Screen refreshed successfully.');

        debugPrint(
          'SELL BACK -> New GOLD: '
          '${sellBackData?['gold']?['balance']}',
        );

        debugPrint(
          'SELL BACK -> New SILVER: '
          '${sellBackData?['silver']?['balance']}',
        );
      } else {
        setState(() {
          sellBackData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Unable to fetch sell back details.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('SELL BACK -> API error: $e');

      if (!mounted) return;

      // Do not keep stale data after an API/session error.
      setState(() {
        sellBackData = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh sell back details.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSellBack = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sell Back Request',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 14),

        const Text(
          'Sell your digital holdings and track bank transfer payouts.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.25,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 25),

        JscBalanceSection(
          showBalances: false,

          /// Called after successful wallet unlock.
          onUnlocked: () async {
            if (!mounted) return;

            debugPrint('SELL BACK -> Wallet unlocked.');

            setState(() {
              isBalancesUnlocked = true;
              sellBackData = null;
            });

            // Fetch latest balances and sell-back requests.
            await _fetchSellBackDetails();
          },
        ),

        const SizedBox(height: 20),

        _buildSellBackCard(),
      ],
    );
  }

  /// ------------------------------------------------------------
  /// SELL BACK CARD
  /// ------------------------------------------------------------
  Widget _buildSellBackCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFF202E), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sell Back for Cash',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E2828),
            ),
          ),

          const SizedBox(height: 4),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 17, 10, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E7),
              border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Sell your digital holdings back to Junu Bullion at the live spot price. Enter your bank details and confirm the amount — we will transfer the payout to your account.',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (isLoadingSellBack)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (!isBalancesUnlocked)
            _buildLockedMessage()
          else if (sellBackData != null)
            _buildSellBackDetails()
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// LOCKED MESSAGE
  /// ------------------------------------------------------------
  Widget _buildLockedMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 17, 10, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Unlock your balances to sell back holdings.',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: Colors.black,
        ),
      ),
    );
  }

  /// ------------------------------------------------------------
  /// SELL BACK DETAILS
  /// ------------------------------------------------------------
  Widget _buildSellBackDetails() {
    final gold = sellBackData?['gold'] as Map<String, dynamic>? ?? {};

    final silver = sellBackData?['silver'] as Map<String, dynamic>? ?? {};

    final goldBalance = gold['balance']?.toString() ?? '0.0000';

    final goldUnit = gold['unit']?.toString() ?? 'gram';

    final goldMarketRate = gold['market_rate']?.toString() ?? '0';

    final silverBalance = silver['balance']?.toString() ?? '0.0000';

    final silverUnit = silver['unit']?.toString() ?? 'gram';

    final silverMarketRate = silver['market_rate']?.toString() ?? '0';

    final currency = sellBackData?['currency']?.toString() ?? '';

    final currencySymbol = _currencySymbol(currency);

    final List<dynamic> sellBacks =
        sellBackData?['sell_backs'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSellBackMetalRow(
          metal: 'Gold',
          balance: goldBalance,
          unit: goldUnit,
          spotPrice: '$currencySymbol$goldMarketRate',
          enabled: _canSellGold(goldBalance, goldUnit),
        ),

        const SizedBox(height: 8),

        _buildSellBackMetalRow(
          metal: 'Silver',
          balance: silverBalance,
          unit: silverUnit,
          spotPrice: '$currencySymbol$silverMarketRate',
          enabled: _canSellSilver(silverBalance, silverUnit),
        ),

        const SizedBox(height: 12),

        _buildMinimumBalanceMessage(
          goldBalance: goldBalance,
          goldUnit: goldUnit,
          silverBalance: silverBalance,
          silverUnit: silverUnit,
        ),

        if (sellBacks.isNotEmpty) ...[
          const SizedBox(height: 25),
          _buildSellBackRequestsTable(sellBacks),
        ],
      ],
    );
  }

  /// ------------------------------------------------------------
  /// GOLD / SILVER ROW
  /// ------------------------------------------------------------
  Widget _buildSellBackMetalRow({
    required String metal,
    required String balance,
    required String unit,
    required String spotPrice,
    required bool enabled,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metal,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    'Available: $balance $unit',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF807878),
                    ),
                  ),

                  Text(
                    'Spot: $spotPrice / $unit',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF807878),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              width: 100,
              height: 35,
              child: ElevatedButton(
                onPressed: enabled
                    ? () async {
                        final bool? submitted = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) {
                            return SellBackDialog(
                              metal: metal,
                              balance: balance,
                              unit: unit,
                              spotPrice: spotPrice,
                            );
                          },
                        );

                        if (!mounted) return;

                        if (submitted == true) {
                          debugPrint(
                            'SELL BACK -> '
                            'Request submitted successfully.',
                          );

                          await _fetchSellBackDetails();

                          if (!mounted) return;

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sell Back request submitted successfully.',
                                ),
                              ),
                            );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD20D2D),
                  disabledBackgroundColor: const Color(0xFFC9C9C9),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sell Back',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(height: 1, color: const Color(0xFFE8E3E3)),
      ],
    );
  }

  /// ------------------------------------------------------------
  /// SELL BACK REQUEST TABLE
  /// ------------------------------------------------------------
  Widget _buildSellBackRequestsTable(List<dynamic> sellBacks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sell Back Requests',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Track the status of your sell back and bank transfer requests.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(145),
                1: FixedColumnWidth(80),
                2: FixedColumnWidth(90),
                3: FixedColumnWidth(90),
                4: FixedColumnWidth(90),
                5: FixedColumnWidth(210),
                6: FixedColumnWidth(90),
              },
              border: const TableBorder(
                horizontalInside: BorderSide(
                  color: Color(0xFFE8E3E3),
                  width: 1,
                ),
                bottom: BorderSide(color: Color(0xFFE8E3E3), width: 1),
              ),
              children: [
                TableRow(
                  children: [
                    _buildTableHeader('REFERENCE'),
                    _buildTableHeader('METAL'),
                    _buildTableHeader('QUANTITY'),
                    _buildTableHeader('PAYOUT'),
                    _buildTableHeader('STATUS'),
                    _buildTableHeader('EXPECTED TRANSFER'),
                    _buildTableHeader('DATE'),
                  ],
                ),

                ...sellBacks.map((item) {
                  final sellBack = item as Map<String, dynamic>;

                  return TableRow(
                    children: [
                      _buildReferenceCell(
                        sellBack['reference_number']?.toString() ?? '-',
                      ),

                      _buildTableCell(
                        _capitalize(sellBack['metal_type']?.toString() ?? '-'),
                      ),

                      _buildTableCell(
                        '${sellBack['amount']?.toString() ?? '0'} '
                        '${_getSellBackUnit(sellBack)}',
                      ),

                      _buildTableCell(
                        '${_currencySymbol(sellBack['currency']?.toString() ?? '')}'
                        '${sellBack['payout_value']?.toString() ?? '0'}',
                      ),

                      _buildStatusCell(sellBack['status']?.toString() ?? ''),

                      _buildExpectedTransferCell(
                        sellBack['status']?.toString() ?? '',
                      ),

                      _buildDateCell(sellBack['created_at']?.toString()),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFF807878),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildReferenceCell(String reference) {
    final parts = reference.split('-');

    String firstLine = reference;
    String? secondLine;

    if (parts.length >= 3) {
      firstLine = '${parts[0]}-${parts[1]}';
      secondLine = parts.sublist(2).join('-');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstLine,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),

          if (secondLine != null)
            Text(
              secondLine,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    final normalizedStatus = status.toLowerCase();

    Color backgroundColor;
    Color textColor;

    switch (normalizedStatus) {
      case 'approved':
      case 'paid':
        backgroundColor = const Color(0xFFE8F7E8);
        textColor = const Color(0xFF2E7D32);
        break;

      case 'rejected':
        backgroundColor = const Color(0xFFFFE8E8);
        textColor = const Color(0xFFC62828);
        break;

      case 'pending':
      default:
        backgroundColor = const Color(0xFFFFF3D9);
        textColor = const Color(0xFFE58A00);
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _capitalize(status),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildExpectedTransferCell(String status) {
    String text;

    switch (status.toLowerCase()) {
      case 'paid':
        text = 'Payment has been credited to your bank account.';
        break;

      case 'rejected':
        text = 'Your sell back request has been rejected.';
        break;

      case 'approved':
      case 'pending':
      default:
        text =
            'Payment will be credited to your bank account within up to 24 hours.';
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          height: 1.3,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDateCell(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return _buildTableCell('-');
    }

    try {
      final date = DateTime.parse(dateString).toLocal();

      final month = _monthName(date.month);

      final formattedDate = '$month ${date.day}, ${date.year}';

      return Container(
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 14),
        alignment: Alignment.centerLeft,
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      );
    } catch (e) {
      return _buildTableCell(dateString);
    }
  }

  String _getSellBackUnit(Map<String, dynamic> sellBack) {
    if (sellBack['unit'] != null) {
      return sellBack['unit'].toString();
    }

    return 'g';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  /// ------------------------------------------------------------
  /// MINIMUM BALANCE MESSAGE
  /// ------------------------------------------------------------
  Widget _buildMinimumBalanceMessage({
    required String goldBalance,
    required String goldUnit,
    required String silverBalance,
    required String silverUnit,
  }) {
    final gold = double.tryParse(goldBalance) ?? 0;

    final silver = double.tryParse(silverBalance) ?? 0;

    final goldEligible = goldUnit.toLowerCase().contains('kg')
        ? gold >= 0.05
        : gold >= 50;

    final silverEligible = silverUnit.toLowerCase().contains('kg')
        ? silver >= 1
        : silver >= 1000;

    if (goldEligible || silverEligible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        border: Border.all(color: const Color(0xFFFFB52E), width: 1.2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Text(
        'Minimum balance required for a Sell Back request: 50 g of Gold or 1 kg of Silver. Please increase your balance to become eligible for a Sell Back request.',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          height: 1.25,
          color: Color(0xFF8A5A00),
        ),
      ),
    );
  }

  bool _canSellGold(String value, String unit) {
    final balance = double.tryParse(value) ?? 0;

    if (unit.toLowerCase().contains('kg')) {
      return balance >= 0.05;
    }

    return balance >= 50;
  }

  bool _canSellSilver(String value, String unit) {
    final balance = double.tryParse(value) ?? 0;

    if (unit.toLowerCase().contains('kg')) {
      return balance >= 1;
    }

    return balance >= 1000;
  }

  String _currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';

      case 'EUR':
        return '€';

      case 'GBP':
        return '£';

      case 'SGD':
        return 'S\$';

      case 'INR':
        return '₹';

      default:
        return '$currency ';
    }
  }
}
