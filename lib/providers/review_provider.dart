import 'package:flutter/material.dart';
import 'package:junubullion/services/home_services.dart';

class ReviewProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<Map<String, dynamic>> submitReview({
    required String token,
    required int productId,
    required int rating,
    required String description,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.addReview(
        token: token,
        productId: productId,
        rating: rating,
        description: description,
      );

      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
