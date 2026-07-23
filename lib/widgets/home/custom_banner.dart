import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class BannerSlider extends StatefulWidget {
  final Map<String, dynamic>? bannerData;
  static const String imageBaseUrl = 'https://staging.junubullion.com/storage/';

  const BannerSlider({super.key, this.bannerData});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.bannerData == null) {
      return const SizedBox.shrink();
    }

    // Extract banner image path dynamically
    final String? imagePath = widget.bannerData!['image'];

    if (imagePath == null || imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert to list (if your backend returns a single string or a list of images)
    final List<String> bannerList = [imagePath];
    final bool isMultiple = bannerList.length > 1;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 350.0,
              autoPlay: isMultiple, // Auto-play only if > 1 banner
              enableInfiniteScroll:
                  isMultiple, // Loop continuously only if > 1 banner
              scrollPhysics:
                  isMultiple // Disable touch drag/swiping if only 1 banner
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              enlargeCenterPage: isMultiple,
              viewportFraction: isMultiple ? 0.92 : 1.0,
              aspectRatio: 16 / 9,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: bannerList.map((path) {
              final String fullUrl = '${BannerSlider.imageBaseUrl}$path';

              return ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    log('Error loading banner image: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              );
            }).toList(),
          ),

          // Show indicator dots ONLY when there are multiple images
          if (isMultiple) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bannerList.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.primaryRed
                        : Colors.grey.shade400,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
