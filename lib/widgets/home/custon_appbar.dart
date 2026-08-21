import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/routes/app_routes.dart';
import 'package:junubullion/screens/main_screen.dart';
import 'package:junubullion/services/session_manager.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:junubullion/providers/home_provider.dart';
import 'package:junubullion/providers/convert_to_physical_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const CustomAppBar({Key? key, this.scaffoldKey}) : super(key: key);

  static const Color accentGold = Color(0xFFD49E00);
  static const Color textGold = Color(0xFFE5B537);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    final ticker =
        homeProvider.homeData?['data']?['spot_prices']?['ticker'] ??
        "Loading...";

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- TOP TICKER BAR ---
            SizedBox(
              height: 20,
              child: Marquee(
                text: ticker,
                style: const TextStyle(
                  color: CustomAppBar.textGold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 40,
                velocity: 30,
                pauseAfterRound: Duration.zero,
              ),
            ),

            // --- MAIN NAVIGATION BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // Logo
                  Image.asset('assets/logo/logo.png', height: 40),

                  const Spacer(),

                  // Cart Icon
                  Consumer2<CartProvider, PhysicalConversionProvider>(
                    builder: (context, cartProvider, physicalProvider, child) {
                      final count = physicalProvider.isActive
                          ? physicalProvider.physicalCartCount
                          : cartProvider.cartItems.length;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        },
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Image.asset(
                                  "assets/shopping-cart.png",
                                  fit: BoxFit.contain,
                                ),
                              ),

                              if (count > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count > 99 ? "99+" : count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
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
                  const SizedBox(width: 12),

                  // Menu Icon
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                    onPressed: () async {
                      widget.scaffoldKey?.currentState?.openDrawer();
                      log("sssssssss ${widget.scaffoldKey}");
                      log("ssssscccc ${widget.scaffoldKey?.currentState}");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Ticker Items
class _TickerItem extends StatelessWidget {
  final String label;
  final String value;

  const _TickerItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: const TextStyle(
        color: CustomAppBar.textGold,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Ticker Vertical Divider
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Text(
        '|',
        style: TextStyle(color: CustomAppBar.textGold, fontSize: 11),
      ),
    );
  }
}

// Gold Action Buttons
class _HeaderButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HeaderButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomAppBar.accentGold,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
