import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

class SettingsSkeleton extends StatelessWidget {
  final Widget? headerSliver;
  const SettingsSkeleton({super.key, this.headerSliver});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderCol = isDark ? const Color(0xFF334155) : AppColors.borderLight;

    return AppShimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          if (headerSliver != null) headerSliver as Widget,
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 32.0),
                  // Avatar profile circle
                  const SkeletonCircle(size: 96),
                  const SizedBox(height: 16.0),
                  // Name and Email
                  const SkeletonText(width: 140, height: 16),
                  const SizedBox(height: 8.0),
                  const SkeletonText(width: 180, height: 12),
                  const SizedBox(height: 32.0),
                  // Setting items list (4 items)
                  ...List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: borderCol.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SkeletonBox(width: 36, height: 36, borderRadius: 10),
                              SizedBox(width: 12.0),
                              SkeletonText(width: 120, height: 14),
                            ],
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
