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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Flat colors to match modern SaaS aesthetic
    final Color barBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color barBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color effectiveActiveColor = isDark ? const Color(0xFF3B82F6) : activeColor;
    final Color effectiveInactiveColor = isDark ? const Color(0xFF64748B) : inactiveColor;

    final List<Color> centerGradient = isDark 
        ? [const Color(0xFF3B82F6), const Color(0xFF93C5FD)]
        : [const Color(0xFF2563EB), const Color(0xFF60A5FA)];

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: barBorder,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(items.length, (index) {
                  final isSelected = currentIndex == index;
                  
                  // Center slot spacer (large floating button placeholder)
                  if (index == 2) {
                    return const SizedBox(width: 68);
                  }
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? effectiveActiveColor.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: AnimatedScale(
                                scale: isSelected ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? items[index].activeIcon : items[index].icon,
                                  color: isSelected ? effectiveActiveColor : effectiveInactiveColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              
              // Floating Center Action Button (Slot 2)
              Positioned(
                top: -20, // Overflows the top of the bar
                child: GestureDetector(
                  onTap: () => onTap(2),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedScale(
                      scale: currentIndex == 2 ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: centerGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: effectiveActiveColor.withOpacity(0.4),
                              blurRadius: 14,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
