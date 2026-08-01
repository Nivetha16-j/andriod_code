import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class KycVerificationCard extends StatelessWidget {
  const KycVerificationCard({super.key});

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
      body: SafeArea(
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
                    const Expanded(
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
                          Text("No Documents Submitted Yet."),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffDCE8FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Not Submitted",
                        style: TextStyle(
                          color: Colors.blue,
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
                children: ["PDF", "JPG", "JPEG", "PNG", "Max 5 MB Per File"]
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
                "Government-Issued ID *",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Browse..."),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "No Files Selected",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Passport, National ID Card or Driving Licence.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              // Proof of Address
              const Text(
                "Proof Of Address (Optional)",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Browse..."),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "No Files Selected",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Utility bill, bank statement or official correspondence (within last 3 months).",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              const Text(
                "Additional Notes",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              TextField(
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
                    onPressed: () {},
                    child: const Text(
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
      ),
    );
  }
}
