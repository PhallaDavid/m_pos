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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: border ?? Border.all(color: AppColors.borderLight, width: 1.0),
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
              color: onPressed == null ? iconColor.withOpacity(0.5) : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
