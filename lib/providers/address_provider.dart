import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/address_services.dart';
import 'package:junubullion/services/session_manager.dart';

class AddressProvider extends ChangeNotifier {
  bool isLoading = false;

  String? name;
  String? address;

  final AddressService _addressService = AddressService();

  Future<void> fetchAddress() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse("https://staging.junubullion.com/api/my-account/addresses"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      log("Address Status : ${response.statusCode}");
      log(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["status"] == true) {
          final data = json["data"];

          name = data["name"];
          address = data["address"];
        }
      }
    } catch (e) {
      log("Address Error : $e");
    }

    isLoading = false;
    notifyListeners();
  }

  bool get hasAddress => address != null && address!.trim().isNotEmpty;

  Future<bool> updateAddress(String address) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _addressService.updateAddress(address);

      isLoading = false;
      notifyListeners();

      if (response["status"] == true) {
        this.address = address; // Update locally
        await fetchAddress();
        notifyListeners();
      }

      return response["status"] == true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
