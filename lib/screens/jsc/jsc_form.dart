import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/jsc_services.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class JscApplicationForm extends StatefulWidget {
  const JscApplicationForm({super.key});

  @override
  State<JscApplicationForm> createState() => _JscApplicationFormState();
}

class _JscApplicationFormState extends State<JscApplicationForm> {
  bool isPersonalInfoExpanded = true;
  bool isIdentityExpanded = true;
  bool isNomineeExpanded = true;
  int _currentIndex = 0;
  String? selectedIdType;
  String? selectedRelationship;
  bool isDeclarationAccepted = false;

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _personalInfoKey = GlobalKey();
  final GlobalKey _identityVerificationKey = GlobalKey();
  final GlobalKey _nomineeKey = GlobalKey();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PlatformFile? selectedPhoto;
  int _selectedStep = 0;

  bool isUploadingPhoto = false;

  // String? selectedIdType;

  List<PlatformFile> selectedIdentityFiles = [];

  bool isSubmitting = false;

  bool isUploadingIdentityFiles = false;

  TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idNumController = TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController nDobController = TextEditingController();
  final TextEditingController nMobileController = TextEditingController();
  final TextEditingController nAddressController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    mobileController.dispose();
    nationalityController.dispose();
    occupationController.dispose();
    addressController.dispose();
    idNumController.dispose();
    nomineeNameController.dispose();
    nDobController.dispose();
    nMobileController.dispose();
    nAddressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final user = await SessionManager.getUser();
    log("uuuuuuu $user");

    setState(() {
      fullNameController.text = user?["name"] ?? "";
      emailController.text = user?["email"] ?? "";
      mobileController.text = user?["phone_number"] ?? "";
    });
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;

    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> pickPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      const maxFileSize = 2 * 1024 * 1024;

      if (file.size > maxFileSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Image size must be less than or equal to 2 MB."),
            ),
          );
        }
        return;
      }

      setState(() {
        isUploadingPhoto = true;
      });

      // If you have an API upload, do it here.
      // await uploadPhoto(file);

      setState(() {
        selectedPhoto = file;
        isUploadingPhoto = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingPhoto = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to select image: $e")));
      }
    }
  }

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}/"
            "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.year}";
      });
    }
  }

  Future<void> selectNomineeDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );

    if (pickedDate != null) {
      setState(() {
        nDobController.text =
            "${pickedDate.day.toString().padLeft(2, '0')}/"
            "${pickedDate.month.toString().padLeft(2, '0')}/"
            "${pickedDate.year}";
      });
    }
  }

  Future<void> submitJscApplication() async {
    // -----------------------------------------
    // DECLARATION VALIDATION
    // -----------------------------------------
    if (!isDeclarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the declaration before submitting."),
        ),
      );
      return;
    }

    // -----------------------------------------
    // IDENTITY TYPE VALIDATION
    // -----------------------------------------
    if (selectedIdType == null || selectedIdType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an identity type.")),
      );
      return;
    }

    // -----------------------------------------
    // IDENTITY FILE VALIDATION
    // -----------------------------------------
    if (selectedIdentityFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload your identity document.")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await JscService.submitJscApplication(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        dob: dobController.text.trim(),
        mobile: mobileController.text.trim(),
        nationality: nationalityController.text.trim(),
        occupation: occupationController.text.trim(),
        residentialAddress: addressController.text.trim(),

        identityType: selectedIdType!,
        identityNumber: idNumController.text.trim(),

        nomineeName: nomineeNameController.text.trim(),
        nomineeRelationship: selectedRelationship ?? "",
        nomineeDob: nDobController.text.trim(),
        nomineeMobile: nMobileController.text.trim(),
        nomineeAddress: nAddressController.text.trim(),

        declarationAccepted: isDeclarationAccepted,

        // PHOTO
        photo: selectedPhoto,

        // IDENTITY DOCUMENTS
        identityFiles: selectedIdentityFiles,
      );

      log("JSC RESPONSE: $response");

      if (!mounted) return;

      if (response["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("JSC application submitted successfully."),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 0)),
          (route) => false,
        );

        // Optional:
        // Navigator.pop(context);
      } else {
        final body = response["body"];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              body?["message"]?.toString() ??
                  "Failed to submit JSC application.",
            ),
          ),
        );
      }
    } catch (e) {
      log("JSC SUBMIT ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------
                const Text(
                  "JSC Application Form",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Complete your application to start investing in premium bullion.",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // STEP INDICATOR
                // ------------------------------------------------
                _buildStepIndicator(),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // INFO MESSAGE
                // ------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(230, 255, 238, 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Your Account Details Have Been Pre-Filled.\n"
                    "Please Complete The Remaining Fields.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                // ------------------------------------------------
                // PERSONAL INFORMATION
                // ------------------------------------------------
                Container(
                  key: _personalInfoKey,
                  child: _buildPersonalInformation(),
                ),
                Container(
                  key: _identityVerificationKey,
                  child: _buildIdentityVerification(),
                ),
                Container(key: _nomineeKey, child: _buildNominee()),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Declaration
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 28,
                      ),
                      color: AppColors.pink,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isDeclarationAccepted,
                            onChanged: (value) {
                              setState(() {
                                isDeclarationAccepted = value ?? false;
                              });
                            },
                            activeColor: const Color(0xff941A1D),
                            side: const BorderSide(
                              color: Color(0xff941A1D),
                              width: 3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                "I hereby declare that the information provided above is true and correct. I agree to the Terms & Conditions of the account.",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff242424),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        // onPressed: () {
                        //   // if (!isDeclarationAccepted) {
                        //   //   ScaffoldMessenger.of(context).showSnackBar(
                        //   //     const SnackBar(
                        //   //       content: Text(
                        //   //         "Please accept the declaration before submitting.",
                        //   //       ),
                        //   //     ),
                        //   //   );
                        //   //   return;
                        //   // }

                        //   // Submit logic here
                        // },
                        onPressed: isSubmitting ? null : submitJscApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff941A1D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "SUBMIT",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        // const Text(
                        //   "SUBMIT",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
    );
  }

  void _switchToTab(int index) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  // ==============================================================
  // STEP INDICATOR
  // ==============================================================

  Widget _buildStepIndicator() {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // STEP 1
          Expanded(
            child: _buildStep(
              number: "1",
              title: "Info",
              active: _selectedStep == 0,
              onPressed: () {
                setState(() {
                  _selectedStep = 0;
                });

                _scrollToSection(_personalInfoKey);
              },
            ),
          ),

          // LINE
          Container(
            width: 75,
            height: 1,
            color: const Color(0xffF0D2D2),
            margin: const EdgeInsets.only(bottom: 25),
          ),

          // STEP 2
          Expanded(
            child: _buildStep(
              number: "2",
              title: "Verify",
              active: _selectedStep == 1,
              onPressed: () {
                setState(() {
                  _selectedStep = 1;
                });

                _scrollToSection(_identityVerificationKey);
              },
            ),
          ),

          // LINE
          Container(
            width: 75,
            height: 1,
            color: const Color(0xffF0D2D2),
            margin: const EdgeInsets.only(bottom: 25),
          ),

          // STEP 3
          Expanded(
            child: _buildStep(
              number: "3",
              title: "Nominee",
              active: _selectedStep == 2,
              onPressed: () {
                setState(() {
                  _selectedStep = 2;
                });

                _scrollToSection(_nomineeKey);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required bool active,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryRed
                  : const Color.fromRGBO(251, 226, 223, 1),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primaryRed : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PERSONAL INFORMATION
  // ==============================================================

  Widget _buildPersonalInformation() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffFCFBF6),
        border: Border.all(color: const Color(0xffE3E0D7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------
          // RED HEADER
          // ------------------------------------------------
          InkWell(
            onTap: () {
              setState(() {
                isPersonalInfoExpanded = !isPersonalInfoExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              height: 67,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const BoxDecoration(color: Color(0xff97191D)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Personal Information",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 186, 73, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Icon(
                    isPersonalInfoExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color.fromRGBO(255, 186, 73, 1),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),

          if (isPersonalInfoExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // PHOTO UPLOAD
                  // ------------------------------------------------
                  _buildPhotoUpload(),

                  const SizedBox(height: 26),

                  // ------------------------------------------------
                  // FULL NAME
                  // ------------------------------------------------
                  _buildLabel("Full Name"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: fullNameController,
                    readOnly: true,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // DATE OF BIRTH
                  // ------------------------------------------------
                  _buildLabel("Date Of Birth"),
                  const SizedBox(height: 9),
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: selectDate,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffFCFBF6),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Add other fields here
                  _buildLabel("Email Address"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: emailController,
                    readOnly: true,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Mobile Number"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: mobileController,
                    readOnly: true,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Nationality"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: nationalityController,
                    readOnly: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Occupation"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: occupationController,
                    readOnly: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Residential Address"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: addressController,
                    readOnly: false,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIdentityVerification() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffFCFBF6),
        border: Border.all(color: const Color(0xffE3E0D7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------
          // RED HEADER
          // ------------------------------------------------
          InkWell(
            onTap: () {
              setState(() {
                isIdentityExpanded = !isIdentityExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              height: 67,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const BoxDecoration(color: Color(0xff97191D)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Identity Verification",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 186, 73, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Icon(
                    isIdentityExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color.fromRGBO(255, 186, 73, 1),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------
          // CONTENT
          // ------------------------------------------------
          if (isIdentityExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // IDENTITY TYPE
                  // ------------------------------------------------
                  _buildLabel("Identity Type"),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedIdType,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffA7191F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1.5,
                        ),
                      ),
                    ),
                    hint: const Text(
                      "Select Identity Type",
                      style: TextStyle(fontSize: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Aadhar", child: Text("Aadhar")),
                      DropdownMenuItem(
                        value: "PAN Card",
                        child: Text("PAN Card"),
                      ),
                      DropdownMenuItem(
                        value: "Passport",
                        child: Text("Passport"),
                      ),
                      DropdownMenuItem(
                        value: "Driving License",
                        child: Text("Driving License"),
                      ),
                      DropdownMenuItem(value: "NRIC", child: Text("NRIC")),
                      DropdownMenuItem(value: "FIN", child: Text("FIN")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedIdType = value;

                        // Clear previously uploaded files
                        selectedIdentityFiles.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // IDENTITY NUMBER
                  // ------------------------------------------------
                  _buildLabel("Identity Number"),
                  const SizedBox(height: 9),

                  _buildTextField(
                    controller: idNumController,
                    readOnly: false,
                    maxLines: 1,
                  ),

                  // =================================================
                  // SHOW UPLOAD ONLY AFTER IDENTITY TYPE IS SELECTED
                  // =================================================
                  if (selectedIdType != null) ...[
                    const SizedBox(height: 25),

                    _buildLabel("Upload ${selectedIdType!} Document"),

                    const SizedBox(height: 8),

                    const Text(
                      "Please upload the Front & Back documents.",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffA7191F),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Upload up to 2 files (Front & Back) in JPG, JPEG or PNG format. Max 5 MB each.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // UPLOAD BUTTON
                    // ------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: isUploadingIdentityFiles
                            ? null
                            : pickIdentityFiles,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xffFCFBF6),
                          side: const BorderSide(
                            color: Color(0xffA7191F),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: isUploadingIdentityFiles
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xffA7191F),
                                ),
                              )
                            : const Icon(
                                Icons.upload_file,
                                color: Color(0xffA7191F),
                              ),
                        label: Text(
                          isUploadingIdentityFiles
                              ? "Uploading..."
                              : selectedIdentityFiles.length >= 2
                              ? "2 Files Selected"
                              : "Choose Files",
                          style: const TextStyle(
                            color: Color(0xffA7191F),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // IMAGE PREVIEWS
                    // ------------------------------------------------
                    if (selectedIdentityFiles.isNotEmpty)
                      Column(
                        children: selectedIdentityFiles.asMap().entries.map((
                          entry,
                        ) {
                          final index = entry.key;
                          final file = entry.value;

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffE0E0E0),
                              ),
                            ),
                            child: Row(
                              children: [
                                // --------------------------------
                                // IMAGE
                                // --------------------------------
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: file.bytes != null
                                      ? Image.memory(
                                          file.bytes!,
                                          width: 90,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 90,
                                          height: 70,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 12),

                                // --------------------------------
                                // FILE DETAILS
                                // --------------------------------
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   index == 0
                                      //       ? "Front Document"
                                      //       : "Back Document",
                                      //   style: const TextStyle(
                                      //     fontSize: 13,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),

                                      // const SizedBox(height: 4),
                                      Text(
                                        file.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // --------------------------------
                                // REMOVE
                                // --------------------------------
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIdentityFiles.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xffA7191F),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> pickIdentityFiles() async {
    try {
      // How many more files can be selected
      final remainingFiles = 2 - selectedIdentityFiles.length;

      if (remainingFiles <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can upload only 2 files.")),
        );
        return;
      }

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      // Check if total files exceed 2
      if (selectedIdentityFiles.length + result.files.length > 2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You can upload a maximum of 2 files."),
            ),
          );
        }
        return;
      }

      // 5 MB per file
      const maxFileSize = 5 * 1024 * 1024;

      for (final file in result.files) {
        if (file.size > maxFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${file.name} is larger than 5 MB.")),
            );
          }
          return;
        }

        // Make sure bytes are available for preview
        if (file.bytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Unable to read ${file.name}.")),
            );
          }
          return;
        }
      }

      setState(() {
        isUploadingIdentityFiles = true;
      });

      // Add instead of replacing
      setState(() {
        selectedIdentityFiles.addAll(result.files);
        isUploadingIdentityFiles = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isUploadingIdentityFiles = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to select files: $e")));
      }
    }
  }

  Widget _buildNominee() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffFCFBF6),
        border: Border.all(color: const Color(0xffE3E0D7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ------------------------------------------------
          // RED HEADER
          // ------------------------------------------------
          InkWell(
            onTap: () {
              setState(() {
                isNomineeExpanded = !isNomineeExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              height: 67,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: const BoxDecoration(color: Color(0xff97191D)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nominee Details",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 186, 73, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Icon(
                    isNomineeExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Color.fromRGBO(255, 186, 73, 1),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),

          if (isNomineeExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nominee Name"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: nomineeNameController,
                    readOnly: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Relationship"),
                  const SizedBox(height: 9),

                  DropdownButtonFormField<String>(
                    value: selectedRelationship,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xffFCFBF6),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1.5,
                        ),
                      ),
                    ),
                    hint: const Text(
                      "Select Relationship",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    items: const [
                      DropdownMenuItem(value: "Father", child: Text("Father")),
                      DropdownMenuItem(value: "Mother", child: Text("Mother")),
                      DropdownMenuItem(value: "Spouse", child: Text("Spouse")),
                      DropdownMenuItem(value: "Son", child: Text("Son")),
                      DropdownMenuItem(
                        value: "Daughter",
                        child: Text("Daughter"),
                      ),
                      DropdownMenuItem(
                        value: "Brother",
                        child: Text("Brother"),
                      ),
                      DropdownMenuItem(value: "Sister", child: Text("Sister")),
                      DropdownMenuItem(value: "Friend", child: Text("Friend")),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRelationship = value;
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  // ------------------------------------------------
                  // DATE OF BIRTH
                  // ------------------------------------------------
                  _buildLabel("Date Of Birth"),
                  const SizedBox(height: 9),
                  TextField(
                    controller: nDobController,
                    readOnly: true,
                    onTap: selectNomineeDate,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffFCFBF6),
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffA7191F),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Mobile Number"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: nMobileController,
                    readOnly: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Nominee Address"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: nAddressController,
                    readOnly: false,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // PHOTO UPLOAD
  // ==============================================================

  Widget _buildPhotoUpload() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xffD9D9D9),
        border: Border.all(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Column(
            children: [
              // Image preview
              if (selectedPhoto != null && selectedPhoto!.bytes != null)
                ClipRRect(
                  // borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    selectedPhoto!.bytes!,
                    width: 170,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 170,
                  height: 150,
                  child: Image.asset("assets/before_upload.png"),
                ),
              const SizedBox(height: 10),

              const Text(
                "Passport Size Photo\n"
                "(JPG / PNG\n"
                "(Max 2 MB))",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 17),

              // Browse button
              SizedBox(
                width: 170,
                height: 46,
                child: ElevatedButton(
                  onPressed: isUploadingPhoto ? null : pickPhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(200, 157, 8, 1),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color.fromRGBO(
                      200,
                      157,
                      8,
                      0.6,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: isUploadingPhoto
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          "BROWSE FILES",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // LABEL
  // ==============================================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  // ==============================================================
  // TEXT FIELD
  // ==============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    bool readOnly = false,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xffFCFBF6),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffA7191F), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffA7191F), width: 1.5),
        ),
      ),
    );
  }
}
