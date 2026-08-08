import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final double iconSize;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.iconSize = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;
    final Color primaryColor = isDark
        ? const Color(0xFF5CC8FF)
        : AppColors.primary;
    final Color glowColor = primaryColor.withOpacity(isDark ? 0.18 : 0.10);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Layered Ambient Glow Icon Badge
          Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Glow Ring
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor,
                ),
              ),
              // Inner Badge Ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF0F2B66)
                      : AppColors.primaryLight,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: iconSize, color: primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8.0),

          // Description Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: subTextColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Optional Action Button
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24.0),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actionIcon != null) ...[
                        Icon(actionIcon, size: 16, color: Colors.white),
                        const SizedBox(width: 6.0),
                      ],
                      Text(
                        actionLabel!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
