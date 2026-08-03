import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/services/account_services.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  bool isLoading = false;

  String name = "";
  String email = "";
  String phone = "";

  Future<void> fetchAccountDetails() async {
    debugPrint("fetchAccountDetails called");
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchAccountDetails();

      if (response["status"] == true) {
        final data = response["data"];

        name = data["name"] ?? "";
        email = data["email"] ?? "";
        phone = data["phone_number"] ?? "";
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccountDetails({
    required String name,
    required String email,
    required String phone,
  }) async {
    isLoading = true;
    notifyListeners();

    log("nnnnnnnnn $name $email $phone");

    try {
      final response = await _service.updateAccountDetails(
        name: name,
        email: email,
        phone: phone,
      );

      log("Update Account Response : $response");

      if (response["status"] == true) {
        this.name = name;
        this.email = email;
        this.phone = phone;

        return true;
      }

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.updatePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      log("Update Password Response : $response");

      return response["status"] == true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyPassword(String currentPassword) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.verifyPassword(currentPassword);

      log("Verify Password Response : $response");

      return response;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
