import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color iconColor;
  final Color backgroundColor;
  final BoxBorder? border;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40.0,
    this.iconColor = AppColors.textPrimary,
    this.backgroundColor = AppColors.surface,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color effectiveBg = backgroundColor == AppColors.surface
        ? (isDark ? const Color(0xFF1E293B) : AppColors.surface)
        : backgroundColor;

    final Color effectiveIconColor = iconColor == AppColors.textPrimary
        ? (isDark ? Colors.white : AppColors.textPrimary)
        : iconColor;

    final Color effectiveBorderColor = isDark ? const Color(0xFF334155) : AppColors.borderLight;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: BoxShape.circle,
        border: border ?? Border.all(color: effectiveBorderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: onPressed == null ? effectiveIconColor.withOpacity(0.4) : effectiveIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
