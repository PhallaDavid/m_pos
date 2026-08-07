import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'skeleton_loader.dart';

class ReportSkeleton extends StatelessWidget {
  final Widget? headerWidget;
  const ReportSkeleton({super.key, this.headerWidget});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color borderCol = isDark ? const Color(0xFF334155) : AppColors.borderLight;

    return AppShimmer(
      child: Column(
        children: [
          if (headerWidget != null) headerWidget as Widget,
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time period selector
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: index < 3 ? 8.0 : 0),
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
                  const SizedBox(height: 20.0),
                  // Revenue & Orders summaries (2 cards side by side)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: borderCol.withOpacity(0.5)),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonText(width: 80, height: 12),
                              SizedBox(height: 12.0),
                              SkeletonText(width: 100, height: 22),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: borderCol.withOpacity(0.5)),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonText(width: 80, height: 12),
                              SizedBox(height: 12.0),
                              SkeletonText(width: 60, height: 22),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  // Large Pie Chart card block skeleton
                  Container(
                    height: 260,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: borderCol.withOpacity(0.5)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 120, height: 14),
                        SizedBox(height: 20.0),
                        Expanded(
                          child: Center(
                            child: SkeletonCircle(size: 140),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
