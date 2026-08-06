import 'package:flutter/material.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/home/custom_bottomnavigationbar.dart';
import 'package:junubullion/widgets/home/custom_drawer.dart';
import 'package:junubullion/widgets/home/custon_appbar.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int expandedIndex = 0; // First item opened initially
  final List<List<Map<String, String>>> faqData = [
    // General Questions
    [
      {
        "question": "What types of gold and silver products do you sell?",
        "answer":
            "At JunuBullion.com, we offer a wide range of gold and silver coins, bars, and bullion from globally recognized mints. Our inventory includes investment-grade precious metals in various weights and designs to suit different investor preferences.",
      },
      {
        "question": "Are your gold and silver products certified?",
        "answer":
            "Yes, all our products come from reputable mints and refineries with certification of purity and authenticity. We deal only with trusted sources to ensure you receive genuine, high-quality bullion.",
      },
      {
        "question": "How do I know if the gold or silver is authentic?",
        "answer":
            "We source our metals from reliable mints such as PAMP, Perth Mint, and the Royal Canadian Mint. Each product comes with proper markings, including weight, purity, and a serial number . Additionally, our experts verify authenticity before shipping.",
      },
    ],

    // Ordering & Payment
    [
      {
        "question": "How can I place an order?",
        "answer":
            "You can place an order directly on our website JunuBullion.com or using the mobile app by selecting your preferred product, adding it to the cart, and proceeding to checkout.",
      },
      {
        "question": "What payment methods do you accept?",
        "answer":
            "We accept bank transfers, credit/debit cards, PayPal, and cryptocurrency payments. Additional payment options may be available upon request.",
      },
      {
        "question": "Is there a minimum or maximum order quantity?",
        "answer":
            "There is no minimum order requirement. However, for large orders above a certain threshold, additional verification may be required for security purposes.",
      },
    ],

    // Shipping
    [
      {
        "question": "How do creators earn money?",
        "answer": "Creators earn through subscriptions and sales.",
      },
    ],

    // Investing
    [
      {
        "question": "Which payment methods are accepted?",
        "answer": "Visa, Mastercard, PayPal and more.",
      },
    ],
  ];

  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedCategory = 0;

  final List<String> categories = [
    "General Questions",
    "Ordering & Payment",
    "Shipping & Delivery",
    "Investing in Precious Metals",
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xffFAFAF8),
        key: scaffoldKey,
        drawer: const CustomDrawer(),
        appBar: CustomAppBar(scaffoldKey: scaffoldKey),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Frequently Asked Questions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "We're here to help with any questions you have about plans, pricing and supported features.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(categories.length, (index) {
                  final isSelected = selectedCategory == index;

                  return ChoiceChip(
                    label: Text(
                      categories[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryRed,
                    backgroundColor: AppColors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqData[selectedCategory].length,
                itemBuilder: (context, index) {
                  final item = faqData[selectedCategory][index];
                  final isExpanded = expandedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item["question"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  isExpanded ? Icons.close : Icons.add,
                                  color: Colors.black,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                item["answer"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              Container(
                width: double.infinity,
                color: AppColors.pink,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      "Need More Help?",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "If you have any additional questions,\nfeel free to contact us at:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ContactItem(
                              icon: Icons.phone,
                              text: "+65 83125775",
                            ),
                            SizedBox(height: 5),
                            // SizedBox(height: 5,),
                            _ContactItem(
                              icon: Icons.email,
                              text: "info@junubullion.com",
                            ),
                            SizedBox(height: 5),
                            _ContactItem(
                              icon: Icons.language,
                              text: "JunuBullion.com",
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
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchToTab,
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryRed, size: 20),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
