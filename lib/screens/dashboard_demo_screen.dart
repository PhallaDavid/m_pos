import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/list_item_card.dart';
import '../widgets/tab_pills.dart';
import '../widgets/status_chip.dart';
import '../widgets/app_icon_button.dart';
import 'login_screen.dart';

class DashboardDemoScreen extends StatefulWidget {
  const DashboardDemoScreen({super.key});

  @override
  State<DashboardDemoScreen> createState() => _DashboardDemoScreenState();
}

class _DashboardDemoScreenState extends State<DashboardDemoScreen> {
  int _activeTab = 0;
  int _quantity = 1;

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppIconButton(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      onPressed: _logout,
                    ),
                    const Text(
                      'Terminal POS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.notifications_none_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications pressed')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Tab Pills Toggle
                SizedBox(
                  width: double.infinity,
                  child: TabPills(
                    tabs: const ['Today', 'Weekly', 'Monthly'],
                    selectedIndex: _activeTab,
                    onTabChanged: (val) {
                      setState(() {
                        _activeTab = val;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24.0),

                // Dark Accent Feature Card (Navy Background)
                AppCard(
                  isDark: true,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Merchant Account Balance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: AppColors.success, size: 8),
                                SizedBox(width: 6),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      const Text(
                        '\$24,892.50',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Divider(color: Colors.white.withOpacity(0.1), thickness: 1.0),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Payout: Auto-sweep active',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Stat Cards Grid (2 columns)
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Sales Revenue',
                        value: '\$3,482.00',
                        trendText: '+12.4%',
                        isTrendPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: StatCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Invoices',
                        value: '42 Orders',
                        trendText: '-2.1%',
                        isTrendPositive: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Interactive Demo Component Area
                const Text(
                  'Interactive Controls',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terminal Licenses',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$25.00 / month each',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Quantity selector using circular AppIconButton controls
                      Row(
                        children: [
                          AppIconButton(
                            icon: Icons.remove,
                            size: 36,
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          AppIconButton(
                            icon: Icons.add,
                            size: 36,
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Badges / Status Chips Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        const StatusChip(label: 'Active', type: StatusType.success),
                        const SizedBox(width: 8),
                        StatusChip(
                          label: 'Ref',
                          type: StatusType.error,
                          customBgColor: AppColors.errorLight.withOpacity(0.8),
                          customTextColor: AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),

                // Transactions List using ListItemCard
                Column(
                  children: [
                    ListItemCard(
                      title: 'Brewed Coffee & Muffin',
                      subtitle: 'Trans ID: #829410 • 10:24 AM',
                      trailingTitle: '+\$12.50',
                      trailingSubtitle: 'Completed',
                      leadingIcon: Icons.coffee_rounded,
                      leadingBgColor: const Color(0xFFFDF2E9),
                      leadingIconColor: const Color(0xFFD35400),
                      isPositive: true,
                    ),
                    const SizedBox(height: 12.0),
                    ListItemCard(
                      title: 'Refund: Table 4 Order',
                      subtitle: 'Trans ID: #829399 • 09:15 AM',
                      trailingTitle: '-\$45.00',
                      trailingSubtitle: 'Refunded',
                      leadingIcon: Icons.restore_rounded,
                      leadingBgColor: AppColors.errorLight,
                      leadingIconColor: AppColors.error,
                      isPositive: false,
                    ),
                    const SizedBox(height: 12.0),
                    ListItemCard(
                      title: 'Gourmet Burger Combo',
                      subtitle: 'Trans ID: #829384 • 08:30 AM',
                      trailingTitle: '+\$24.90',
                      trailingSubtitle: 'Completed',
                      leadingIcon: Icons.fastfood_rounded,
                      leadingBgColor: const Color(0xFFE8F8F5),
                      leadingIconColor: const Color(0xFF16A085),
                      isPositive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
