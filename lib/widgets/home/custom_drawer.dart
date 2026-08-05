import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // static const Color primaryRed = Color(0xFF8B1E1E);
  static const Color accentGold = Color(0xFFE4B42D);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Container(
        color: AppColors.primaryRed,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  children: [
                    _drawerTile(
                      context,
                      icon: Icons.info_outline,
                      title: "About us",
                      onTap: () {},
                    ),
                    _drawerTile(
                      context,
                      icon: Icons.call_outlined,
                      title: "Contact Us",
                      onTap: () {},
                    ),
                    _drawerTile(
                      context,
                      icon: Icons.help_outline,
                      title: "FAQ",
                      onTap: () {},
                    ),
                    _drawerTile(
                      context,
                      icon: Icons.local_shipping_outlined,
                      title: "Shipping",
                      onTap: () {},
                    ),
                    _drawerTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy & More",
                      onTap: () {},
                    ),
                    _drawerTile(
                      context,
                      icon: Icons.star_border,
                      title: "Testimonial",
                      onTap: () {},
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(153, 30, 30, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.location_on, color: accentGold, size: 34),
                          SizedBox(height: 12),
                          Text(
                            "10 Anson Road\n02-91A International Plaza\nSingapore - 079903",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 20),
                          Icon(Icons.phone, color: accentGold),
                          SizedBox(height: 8),
                          Text(
                            "+65 83125775",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Connect with Us",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(height: 1, color: accentGold),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/telegram.png",
                          width: 40,
                          height: 40,
                        ),
                        Image.asset("assets/fb.png", width: 40, height: 40),
                        Image.asset("assets/insta.png", width: 40, height: 40),
                        Image.asset(
                          "assets/youtube.png",
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: accentGold),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
