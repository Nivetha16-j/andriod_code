import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/services/session_manager.dart';
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
  final bool isLogin;
  final Map<String, dynamic>? loginUser;
  final String? loginToken;

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

    this.isLogin = false,
    this.loginUser,
    this.loginToken,
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
      // ==========================
      // EMAIL LOGIN
      // ==========================
      if (widget.isLogin && widget.email != null && widget.email!.isNotEmpty) {
        final response = await http.post(
          Uri.parse("https://staging.junubullion.com/api/verify-login-otp"),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({"email": widget.email, "otp": _enteredOtp}),
        );

        final responseData = jsonDecode(response.body);

        if (responseData["status"] == true) {
          await SessionManager.saveLogin(
            user: responseData["data"],
            token: responseData["token"],
          );

          _showToast("Login Successful");

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          }
        } else {
          _showToast(responseData["message"] ?? "Invalid OTP", isError: true);
        }

        return;
      }

      // ==========================
      // PHONE LOGIN / REGISTRATION
      // ==========================
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _enteredOtp,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      String? firebaseToken = await userCredential.user?.getIdToken(true);

      log("Firebase User: ${userCredential.user?.uid}");

      log("Firebase Token - $firebaseToken");

      if (firebaseToken == null) {
        throw Exception("Unable to get Firebase token");
      }

      /// ============================
      /// LOGIN FLOW0
      /// ============================
      log("isloggggg ${widget.isLogin}");
      if (widget.isLogin) {
        log(
          "IsLoginnnnnn ${widget.isLogin}........${widget.loginToken}......${widget.loginUser}",
        );
        // await SessionManager.saveLogin(widget.loginUser!);
        if (widget.loginUser != null && widget.loginToken != null) {
          await SessionManager.saveLogin(
            user: widget.loginUser!,
            token: widget.loginToken!,
          );

          final loggedIn = await SessionManager.isLoggedIn();
          final user = await SessionManager.getUser();
          final token = await SessionManager.getToken();

          log("isLoggedIn = $loggedIn");
          log("user = $user");
          log("token = $token");
        }

        if (mounted) {
          _showToast("Login Successful");

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }

        return;
      }

      /// ============================
      /// REGISTRATION FLOW
      /// ============================

      final fullName = "${widget.fname ?? ""} ${widget.lname ?? ""}".trim();

      log(
        "Payloadddddd $fullName ${widget.email} ${widget.phoneNumber} ${widget.password} ${widget.passwordConfirmation} ${widget.countryId} ${firebaseToken}",
      );

      final payload = {
        "name": fullName,
        "email": widget.email ?? "",
        "phone_number": widget.phoneNumber,
        "password": widget.password ?? "",
        "password_confirmation": widget.passwordConfirmation ?? "",
        "country_id": widget.countryId,
        "address": "",
        "firebase_token": firebaseToken,
      };

      final response = await http.post(
        Uri.parse("https://staging.junubullion.com/api/verify-register-otp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      log("Reeeeeee ${responseData}");

      if (responseData["status"] == true) {
        await SessionManager.saveLogin(
          user: responseData["data"],
          token: responseData["token"],
        );

        if (mounted) {
          _showToast("Registration Successful");

          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        }
      } else {
        _showToast(
          responseData["message"] ?? "Registration failed",
          isError: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showToast(e.message ?? "Invalid OTP", isError: true);
    } catch (e) {
      log("eeeeeeeeeeee ${e.toString()}");

      _showToast("Something went wrong", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    final bool isEmailOtp = widget.email != null && widget.email!.isNotEmpty;

    final String displayValue = isEmailOtp ? widget.email! : widget.phoneNumber;

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
                    isEmailOtp
                        ? "Enter the verification code we sent to your registered email $displayValue."
                        : "Enter the verification code we just sent to your number ${_maskPhoneNumber(displayValue)}.",
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
