import 'dart:ui';
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
  final bool enableBlur;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.isDark = false,
    this.onTap,
    this.borderRadius = 20.0,
    this.customBorderRadius,
    this.backgroundColor,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkModeActive =
        Theme.of(context).brightness == Brightness.dark || isDark;

    final Color defaultBg = isDarkModeActive
        ? const Color(0xFF1E293B).withOpacity(0.70)
        : Colors.white.withOpacity(0.75);

    final Color effectiveBgColor = backgroundColor ?? defaultBg;
    final BorderRadiusGeometry effectiveBorderRadius =
        customBorderRadius ?? BorderRadius.circular(borderRadius);

    Widget cardContent = InkWell(
      onTap: onTap,
      splashColor: isDarkModeActive
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.02),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: padding,
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: TextStyle(
                color: isDarkModeActive ? Colors.white : AppColors.textPrimary,
              ),
              bodyMedium: TextStyle(
                color: isDarkModeActive
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondary,
              ),
              displayMedium: TextStyle(
                color: isDarkModeActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkModeActive ? 0.20 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: enableBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveBgColor,
                    borderRadius: effectiveBorderRadius,
                  ),
                  child: cardContent,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: effectiveBorderRadius,
                ),
                child: cardContent,
              ),
      ),
    );
  }
}
