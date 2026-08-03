import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class KycService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  Future<Map<String, dynamic>> fetchKycDetails() async {
    final token = await SessionManager.getToken();
    // final token = user?["token"];

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
    try {
      final token = await SessionManager.getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/my-account/kyc"),
      );

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // Required file
      request.files.add(
        await http.MultipartFile.fromPath(
          "identity_document",
          identityDocument.path,
        ),
      );

      // Optional file
      if (addressDocument != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "address_document",
            addressDocument.path,
          ),
        );
      }

      request.fields["customer_notes"] = customerNotes;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final body = jsonDecode(response.body);

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "statusCode": response.statusCode,
        "body": body,
      };
    } catch (e) {
      return {
        "success": false,
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }
}
