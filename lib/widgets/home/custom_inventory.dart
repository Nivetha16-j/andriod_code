import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class InventorySection extends StatelessWidget {
  final Function(int categoryIndex) onCategoryTap;

  const InventorySection({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> content = [
      {
        "image": "assets/inventory1.png",
        "description": "Buy Gold Coins",
        "index": 1,
      },
      {
        "image": "assets/inventory2.png",
        "description": "Buy Silver Coins",
        "index": 3,
      },
      {
        "image": "assets/inventory3.png",
        "description": "Buy Gold Bars",
        "index": 2,
      },
      {
        "image": "assets/inventory4.png",
        "description": "Buy Silver Bars",
        "index": 4,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            "Our Inventory",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: content.length,
              itemBuilder: (context, index) {
                final item = content[index];

                return GestureDetector(
                  onTap: () {
                    onCategoryTap(item["index"] as int);
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.BgGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              item["image"] as String,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TranslatedText(
                          item["description"] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
