import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

/// Full-page animated Skeleton UI loader specifically designed for the Home Page tab.
/// Replicates the structure of the Home Screen (Revenue Card, Stat Cards, Quick Actions Grid, Orders List)
/// to provide a smooth, professional shimmer loading state.
class HomeSkeleton extends StatelessWidget {
  final Widget? headerSliver;
  const HomeSkeleton({super.key, this.headerSliver});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          if (headerSliver != null) headerSliver as Widget,
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Sales Revenue Card Skeleton
                  _buildRevenueCardSkeleton(),
                  const SizedBox(height: 16.0),

                  // 2. Stat Cards Grid Skeleton (2 Columns)
                  Row(
                    children: [
                      Expanded(child: _buildStatCardSkeleton()),
                      const SizedBox(width: 16.0),
                      Expanded(child: _buildStatCardSkeleton()),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // 3. Quick Actions Header & Grid Skeleton (3 Columns)
                  const SkeletonText(width: 120, height: 16),
                  const SizedBox(height: 12.0),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 2 ? 12.0 : 0.0),
                          child: _buildQuickActionTileSkeleton(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // 4. Today's Orders Header Skeleton
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonText(width: 130, height: 16),
                      SkeletonText(width: 60, height: 14),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),

          // 5. Today's Orders List Items Skeleton (5 Items)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildOrderItemCardSkeleton(),
                  );
                },
                childCount: 5,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24.0),
          ),
        ],
      ),
    );
  }

  /// Sales Revenue Balance Card Skeleton
  Widget _buildRevenueCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(
                width: 140,
                height: 14,
                color: Colors.white.withOpacity(0.2),
              ),
              SkeletonBox(
                width: 85,
                height: 22,
                borderRadius: 12,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          SkeletonText(
            width: 180,
            height: 32,
            borderRadius: 6,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16.0),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonText(
                width: 130,
                height: 12,
                color: Colors.white.withOpacity(0.2),
              ),
              SkeletonText(
                width: 110,
                height: 12,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Single Stat Card Skeleton
  Widget _buildStatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonBox(width: 38, height: 38, borderRadius: 12),
              SkeletonBox(width: 48, height: 20, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 14.0),
          const SkeletonText(width: 90, height: 12),
          const SizedBox(height: 8.0),
          const SkeletonText(width: 75, height: 18),
        ],
      ),
    );
  }

  /// Single Quick Action Grid Tile Skeleton
  Widget _buildQuickActionTileSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
        boxShadow: AppColors.softShadow,
      ),
      child: const Column(
        children: [
          SkeletonBox(width: 44, height: 44, borderRadius: 14),
          SizedBox(height: 8.0),
          SkeletonText(width: 48, height: 10),
        ],
      ),
    );
  }

  /// Single Order List Item Card Skeleton
  Widget _buildOrderItemCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
        boxShadow: AppColors.softShadow,
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 44, height: 44, borderRadius: 12),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(width: 140, height: 14),
                SizedBox(height: 6.0),
                SkeletonText(width: 100, height: 11),
              ],
            ),
          ),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonText(width: 55, height: 14),
              SizedBox(height: 6.0),
              SkeletonText(width: 65, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}
