import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final String? trendText;
  final bool? isTrendPositive;
  final Color? badgeColor;
  final Color? badgeIconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isDark = false,
    this.trendText,
    this.isTrendPositive,
    this.badgeColor,
    this.badgeIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkModeActive =
        Theme.of(context).brightness == Brightness.dark || isDark;
    final Color backgroundColor = isDarkModeActive
        ? const Color(0xFF1E293B).withOpacity(0.65)
        : Colors.white.withOpacity(0.75);

    final Color labelColor = isDarkModeActive
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;
    final Color valueColor = isDarkModeActive
        ? Colors.white
        : AppColors.heading;

    // Icon square container background
    final Color effectiveBadgeColor =
        badgeColor ??
        (isDarkModeActive ? const Color(0xFF0F2B66) : const Color(0xFFEEF5FB));
    final Color effectiveBadgeIconColor =
        badgeIconColor ??
        (isDarkModeActive ? const Color(0xFF5CC8FF) : AppColors.primary);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkModeActive ? 0.20 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Badge & Trend Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: effectiveBadgeColor,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: effectiveBadgeIconColor,
                          size: 22,
                        ),
                      ),
                    ),
                    if (trendText != null && isTrendPositive != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: isTrendPositive!
                              ? const Color(0xFFE8F9F1)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isTrendPositive!
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 12,
                              color: isTrendPositive!
                                  ? const Color(0xFF16C784)
                                  : const Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              trendText!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isTrendPositive!
                                    ? const Color(0xFF16C784)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Label
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6.0),
                // Large Bold Number
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
