import 'dart:convert';

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

    // Images
    PlatformFile? photo,
    List<PlatformFile> identityFiles = const [],
  }) async {
    try {
      final token = await SessionManager.getToken();

      // ------------------------------------------------
      // CREATE MULTIPART REQUEST
      // ------------------------------------------------

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/jsc-registration"),
      );

      // ------------------------------------------------
      // HEADERS
      // ------------------------------------------------

      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // ------------------------------------------------
      // TEXT FIELDS
      // ------------------------------------------------

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

      // ------------------------------------------------
      // PHOTO
      // ------------------------------------------------

      if (photo != null) {
        if (photo.path != null && photo.path!.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath("photo", photo.path!),
          );
        }
      }

      // ------------------------------------------------
      // IDENTITY FILES
      // ------------------------------------------------

      for (int i = 0; i < identityFiles.length; i++) {
        final file = identityFiles[i];

        if (file.path != null && file.path!.isNotEmpty) {
          request.files.add(
            await http.MultipartFile.fromPath("identity_files[$i]", file.path!),
          );
        }
      }
      // ------------------------------------------------
      // LOG FILES BEFORE UPLOAD
      // ------------------------------------------------

      print("JSC PHOTO: ${photo?.path}");

      for (final file in identityFiles) {
        print("JSC IDENTITY FILE: ${file.path}");
      }

      // ------------------------------------------------
      // SEND REQUEST
      // ------------------------------------------------

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      print("JSC STATUS CODE: ${response.statusCode}");
      print("JSC RESPONSE: ${response.body}");

      // ------------------------------------------------
      // DECODE RESPONSE
      // ------------------------------------------------

      dynamic body;

      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = {"message": response.body};
      }

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "statusCode": response.statusCode,
        "body": body,
      };
    } catch (e) {
      print("JSC SUBMIT ERROR: $e");

      return {
        "success": false,
        "statusCode": 500,
        "body": {"message": e.toString()},
      };
    }
  }
}
