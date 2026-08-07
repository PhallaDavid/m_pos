import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

class POSSkeleton extends StatelessWidget {
  final Widget? headerSliver;
  const POSSkeleton({super.key, this.headerSliver});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderCol = isDark
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    Widget? headerWidget = headerSliver;
    if (headerWidget is SliverToBoxAdapter) {
      headerWidget = headerWidget.child;
    }

    return AppShimmer(
      child: Column(
        children: [
          ?headerWidget,

          // 1. Search Bar Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SkeletonBox(
              width: double.infinity,
              height: 44,
              borderRadius: 22,
            ),
          ),

          // 2. Horizontal Category Swiper Tabs Skeleton
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6.0,
              ),
              itemCount: 5,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SkeletonBox(width: 76, height: 36, borderRadius: 22),
                );
              },
            ),
          ),

          // 3. 2-Column Product Grid Skeleton
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 0.72,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: borderCol.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: SkeletonBox(
                          width: double.infinity,
                          borderRadius: 12,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const SkeletonText(width: 90, height: 12),
                      const SizedBox(height: 6.0),
                      const SkeletonText(width: 60, height: 10),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SkeletonText(width: 50, height: 14),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
