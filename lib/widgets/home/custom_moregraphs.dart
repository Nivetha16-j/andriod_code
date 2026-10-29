import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/currency_provider.dart';
import 'package:junubullion/providers/graph_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:provider/provider.dart';

class CustomMoreGraphs extends StatefulWidget {
  const CustomMoreGraphs({super.key});

  @override
  State<CustomMoreGraphs> createState() => _CustomMoreGraphsState();
}

class _CustomMoreGraphsState extends State<CustomMoreGraphs> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ---- Selections (one source of truth for both cards) ----
  String metal = 'Gold';
  // Shared with the app bar dropdown
  String get currency => context.read<CurrencyProvider>().selectedCurrency;
  String weightUnit = 'Gram';
  int rangeIndex = 0; // 1D by default

  final List<String> metals = const ['Gold', 'Silver', 'Platinum'];
  final List<String> units = const ['Gram', 'Ounce', 'Kilogram'];
  final List<String> defaultCurrencies = const [
    'USD',
    'SGD',
    'CAD',
    'INR',
    'EUR',
    'AED',
    'CNY',
  ];

  final List<String> rangeLabels = const [
    '1D',
    '1M',
    'YTD',
    '1Y',
    '5Y',
    '10Y',
    'ALL',
  ];
  final List<String> rangeCodes = const [
    '1d',
    '1mo',
    'ytd',
    '1y',
    '5y',
    '10y',
    'all',
  ];

  static const _months = [
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

  late final CurrencyProvider _currencyProvider;
  String _lastCurrency = '';

  @override
  void initState() {
    super.initState();

    _currencyProvider = context.read<CurrencyProvider>();
    _lastCurrency = _currencyProvider.selectedCurrency;
    _currencyProvider.addListener(_onCurrencyChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetch();
    });
  }

  @override
  void dispose() {
    _currencyProvider.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  // Runs when the currency changes anywhere (app bar or this screen)
  void _onCurrencyChanged() {
    final String c = _currencyProvider.selectedCurrency;
    if (!mounted || c == _lastCurrency) return;
    _lastCurrency = c;
    _fetch(); // reload the charts for the new currency
  }

  Future<void> _fetch({bool clear = false}) {
    return context.read<GraphProvider>().fetchMoreGraphs(
      metal: metal.toLowerCase(),
      currency: currency,
      unit: weightUnit,
      range: rangeCodes[rangeIndex],
      clear: clear,
    );
  }

  Future<void> _refresh() async {
    if (context.read<GraphProvider>().moreLoading)
      return; // ignore taps while loading
    await _fetch(clear: true);
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  // ------------------------------------------------------------------
  // Formatting helpers
  // ------------------------------------------------------------------
  String _symbol(Map<String, dynamic>? data) {
    final cur = data?['currencies'];
    if (cur is Map && cur[currency] is Map) {
      return cur[currency]['symbol']?.toString() ?? '';
    }
    return '';
  }

  String _money(double v, String symbol) {
    final parts = v.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    return '$symbol$whole.${parts[1]}';
  }

  bool get _isLongRange =>
      const {'1y', '5y', '10y', 'all'}.contains(rangeCodes[rangeIndex]);

  String _time(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour >= 12 ? 'pm' : 'am'}';
  }

  String _xLabel(DateTime d) {
    final code = rangeCodes[rangeIndex];
    if (code == '1d') return _time(d);
    if (_isLongRange) return '${_months[d.month - 1]}\n${d.year}';
    return '${d.day} ${_months[d.month - 1]}';
  }

  String _tooltipDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}, ${_time(d)}';

  DateTime _date(dynamic ts) =>
      DateTime.fromMillisecondsSinceEpoch((ts as num).toInt() * 1000);

  // ------------------------------------------------------------------
  // Build
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GraphProvider>();
    final data = provider.moreData;

    final List<String> currencyItems = (data?['currencies'] is Map)
        ? (data!['currencies'] as Map).keys.map((e) => e.toString()).toList()
        : defaultCurrencies;

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      body: RefreshIndicator(
        color: const Color(0xff991515),
        onRefresh: () => _fetch(), // pull down to refresh too
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: (provider.moreLoading && data == null)
              ? const SizedBox(
                  height: 400,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xff991515)),
                  ),
                )
              : Column(
                  children: [
                    _buildFilterCard(currencyItems, provider.moreLoading),
                    const SizedBox(height: 16),
                    _buildChartCard(provider, data),
                    const SizedBox(height: 16),
                    _buildSpotPriceChartsCard(provider, data),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: _switchToTab,
      ),
    );
  }

  // ------------------------------------------------------------------
  // Filter card
  // ------------------------------------------------------------------
  Widget _buildFilterCard(List<String> currencyItems, bool loading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffD4A437), width: .6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Customize Your Chart",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: loading ? null : _refresh,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xffD4A437),
                          ),
                        )
                      : const Icon(Icons.refresh, color: Color(0xffD4A437)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Measure and analyze precious metal prices in real-time.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  title: "PRECIOUS METAL",
                  value: metal,
                  items: metals,
                  onChanged: (v) {
                    if (v == null || v == metal) return;
                    setState(() => metal = v);
                    _fetch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  title: "CURRENCY",
                  value: currencyItems.contains(currency)
                      ? currency
                      : currencyItems.first,
                  items: currencyItems,
                  onChanged: (v) {
                    if (v == null || v == currency) return;
                    context.read<CurrencyProvider>().changeCurrency(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown(
                  title: "WEIGHT UNIT",
                  value: weightUnit,
                  items: units,
                  onChanged: (v) {
                    if (v == null || v == weightUnit) return;
                    setState(() => weightUnit = v);
                    _fetch();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xff991515),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              dropdownColor: const Color(0xff991515),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              onChanged: (v) => onChanged(v),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // Main chart card
  // ------------------------------------------------------------------
  Widget _buildChartCard(GraphProvider provider, Map<String, dynamic>? data) {
    final Map<String, dynamic>? chart = data?['chart'] is Map
        ? Map<String, dynamic>.from(data!['chart'])
        : null;
    final List points = (chart?['points'] as List?) ?? const [];
    final String symbol = _symbol(data);

    // Open / Low / High / Close from the points
    String ohlc = '';
    if (points.isNotEmpty) {
      final prices = points.map((e) => (e['price'] as num).toDouble()).toList();
      ohlc =
          'Open: ${_money(prices.first, symbol)}   '
          'Low: ${_money(prices.reduce(math.min), symbol)}   '
          'High: ${_money(prices.reduce(math.max), symbol)}   '
          'Close: ${_money(prices.last, symbol)}';
    }

    final num changePct = (chart?['change_percent'] as num?) ?? 0;
    final bool isUp = changePct >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD4A437), width: .6),
      ),
      child: Column(
        children: [
          if (provider.moreLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xffE4B43A),
                backgroundColor: Color(0xffF3EBD3),
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$metal in $currency",
                      style: const TextStyle(
                        color: Color(0xffE4B43A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(ohlc, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        chart?['formatted_current_price']?.toString() ?? '--',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currency,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    chart?['formatted_change']?.toString() ?? '',
                    style: TextStyle(
                      color: isUp ? Colors.green : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---- range tabs ----
          Row(
            children: List.generate(rangeLabels.length, (index) {
              final selected = rangeIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (selected) return;
                    setState(() => rangeIndex = index);
                    _fetch();
                  },
                  child: Column(
                    children: [
                      Text(
                        rangeLabels[index],
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? Colors.orange : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        color: selected ? Colors.red : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const Divider(height: 1),
          const SizedBox(height: 16),

          SizedBox(height: 350, child: _chartBody(provider, points, symbol)),
        ],
      ),
    );
  }

  Widget _chartBody(GraphProvider provider, List points, String symbol) {
    if (provider.moreError != null) {
      return Center(
        child: Text(
          provider.moreError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (points.isEmpty) {
      return Center(
        child: provider.moreLoading
            ? const CircularProgressIndicator()
            : const Text('No chart data available'),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), (points[i]['price'] as num).toDouble()),
    ];

    final double dataMin = spots.map((s) => s.y).reduce(math.min);
    final double dataMax = spots.map((s) => s.y).reduce(math.max);
    final double span = dataMax - dataMin;
    final double pad = span == 0 ? (dataMax.abs() * 0.01 + 0.01) : span * 0.10;
    final double minY = dataMin - pad;
    final double maxY = dataMax + pad;
    final double yInterval = (maxY - minY) / 4;

    final double maxX = points.length > 1 ? (points.length - 1).toDouble() : 1;
    final Set<int> labelIndexes = {
      for (int k = 0; k <= 5; k++) ((points.length - 1) * k / 5).round(),
    };

    final double rightReserved = (_money(maxY, symbol).length * 6.4 + 10).clamp(
      48.0,
      100.0,
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xff1A1A1A),
            getTooltipItems: (touched) {
              return touched.map((e) {
                final p = points[e.spotIndex];
                return LineTooltipItem(
                  '${_tooltipDate(_date(p['timestamp']))}\n',
                  const TextStyle(color: Colors.white70, fontSize: 10),
                  children: [
                    TextSpan(
                      text: p['formatted_price'].toString(),
                      style: const TextStyle(
                        color: Color(0xffE4B43A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: yInterval,
          verticalInterval: maxX / 5,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              FlLine(color: Colors.black12, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: rightReserved,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  _money(value, symbol),
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: _isLongRange ? 40 : 28,
              getTitlesWidget: (value, meta) {
                final int index = value.round();
                if (index < 0 ||
                    index >= points.length ||
                    !labelIndexes.contains(index)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _xLabel(_date(points[index]['timestamp'])),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: const Color(0xffE4B43A),
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xffE4B43A).withOpacity(0.25),
                  const Color(0xffE4B43A).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // "Spot Price Charts" card
  // ------------------------------------------------------------------
  Widget _buildSpotPriceChartsCard(
    GraphProvider provider,
    Map<String, dynamic>? data,
  ) {
    const darkRed = Color(0xff8B1A1A);

    final Map? metalsMap = (data?['spot_prices'] is Map)
        ? (data!['spot_prices']['metals'] as Map?)
        : null;
    final List points = (data?['chart'] is Map)
        ? ((data!['chart']['points'] as List?) ?? const [])
        : const [];

    Widget summary(String name) {
      final Map? m = metalsMap?[name.toLowerCase()] as Map?;
      final num pct = (m?['change_percent'] as num?) ?? 0;
      return _spotSummary(
        name,
        m?['formatted_change']?.toString() ?? '--',
        m?['formatted_price']?.toString() ?? '--',
        pct >= 0,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffEADFB8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pie_chart_outline, size: 24, color: Colors.black),
              SizedBox(width: 12),
              Text(
                'Spot Price Charts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [summary('Gold'), summary('Silver'), summary('Platinum')],
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _spotDropdown(
                  value: metal,
                  items: metals,
                  onChanged: (v) {
                    if (v == null || v == metal) return;
                    setState(() => metal = v);
                    _fetch();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _spotDropdown(
                  value: weightUnit,
                  items: units,
                  onChanged: (v) {
                    if (v == null || v == weightUnit) return;
                    setState(() => weightUnit = v);
                    _fetch();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              const double gap = 2;
              final double btnWidth = (constraints.maxWidth - gap * 6) / 7;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: List.generate(rangeLabels.length, (index) {
                  final bool selected = rangeIndex == index;
                  return GestureDetector(
                    onTap: () {
                      if (selected) return;
                      setState(() => rangeIndex = index);
                      _fetch();
                    },
                    child: Container(
                      width: btnWidth,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? darkRed : const Color(0xff111111),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? darkRed : const Color(0xff2A2A2A),
                        ),
                      ),
                      child: Text(
                        rangeLabels[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),

          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffF7F8F7),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: points.isEmpty
                ? Center(
                    child: provider.moreLoading
                        ? const CircularProgressIndicator()
                        : const Text('No chart data'),
                  )
                : _miniChart(points),
          ),
        ],
      ),
    );
  }

  Widget _miniChart(List points) {
    final prices = points.map((e) => (e['price'] as num).toDouble()).toList();
    final double lo = prices.reduce(math.min);
    final double hi = prices.reduce(math.max);
    final double pad = (hi - lo) == 0 ? 1 : (hi - lo) * 0.08;

    return LineChart(
      LineChartData(
        minY: lo - pad,
        maxY: hi + pad,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < prices.length; i++)
                FlSpot(i.toDouble(), prices[i]),
            ],
            isCurved: false,
            color: const Color(0xffE4A82E),
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _spotSummary(String name, String change, String price, bool isUp) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: TextStyle(
              fontSize: 13,
              color: isUp ? const Color(0xff7CB518) : const Color(0xffD81B4A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _spotDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xff8B1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          dropdownColor: const Color(0xff8B1A1A),
          iconEnabledColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down, size: 26),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }
}
