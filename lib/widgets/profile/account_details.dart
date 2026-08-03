import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/account_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 3;

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AccountProvider>();

      await provider.fetchAccountDetails();

      if (!mounted) return;

      nameController.text = provider.name;
      emailController.text = provider.email;
      phoneController.text = provider.phone;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Account screen build");
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Account Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            buildTextField(label: "Name", controller: nameController),

            const SizedBox(height: 18),

            buildTextField(
              label: "Email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),

            const SizedBox(height: 18),

            buildTextField(
              label: "Phone Number",
              controller: phoneController,
              keyboardType: TextInputType.phone,
              readOnly: true,
            ),

            const SizedBox(height: 22),

            Consumer<AccountProvider>(
              builder: (context, provider, child) {
                return buildButton(
                  text: provider.isLoading ? "Saving..." : "Save Changes",
                  onPressed: provider.isLoading
                      ? () {}
                      : () async {
                          final success = await provider.updateAccountDetails(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            phone: phoneController.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Account updated successfully"
                                    : "Failed to update account",
                              ),
                            ),
                          );
                        },
                );
              },
            ),

            const SizedBox(height: 34),

            const Text(
              "Password Change",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            buildTextField(
              label: "Current Password",
              controller: currentPasswordController,
              obscure: true,
            ),

            const SizedBox(height: 18),

            buildTextField(
              label: "New Password",
              controller: newPasswordController,
              obscure: true,
            ),

            const SizedBox(height: 18),

            buildTextField(
              label: "Confirm New Password",
              controller: confirmPasswordController,
              obscure: true,
            ),

            const SizedBox(height: 22),

            Consumer<AccountProvider>(
              builder: (context, provider, child) {
                return buildButton(
                  text: provider.isLoading ? "Updating..." : "Update Password",
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (currentPasswordController.text.isEmpty ||
                              newPasswordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please fill all password fields",
                                ),
                              ),
                            );
                            return;
                          }

                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }

                          // Verify current password
                          final verify = await provider.verifyPassword(
                            currentPasswordController.text.trim(),
                          );

                          if (verify["status"] != true ||
                              verify["valid"] != true) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  verify["message"] ??
                                      "Current password is incorrect.",
                                ),
                              ),
                            );
                            return;
                          }

                          // Update password
                          final success = await provider.updatePassword(
                            currentPassword: currentPasswordController.text
                                .trim(),
                            password: newPasswordController.text.trim(),
                            passwordConfirmation: confirmPasswordController.text
                                .trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Password updated successfully"
                                    : "Failed to update password",
                              ),
                            ),
                          );

                          if (success) {
                            currentPasswordController.clear();
                            newPasswordController.clear();
                            confirmPasswordController.clear();
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildButton({required String text, VoidCallback? onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 46,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff8F2424),
        disabledBackgroundColor: Colors.grey,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
  );
}

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          // filled: true,
          // fillColor: const Color(0xffF8F6F1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xffDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xffDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xff8F2424)),
          ),
        ),
      ),
    ],
  );
}
