import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:junubullion/screens/main_screen.dart';
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

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  PlatformFile? selectedPhoto;

  final TextEditingController fullNameController = TextEditingController(
    text: "Keerthi S Nair",
  );

  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idTypeController = TextEditingController();
  final TextEditingController idNumController = TextEditingController();
  final TextEditingController nomineeNameController = TextEditingController();
  final TextEditingController relationshipController = TextEditingController();
  final TextEditingController nDobController = TextEditingController();
  final TextEditingController nMobileController = TextEditingController();
  final TextEditingController nAddressController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    emailController.dispose();
    mobileController.dispose();
    nationalityController.dispose();
    occupationController.dispose();
    addressController.dispose();
    idTypeController.dispose();
    idNumController.dispose();
    nomineeNameController.dispose();
    relationshipController.dispose();
    nDobController.dispose();
    nMobileController.dispose();
    relationshipController.dispose();
    nAddressController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedPhoto = result.files.first;
      });
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
                _buildPersonalInformation(),
                _buildIdentityVerification(),
                _buildNominee(),

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
            child: _buildStep(number: "1", title: "Info", active: true),
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
            child: _buildStep(number: "2", title: "Verify", active: false),
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
            child: _buildStep(number: "3", title: "Nominee", active: false),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required bool active,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primaryRed
                : Color.fromRGBO(251, 226, 223, 1),
            borderRadius: BorderRadius.circular(11),
            border: active
                ? null
                : Border.all(color: Color.fromRGBO(251, 226, 223, 1)),
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
                    readOnly: false,
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
                    color: Color.fromRGBO(255, 186, 73, 1),
                    size: 36,
                  ),
                ],
              ),
            ),
          ),

          if (isIdentityExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Identity Controller"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: idTypeController,
                    readOnly: false,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),

                  // Add other fields here
                  _buildLabel("Identity Number"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: idNumController,
                    readOnly: true,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
        ],
      ),
    );
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
                  _buildTextField(
                    controller: relationshipController,
                    readOnly: false,
                    maxLines: 1,
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

                  _buildLabel("Mobile Number"),
                  const SizedBox(height: 9),
                  _buildTextField(
                    controller: nMobileController,
                    readOnly: true,
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
          // PHOTO
          Container(
            width: 152,
            height: 152,
            // decoration: BoxDecoration(
            //   color: const Color(0xff91B9DE),
            //   image: selectedPhoto?.bytes != null
            //       ? DecorationImage(
            //           image: MemoryImage(selectedPhoto!.bytes!),
            //           fit: BoxFit.cover,
            //         )
            //       : null,
            // ),
            child: selectedPhoto == null
                ? Image.asset("assets/before_upload.png")
                : null,
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

          // BROWSE FILES BUTTON
          SizedBox(
            width: 170,
            height: 46,
            child: ElevatedButton(
              onPressed: pickPhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(200, 157, 8, 1),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                "BROWSE FILES",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
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
