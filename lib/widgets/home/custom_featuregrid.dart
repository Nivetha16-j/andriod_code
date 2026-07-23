import 'package:flutter/material.dart';

class FeaturesGridSection extends StatelessWidget {
  const FeaturesGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    // List supporting both SVG pictures and standard Icons
    final List<_FeatureItem> features = [
      _FeatureItem(
        icon: Image.asset(
          'assets/1.png',
          height: 40,
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        title: '100% Secure',
        description: 'Your investment is backed by real gold & silver.',
      ),
      _FeatureItem(
        icon: Image.asset(
          'assets/2.png', // Or use Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22)
          height: 40,
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        title: 'Best Market\nRates',
        description: 'We offer competitive rates in the market.',
      ),
      _FeatureItem(
        icon: Image.asset(
          'assets/3.png',
          height: 40,
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        title: 'Safe & Insured',
        description: 'Stored in highly secure vaults.',
      ),
      _FeatureItem(
        icon: Image.asset(
          'assets/4.png',
          height: 40,
          // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        title: '24/7 Support',
        description: 'Expert assistance whenever needed.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: features.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final item = features[index];
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Red Circle Badge containing the SVG/Icon widget
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    // color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: item.icon, // Render widget directly
                ),
                const SizedBox(height: 12.0),

                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Description
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Updated Data Model accepting a Widget for the icon
class _FeatureItem {
  final Widget icon; // Changed from IconData to Widget
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
