import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeGraph extends StatelessWidget {
  final Map<String, dynamic> chartData;

  const HomeGraph({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final points = chartData['points'] as List;

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value['price'] as num).toDouble(),
      );
    }).toList();

    final prices = points.map((e) => (e['price'] as num).toDouble()).toList();

    final minY = prices.reduce((a, b) => a < b ? a : b);
    final maxY = prices.reduce((a, b) => a > b ? a : b);

    return Container(
      height: 460,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF991515),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(),

          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY - .05,
                maxY: maxY + .05,
                clipData: const FlClipData.all(),

                borderData: FlBorderData(show: false),

                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // tooltipBgColor: Colors.black,
                    getTooltipItems: (touched) {
                      return touched.map((e) {
                        final point = points[e.spotIndex];

                        return LineTooltipItem(
                          point['formatted_price'],
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
                  horizontalInterval: ((maxY - minY) / 4),

                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Colors.white54,
                      strokeWidth: .7,
                      dashArray: [5, 4],
                    );
                  },

                  getDrawingVerticalLine: (_) {
                    return FlLine(
                      color: Colors.white.withOpacity(.06),
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
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
                      interval: points.length / 5,

                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();

                        if (index < 0 || index >= points.length) {
                          return const SizedBox();
                        }

                        final date = DateTime.fromMillisecondsSinceEpoch(
                          points[index]['timestamp'] * 1000,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day} Oct',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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

                    barWidth: 2,

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

              Text(
                chartData['formatted_current_price'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                '${chartData['currency']} / ${chartData['unit_label']}',
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 4),

              Text(
                '${chartData['formatted_change']} (${chartData['change_amount']})',
                style: TextStyle(
                  color: chartData['change_percent'] >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chartData['updated_at'],
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),

            Text(
              chartData['formatted_current_price'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
