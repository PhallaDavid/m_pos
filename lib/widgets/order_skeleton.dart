import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

class OrderSkeleton extends StatelessWidget {
  final Widget? headerSliver;
  const OrderSkeleton({super.key, this.headerSliver});

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
          // Tab pills skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8.0 : 0.0),
                      height: 38,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: borderCol.withOpacity(0.5)),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // List item cards skeleton
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: borderCol.withOpacity(0.5)),
                      ),
                      child: const Row(
                        children: [
                          SkeletonBox(width: 44, height: 44, borderRadius: 12),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonText(width: 130, height: 14),
                                SizedBox(height: 6.0),
                                SkeletonText(width: 90, height: 11),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SkeletonText(width: 55, height: 14),
                              SizedBox(height: 6.0),
                              SkeletonText(width: 45, height: 11),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
