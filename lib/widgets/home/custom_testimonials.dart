import 'package:flutter/material.dart';

class TestimonialsSection extends StatefulWidget {
  final List<dynamic> testimonialsData; // Pass testimonials list from /home API
  final VoidCallback? onViewMorePressed;

  const TestimonialsSection({
    super.key,
    required this.testimonialsData,
    this.onViewMorePressed,
  });

  @override
  State<TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<TestimonialsSection> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper widget to build gold star ratings dynamically
  Widget _buildRatingStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFB800), // Amber Gold
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "($rating.0)",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse list of testimonials from JSON
    final List<Testimonial> testimonials = widget.testimonialsData
        .map((json) => Testimonial.fromJson(json))
        .toList();

    if (testimonials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F9), // Light grayish background
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Title
          const Text(
            'What People are Saying',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 24),

          // Swipable Testimonial Cards Carousel
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              itemCount: testimonials.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = testimonials[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Star Ratings
                      _buildRatingStars(item.rating),

                      const SizedBox(height: 14),

                      // Testimonial Description
                      Expanded(
                        child: Text(
                          item.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // User Name
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action: View More Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: widget.onViewMorePressed,
                  child: const Text(
                    'View more',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC39B32), // Gold theme color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Testimonial {
  final int id;
  final String name;
  final String email;
  final int rating;
  final String description;
  final String status;

  Testimonial({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.description,
    required this.status,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rating: json['rating'] ?? 5,
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
