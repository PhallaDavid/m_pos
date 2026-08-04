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
    this.borderRadius = 16.0,
    this.customBorderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBgColor = backgroundColor ?? 
        (isDark ? AppColors.navyAccent : AppColors.surface);

    final BorderRadiusGeometry effectiveBorderRadius = customBorderRadius ?? BorderRadius.circular(borderRadius);

    Widget cardWidget = Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveBorderRadius,
        boxShadow: isDark ? [] : AppColors.softShadow,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : AppColors.borderLight,
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          splashColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: padding,
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(
                  // Override colors inside dark card
                  bodyLarge: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
                  bodyMedium: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary),
                  displayMedium: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
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
