import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class ListItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingTitle;
  final String? trailingSubtitle;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final Color? leadingBgColor;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool? isPositive; // Null = default, True = Green, False = Red

  const ListItemCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingTitle,
    this.trailingSubtitle,
    this.leadingIcon,
    this.leadingIconColor,
    this.leadingBgColor,
    this.imageUrl,
    this.onTap,
    this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color trailingColor = isDark ? Colors.white : AppColors.textPrimary;
    if (isPositive != null) {
      trailingColor = isPositive! ? AppColors.success : AppColors.error;
    }

    final Color titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subtitleColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final Color effectiveLeadingBg = leadingBgColor ?? (isDark ? const Color(0xFF0F2B66) : AppColors.background);
    final Color effectiveIconColor = leadingIconColor ?? (isDark ? const Color(0xFF5CC8FF) : AppColors.primary);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      onTap: onTap,
      child: Row(
        children: [
          // Leading section: 48x48 rounded-square thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveLeadingBg,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(effectiveIconColor),
                    )
                  : _buildFallbackIcon(effectiveIconColor),
            ),
          ),
          const SizedBox(width: 16.0),
          // Middle section: Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          // Trailing section: Value/Price + Subtitle status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trailingTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: trailingColor,
                ),
              ),
              if (trailingSubtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  trailingSubtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(Color iconColor) {
    return Center(
      child: Icon(
        leadingIcon ?? Icons.receipt_long_outlined,
        color: iconColor,
        size: 24.0,
      ),
    );
  }
}
