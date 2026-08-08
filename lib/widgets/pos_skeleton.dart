import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Full-grid animated Skeleton UI loader for the POS Product Grid tab.
/// Displays shimmering search bar, category pills, and 2-column product card skeletons.
class PosSkeleton extends StatelessWidget {
  const PosSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: Column(
        children: [
          // 1. Search Bar Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Row(
                children: [
                  SkeletonCircle(size: 18),
                  SizedBox(width: 12.0),
                  SkeletonText(width: 140, height: 12),
                ],
              ),
            ),
          ),

          // 2. Category Swiper Skeleton Pills
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 6.0,
            ),
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SkeletonBox(
                    width: index == 0 ? 60 : (index == 1 ? 80 : 70),
                    height: 36,
                    borderRadius: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8.0),

          // 3. Product Cards Grid Skeleton (6 Cards, 2 Columns)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image Skeleton Box
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        // Product Name Line
                        const SkeletonText(width: 100, height: 14),
                        const SizedBox(height: 6.0),
                        // Price Line & Add Button Placeholder
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SkeletonText(width: 50, height: 14),
                            SkeletonCircle(size: 28),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
