import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class KycVerificationCard extends StatelessWidget {
  const KycVerificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2C94C), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xffD8A007), Color(0xffF6B53E)],
              ),
            ),
            child: Image.asset(
              "assets/kyc_validation.png",
              height: 20,
              width: 20,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "KYC Verification Required",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xffB53A1C),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "KYC Verification is required before you can access certain services or complete transactions. "
            "Please upload valid identification documents for verification. "
            "The review process may take 1–3 business days. "
            "You will be notified once your KYC has been reviewed and approved.",
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xffA14B30),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/cloud.png",
                    height: 15,
                    width: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Complete KYC Now",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // ElevatedButton.icon(
            //   onPressed: () {},
            //   icon: ,
            //   label: const Text(
            //     "Complete KYC Now",
            //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xffA91F1F),
            //     foregroundColor: Colors.white,
            //     elevation: 0,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(14),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
