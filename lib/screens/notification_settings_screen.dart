import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _newSaleAlerts = true;
  bool _lowStockAlerts = true;
  bool _dailyReports = false;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 8.0),
          child: AppIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const Text(
              'Alert Preferences',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12.0),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildToggleRow(
                    title: 'New Sale Alerts',
                    subtitle: 'Trigger a chime on each successful receipt checkout.',
                    value: _newSaleAlerts,
                    onChanged: (val) => setState(() => _newSaleAlerts = val),
                  ),
                  const Divider(color: AppColors.borderLight, height: 16.0),
                  _buildToggleRow(
                    title: 'Low Stock Alerts',
                    subtitle: 'Notify when item stock quantities drop below 10 units.',
                    value: _lowStockAlerts,
                    onChanged: (val) => setState(() => _lowStockAlerts = val),
                  ),
                  const Divider(color: AppColors.borderLight, height: 16.0),
                  _buildToggleRow(
                    title: 'Daily Reports',
                    subtitle: 'Receive daily close-out sales figures via email.',
                    value: _dailyReports,
                    onChanged: (val) => setState(() => _dailyReports = val),
                  ),
                  const Divider(color: AppColors.borderLight, height: 16.0),
                  _buildToggleRow(
                    title: 'Security Alerts',
                    subtitle: 'Notify on unauthorized password changes or login attempts.',
                    value: _securityAlerts,
                    onChanged: (val) => setState(() => _securityAlerts = val),
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

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.borderLight,
          ),
        ],
      ),
    );
  }
}
