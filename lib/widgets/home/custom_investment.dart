import 'package:flutter/material.dart';
import 'package:junubullion/screens/plans/gsp/gsp_details.dart';
import 'package:junubullion/screens/plans/jsc/jsc_details.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class InvestmentSection extends StatelessWidget {
  const InvestmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> content = [
      {
        "image": "assets/gold.png",
        "title": "GSP - GOLD Savings Passbook",
        "bgColor": AppColors.mustard,
        "button": AppColors.yellow,
        "description":
            "Starting from just 1 gram, GSP provides a simple, secure, and flexible way to save for retirement, children's education, and future financial goals while benefiting from the long-term value of precious metals.",
      },
      {
        "image": "assets/gold.png",
        "title": "JSC - Junu Savings Capital",
        "bgColor": AppColors.grey,
        "button": AppColors.lightGrey,
        "description":
            "Starting from just 1 gram, JSC provides a simple, secure, and flexible way to save for retirement, children's education, and future financial goals while benefiting from the long-term value of precious metals.",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            "Our Investments",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InvestmentCard(
                  image: content[0]["image"],
                  title: content[0]["title"],
                  description: content[0]["description"],
                  bgColor: content[0]["bgColor"],
                  buttonColor: content[0]["button"],
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => GspScreen()));
                  },
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _InvestmentCard(
                  image: content[1]["image"],
                  title: content[1]["title"],
                  description: content[1]["description"],
                  bgColor: content[1]["bgColor"],
                  buttonColor: content[1]["button"],
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => JscScreen()));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final Color bgColor;
  final Color buttonColor;
  final VoidCallback onTap;

  const _InvestmentCard({
    required this.image,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(image, height: 60, width: 60, fit: BoxFit.contain),

              const SizedBox(width: 8),

              Expanded(
                child: TranslatedText(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TranslatedText(
            description,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const TranslatedText(
                "Explore More",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
