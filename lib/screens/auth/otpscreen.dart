import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/theme/app_colors.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? email;
  final int? countryId;
  final String? fname;
  final String? lname;
  final String? password;
  final String? passwordConfirmation;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.email,
    this.countryId,
    this.fname,
    this.lname,
    this.password,
    this.passwordConfirmation,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String _enteredOtp = "";
  bool _isLoading = false;

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppColors.primaryRed : Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Future<void> _verifyAndSubmitOtp() async {
    if (_enteredOtp.length != 6) {
      _showToast("Please enter a complete 6-digit OTP", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String verificationId = widget.verificationId.toString();

      if (verificationId == null || verificationId.isEmpty) {
        throw Exception("Verification ID is missing. Please resend OTP.");
      }

      log("Verifying OTP credential.");

      // 1. Authenticate with Firebase
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: _enteredOtp,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // 2. Fetch JWT Token
      String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null) {
        throw Exception("Failed to retrieve Firebase Token.");
      }

      log("Firebase ID token obtained.");

      // 3. Concatenate First Name and Last Name
      final String firstName = widget.fname?.toString() ?? "";
      final String lastName = widget.lname?.toString() ?? "";
      final String fullName = "$firstName $lastName".trim();

      // 4. Construct Registration Payload
      final Map<String, dynamic> insertPayload = {
        "name": fullName,
        "email": widget.email ?? "",
        "phone_number": widget.phoneNumber,
        "password": widget.password ?? "",
        "password_confirmation": widget.passwordConfirmation,
        "country_id": widget.countryId,
        "address": "",
        "firebase_token": firebaseToken,
      };

      log("Submitting verified registration request.");

      // 5. Submit to Backend API
      final response = await http.post(
        Uri.parse("https://staging.junubullion.com/api/verify-otp"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(insertPayload),
      );

      log("Insert User Response Code: ${response.statusCode}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      final bool isSuccess =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          responseData['status'] == true ||
          responseData['status'] == 'true';

      if (isSuccess) {
        if (mounted) {
          _showToast("Registration successful!");
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        final message =
            responseData['message'] ?? "Backend registration failed.";
        if (mounted) {
          _showToast(message.toString(), isError: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Exception: ${e.message}");
      if (mounted) {
        _showToast(e.message ?? "Invalid OTP code", isError: true);
      }
    } catch (e) {
      log("Error during registration insertion: $e");
      if (mounted) {
        _showToast("An error occurred during verification.", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _maskPhoneNumber(String phone) {
    final cleanPhone = phone.replaceAll(' ', '');
    if (cleanPhone.length < 8) return cleanPhone;

    String start = cleanPhone.substring(0, 5);
    String end = cleanPhone.substring(cleanPhone.length - 2);

    return "$start ******* $end";
  }

  @override
  Widget build(BuildContext context) {
    final String displayPhoneNumber = (widget.phoneNumber).toString();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'OTP Sent !',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Enter the verification code we just sent to your number ${_maskPhoneNumber(displayPhoneNumber)}.",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(128, 128, 127, 1),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // OTP Input Field
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: const Color.fromRGBO(0, 0, 0, 0.15),
                    focusedBorderColor: AppColors.primaryRed,
                    showFieldAsBox: true,
                    fieldWidth: 46.0,
                    borderRadius: BorderRadius.circular(10.0),
                    filled: true,
                    cursorColor: AppColors.primaryRed,
                    fillColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onCodeChanged: (String code) {
                      _enteredOtp = code;
                    },
                    onSubmit: (String verificationCode) {
                      setState(() {
                        _enteredOtp = verificationCode;
                      });
                      _verifyAndSubmitOtp();
                    },
                  ),

                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyAndSubmitOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(
                            128,
                            128,
                            127,
                            1,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
