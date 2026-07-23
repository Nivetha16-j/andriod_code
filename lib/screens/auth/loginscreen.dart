import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                // CustomTextField(
                //   label: "Password",
                //   hintText: "Enter Password",
                //   controller: passwordController,
                //   keyboardType: TextInputType.visiblePassword,
                //   obscureText: obscurePassword,
                //   suffixIcon: IconButton(
                //     icon: Icon(
                //       obscurePassword ? Icons.visibility_off : Icons.visibility,
                //     ),
                //     onPressed: () {
                //       setState(() {
                //         obscurePassword = !obscurePassword;
                //       });
                //     },
                //   ),
                // ),

                // const SizedBox(height: 15),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Row(
                //       children: [
                //         Checkbox(
                //           value: rememberMe,
                //           onChanged: (value) {
                //             setState(() {
                //               rememberMe = value!;
                //             });
                //           },
                //         ),
                //         Text(
                //           "Remember Me",
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w600,
                //             color: Color.fromRGBO(119, 122, 124, 1),
                //           ),
                //         ),
                //       ],
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         // Handle forgot password logic here
                //       },
                //       child: const Text(
                //         "Forgot Password?",
                //         style: TextStyle(
                //           fontSize: 20,
                //           fontWeight: FontWeight.w600,
                //           color: Color.fromRGBO(133, 34, 33, 1),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                CustomButton(
                  label: "Login",
                  height: 70,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  borderRadius: 50,
                  padding: const EdgeInsets.all(25),
                  onPressed: () {
                    // Login logic
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
                              // Navigator.pushNamed(context, AppRoutes.register);
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/home',
                                (route) => false,
                              );
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
