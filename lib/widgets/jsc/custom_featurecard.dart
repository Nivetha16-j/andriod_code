import 'package:flutter/material.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class FeatureCard extends StatelessWidget {
  final String image;
  final String title;
  final List<String> descriptions;

  const FeatureCard({
    super.key,
    required this.image,
    required this.title,
    required this.descriptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFFFDF8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xffE8D45A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Image
            SizedBox(
              width: 72,
              child: Center(
                child: Image.asset(image, width: 72, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(width: 15),

            /// Content
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  TranslatedText(
                    title,
                    maxLines: null,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Descriptions
                  ...descriptions.map(
                    (description) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TranslatedText(
                            "•",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: TranslatedText(
                              description,
                              maxLines: null,
                              softWrap: true,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
