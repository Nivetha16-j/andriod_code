import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/contact_services.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController firstName = TextEditingController();

  final TextEditingController lastName = TextEditingController();

  final TextEditingController email = TextEditingController();

  final TextEditingController message = TextEditingController();
  bool _isSubmitting = false;

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showMap = false;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> _submitContactForm() async {
    FocusScope.of(context).unfocus();

    final firstNameText = firstName.text.trim();
    final lastNameText = lastName.text.trim();
    final emailText = email.text.trim();
    final description = message.text.trim();

    if (firstNameText.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your first name");
      return;
    }

    if (lastNameText.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your last name");
      return;
    }

    if (emailText.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }

    if (description.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your message");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ContactService.submitContact(
        firstName: firstNameText,
        lastName: lastNameText,
        email: emailText,
        description: description,
      );

      debugPrint("Contact API Response: $response");

      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Message sent successfully.",
        );

        // Clear form after successful submission
        firstName.clear();
        lastName.clear();
        email.clear();
        message.clear();
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? "Failed to send message.",
        );
      }
    } catch (e) {
      debugPrint("Contact API Error: $e");

      Fluttertoast.showToast(msg: "Something went wrong. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAF8),
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND - 75% GRADIENT + 25% WHITE
          // ============================================================
          Positioned.fill(
            child: Column(
              children: [
                // --------------------------------------------------------
                // TOP 75% - GRADIENT
                // --------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.BgGradient),
                  ),
                ),

                // --------------------------------------------------------
                // BOTTOM 25% - WHITE
                // --------------------------------------------------------
                Expanded(
                  child: Container(width: double.infinity, color: Colors.white),
                ),
              ],
            ),
          ),

          // ============================================================
          // SCROLLABLE CONTENT
          // ============================================================
          SingleChildScrollView(
            child: Column(
              children: [
                // ========================================================
                // CONTACT HERO SECTION
                // ========================================================
                Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HERO IMAGE + OVERLAY CONTENT
                      // ==================================================
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            // ------------------------------------------------
                            // BACKGROUND IMAGE
                            // ------------------------------------------------
                            Positioned.fill(
                              child: Image.asset(
                                "assets/contact.png",
                                fit: BoxFit.cover,
                              ),
                            ),

                            // ------------------------------------------------
                            // RED OVERLAY
                            // ------------------------------------------------
                            Positioned.fill(
                              child: Container(
                                color: AppColors.primaryRed.withOpacity(0.55),
                              ),
                            ),

                            // ------------------------------------------------
                            // CONTACT US + CALL + EMAIL
                            // ------------------------------------------------
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // CONTACT US
                                  const TranslatedText(
                                    "CONTACT US",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 35),

                                  // CALL + EMAIL
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // ==================================================
                                        // CALL US
                                        // ==================================================
                                        Expanded(
                                          child: Container(
                                            height: 52,
                                            margin: const EdgeInsets.only(
                                              right: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryRed
                                                  .withOpacity(0.55),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColors.mustard
                                                    .withOpacity(0.6),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const TranslatedText(
                                                  "CALL US",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),

                                                const SizedBox(height: 5),

                                                const TranslatedText(
                                                  "9947532323",
                                                  style: TextStyle(
                                                    color: AppColors.yellow,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // ==================================================
                                        // EMAIL US
                                        // ==================================================
                                        Expanded(
                                          child: Container(
                                            height: 52,
                                            margin: const EdgeInsets.only(
                                              left: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryRed
                                                  .withOpacity(0.55),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColors.mustard
                                                    .withOpacity(0.6),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const TranslatedText(
                                                  "EMAIL US",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),

                                                const SizedBox(height: 5),

                                                const TranslatedText(
                                                  "info@junubullion.com",
                                                  style: TextStyle(
                                                    color: AppColors.yellow,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================================================
                      // LET'S GET IN TOUCH
                      // ==================================================
                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.only(
                          left: 14.0,
                          top: 8,
                          bottom: 8,
                        ),
                        child: const TranslatedText(
                          "Let's Get in Touch",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 9),

                      // ==================================================
                      // CONTACT / MAP SECTION
                      // ==================================================
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                        decoration: BoxDecoration(
                          gradient: AppColors.BgGradient,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==================================================
                            // CONTACT + MAP BUTTONS
                            // ==================================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ------------------------------------------------
                                // CONTACT BUTTON
                                // ------------------------------------------------
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showMap = false;
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      "assets/email.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                // ------------------------------------------------
                                // MAP BUTTON
                                // ------------------------------------------------
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showMap = true;
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      "assets/location.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // FORM / MAP SWITCH
                            // ==================================================
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              child: _showMap
                                  ? _buildMapSection()
                                  : _buildContactFormSection(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      key: const ValueKey("contactForm"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        _field(controller: firstName, hint: "First name"),

        const SizedBox(height: 12),

        _field(controller: lastName, hint: "Last name"),

        const SizedBox(height: 12),

        _field(controller: email, hint: "Your email"),

        const SizedBox(height: 12),

        _field(controller: message, hint: "How can we help you?", maxLines: 5),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitContactForm,
            child: const TranslatedText(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildContactFormSection() {
    return Column(
      key: const ValueKey("contact_form"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),

        const TranslatedText(
          "YOU CAN REACH US ANYTIME",
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 8),

        _contactField(controller: firstName, hint: "First name"),

        const SizedBox(height: 10),

        _contactField(controller: lastName, hint: "Last name"),

        const SizedBox(height: 10),

        _contactField(controller: email, hint: "Your email"),

        const SizedBox(height: 10),

        _contactField(
          controller: message,
          hint: "How can we help you?",
          maxLines: 4,
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitContactForm,
            child: const TranslatedText(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 10),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.55),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.yellow, width: 1),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      key: const ValueKey("map_section"),
      children: [
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/map.png",
            width: double.infinity,
            height: 185,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final uri = Uri.parse(
                "https://maps.app.goo.gl/NUTETVZUYKVcRAoM7",
              );

              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.location_on, color: Colors.white, size: 18),
            label: const TranslatedText(
              "Open in Google Maps",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    return Column(
      key: const ValueKey("map"),
      children: [
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/map.png",
            width: double.infinity,
            height: 185,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final uri = Uri.parse(
                "https://maps.app.goo.gl/NUTETVZUYKVcRAoM7",
              );

              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.location_on, color: Colors.white, size: 20),
            label: const TranslatedText(
              "Open in Google Maps",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryRed),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xffFCE1E1),
          child: Icon(icon, color: AppColors.primaryRed),
        ),
        const SizedBox(width: 14),
        TranslatedText(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
