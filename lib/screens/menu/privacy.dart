import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: CustomAppBar(scaffoldKey: scaffoldKey),

      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _switchToTab,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Privacy Policy and Terms & Conditions",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              // "At JunuBullion.com, we respect your privacy and are committed to ensuring transparency in how we use cookies and handle your personal data. This document explains our use of cookies, how we collect and process your personal data, and how you can manage your privacy preferences.",
              "At JunuBullion.com, we respect your privacy and are committed to  ensuring transparency in how we use cookies and handle your personal  data.  This document explains our use of cookies, how we collect and  process personal data, and how you can manage you privacy preferences.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            const PolicyTile(
              title: "Cookies Policy",
              content: CookiePolicyContent(),
            ),

            const SizedBox(height: 10),

            const PolicyTile(
              title: "Data Protection Policy",
              content: DataProtectionPolicyContent(),
            ),

            const SizedBox(height: 10),

            const PolicyTile(
              title: "Shipping & Delivery Policy",
              content: ShippingAndDeliveryPolicy(),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              color: AppColors.primaryRed,
              child: Column(
                children: [
                  const Text(
                    "Contact Us",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "If you have any questions about our\nCookies Policy or Data Protection Policy,\nplease contact us:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      // height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ContactCard(
                    icon: Icons.email,
                    title: "Mail",
                    value: "info@junubullion.com",
                  ),

                  const SizedBox(height: 15),

                  ContactCard(
                    icon: Icons.phone,
                    title: "Phone",
                    value: "+65 83125775",
                  ),
                ],
              ),
            ),
          ],
        ),
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
}

class CookiePolicyContent extends StatelessWidget {
  const CookiePolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What Are Cookies?",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        const Text(
          "Cookies are small text files stored on your device (computer, tablet, or mobile phone) when you visit our website. These files help improve your browsing experience by remembering your preferences, analyzing site traffic, and enabling website functionality. Cookies are not harmful and do not contain any viruses or malicious code.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 20),

        const Text(
          "Types of Cookies We Use",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        const Text(
          "1. Session Cookies (First-Party Cookies)",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        const Text(
          "These cookies are temporary and stored only while you are actively using the website. They help maintain secure logins and allow you to navigate the website without having to log in repeatedly. Once you close your browser, session cookies are automatically deleted.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 16),

        const Text(
          "2. Permanent Cookies (First-Party Cookies)",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        const Text(
          "These cookies remain on your device for a set period to remember your preferences. They allow us to save items in your shopping cart and remember settings like language, currency, and location.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 20),

        const Text(
          "3. Third-Party Cookies",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 6),

        const Text(
          "These cookies are placed by external services such as Google Analytics to track website traffic and analyze visitor behavior. They help us understand how users interact with our website to improve our services.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 20),

        const Text(
          "Why We Use Cookies",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We use cookies for the following purposes:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const BulletText(
          "User Experience: To remember your settings and preferences.",
        ),

        const BulletText(
          "Security: To keep you logged in securely while browsing.",
        ),

        const BulletText(
          "Analytics: To track website traffic and measure performance.",
        ),

        const BulletText(
          "Marketing: To analyze how visitors find our website and optimize our marketing efforts.",
        ),
      ],
    );
  }
}

class DataProtectionPolicyContent extends StatelessWidget {
  const DataProtectionPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "1. What Data Do We Collect?",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "When you interact with JunuBullion.com, we may collect the following personal data:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const BulletText(
          "Account Information: Full name, email, phone number, shipping & billing address.",
        ),

        const BulletText(
          "Order Details: Purchase history, payment details (processed securely via third-party payment gateways).",
        ),

        const BulletText(
          "Identity Verification: In cases where legal requirements apply, we may collect additional information such as nationality and proof of identity.",
        ),

        const BulletText(
          "Browsing Data: Information such as IP address, device type, and browsing behavior for analytics purposes.",
        ),

        const SizedBox(height: 10),

        const Text(
          "2. How We Collect Data",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We collect your data through:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("Account Registration & Checkout Forms"),
        const BulletText("Cookies & Website Analytics"),
        const BulletText("Customer Support Inquiries"),

        const SizedBox(height: 10),

        const Text(
          "3. Why We Collect Your Data",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We use your information to:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("Process and fulfill orders efficiently"),
        const BulletText("Provide customer support"),
        const BulletText("Send order confirmations and updates"),
        const BulletText("Improve our website functionality and services"),
        const BulletText("Ensure security and prevent fraudulent activity"),
        const BulletText("Comply with legal and regulatory requirements"),

        const SizedBox(height: 10),

        const Text(
          "4. Third-Party Access to Data",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We do not sell, rent, or trade your personal data. However, we may share data with:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText(
          "Payment Processors (e.g., Stripe, PayPal) to handle transactions securely.",
        ),
        const BulletText("Shipping Partners to deliver your orders."),
        const BulletText("Legal Authorities when required by law."),

        const SizedBox(height: 10),

        const Text(
          "5. Data Retention",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We store your personal data only as long as necessary to:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("Provide services to you."),
        const BulletText("Comply with legal and regulatory requirements."),
        const BulletText("Prevent fraud and enforce our terms."),
        const Text(
          "When no longer needed, your data will be securely deleted.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const Text(
          "6. Your Rights & Choices",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "As a user, you have the right to:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("Access your personal data."),
        const BulletText("Modify or correct incorrect data."),
        const BulletText(
          "Request deletion of your data, unless legally required to retain it.",
        ),
        const BulletText(
          "Opt-out of marketing communications (unsubscribe link available in emails).",
        ),

        const SizedBox(height: 10),

        const Text(
          "7. How We Protect Your Data",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We implement strict security measures, including:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("SSL Encryption to secure data transmission."),
        const BulletText(
          "Limited access to personal data (only authorized personnel can access).",
        ),
        const BulletText("Regular security audits to ensure data protection."),

        const SizedBox(height: 10),

        const Text(
          "8. External Links",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Our app may contain links to third-party sites. We are not responsible for their privacy policies. Please review their policies before sharing any personal data.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class ShippingAndDeliveryPolicy extends StatelessWidget {
  const ShippingAndDeliveryPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "1. Securely shipped. Professionally handled. Globally trusted.",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Orders including jewellery, gold bars, silver coins, or investment-grade collectibles, our shipping process is designed to protect your investment at every stage - from our secure facility in Singapore to your doorstep",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const Text(
          "2. Order Processing",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Every order is subject to thorough verification and packaging protocols to ensure safety, compliance, and confidentiality",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const BulletText(
          "In-stock bullion is typically dispatched within 1-3 business days",
        ),
        const BulletText(
          "Pre-orders or high-volume purchases may require additional time for allocation and verification",
        ),
        const BulletText(
          "Orders are shipped only after full payment has been verified and cleared",
        ),

        const SizedBox(height: 10),

        const Text(
          "3. Domestic Delivery - Singapore",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We offer secure, fully insured delivery options within Singapore",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText(
          "Secure Courier (Tracked): 1-2 business days | Complimentary on orders above \$5000",
        ),
        const BulletText(
          "Same-Day Delivery: Available Mon-Fri | Quoted individually",
        ),
        const Text(
          "All parcels are shipped in tamper-evident, unbranded packaging. Government-issued ID may be required for high-value orders. Signature is mandatory",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const Text(
          "4. International Shipping",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We ship select products internationally from Singapore, subject to local laws and customs regulations",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText(
          "Carriers: DHL Express or FedEx International Priority",
        ),
        const BulletText("Full insurance and tracking included"),
        const BulletText(
          "Customs duties, VAT, or import taxes are the responsibility of the recipient",
        ),
        const BulletText(
          "Ensure bullion shipments are allowed in your country before ordering",
        ),

        const SizedBox(height: 10),

        const Text(
          "5. Packaging & Discretion",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "All orders are packed in plain, secure, tamper-evident packaging. No external labeling indicates the package contains precious metals. Each shipment is handled under CCTV surveillance prior to dispatch",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const Text(
          "6. Tracking & Insurance",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const BulletText("Tracking number provided once order ships"),
        const BulletText("Fully insured during transit"),
        const BulletText(
          "Notify us within 3 business days of delay/loss for claims assistance.",
        ),

        const SizedBox(height: 10),

        const Text(
          "7. Address Accuracy & Liability",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "Ensure your delivery details are accurate. We are not liable for incorrect addresses or unauthorized acceptance. Once a delivery is marked complete by the courier, responsibility transfers to the recipient",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        const Text(
          "8. In-Person Pickup (Singapore Only)",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "We offer secure, appointment-based pickup from our Singapore facility",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const BulletText("Valid government-issued photo ID required"),
        const BulletText("Name must match invoice unless authorize"),

        const SizedBox(height: 10),

        const Text(
          "Need Assistance?",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        const Text(
          "For special arrangements, courier preferences, or high-security requests, contact us info@junubullion.com. From vault to value, we ship with confidence - so you can invest with peace of mind",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;

  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "✔ ",
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class PolicyTile extends StatelessWidget {
  final String title;
  final Widget content;

  const PolicyTile({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        color: const Color(0xffA51E22),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          collapsedIconColor: const Color(0xffF4C542),
          iconColor: const Color(0xffF4C542),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),

          Icon(icon, color: const Color(0xffF4C542), size: 34),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color.fromRGBO(200, 157, 8, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
