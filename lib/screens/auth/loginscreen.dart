import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/auth/otpscreen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_button.dart';
import 'package:junubullion/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppColors.primaryRed : Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> loginUser() async {
    log("////////");
    if (emailController.text.trim().isEmpty) {
      _showToast("Please enter Email or Phone Number", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    log("nooooooooo ${emailController.text.trim()}");

    try {
      final response = await http.post(
        Uri.parse("https://staging.junubullion.com/api/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"login": emailController.text.trim()}),
      );

      log("response.bodyyyy ${response.body}");

      final responseData = jsonDecode(response.body);

      if (responseData["status"] == true) {
        final type = responseData["type"];

        if (type == "email") {
          Fluttertoast.showToast(
            msg:
                "OTP has been sent to your registered email. Please check your inbox.",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPScreen(
                phoneNumber: "",
                verificationId: "",
                email: emailController.text.trim(),
                isLogin: true,
                loginUser: responseData["data"],
                loginToken: responseData["token"],
              ),
            ),
          );
        } else {
          await sendOtp(
            phoneNumber: emailController.text.trim(),
            user: responseData["data"],
            token: responseData["token"],
          );
        }
      } else if (responseData["message"] == "Customer not found.") {
        _showToast(
          "${responseData["message"]} Try login with a different account.",
          isError: true,
        );
      } else {
        _showToast("Unexpected response from server", isError: true);
      }
    } catch (e) {
      log("errorrrrrrrr ${e.toString()}");

      _showToast("Something went wrong", isError: true);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Map<String, dynamic> user,
    required String token,
  }) async {
    log("ppppppppppp $phoneNumber.......");
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {},

      verificationFailed: (FirebaseAuthException e) {
        _showToast(e.message ?? "OTP Failed", isError: true);
      },

      codeSent: (String verificationId, int? resendToken) {
        _showToast("OTP Sent to this number");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              isLogin: true,
              loginUser: user,
              loginToken: token,
            ),
          ),
        );
      },

      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 248, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                ),
                const SizedBox(height: 15),
                Text(
                  "To get full profile and unlimited searches, please login or register.",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  label: "Email or Phone Number",
                  hintText: "Enter Email or Phone Number",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                CustomButton(
                  label: "Login",
                  height: 70,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  borderRadius: 50,
                  padding: const EdgeInsets.all(25),
                  onPressed: () {
                    log("messageeeeeee");
                    if (!_isLoading) {
                      log("message...........");
                      loginUser();
                    }
                  },
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      children: [
                        const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Register',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, AppRoutes.register);
                              // Navigator.pushNamedAndRemoveUntil(
                              //   context,
                              //   '/home',
                              //   (route) => false,
                              // );
                            },

                          style: const TextStyle(
                            color: AppColors
                                .primaryRed, // Different color for this word
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
