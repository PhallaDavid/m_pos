import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Shimmer skeleton loader for list-based screens like Manage Categories & Manage Products.
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Row(
                children: [
                  SkeletonBox(width: 44, height: 44, borderRadius: 12),
                  SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 120, height: 14),
                        SizedBox(height: 6.0),
                        SkeletonText(width: 80, height: 11),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.0),
                  SkeletonBox(width: 50, height: 22, borderRadius: 11),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
