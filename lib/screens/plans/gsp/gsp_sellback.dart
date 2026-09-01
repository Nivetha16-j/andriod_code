import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/models/plans.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/gsp_balance_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/screens/plans/custom_sellbackdialog.dart';
import 'package:junubullion/screens/plans/layout.dart';
import 'package:junubullion/services/gsp_service.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/widgets/gsp/gsp_balance_section.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class GspSellBackScreen extends StatefulWidget {
  const GspSellBackScreen({super.key});

  @override
  State<GspSellBackScreen> createState() => _GspSellBackScreenState();
}

class _GspSellBackScreenState extends State<GspSellBackScreen> {
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
        selectedMenu: 'Sell Back Request',
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
          child: const GspSellBackContent(),
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

class GspSellBackContent extends StatefulWidget {
  const GspSellBackContent({super.key});

  @override
  State<GspSellBackContent> createState() => _GspSellBackContentState();
}

class _GspSellBackContentState extends State<GspSellBackContent> {
  bool isLoadingSellBack = false;

  Map<String, dynamic>? sellBackData;

  bool isBalancesUnlocked = false;

  Timer? _refreshTimer;

  bool isLoading = true;

  String? errorMessage;

  // @override
  // void initState() {
  //   super.initState();

  //   _checkUnlockStatus();
  // }

  @override
  void initState() {
    super.initState();

    _fetchSellBackData();

    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchSellBackData(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  Future<void> _fetchSellBackData({bool isRefresh = false}) async {
    try {
      // Only show loader for the first fetch.
      // Do NOT show loader every second.
      if (!isRefresh && mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final selectedCurrency = currencyProvider.selectedCurrency;

      final result = await GspService.getSellBackDetails(
        currency: selectedCurrency,
      );

      log('GSP Sell Back Response: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        final data = result['data'];

        setState(() {
          sellBackData = data is Map ? Map<String, dynamic>.from(data) : {};

          isLoading = false;
          errorMessage = null;
        });
      } else {
        // Don't destroy already displayed live data
        // during a temporary refresh failure.
        if (!isRefresh) {
          setState(() {
            sellBackData = {};
            errorMessage =
                result['message']?.toString() ??
                'Unable to fetch sell back details.';
            isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      log('GSP Sell Back Error: $e', stackTrace: stackTrace);

      if (!mounted) return;

      // During background refresh, keep the previous
      // values visible instead of showing a loader/error.
      if (!isRefresh) {
        setState(() {
          sellBackData = {};
          errorMessage = 'Unable to load sell back details.';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkUnlockStatus() async {
    final provider = context.read<GspBalanceProvider>();

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

  Future<void> _fetchSellBackDetails() async {
    if (!mounted) return;

    // Always verify session unlock state before making the request.
    final unlocked = await SessionManager.isGspBalanceUnlocked();

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

      final result = await GspService.getSellBackDetails(currency: currency);

      debugPrint('SELL BACK -> API RESULT: $result');

      if (!mounted) return;

      if (result['status'] == true) {
        final dynamic data = result['data'];

        final Map<String, dynamic> parsedData = data is Map<String, dynamic>
            ? Map<String, dynamic>.from(data)
            : <String, dynamic>{};

        // Verify unlock state again before storing data.
        final stillUnlocked = await SessionManager.isGspBalanceUnlocked();

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

        GspBalanceSection(
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

  Widget _buildSellBackDetails() {
    // API structure:
    //
    // data
    //   └── summary
    //        ├── gold
    //        │    ├── balance
    //        │    ├── unit
    //        │    └── formatted_spot_price
    //        └── silver
    //             ├── balance
    //             ├── unit
    //             └── formatted_spot_price

    final summary = sellBackData?['summary'] as Map<String, dynamic>? ?? {};

    final gold = summary['gold'] as Map<String, dynamic>? ?? {};

    final silver = summary['silver'] as Map<String, dynamic>? ?? {};

    // GOLD
    final goldBalance = gold['balance']?.toString() ?? '0';

    final goldUnit = gold['unit']?.toString() ?? 'gram';

    final goldSpotPrice = gold['formatted_spot_price']?.toString() ?? '\$0.00';

    // SILVER
    final silverBalance = silver['balance']?.toString() ?? '0';

    final silverUnit = silver['unit']?.toString() ?? 'gram';

    final silverSpotPrice =
        silver['formatted_spot_price']?.toString() ?? '\$0.00';

    // Sell-back requests
    final List<dynamic> sellBacks =
        sellBackData?['sellBackRequests'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GOLD
        _buildSellBackMetalRow(
          metal: 'Gold',
          balance: goldBalance,
          unit: goldUnit,
          spotPrice: goldSpotPrice,
          enabled: _canSellGold(goldBalance, goldUnit),
        ),

        const SizedBox(height: 8),

        // SILVER
        _buildSellBackMetalRow(
          metal: 'Silver',
          balance: silverBalance,
          unit: silverUnit,
          spotPrice: silverSpotPrice,
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
                              plan: Plans.gsp,
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
