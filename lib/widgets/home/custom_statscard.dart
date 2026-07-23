import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class StatsCardSection extends StatelessWidget {
  const StatsCardSection({super.key});

  // Colors based on the design
  static const Color goldBorderColor = Color.fromRGBO(200, 157, 8, 1);
  static const Color cardBackgroundColor = Color.fromRGBO(
    245,
    237,
    237,
    1,
  ); // Slightly transparent white

  @override
  Widget build(BuildContext context) {
    // Static data list
    final List<_StatItem> stats = [
      const _StatItem(value: '15+', label: 'Years Operating'),
      const _StatItem(value: '50,000+', label: 'Trusted Clients'),
      const _StatItem(value: 'SGD 2B+', label: 'Volume Traded'),
      const _StatItem(value: '100%', label: 'Fully Insured'),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: goldBorderColor, width: 1.5),
        ),
        child: Column(
          children: [
            // Row 1
            Row(
              children: [
                Expanded(child: _buildStatColumn(stats[0])),
                Expanded(child: _buildStatColumn(stats[1])),
              ],
            ),

            const SizedBox(height: 28.0), // Spacing between rows
            // Row 2
            Row(
              children: [
                Expanded(child: _buildStatColumn(stats[2])),
                Expanded(child: _buildStatColumn(stats[3])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each stat item
  Widget _buildStatColumn(_StatItem stat) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stat.value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryRed,
            // fontFamily: 'Raleway',
            fontSize: 20.0,
            fontWeight: FontWeight.bold, // Extra bold
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.primaryRed,
            // fontFamily: 'Raleway',
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Data model class
class _StatItem {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});
}
