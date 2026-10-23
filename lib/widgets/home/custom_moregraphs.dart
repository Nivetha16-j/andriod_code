import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custom_appbar.dart';

class CustomMoreGraphs extends StatefulWidget {
  const CustomMoreGraphs({super.key});

  @override
  State<CustomMoreGraphs> createState() => _CustomMoreGraphsState();
}

class _CustomMoreGraphsState extends State<CustomMoreGraphs> {
  String metal = 'Platinum';
  String currency = 'USD';
  String weightUnit = 'Gram';

  int selectedRange = 0;

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 0;

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      backgroundColor: const Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      // body: PlansLayout(
      //   plans: Plans.jsc,
      //   selectedMenu: 'Convert To Physical',
      //   child: SingleChildScrollView(
      //     padding: const EdgeInsets.fromLTRB(16, 10, 14, 20),
      //     child: const JscConvertToPhysicalContent(),
      //   ),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterCard(),
            const SizedBox(height: 16),
            _buildChartCard(),
          ],
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

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD4A437), width: .6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Customize Your Chart",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Measure and analyze precious metal prices in real-time.",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _dropdown(
                  title: "PRECIOUS METAL",
                  value: metal,
                  items: const ["Platinum", "Gold", "Silver"],
                  onChanged: (v) {
                    setState(() {
                      metal = v!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _dropdown(
                  title: "CURRENCY",
                  value: currency,
                  items: const ["USD", "AED"],
                  onChanged: (v) {
                    setState(() {
                      currency = v!;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _dropdown(
                  title: "WEIGHT UNIT",
                  value: weightUnit,
                  items: const ["Gram", "Kg", "Toz"],
                  onChanged: (v) {
                    setState(() {
                      weightUnit = v!;
                    });
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
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xff991515),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xff991515),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              onChanged: onChanged,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffD4A437), width: .6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Platinum in USD",
                      style: TextStyle(
                        color: Color(0xffE4B43A),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Open: \$51.79   Low: \$51.84   High: \$52.31   Close: \$52.16",
                    ),
                  ],
                ),
              ),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$52.16",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text("USD", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text("+0.71%", style: TextStyle(color: Colors.green)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: List.generate(4, (index) {
              final labels = ["1D", "1M", "YTD", "1Y"];

              return Padding(
                padding: const EdgeInsets.only(right: 50),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRange = index;
                    });
                  },
                  child: Column(
                    children: [
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: selectedRange == index
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (selectedRange == index)
                        Container(width: 50, height: 2, color: Colors.red),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 15),

          const Divider(),

          const SizedBox(height: 16),

          SizedBox(
            height: 350,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                minY: 51.5,
                maxY: 52.4,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: .2,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 55),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: const Color(0xffE4B43A),
                    barWidth: 2,
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xffE4B43A).withOpacity(0.15),
                    ),
                    dotData: const FlDotData(show: false),
                    spots: const [
                      FlSpot(0, 51.80),
                      FlSpot(1, 51.88),
                      FlSpot(2, 51.91),
                      FlSpot(3, 51.83),
                      FlSpot(4, 51.99),
                      FlSpot(5, 51.72),
                      FlSpot(6, 51.68),
                      FlSpot(7, 51.98),
                      FlSpot(8, 51.92),
                      FlSpot(9, 52.08),
                      FlSpot(10, 52.03),
                      FlSpot(11, 52.25),
                      FlSpot(12, 52.16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
