import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';
import 'package:provider/provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66.0, // a bit taller to fit icon + label
          child: Row(
            children: [
              // Index 0: Home
              _NavItem(
                label: "Home",
                icon: Image.asset(
                  'assets/Home.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // Index 1: Search
              _NavItem(
                label: "Search",
                icon: Image.asset(
                  'assets/Search.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // Index 2: Cart (with badge)
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final count = cartProvider.cartItems.length;

                  return _NavItem(
                    label: "Cart",
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset('assets/Cart.png', height: 24),

                        if (count > 0)
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: TranslatedText(
                                  count > 99 ? '99+' : count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Index 3: Products
              _NavItem(
                label: "All Items",
                icon: Image.asset('assets/Menu.png', height: 24),
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              // Index 4: Profile
              _NavItem(
                label: "Profile",
                icon: Image.asset(
                  'assets/Profile.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),

              // Index 5: Balance
              _NavItem(
                label: "Balance",
                icon: Image.asset('assets/balance.png', height: 24),
                isSelected: currentIndex == 5,
                onTap: () => onTap(5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final Widget? activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Expanded gives every item an equal share of the width
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSelected ? (activeIcon ?? icon) : icon,

            const SizedBox(height: 4),

            // FittedBox shrinks the label instead of wrapping or clipping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TranslatedText(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xffFFD166)
                        : Colors.white.withOpacity(0.85),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
