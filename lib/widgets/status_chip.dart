import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusType { success, error, warning, info }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  final Color? customBgColor;
  final Color? customTextColor;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.info,
    this.customBgColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (customBgColor != null && customTextColor != null) {
      bgColor = customBgColor!;
      textColor = customTextColor!;
    } else {
      switch (type) {
        case StatusType.success:
          bgColor = AppColors.successLight;
          textColor = AppColors.success;
          break;
        case StatusType.error:
          bgColor = AppColors.errorLight;
          textColor = AppColors.error;
          break;
        case StatusType.warning:
          bgColor = AppColors.warningLight;
          textColor = AppColors.warning;
          break;
        case StatusType.info:
          bgColor = AppColors.primaryLight;
          textColor = AppColors.primary;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
