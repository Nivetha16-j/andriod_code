import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class JscService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<Map<String, dynamic>> submitApplication({
    required String applicationType,
    required String name,
    required String email,
    required String dob,
    required String mobile,
    required String nationality,
    required String occupation,
    required String residentialAddress,
    required String identityType,
    required String identityNumber,
    required String nomineeName,
    required String nomineeRelationship,
    required String nomineeDob,
    required String nomineeMobile,
    required String nomineeAddress,
    required bool declarationAccepted,
    PlatformFile? photo,
    List<PlatformFile> identityFiles = const [],
  }) async {
    try {
      final token = await SessionManager.getToken();

      final endpoint = applicationType.toUpperCase() == "GSP"
          ? "gsp-registration"
          : "jsc-registration";

      final uri = Uri.parse("$baseUrl/$endpoint");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      request.fields.addAll({
        "name": name,
        "email": email,
        "dob": dob,
        "mobile": mobile,
        "nationality": nationality,
        "occupation": occupation,
        "residential_address": residentialAddress,
        "identity_type": identityType,
        "identity_number": identityNumber,
        "nominee_name": nomineeName,
        "nominee_relationship": nomineeRelationship,
        "nominee_dob": nomineeDob,
        "nominee_mobile": nomineeMobile,
        "nominee_address": nomineeAddress,
        "declaration_accepted": declarationAccepted ? "1" : "0",
      });

      // ---------------------------------------------
      // PHOTO
      // ---------------------------------------------
      if (photo != null &&
          photo.path != null &&
          photo.path!.trim().isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath("photo", photo.path!),
        );

        log("$applicationType PHOTO: ${photo.path}");
      }

      // ---------------------------------------------
      // IDENTITY DOCUMENTS
      // ---------------------------------------------
      for (int i = 0; i < identityFiles.length; i++) {
        final file = identityFiles[i];

        if (file.path != null && file.path!.trim().isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath("identity_files[$i]", file.path!),
          );

          log("$applicationType IDENTITY FILE [$i]: ${file.path}");
        }
      }

      log("$applicationType SUBMIT URL: $uri");

      log("$applicationType FIELDS: ${request.fields}");

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      log("$applicationType STATUS CODE: ${response.statusCode}");

      log("$applicationType RESPONSE: ${response.body}");

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"message": response.body};
      }

      final success = response.statusCode >= 200 && response.statusCode < 300;

      return {
        "success": success,
        "statusCode": response.statusCode,
        "body": body,
      };
    } catch (e, stackTrace) {
      log("$applicationType SUBMIT ERROR: $e", stackTrace: stackTrace);

      return {
        "success": false,
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> getApplication({
    required String applicationType,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final endpoint = applicationType.toUpperCase() == "GSP"
          ? "gsp-registration"
          : "jsc-registration";

      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      log("$applicationType Registration Status: ${response.statusCode}");
      log("$applicationType Registration Response: ${response.body}");

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        return {
          "success": false,
          "hasRegistration": false,
          "message": "Invalid response from server.",
        };
      }

      if (response.statusCode == 200) {
        final registration = data["data"]?["registration"];

        log(
          "$applicationType Registration Exists: "
          "${registration != null}",
        );

        return {
          "success": true,
          "hasRegistration": registration != null,
          "data": data["data"],
          "message": data["message"],
        };
      }

      return {
        "success": false,
        "hasRegistration": false,
        "message":
            data["message"] ?? "Unable to load $applicationType application.",
      };
    } catch (e, stackTrace) {
      log("GET $applicationType APPLICATION ERROR: $e", stackTrace: stackTrace);

      return {
        "success": false,
        "hasRegistration": false,
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> unlockWallet({
    required String unlockPassword,
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/my-account/wallet/unlock'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'unlock_password': unlockPassword,
        'currency': currency,
      }),
    );

    final data = jsonDecode(response.body);

    log("Unnnn $data......${data['message']}");

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        data['status'] == true) {
      return data;
    }

    throw Exception(data['message'] ?? 'Unable to unlock balances.');
  }

  static Future<Map<String, dynamic>> fetchWallet({
    required String currency,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-account/wallet?currency=$currency'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await SessionManager.getToken()}',
        },
      );

      log('Wallet API status: ${response.statusCode}');
      log('Wallet API response: ${response.body}');

      final data = jsonDecode(response.body);

      return data is Map<String, dynamic>
          ? data
          : {'status': false, 'message': 'Invalid wallet response.'};
    } catch (e) {
      log('fetchWallet error: $e');

      return {'status': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getPurchases({
    required String currency,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/my-account/purchases?currency=${currency}'),
      headers: {
        'Authorization': 'Bearer ${await SessionManager.getToken()}',
        'Accept': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message']?.toString() ?? 'Failed to fetch purchases');
  }

  static Future<Map<String, dynamic>> getTransactions({
    required String currency,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final uri = Uri.parse(
        '$baseUrl/my-account/transactions',
      ).replace(queryParameters: {'currency': currency});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('Transactions API response: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      log('Transactions API error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getSellBackDetails({
    required String currency,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final uri = Uri.parse(
        '$baseUrl/my-account/sell-backs',
      ).replace(queryParameters: {'currency': currency});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      log('Sell Back API Response: ${response.statusCode} ${response.body}');

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      log('Sell Back API error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchConvertPhysicalDetails({
    required String currency,
  }) async {
    final token = await SessionManager.getToken();
    final uri = Uri.parse(
      '$baseUrl/my-account/convert-physical',
    ).replace(queryParameters: {'currency': currency});

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    log("ressssssss-- ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to fetch convert physical data: ${response.statusCode}',
    );
  }

  static Future<Map<String, dynamic>> convertToPhysical({
    required String metal,
    required double amount,
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final url = Uri.parse(
      'https://staging.junubullion.com/api/my-account/wallet/convert',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'metal': metal.toLowerCase(),
        'amount': amount,
        'currency': currency,
      }),
    );

    log('CONVERT API STATUS: ${response.statusCode}');
    log('CONVERT API BODY: ${response.body}');

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {'status': false, 'message': 'Invalid response from server.'};
    } catch (e) {
      log('Convert API JSON error: $e');

      return {'status': false, 'message': 'Invalid response from server.'};
    }
  }

  static Future<Map<String, dynamic>> cancelPhysicalConversion({
    required String metal,
    required double amount,
    required String currency,
  }) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse(
        'https://staging.junubullion.com/api/my-account/wallet/convert/cancel',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'metal': metal.toLowerCase(),
        'amount': amount,
        'currency': currency,
      }),
    );

    log('CANCEL CONVERSION RESPONSE: ${response.statusCode}');
    log('CANCEL CONVERSION BODY: ${response.body}');

    final responseData = jsonDecode(response.body);

    return Map<String, dynamic>.from(responseData);
  }

  static Future<Map<String, dynamic>> fetchConvertDetails() async {
    log('🌐 [SERVICE] fetchConvertDetails() STARTED');

    try {
      final token = await SessionManager.getToken();

      final url = Uri.parse('$baseUrl/my-account/wallet/convert-details');

      log('🌐 [SERVICE] URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log('🌐 [SERVICE] STATUS CODE: ${response.statusCode}');

      log('🌐 [SERVICE] RAW BODY: ${response.body}');

      // ============================================================
      // ALWAYS TRY TO RETURN THE BACKEND RESPONSE
      //
      // IMPORTANT:
      // 404 with:
      //
      // {
      //   "status": false,
      //   "message": "No active physical conversion found.",
      //   "data": null
      // }
      //
      // IS A VALID "NO ACTIVE CONVERSION" RESPONSE.
      // ============================================================

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        log('❌ [SERVICE] JSON DECODE ERROR: $e');

        throw Exception('Invalid conversion status response.');
      }

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid conversion status response.');
    } catch (e, stackTrace) {
      log('❌ [SERVICE] fetchConvertDetails ERROR: $e', stackTrace: stackTrace);

      rethrow;
    }
  }
}
