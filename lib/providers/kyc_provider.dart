import 'dart:io';

import 'package:flutter/material.dart';
import 'package:junubullion/services/kyc_service.dart';

class KycProvider extends ChangeNotifier {
  final KycService _service = KycService();

  bool isLoading = false;

  String kycStatus = "";
  bool kycApproved = false;
  bool canSubmit = false;

  List<String> allowedExtensions = [];

  int maxFileMb = 5;

  dynamic submission;

  Future<void> fetchKycDetails() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchKycDetails();

      if (response["status"] == true) {
        final data = response["data"];

        kycStatus = data["kyc_status"] ?? "";
        kycApproved = data["kyc_approved"] ?? false;
        canSubmit = data["can_submit"] ?? false;
        submission = data["submission"];

        allowedExtensions = List<String>.from(data["allowed_extensions"] ?? []);

        maxFileMb = data["max_file_mb"] ?? 5;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> submitKyc({
    required File identityDocument,
    File? addressDocument,
    String customerNotes = "",
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await KycService.submitKyc(
        identityDocument: identityDocument,
        addressDocument: addressDocument,
        customerNotes: customerNotes,
      );

      await fetchKycDetails();

      return response;
    } catch (e) {
      return {"status": false, "message": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
