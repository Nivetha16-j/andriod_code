import 'package:flutter/material.dart';
import 'package:junubullion/models/testimonial.dart';
import 'package:junubullion/providers/testimonial_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
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
            /// Heading
            const Text(
              "Reviews from real people",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            const Text(
              "What our customers are saying",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 25),

            /// Review Cards
            // SizedBox(
            //   height: 260,
            //   child: ListView.separated(
            //     scrollDirection: Axis.horizontal,
            //     itemBuilder: (context, index) => const ReviewCard(),
            //     separatorBuilder: (_, __) => const SizedBox(width: 18),
            //     itemCount: 5,
            //   ),
            // ),
            Consumer<TestimonialProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SizedBox(
                  height: 250,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.testimonials.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      final review = provider.testimonials[index];

                      return ReviewCard(testimonial: review);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            /// Form Heading
            const Text(
              "We'd love to hear your thoughts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            const Text(
              "Tell us about your vision: which challenges are you facing? We'd love to stay in touch with you, so we are always ready to answer any question that interests you.",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 25),

            const Text(
              "What's your name?",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            CustomField(controller: nameController, hint: "Your Name"),

            const SizedBox(height: 20),

            const Text(
              "What's your email?",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            CustomField(controller: emailController, hint: "Your Email"),

            const SizedBox(height: 20),

            const Text(
              "Share your thoughts",
              style: TextStyle(fontWeight: FontWeight.w500),
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

                            final success = await provider.submitTestimonial(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              rating: rating,
                              description: descriptionController.text.trim(),
                            );

                            if (!mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to submit feedback."),
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
                        : const Text(
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
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
}

class ReviewCard extends StatelessWidget {
  final Testimonial testimonial;

  const ReviewCard({super.key, required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              testimonial.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.5),
            ),
          ),

          Row(
            children: List.generate(
              testimonial.rating,
              (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
            ),
          ),

          const SizedBox(height: 12),

          const Divider(),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.amber.withOpacity(.2),
                child: const Icon(Icons.person, color: Colors.amber),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    Text(
                      testimonial.createdAt.substring(0, 10),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
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
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
