import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/tab_pills.dart';
import '../widgets/pie_chart_widget.dart';
import '../services/api_service.dart';
import '../widgets/report_skeleton.dart';
import '../services/pdf_export_service.dart';

class ReportDashboardScreen extends StatefulWidget {
  const ReportDashboardScreen({super.key});

  @override
  State<ReportDashboardScreen> createState() => _ReportDashboardScreenState();
}

class _ReportDashboardScreenState extends State<ReportDashboardScreen> {
  int _selectedPeriodIndex = 0;
  final List<String> _periodOptions = [
    'Today',
    'This Week',
    'This Month',
    'Yearly',
  ];

  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  List<PieChartSegment> _categorySegments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stats = await ApiService.getDashboardStats();
      final totalRev = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
      final totalOrd = (stats['total_orders'] as num?)?.toInt() ?? 0;
      final List<dynamic> topSelling = stats['top_selling'] ?? [];

      final List<PieChartSegment> segments = [];
      final List<Color> colors = [
        const Color(0xFF0F172A), // Dark Slate
        const Color(0xFF2563EB), // Royal Navy Blue
        const Color(0xFF64748B), // Slate Muted
        const Color(0xFF94A3B8), // Cool Grey
      ];

      double sumValues = 0.0;
      for (var item in topSelling) {
        final val = (item['units_sold'] as num?)?.toDouble() ?? 0.0;
        sumValues += val;
      }

      int idx = 0;
      for (var item in topSelling) {
        final label = item['name'] as String;
        final val = (item['units_sold'] as num?)?.toDouble() ?? 0.0;
        final pct = sumValues > 0
            ? (val / sumValues * 100).toStringAsFixed(0)
            : '0';
        segments.add(
          PieChartSegment(
            label: label,
            value: val,
            color: colors[idx % colors.length],
            percentageText: '$pct%',
            amountText: '${val.toInt()} units',
          ),
        );
        idx++;
      }

      if (segments.isEmpty) {
        segments.add(
          const PieChartSegment(
            label: 'No Sales Yet',
            value: 1.0,
            color: Color(0xFF64748B),
            percentageText: '100%',
            amountText: '0 units',
          ),
        );
      }

      setState(() {
        _totalRevenue = totalRev;
        _totalOrders = totalOrd;
        _categorySegments = segments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load dashboard stats: ${e.toString().replaceAll("Exception: ", "")}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: ReportSkeleton(
          headerWidget: Container(
            padding: EdgeInsets.fromLTRB(
              20.0,
              statusBarHeight + 12.0,
              20.0,
              12.0,
            ),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      iconColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surface,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14.0),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales & Report Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Analytics & Revenue Breakdown',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.fromLTRB(
              20.0,
              statusBarHeight + 12.0,
              20.0,
              12.0,
            ),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      iconColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surface,
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1.0,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14.0),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales & Report Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Analytics & Revenue Breakdown',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Period Selector
                        TabPills(
                          tabs: _periodOptions,
                          selectedIndex: _selectedPeriodIndex,
                          onTabChanged: (index) {
                            setState(() {
                              _selectedPeriodIndex = index;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Key Performance Indicators Cards
                        Row(
                          children: [
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.payments_rounded,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD1FAE5),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            '+14.2%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '\$${_totalRevenue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Total Sales Revenue',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: AppCard(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_bag_rounded,
                                            color: Color(0xFFD97706),
                                            size: 20,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD1FAE5),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            '+8.5%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '$_totalOrders Orders',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Avg Order: \$${(_totalOrders > 0 ? _totalRevenue / _totalOrders : 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),

                        // 1. Sales Category Pie Chart Card
                        AppCard(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Category Sales Proportion',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.pie_chart_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Pie Chart Widget
                              PieChartWidget(
                                segments: _categorySegments,
                                chartRadius: 180.0,
                                centerTitle:
                                    '\$${_totalRevenue > 1000 ? "${(_totalRevenue / 1000).toStringAsFixed(1)}K" : _totalRevenue.toStringAsFixed(0)}',
                                centerSubtitle: 'Total Sales',
                              ),
                              const SizedBox(height: 24),
                              const Divider(
                                color: AppColors.borderLight,
                                height: 1.0,
                              ),
                              const SizedBox(height: 16),

                              // Detailed Category Breakdown
                              ..._categorySegments.map((seg) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: seg.color,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                seg.label,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${seg.amountText} (${seg.percentageText})',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Builder(
                                          builder: (context) {
                                            final double totalUnits =
                                                _categorySegments.fold(
                                                  0.0,
                                                  (sum, s) => sum + s.value,
                                                );
                                            return LinearProgressIndicator(
                                              value: totalUnits > 0
                                                  ? seg.value / totalUnits
                                                  : 0.0,
                                              backgroundColor:
                                                  AppColors.borderLight,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    seg.color,
                                                  ),
                                              minHeight: 6,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Export Action Button
                        PrimaryButton(
                          text: 'Export Full Sales PDF Report',
                          icon: const Icon(
                            Icons.picture_as_pdf_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              final periodName =
                                  _periodOptions[_selectedPeriodIndex];
                              await PdfExportService.exportSalesReport(
                                period: periodName,
                                totalRevenue: _totalRevenue,
                                totalOrders: _totalOrders,
                                segments: _categorySegments,
                              );
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to generate PDF: ${e.toString().replaceAll("Exception: ", "")}',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
