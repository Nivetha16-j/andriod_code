import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';

class JscService {
  static const String baseUrl = "https://staging.junubullion.com/api";

  static Future<Map<String, dynamic>> submitJscApplication({
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

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/jsc-registration"),
      );

      // ----------------------------------------------------------
      // HEADERS
      // ----------------------------------------------------------

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // ----------------------------------------------------------
      // TEXT FIELDS
      // ----------------------------------------------------------

      request.fields["name"] = name;
      request.fields["email"] = email;
      request.fields["dob"] = dob;
      request.fields["mobile"] = mobile;
      request.fields["nationality"] = nationality;
      request.fields["occupation"] = occupation;
      request.fields["residential_address"] = residentialAddress;

      request.fields["identity_type"] = identityType;
      request.fields["identity_number"] = identityNumber;

      request.fields["nominee_name"] = nomineeName;
      request.fields["nominee_relationship"] = nomineeRelationship;
      request.fields["nominee_dob"] = nomineeDob;
      request.fields["nominee_mobile"] = nomineeMobile;
      request.fields["nominee_address"] = nomineeAddress;

      request.fields["declaration_accepted"] = declarationAccepted ? "1" : "0";

      // ----------------------------------------------------------
      // PHOTO
      // ----------------------------------------------------------

      if (photo != null && photo.path != null && photo.path!.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath("photo", photo.path!),
        );
      }

      // ----------------------------------------------------------
      // IDENTITY FILES
      // ----------------------------------------------------------

      for (int i = 0; i < identityFiles.length; i++) {
        final file = identityFiles[i];

        if (file.path != null && file.path!.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath("identity_files[$i]", file.path!),
          );
        }
      }

      // ----------------------------------------------------------
      // DEBUG LOG
      // ----------------------------------------------------------

      log("JSC PHOTO: ${photo?.path}");

      for (final file in identityFiles) {
        log("JSC IDENTITY FILE: ${file.path}");
      }

      // ----------------------------------------------------------
      // SEND REQUEST
      // ----------------------------------------------------------

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      log("JSC STATUS CODE: ${response.statusCode}");
      log("JSC RESPONSE: ${response.body}");

      // ----------------------------------------------------------
      // DECODE RESPONSE
      // ----------------------------------------------------------

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"message": response.body};
      }

      final success = response.statusCode == 200 || response.statusCode == 201;

      return {
        "success": success,
        "statusCode": response.statusCode,
        "body": body,
      };
    } catch (e, stackTrace) {
      log("JSC SUBMIT ERROR: $e", stackTrace: stackTrace);

      return {
        "success": false,
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }

  static Future<Map<String, dynamic>> getJscApplication() async {
    try {
      final token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse("$baseUrl/jsc-registration"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      log("JSC Registration Status: ${response.statusCode}");

      log("JSC Registration Response: ${response.body}");

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

      // ----------------------------------------------------------
      // SUCCESS RESPONSE
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        // IMPORTANT:
        // Keep this check.
        final registration = data['data']?['registration'];

        log("JSC Registration Exists: ${registration != null}");

        return {
          "success": true,

          // This tells the UI whether the user already
          // has a JSC registration.
          "hasRegistration": registration != null,

          // Keep the complete data.
          "data": data['data'],

          "message": data['message'],
        };
      }

      // ----------------------------------------------------------
      // ERROR RESPONSE
      // ----------------------------------------------------------

      return {
        "success": false,
        "hasRegistration": false,
        "message": data["message"] ?? "Unable to load JSC application.",
      };
    } catch (e, stackTrace) {
      log("GET JSC APPLICATION ERROR: $e", stackTrace: stackTrace);

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
}
