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
    final Color backgroundColor = isDark ? AppColors.navyAccent : AppColors.primaryLight;
    final Color labelColor = isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary;
    final Color valueColor = isDark ? Colors.white : AppColors.textPrimary;
    
    // Default badge backgrounds
    final Color effectiveBadgeColor = badgeColor ?? 
        (isDark ? Colors.white.withOpacity(0.15) : Colors.white);
    final Color effectiveBadgeIconColor = badgeIconColor ?? 
        (isDark ? Colors.white : AppColors.primary);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: isDark ? [] : AppColors.softShadow,
        border: isDark ? null : Border.all(color: AppColors.borderLight.withOpacity(0.6), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Badge & Trend (if any) in row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: effectiveBadgeColor,
                  borderRadius: BorderRadius.circular(12.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isTrendPositive!
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive! ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isTrendPositive! ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        trendText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isTrendPositive! ? AppColors.success : AppColors.error,
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
          // Big bold number
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
