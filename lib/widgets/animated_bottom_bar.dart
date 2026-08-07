import 'dart:ui';
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
    this.inactiveColor = const Color(0xFF94A3B8),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // White frosted glass in light mode, dark frosted glass in dark mode
    final Color glassFill = isDark
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.70);

    final Color glassBorder = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.white.withOpacity(0.80);

    // Active pill: blue in both modes
    const Color activePillColor = Color(0xFF2563EB);
    const Color activeIconColor = Colors.white;
    const Color activeTextColor = Colors.white;

    final Color inactiveIconColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 14, bottom: 2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: glassFill,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: glassBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final isSelected = currentIndex == index;

                    return GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSelected ? 12.0 : 10.0,
                            vertical: 5.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activePillColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? items[index].activeIcon
                                    : items[index].icon,
                                color: isSelected
                                    ? activeIconColor
                                    : inactiveIconColor,
                                size: 20,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOut,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          items[index].label,
                                          style: const TextStyle(
                                            color: activeTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
