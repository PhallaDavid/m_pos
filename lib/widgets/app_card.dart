import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isDark;
  final VoidCallback? onTap;
  final double borderRadius;
  final BorderRadiusGeometry? customBorderRadius;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.isDark = false,
    this.onTap,
    this.borderRadius = 20.0,
    this.customBorderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkModeActive = Theme.of(context).brightness == Brightness.dark || isDark;
    final Color effectiveBgColor = backgroundColor ?? 
        (isDarkModeActive ? const Color(0xFF1E293B) : AppColors.surface);

    final BorderRadiusGeometry effectiveBorderRadius = customBorderRadius ?? BorderRadius.circular(borderRadius);

    Widget cardWidget = Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: isDarkModeActive ? const Color(0xFF334155) : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          splashColor: isDarkModeActive ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: padding,
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(
                  // Override colors inside dark card
                  bodyLarge: TextStyle(color: isDarkModeActive ? Colors.white : AppColors.textPrimary),
                  bodyMedium: TextStyle(color: isDarkModeActive ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                  displayMedium: TextStyle(color: isDarkModeActive ? Colors.white : AppColors.textPrimary),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    return cardWidget;
  }
}
