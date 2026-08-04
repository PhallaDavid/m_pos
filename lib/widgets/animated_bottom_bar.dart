import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBottomBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AnimatedBottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AnimatedBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AnimatedBottomBarItem> items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor = AppColors.surface,
    this.activeColor = AppColors.primary,
    this.inactiveColor = const Color(0xFF94A3B8), // Muted slate gray
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0), // Floating style
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: AppColors.softShadow,
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.6),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                // Semi-transparent brand color overlay for active item
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon scaling and swap
                  AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? items[index].activeIcon : items[index].icon,
                      color: isSelected ? activeColor : inactiveColor,
                      size: 24,
                    ),
                  ),
                  
                  // ClipRect & AnimatedSize to smoothly slide and expand the text label
                  ClipRect(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.centerLeft,
                      child: isSelected
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                items[index].label,
                                style: TextStyle(
                                  color: activeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
