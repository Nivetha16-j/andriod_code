import 'package:flutter/material.dart';
import 'package:junubullion/models/testimonial.dart';
import 'package:junubullion/providers/testimonial_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final PageController _reviewPageController = PageController();
  int _currentReviewIndex = 0;
  int rating = 5;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TestimonialProvider>().fetchTestimonials();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    _reviewPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F5EF),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TranslatedText(
              "Reviews from real people",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const TranslatedText(
              "What our customers are saying",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 25),

            Consumer<TestimonialProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.testimonials.isEmpty) {
                  return const Center(
                    child: TranslatedText(
                      "No reviews available",
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                }

                return SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // REVIEW SLIDER
                      PageView.builder(
                        controller: _reviewPageController,
                        itemCount: provider.testimonials.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentReviewIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.78,
                              child: ReviewCard(
                                testimonial: provider.testimonials[index],
                              ),
                            ),
                          );
                        },
                      ),

                      // BACKWARD ARROW
                      if (_currentReviewIndex > 0)
                        Positioned(
                          left: 5,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _reviewPageController.previousPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: _reviewArrow(
                                icon: Icons.arrow_back_ios_new,
                              ),
                            ),
                          ),
                        ),

                      // FORWARD ARROW
                      if (_currentReviewIndex <
                          provider.testimonials.length - 1)
                        Positioned(
                          right: 5,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _reviewPageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: _reviewArrow(
                                icon: Icons.arrow_forward_ios,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            Container(
              decoration: BoxDecoration(
                gradient: AppColors.BgGradient,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText(
                      "We'd love to hear your thoughts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const TranslatedText(
                      "Tell us about your vision: which challenges are you facing? We'd love to stay in touch with you, so we are always ready to answer any question that interests you.",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const TranslatedText(
                      "What's your name?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CustomField(controller: nameController, hint: "Your Name"),

                    const SizedBox(height: 20),

                    const TranslatedText(
                      "What's your email?",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CustomField(
                      controller: emailController,
                      hint: "Your Email",
                    ),

                    const SizedBox(height: 20),

                    const TranslatedText(
                      "Share your thoughts",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    CustomField(
                      controller: descriptionController,
                      hint: "How can we help?",
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),

                    Consumer<TestimonialProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: provider.isSubmitting
                                ? null
                                : () async {
                                    debugPrint("SEND BUTTON CLICKED");

                                    final provider = context
                                        .read<TestimonialProvider>();

                                    final success = await provider
                                        .submitTestimonial(
                                          name: nameController.text.trim(),
                                          email: emailController.text.trim(),
                                          rating: rating,
                                          description: descriptionController
                                              .text
                                              .trim(),
                                        );

                                    if (!mounted) return;

                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: TranslatedText(
                                            "Feedback submitted successfully.",
                                          ),
                                        ),
                                      );

                                      nameController.clear();
                                      emailController.clear();
                                      descriptionController.clear();

                                      // Refresh the testimonials list
                                      provider.fetchTestimonials();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: TranslatedText(
                                            "Failed to submit feedback.",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                            child: provider.isSubmitting
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const TranslatedText(
                                    "SEND",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  Widget _reviewArrow({required IconData icon}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, size: 17, color: AppColors.primaryRed),
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Testimonial testimonial;

  const ReviewCard({super.key, required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.BgGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.amber.withOpacity(.2),
            child: const Icon(Icons.person, color: Colors.amber),
          ),

          const SizedBox(height: 10),

          TranslatedText(
            testimonial.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),
          TranslatedText(
            testimonial.createdAt.substring(0, 10),
            style: const TextStyle(color: AppColors.white),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: Expanded(
              child: TranslatedText(
                testimonial.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              testimonial.rating,
              (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const CustomField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: AppColors.white),
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        // enabledBorder: ,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.white, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.white, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.white, width: 1.5),
        ),
      ),
    );
  }
}
