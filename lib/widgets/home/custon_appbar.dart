import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:marquee/marquee.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: const Key('custom_appbar'));

  @override
  Size get preferredSize => const Size.fromHeight(100.0);

  // Styling Constants
  static const Color accentGold = Color(0xFFD49E00);
  static const Color textGold = Color(0xFFE5B537);

  @override
  Widget build(BuildContext context) {
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
              height: 20, // Give the ticker a fixed height
              child: Marquee(
                text:
                    'Gold \$2,042.50   |   Silver \$23.12   |   Platinum \$915.00   |   Palladium \$1,028.40   |   ',
                style: const TextStyle(
                  color: CustomAppBar.textGold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 20.0,
                velocity: 30.0, // Adjust scrolling speed
                pauseAfterRound: const Duration(seconds: 0),
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
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: textGold,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),

                  // Menu Icon
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                    onPressed: () {},
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
