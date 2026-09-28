import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/kyc_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class KycVerificationCard extends StatefulWidget {
  const KycVerificationCard({super.key});

  @override
  State<KycVerificationCard> createState() => _KycVerificationCardState();
}

class _KycVerificationCardState extends State<KycVerificationCard> {
  File? selectedGovtIdFile;
  File? selectedAddressFile;

  bool isUploadingGovernmentId = false;
  bool isUploadingAddress = false;

  String? governmentFileName;
  String? addressFileName;

  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KycProvider>().fetchKycDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    int _currentIndex = 3;

    void _switchToTab(int index) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
        (route) => false,
      );
    }

    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: Consumer<KycProvider>(
        builder: (context, provider, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.BgGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KYC Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppColors.BgGradient,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            "KYC Verification",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 10),
                          TranslatedText(
                            "Upload valid identification documents to verify\n"
                            "your account. Review usually takes 1–3\n"
                            "business days.",
                            style: TextStyle(color: Colors.white, height: 1.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Verification Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Verification Status",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    TranslatedText(
                                      provider.kycApproved
                                          ? "Your KYC has been approved."
                                          : provider.kycStatus == "pending"
                                          ? "Your verification is under review."
                                          : "No Documents Submitted Yet.",
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: provider.kycApproved
                                      ? Colors.green.shade100
                                      : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TranslatedText(
                                  provider.kycStatus
                                      .replaceAll("_", " ")
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: provider.kycApproved
                                        ? Colors.green
                                        : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                [
                                      ...provider.allowedExtensions.map(
                                        (e) => e.toUpperCase(),
                                      ),
                                      "Max ${provider.maxFileMb} MB Per File",
                                    ]
                                    .map(
                                      (e) => Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.lightRed,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: TranslatedText(
                                          e,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/Upload.png",
                                  height: 15,
                                  width: 15,
                                ),
                                SizedBox(width: 6),
                                const TranslatedText(
                                  "Upload Documents",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const TranslatedText(
                              "Encrypted compliance verification",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.red),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const TranslatedText(
                                      "Passport",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.red),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const TranslatedText(
                                      "National ID Card",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.red),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const TranslatedText(
                                      "Driving Licence",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Government ID Upload
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const TranslatedText(
                                  "Government-Issued ID *",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightRed,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TranslatedText(
                                    "Required",
                                    style: TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            DottedBorder(
                              options: RectDottedBorderOptions(
                                strokeWidth: 1.5,
                                dashPattern: const [6, 4],
                                color: Colors.grey.shade400,
                                // radius: const Radius.circular(18),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8E8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Government ID icon
                                    Image.asset("assets/gid.png"),

                                    const SizedBox(height: 8),

                                    // Browse button
                                    SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final provider = context
                                              .read<KycProvider>();

                                          pickFile(
                                            isGovernmentId: true,
                                            allowedExtensions:
                                                provider.allowedExtensions,
                                            maxFileMb: provider.maxFileMb,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF912323,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        child: isUploadingGovernmentId
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Align(
                                                alignment: Alignment.center,
                                                child: TranslatedText(
                                                  "Browse....",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // File name
                                    TranslatedText(
                                      governmentFileName ?? "No Files Selected",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Proof of Address
                            const TranslatedText(
                              "Proof Of Address (Optional)",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 8),

                            DottedBorder(
                              options: RectDottedBorderOptions(
                                strokeWidth: 1.5,
                                dashPattern: const [6, 4],
                                color: Colors.grey.shade400,
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE8E8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Address document icon
                                    Image.asset("assets/aid.png"),

                                    const SizedBox(height: 16),

                                    // Browse button
                                    SizedBox(
                                      width: 150,
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final provider = context
                                              .read<KycProvider>();

                                          pickFile(
                                            isGovernmentId: false,
                                            allowedExtensions:
                                                provider.allowedExtensions,
                                            maxFileMb: provider.maxFileMb,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF912323,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                        child: isUploadingAddress
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Align(
                                                alignment: Alignment.center,
                                                child: TranslatedText(
                                                  "Browse....",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // Selected file name
                                    TranslatedText(
                                      addressFileName ?? "No Files Selected",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const TranslatedText(
                              "Utility bill, bank statement or official correspondence (within last 3 months).",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 24),

                            const TranslatedText(
                              "Additional Notes",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),

                            const SizedBox(height: 8),

                            TextField(
                              controller: notesController,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hint: const TranslatedText(
                                  "Optional Information For The Reviewer...",
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff981B1E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: provider.isLoading
                                    ? null
                                    : () async {
                                        print("Submit button pressed");

                                        if (selectedGovtIdFile == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: TranslatedText(
                                                "Please upload Government ID",
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        final provider = context
                                            .read<KycProvider>();

                                        log(
                                          "Submitting KYC with files: ${selectedGovtIdFile!.path}, ${selectedAddressFile?.path}, ${notesController.text.trim()}",
                                        );

                                        final response = await provider
                                            .submitKyc(
                                              identityDocument:
                                                  selectedGovtIdFile!,
                                              addressDocument:
                                                  selectedAddressFile,
                                              customerNotes: notesController
                                                  .text
                                                  .trim(),
                                            );

                                        if (!mounted) return;

                                        if (response["status"] == true) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: TranslatedText(
                                                response["message"] ??
                                                    "KYC submitted successfully",
                                              ),
                                            ),
                                          );

                                          setState(() {
                                            selectedGovtIdFile = null;
                                            selectedAddressFile = null;
                                            governmentFileName = null;
                                            addressFileName = null;
                                            notesController.clear();
                                          });

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MainScreen(initialIndex: 4),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: TranslatedText(
                                                response["message"] ??
                                                    "Failed to submit KYC",
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                child: provider.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const TranslatedText(
                                        "Submit For Verification",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> pickFile({
    required bool isGovernmentId,
    required List<String> allowedExtensions,
    required int maxFileMb,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null) return;

      final pickedFile = result.files.first;

      if (pickedFile.path == null) return;

      if (pickedFile.size > maxFileMb * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TranslatedText(
              "File size should not exceed $maxFileMb MB",
            ),
          ),
        );
        return;
      }

      setState(() {
        if (isGovernmentId) {
          isUploadingGovernmentId = true;
        } else {
          isUploadingAddress = true;
        }
      });

      final file = File(pickedFile.path!);

      // Simulate loading (remove if not needed)
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        if (isGovernmentId) {
          selectedGovtIdFile = file;
          governmentFileName = pickedFile.name;
          isUploadingGovernmentId = false;
        } else {
          selectedAddressFile = file;
          addressFileName = pickedFile.name;
          isUploadingAddress = false;
        }
      });
    } catch (e) {
      setState(() {
        isUploadingGovernmentId = false;
        isUploadingAddress = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: TranslatedText(e.toString())));
    }
  }
}
