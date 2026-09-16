import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class KycService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<Map<String, dynamic>> fetchKycDetails() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/my-account/kyc"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> submitKyc({
    required File identityDocument,
    File? addressDocument,
    String customerNotes = "",
  }) async {
    final token = await SessionManager.getToken();

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/my-account/kyc"),
    );

    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    request.fields["customer_notes"] = customerNotes;

    request.files.add(
      await http.MultipartFile.fromPath(
        "identity_document",
        identityDocument.path,
      ),
    );

    if (addressDocument != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "address_document",
          addressDocument.path,
        ),
      );
    }

    final response = await request.send();

    log("responseresponse $response");

    final responseBody = await response.stream.bytesToString();

    final responseData = jsonDecode(responseBody);

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData["status"] == true) {
      return responseData;
    }

    throw Exception(responseData["message"] ?? "Unable to submit KYC.");
  }
}
