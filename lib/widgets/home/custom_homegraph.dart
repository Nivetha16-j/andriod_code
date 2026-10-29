import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeGraph extends StatelessWidget {
  final Map<String, dynamic> chartData;

  const HomeGraph({super.key, required this.chartData});

  static const _cardDecoration = BoxDecoration(
    color: Color(0xFF991515),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

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

  // "27 Oct"
  String _formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  // "Oct 2026"
  String _formatMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

  // 1y, 5y, 10y, all
  bool get _isLongRange {
    final String range = (chartData['range']?.toString() ?? '').toLowerCase();
    return const {'1y', '5y', '10y', 'all'}.contains(range);
  }

  // Long ranges: "Oct" over "2026". Shorter ranges: "27 Oct"
  String _formatXLabel(DateTime d) {
    return _isLongRange ? '${_months[d.month - 1]}\n${d.year}' : _formatDay(d);
  }

  // "27 Oct 2026, 06:15 pm" (converted to the phone's local time)
  String _formatUpdatedAt(String? raw) {
    final parsed = DateTime.tryParse(raw ?? '');
    if (parsed == null) return raw ?? '';
    final d = parsed.toLocal();
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'pm' : 'am';
    return '${_formatDay(d)} ${d.year}, '
        '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final List points = (chartData['points'] as List?) ?? const [];

    if (points.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: _cardDecoration,
        child: const Text(
          'No chart data available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), (points[i]['price'] as num).toDouble()),
    ];

    final double dataMin = spots.map((s) => s.y).reduce(math.min);
    final double dataMax = spots.map((s) => s.y).reduce(math.max);

    // 10% padding top and bottom, 4 equal steps => 5 dashed lines
    final double range = dataMax - dataMin;
    final double pad = range == 0
        ? (dataMax.abs() * 0.01 + 0.01)
        : range * 0.10;
    final double minY = dataMin - pad;
    final double maxY = dataMax + pad;
    final double yInterval = (maxY - minY) / 4;

    final double lastX = (points.length - 1).toDouble();
    final double maxX = lastX == 0 ? 1 : lastX;
    final double xInterval = maxX / 5;

    // 6 evenly spaced x labels, first and last included
    final Set<int> labelIndexes = {
      for (int k = 0; k <= 5; k++) ((points.length - 1) * k / 5).round(),
    };

    // make room for the y labels (long values like 129,790.00)
    final double leftReserved = (maxY.toStringAsFixed(2).length * 6.2 + 8)
        .clamp(42.0, 90.0);

    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                clipData: const FlClipData.all(),

                borderData: FlBorderData(show: false),

                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItems: (touched) {
                      return touched.map((e) {
                        final point = points[e.spotIndex];

                        return LineTooltipItem(
                          point['formatted_price'].toString(),
                          const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yInterval,
                  verticalInterval: xInterval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white54,
                    strokeWidth: .7,
                    dashArray: [5, 4],
                  ),
                  getDrawingVerticalLine: (_) => FlLine(
                    color: Colors.white.withOpacity(.06),
                    strokeWidth: 1,
                  ),
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: leftReserved,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: _isLongRange
                          ? 40
                          : 28, // taller for two-line labels
                      getTitlesWidget: (value, meta) {
                        final int index = value.round();

                        if (index < 0 ||
                            index >= points.length ||
                            !labelIndexes.contains(index)) {
                          return const SizedBox.shrink();
                        }

                        final date = DateTime.fromMillisecondsSinceEpoch(
                          (points[index]['timestamp'] as num).toInt() * 1000,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatXLabel(date),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              height: 1.3,
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
                    color: const Color(0xFFE2B123),
                    barWidth: 1.8,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final String formattedPrice =
        chartData['formatted_current_price']?.toString() ?? '';

    // "S$166.16" -> "S$", "$129.79" -> "$"
    final String symbol =
        RegExp(r'^[^\d+\-]*').stringMatch(formattedPrice) ?? '';

    final num changePercent = (chartData['change_percent'] as num?) ?? 0;
    final num changeAmount = ((chartData['change_amount'] as num?) ?? 0).abs();
    final bool isUp = changePercent >= 0;
    final Color changeColor = isUp
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Price',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),

              const SizedBox(height: 2),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${chartData['currency']} / ${chartData['unit_label']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                '${isUp ? '▲' : '▼'} ${chartData['formatted_change']} '
                '($symbol${changeAmount.toStringAsFixed(2)})',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatUpdatedAt(chartData['updated_at']?.toString()),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(
              formattedPrice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
