import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PieChartSegment {
  final String label;
  final double value;
  final Color color;
  final String percentageText;
  final String amountText;

  const PieChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.percentageText,
    required this.amountText,
  });
}

class PieChartWidget extends StatelessWidget {
  final List<PieChartSegment> segments;
  final double chartRadius;
  final String centerTitle;
  final String centerSubtitle;

  const PieChartWidget({
    super.key,
    required this.segments,
    this.chartRadius = 180.0,
    this.centerTitle = r'$14.25K',
    this.centerSubtitle = 'Total Sales',
  });

  @override
  Widget build(BuildContext context) {
    final double total = segments.fold(0, (sum, item) => sum + item.value);

    return Column(
      children: [
        SizedBox(
          width: chartRadius,
          height: chartRadius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(chartRadius, chartRadius),
                painter: _PieChartPainter(segments: segments, totalValue: total),
              ),
              // Inner donut cutout with summary text
              Container(
                width: chartRadius * 0.58,
                height: chartRadius * 0.58,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0F1E293B),
                      blurRadius: 10,
                      spreadRadius: -2,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          centerTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      centerSubtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Interactive Legend Grid
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: segments.map((seg) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: seg.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    seg.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    seg.percentageText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<PieChartSegment> segments;
  final double totalValue;

  _PieChartPainter({required this.segments, required this.totalValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (totalValue <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;

    for (final seg in segments) {
      final sweepAngle = (seg.value / totalValue) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = seg.color;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.totalValue != totalValue;
  }
}
