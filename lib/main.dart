// import 'package:flutter/material.dart';
// import 'package:junubullion/providers/account_provider.dart';
// import 'package:junubullion/providers/address_provider.dart';
// import 'package:junubullion/providers/balance_provider.dart';
// import 'package:junubullion/providers/cart_provider.dart';
// import 'package:junubullion/providers/checkout_provider.dart';
// import 'package:junubullion/providers/convert_to_physical_provider.dart';
// import 'package:junubullion/providers/currency_provider.dart';
// import 'package:junubullion/providers/exclusive_product_provider.dart';
// import 'package:junubullion/providers/graph_provider.dart';
// import 'package:junubullion/providers/gsp_balance_provider.dart';
// import 'package:junubullion/providers/gsp_monthly_plan_provider.dart';
// import 'package:junubullion/providers/home_provider.dart';
// import 'package:junubullion/providers/jsc_balance_provider.dart';
// import 'package:junubullion/providers/jsc_monthly_plan_provider.dart';
// import 'package:junubullion/providers/kyc_provider.dart';
// import 'package:junubullion/providers/language_provider.dart';
// import 'package:junubullion/providers/order_provider.dart';
// import 'package:junubullion/providers/product_detail_provider.dart';
// import 'package:junubullion/providers/review_provider.dart';
// import 'package:junubullion/providers/testimonial_provider.dart';
// import 'package:junubullion/routes/app_routes.dart';
// import 'package:junubullion/screens/balance/balancescreen.dart';
// import 'package:junubullion/services/app_bootstrap.dart';
// import 'package:provider/provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final languageProvider = LanguageProvider();

//   // Start heavy init in the background — do not block the first frame.
//   AppBootstrap.start(languageProvider);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => CurrencyProvider()),
//         ChangeNotifierProvider(create: (_) => HomeProvider()),
//         ChangeNotifierProvider(create: (_) => ExclusiveProductProvider()),
//         ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
//         ChangeNotifierProvider(create: (_) => ReviewProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(create: (_) => AddressProvider()),
//         ChangeNotifierProvider(create: (_) => OrdersProvider()),
//         ChangeNotifierProvider(create: (_) => AccountProvider()),
//         ChangeNotifierProvider(create: (_) => KycProvider()),
//         ChangeNotifierProvider(create: (_) => CheckoutProvider()),
//         ChangeNotifierProvider(create: (_) => TestimonialProvider()),
//         ChangeNotifierProvider(create: (_) => PhysicalConversionProvider()),
//         ChangeNotifierProvider(create: (_) => JscBalanceProvider()),
//         ChangeNotifierProvider(create: (_) => GspBalanceProvider()),
//         ChangeNotifierProvider(create: (_) => GspMonthlyPlanProvider()),
//         ChangeNotifierProvider(create: (_) => JscMonthlyPlanProvider()),
//         ChangeNotifierProvider(create: (_) => GraphProvider()),
//         ChangeNotifierProvider(create: (_) => BalanceProvider()),
//         ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       initialRoute: AppRoutes.splash,
//       onGenerateRoute: AppRoutes.generateRoute,
//       theme: ThemeData(
//         fontFamily: 'Montserrat',
//         scaffoldBackgroundColor: Colors.black,
//         canvasColor: Colors.black,
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: PriceChartCard(),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------
class ChartResponse {
  final String metal;
  final String currency;
  final String unitLabel;
  final String range;
  final DateTime updatedAt;
  final double currentPrice;
  final String formattedCurrentPrice;
  final double changePercent;
  final double changeAmount;
  final String formattedChange;
  final List<ChartPoint> points;

  ChartResponse({
    required this.metal,
    required this.currency,
    required this.unitLabel,
    required this.range,
    required this.updatedAt,
    required this.currentPrice,
    required this.formattedCurrentPrice,
    required this.changePercent,
    required this.changeAmount,
    required this.formattedChange,
    required this.points,
  });

  factory ChartResponse.fromJson(Map<String, dynamic> json) {
    return ChartResponse(
      metal: json['metal'] ?? 'gold',
      currency: json['currency'] ?? 'USD',
      unitLabel: json['unit_label'] ?? 'Gram',
      range: json['range'] ?? '1mo',
      updatedAt:
          DateTime.tryParse(json['updated_at'] ?? '')?.toLocal() ??
          DateTime.now(),
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      formattedCurrentPrice: json['formatted_current_price'] ?? '',
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0.0,
      formattedChange: json['formatted_change'] ?? '',
      points: (json['points'] as List? ?? [])
          .map((p) => ChartPoint.fromJson(p))
          .toList(),
    );
  }
}

class ChartPoint {
  final int timestamp;
  final double price;
  final String formattedPrice;

  ChartPoint({
    required this.timestamp,
    required this.price,
    required this.formattedPrice,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      timestamp: json['timestamp'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      formattedPrice: json['formatted_price'] ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class PriceChartCard extends StatefulWidget {
  const PriceChartCard({super.key});

  @override
  State<PriceChartCard> createState() => _PriceChartCardState();
}

class _PriceChartCardState extends State<PriceChartCard> {
  late Future<ChartResponse> _chartFuture;

  @override
  void initState() {
    super.initState();
    _chartFuture = fetchChartData();
  }

  Future<ChartResponse> fetchChartData() async {
    // Note: range=1mo gives the exact 1-month data from your image!
    final uri = Uri.parse(
      'https://staging.junubullion.com/api/spot-prices/chart?metal=gold&currency=USD&unit=gram&range=1mo',
    );
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ChartResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load chart data (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF7E1C1A), // Exact deep burgundy card background
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FutureBuilder<ChartResponse>(
        future: _chartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 400,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFEAA639)),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 400,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white70,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAA639),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () =>
                          setState(() => _chartFuture = fetchChartData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(data),
              const SizedBox(height: 20),
              SizedBox(height: 350, child: LineChart(_buildChartData(data))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ChartResponse data) {
    final isNegative = data.changePercent < 0;
    final changeColor = isNegative
        ? const Color(0xFFFFA5A5)
        : const Color(0xFF81C784);
    final sign = isNegative ? '▼ ' : '▲ +';

    final formattedDate =
        '${data.updatedAt.day} ${_monthName(data.updatedAt.month)} ${data.updatedAt.year}, '
        '${data.updatedAt.hour.toString().padLeft(2, '0')}:${data.updatedAt.minute.toString().padLeft(2, '0')}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Price',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  data.formattedCurrentPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${data.currency} / ${data.unitLabel}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$sign${data.formattedChange} (\$${data.changeAmount.abs().toStringAsFixed(2)})',
              style: TextStyle(
                color: changeColor.withOpacity(0.85),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // Right Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.formattedCurrentPrice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  LineChartData _buildChartData(ChartResponse data) {
    final spots = data.points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();

    // The 5 exact grid levels from the image: 128.86 up to 135.56
    const double minY = 128.86;
    const double maxY = 135.56;
    const double yInterval = 1.675; // (135.56 - 128.86) / 4

    return LineChartData(
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineTouchData: const LineTouchData(enabled: true),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: yInterval,
        verticalInterval: (spots.length / 5).floorToDouble(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.55),
            strokeWidth: 1.2,
            dashArray: [5, 4], // Dashed line effect
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.06), // Faint vertical grid
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= data.points.length) {
                return const SizedBox.shrink();
              }

              // Show 6 milestone labels matching the screenshot:
              // Index 0: 28 Sept, Index 4: 2 Oct, Index 8: 8 Oct,
              // Index 13: 15 Oct, Index 17: 21 Oct, Index 21: 27 Oct
              final milestoneIndices = [0, 4, 8, 13, 17, 21];
              if (!milestoneIndices.contains(index)) {
                return const SizedBox.shrink();
              }

              final date = DateTime.fromMillisecondsSinceEpoch(
                data.points[index].timestamp * 1000,
              ).toLocal();

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${date.day} ${_monthName(date.month)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
          isCurved: false, // Straight segments exactly like the image
          barWidth: 2.2,
          color: const Color(0xFFEAA639), // Golden amber line
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          shadow: const Shadow(
            color: Color(0x99FFA726), // Glowing neon amber effect
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
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
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : '';
  }
}
