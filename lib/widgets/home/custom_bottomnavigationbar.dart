import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

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
              _NavItem(
                icon: Image.asset('assets/Cart.png', height: 24),
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
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
