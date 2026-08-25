import 'package:flutter/material.dart';
import 'package:junubullion/providers/cart_provider.dart';
import 'package:junubullion/theme/app_colors.dart';
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
        top: false, // Ensures padding applies safely to bottom home indicator
        child: SizedBox(
          height: 60.0, // Fixed height prevents shrinking or clipping
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Index 0: Home
              _NavItem(
                icon: Image.asset(
                  'assets/Home.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),

              // Index 1: Search / Category
              _NavItem(
                icon: Image.asset(
                  'assets/Search.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),

              // Index 2: Cart
              // Index 2: Cart
              // Index 2: Cart
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  final count = cartProvider.cartItems.length;

                  return _NavItem(
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
                                child: Text(
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

              // Index 3: Products / View More (4th Icon)
              _NavItem(
                icon: Image.asset('assets/Menu.png', height: 24),
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),

              // Index 4: Profile
              _NavItem(
                icon: Image.asset(
                  'assets/Profile.png',
                  height: 24,
                  color: Colors.white.withOpacity(0.85),
                ),
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 24.0,
      onPressed: onTap,
      icon: isSelected ? (activeIcon ?? icon) : icon,
    );
  }
}
