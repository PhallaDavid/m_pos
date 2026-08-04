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
    Color trailingColor = AppColors.textPrimary;
    if (isPositive != null) {
      trailingColor = isPositive! ? AppColors.success : AppColors.error;
    }

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
              color: leadingBgColor ?? AppColors.background,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
                    )
                  : _buildFallbackIcon(),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        leadingIcon ?? Icons.receipt_long_outlined,
        color: leadingIconColor ?? AppColors.primary,
        size: 24.0,
      ),
    );
  }
}
