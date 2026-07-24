import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/screens/auth/otpscreen.dart';
import 'package:junubullion/services/country_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_button.dart';
import 'package:junubullion/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Selected Country ID variable
  dynamic selectedCountryId;

  // Future to hold the API request
  late Future<List<Country>> _countriesFuture;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  void _fetchCountries() {
    _countriesFuture = CountryService.fetchCountries();
  }

  // @override
  // void dispose() {
  //   firstNameController.dispose();
  //   lastNameController.dispose();
  //   emailController.dispose();
  //   phoneController.dispose();
  //   countryController.dispose();
  //   passwordController.dispose();
  //   confirmPasswordController.dispose();
  //   super.dispose();
  // }

  // --- Validation Methods ---

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final trimmed = value.trim();
    final phoneWithCodeRegex = RegExp(r'^\+[0-9]{7,15}$');

    if (!phoneWithCodeRegex.hasMatch(trimmed)) {
      return 'Enter full number with country code (e.g., +6570903029)';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppColors.primaryRed : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // --- Submission Handler ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final String fullPhoneNumber = phoneController.text.trim();
    final String email = emailController.text.trim();

    log("Submitting registration pre-check.");

    try {
      // STEP 1: Dry run/validation request to check if email or phone exists
      final url = Uri.parse("https://staging.junubullion.com/api/register");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "name":
              "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
          "email": email,
          "phone_number": fullPhoneNumber,
          "country_id": selectedCountryId,
          "address": countryController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
        }),
      );

      log("Check Status Code: ${response.statusCode}");

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if email or phone already exists
      if (responseData.containsKey('errors') && responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;

        final bool emailExists =
            errors.containsKey('email') &&
            errors['email'] is List &&
            (errors['email'] as List).isNotEmpty;

        final bool phoneExists =
            errors.containsKey('phone_number') &&
            errors['phone_number'] is List &&
            (errors['phone_number'] as List).isNotEmpty;

        if (mounted) {
          setState(() => _isLoading = false);

          if (emailExists && phoneExists) {
            _showToast(
              "Email and Phone number already exist. Try login.",
              isError: true,
            );
            return;
          }

          if (emailExists) {
            _showToast(
              "Email already exists. Try login with the same email.",
              isError: true,
            );
            return;
          }

          if (phoneExists) {
            _showToast(
              "Phone number already exists. Try login with the same Phone number.",
              isError: true,
            );
            return;
          }
        }
      }

      // 4. If user does NOT exist, send OTP via Firebase
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          log("Firebase Phone Auth Failed: ${e.message}");
          if (mounted) {
            setState(() => _isLoading = false);
            _showToast(
              e.message ?? "Phone verification failed.",
              isError: true,
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          log("Firebase OTP code sent.");

          if (mounted) {
            setState(() => _isLoading = false);

            // Toast: "OTP sent"
            _showToast("OTP sent");

            log("Navigating to OTP verification.");

            // Navigate to OTP screen
            // Navigator.pushNamed(
            //   context,
            //   '/otp',
            //   arguments: {
            //     'phoneNumber': fullPhoneNumber,
            //     'verificationId': verificationId,
            //     'email': email,
            //     'countryId': selectedCountryId,
            //     'firstName': firstNameController.text.trim(),
            //     'lastName': lastNameController.text.trim(),
            //     'password': passwordController.text,
            //     'confirmPassword': confirmPasswordController.text,
            //     'address': countryController.text,
            //   },
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OTPScreen(
                  phoneNumber: fullPhoneNumber,
                  verificationId: verificationId,
                  email: email,
                  countryId: selectedCountryId,
                  fname: firstNameController.text.trim(),
                  lname: lastNameController.text.trim(),
                  password: passwordController.text,
                  passwordConfirmation: confirmPasswordController.text,
                ),
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
    } catch (e) {
      log("Error checking user existence: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast("An error occurred. Please try again.", isError: true);
      }
    }
  }

  // --- Dropdown Field Widget ---

  Widget _buildCountryDropdown() {
    return FutureBuilder<List<Country>>(
      future: _countriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Country"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF5F5F5,
                  ), // Same background as other fields
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Loading countries...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Country"),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Failed to load countries',
                      style: TextStyle(color: AppColors.primaryRed),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        _fetchCountries();
                      });
                    },
                  ),
                ],
              ),
            ],
          );
        }

        final countries = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel("Country"),
            const SizedBox(height: 8),
            DropdownButtonFormField<dynamic>(
              initialValue: selectedCountryId,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              decoration: InputDecoration(
                hintText: "Select Country",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F5F5), // Light gray field fill
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryRed),
                ),
              ),
              items: countries.map((Country country) {
                return DropdownMenuItem<dynamic>(
                  value: country.id,
                  child: Text(
                    country.name,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCountryId = newValue;
                  final selectedCountry = countries.firstWhere(
                    (c) => c.id == newValue,
                  );
                  countryController.text = selectedCountry.name;
                });
              },
              validator: (val) {
                if (val == null) {
                  return "Country is required";
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to create the exact top label with red asterisk
  Widget _buildFieldLabel(String label) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Register here",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Fill the form below to create an account",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 20),

                  // First Name
                  CustomTextField(
                    label: "First Name",
                    hintText: "Enter First Name",
                    controller: firstNameController,
                    validator: (val) => _validateName(val, "First Name"),
                  ),

                  const SizedBox(height: 20),

                  // Last Name
                  CustomTextField(
                    label: "Last Name",
                    hintText: "Enter Last Name",
                    controller: lastNameController,
                    validator: (val) => _validateName(val, "Last Name"),
                  ),

                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    label: "Email",
                    hintText: "Enter Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  // Phone Number
                  CustomTextField(
                    label: "Phone Number",
                    hintText: "+6570903029",
                    helperText: "Include country code (e.g., +91 or +65)",
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),

                  const SizedBox(height: 20),

                  // Country Dropdown
                  _buildCountryDropdown(),

                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    label: "Password",
                    hintText: "Enter Password",
                    controller: passwordController,
                    validator: _validatePassword,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Confirm Password
                  CustomTextField(
                    label: "Confirm Password",
                    hintText: "Confirm Password",
                    controller: confirmPasswordController,
                    validator: _validateConfirmPassword,
                    obscureText: obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Submit Button
                  CustomButton(
                    label: "Submit",
                    isLoading: _isLoading,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
