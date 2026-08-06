import 'package:flutter/material.dart';
import 'package:junubullion/models/testimonial.dart';
import 'package:junubullion/services/testimonial_provider.dart';

class TestimonialProvider extends ChangeNotifier {
  final TestimonialService _service = TestimonialService();

  bool isLoading = false;

  List<Testimonial> testimonials = [];

  Future<void> fetchTestimonials() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchTestimonials();

      testimonials = response.map((e) => Testimonial.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  bool isSubmitting = false;

  Future<bool> submitTestimonial({
    required String name,
    required String email,
    required int rating,
    required String description,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      await _service.submitTestimonial(
        name: name,
        email: email,
        rating: rating,
        description: description,
      );

      isSubmitting = false;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(e.toString());

      isSubmitting = false;
      notifyListeners();

      return false;
    }
  }
}
