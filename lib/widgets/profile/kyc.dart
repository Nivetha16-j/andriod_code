import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:junubullion/providers/kyc_provider.dart';
import 'package:junubullion/screens/main_screen.dart';
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
          return SafeArea(
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
                      gradient: const LinearGradient(
                        colors: [Color(0xff981B1E), Color(0xffD97B2A)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "KYC Verification",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Verification Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
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
                          child: Text(
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
                  ),

                  const SizedBox(height: 20),

                  // Supported Formats
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Upload Documents",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Government ID Upload
                  const Text(
                    "Government-Issued ID",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  DottedBorder(
                    options: RectDottedBorderOptions(
                      strokeWidth: 1.5,
                      dashPattern: const [6, 4],
                      color: Colors.grey.shade400,
                    ),

                    // color: Colors.grey.shade400,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final provider = context.read<KycProvider>();

                              pickFile(
                                isGovernmentId: true,
                                allowedExtensions: provider.allowedExtensions,
                                maxFileMb: provider.maxFileMb,
                              );
                            },
                            child: isUploadingGovernmentId
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Text("Browse"),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child:
                                // isUploadingGovernmentId
                                //     ? const SizedBox(
                                //         height: 20,
                                //         width: 20,
                                //         child: Align(
                                //           alignment: Alignment.centerLeft,
                                //           child: SizedBox(
                                //             width: 18,
                                //             height: 18,
                                //             child: CircularProgressIndicator(
                                //               strokeWidth: 2,
                                //             ),
                                //           ),
                                //         ),
                                //       )
                                //     :
                                Text(
                                  governmentFileName ?? "No File Selected",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Passport, National ID Card or Driving Licence.",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),

                  const SizedBox(height: 24),

                  // Proof of Address
                  const Text(
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
                    // strokeWidth: 1.5,
                    // radius: const Radius.circular(10),
                    // dashPattern: const [6, 4],
                    // borderType: BorderType.RRect,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 22,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final provider = context.read<KycProvider>();

                              pickFile(
                                isGovernmentId: false,
                                allowedExtensions: provider.allowedExtensions,
                                maxFileMb: provider.maxFileMb,
                              );
                            },
                            child: isUploadingAddress
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Text("Browse"),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child:
                                //  isUploadingAddress
                                //     ? const SizedBox(
                                //         height: 20,
                                //         width: 20,
                                //         child: Align(
                                //           alignment: Alignment.centerLeft,
                                //           child: SizedBox(
                                //             width: 18,
                                //             height: 18,
                                //             child: CircularProgressIndicator(
                                //               strokeWidth: 2,
                                //             ),
                                //           ),
                                //         ),
                                //       )
                                //     :
                                Text(
                                  addressFileName ?? "No File Selected",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Utility bill, bank statement or official correspondence (within last 3 months).",
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Additional Notes",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: notesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Optional Information For The Reviewer...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: SizedBox(
                      width: 240,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please upload Government ID",
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final provider = context.read<KycProvider>();

                                log(
                                  "Submitting KYC with files: ${selectedGovtIdFile!.path}, ${selectedAddressFile?.path}, ${notesController.text.trim()}",
                                );

                                final response = await provider.submitKyc(
                                  identityDocument: selectedGovtIdFile!,
                                  addressDocument: selectedAddressFile,
                                  customerNotes: notesController.text.trim(),
                                );

                                if (!mounted) return;

                                if (response["status"] == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
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
                                          MainScreen(initialIndex: 3),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
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
                            : const Text(
                                "Submit For Verification",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
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
          SnackBar(content: Text("File size should not exceed $maxFileMb MB")),
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
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
