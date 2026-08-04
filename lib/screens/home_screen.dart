import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_item.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/list_item_card.dart';
import '../widgets/tab_pills.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/animated_bottom_bar.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'manage_products_screen.dart';
import 'manage_categories_screen.dart';
import 'report_dashboard_screen.dart';
import '../theme/app_translations.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class OrderItemModel {
  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final String status; // 'Completed', 'Pending', 'Refunded'
  final IconData icon;
  final Color leadingBgColor;
  final Color leadingIconColor;
  final bool isPositive;

  OrderItemModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.icon,
    required this.leadingBgColor,
    required this.leadingIconColor,
    required this.isPositive,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _activeOrderFilter = 0;
  
  // Selected display language (default Khmer, hot-reload safe)
  String? _selectedLanguage = 'Khmer';

  String get selectedLanguage {
    _selectedLanguage ??= 'Khmer';
    return _selectedLanguage!;
  }

  // Translation helper shorthand
  String _t(String khmerText, String englishText) {
    return AppTranslations.tr(selectedLanguage, khmerText, englishText);
  }

  // State for POS terminal settings expansion
  bool _isAboutExpanded = false;
  
  // Category state filtering
  int _selectedPOSCategoryIndex = 0;
  List<String> _categories = [
    'Coffee',
    'Bakery',
  ];
  List<Map<String, dynamic>> _dbCategories = [];

  // Selected product variants state
  Map<String, ProductVariant>? _selectedVariants = {};

  // Map accessor with hot reload safety
  Map<String, ProductVariant> get selectedVariants {
    _selectedVariants ??= {};
    return _selectedVariants!;
  }

  // Selected sugar levels state
  Map<String, String>? _selectedSugarLevels;
  Map<String, String> get selectedSugarLevels {
    _selectedSugarLevels ??= {};
    return _selectedSugarLevels!;
  }

  // Selected add-ons state
  Map<String, List<ProductVariant>>? _selectedAddOns;
  Map<String, List<ProductVariant>> get selectedAddOns {
    _selectedAddOns ??= {};
    return _selectedAddOns!;
  }

  // Dynamic products list with variants, sugar levels, and add-ons
  List<ProductItem> _products = [];
  bool _isLoadingData = false;
  
  // State for POS terminal checkout quantities
  final Map<String, int> _posQuantities = {};

  String _merchantName = 'Alexa Smith';
  String _merchantEmail = 'alexa.smith@merchant.com';
  String? _merchantImageUrl;

  double _totalSalesRevenue = 0.0;
  int _totalOrdersCount = 0;
  double _salesToday = 0.0;
  int _ordersTodayCount = 0;

  // Dynamic Orders list
  List<OrderItemModel>? _ordersList;

  List<OrderItemModel> get ordersList {
    return _ordersList ?? [];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingData = true;
    });
    try {
      final dbCats = await ApiService.getCategories();
      final products = await ApiService.getProducts();
      
      // Fetch profile in parallel or secondary
      try {
        final profile = await ApiService.getProfile();
        _merchantName = profile['name'] != null && profile['name'].isNotEmpty ? profile['name'] : 'Alexa Smith';
        _merchantEmail = ApiService.userEmail ?? 'alexa.smith@merchant.com';
        _merchantImageUrl = profile['image_url'];
      } catch (_) {}

      // Fetch dashboard metrics
      try {
        final stats = await ApiService.getDashboardStats();
        _totalSalesRevenue = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
        _totalOrdersCount = (stats['total_orders'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      // Fetch recent orders
      try {
        final ordersData = await ApiService.getOrders();
        final List<OrderItemModel> loadedOrders = [];
        double salesToday = 0.0;
        int ordersToday = 0;
        final now = DateTime.now();
        
        for (var item in ordersData) {
          final idStr = item['id'].toString().substring(0, 4).toUpperCase();
          final orderIdFull = item['id'].toString();
          final paymentMethod = item['payment_method'] as String? ?? 'Cash';
          final totalAmount = (item['total_amount'] as num?)?.toDouble() ?? 0.0;
          final createdAtStr = item['created_at'] != null 
              ? DateTime.parse(item['created_at'].toString()) 
              : DateTime.now();
              
          // Calculate today stats
          if (createdAtStr.year == now.year && createdAtStr.month == now.month && createdAtStr.day == now.day) {
            salesToday += totalAmount;
            ordersToday++;
          }

          // Parse order items for name list
          final itemsList = item['order_items'] as List<dynamic>? ?? [];
          final names = itemsList.map((oi) {
            final prod = oi['products'];
            return prod != null ? prod['name'] as String : 'Unknown';
          }).toList();
          
          final String title = 'Order #$idStr • ${names.isNotEmpty ? names.join(', ') : 'No Items'}';
          
          // Format time, e.g. "10:42 AM"
          final hour = createdAtStr.hour > 12 ? createdAtStr.hour - 12 : (createdAtStr.hour == 0 ? 12 : createdAtStr.hour);
          final period = createdAtStr.hour >= 12 ? 'PM' : 'AM';
          final minute = createdAtStr.minute.toString().padLeft(2, '0');
          final timeStr = '$hour:$minute $period';
          
          final String subtitle = '$timeStr • $paymentMethod • ${itemsList.length} ${itemsList.length == 1 ? 'Item' : 'Items'}';
          
          loadedOrders.add(
            OrderItemModel(
              id: orderIdFull,
              title: title,
              subtitle: subtitle,
              amount: '+\$${totalAmount.toStringAsFixed(2)}',
              status: 'Completed',
              icon: Icons.local_cafe_rounded,
              leadingBgColor: AppColors.primaryLight,
              leadingIconColor: AppColors.primary,
              isPositive: true,
            ),
          );
        }
        
        _ordersList = loadedOrders;
        _salesToday = salesToday;
        _ordersTodayCount = ordersToday;
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _dbCategories = dbCats;
        _categories = dbCats.map((c) => c['name'] as String).toList();
        _products = products;
        
        // Ensure quantities map covers all products safely
        for (var p in _products) {
          _posQuantities.putIfAbsent(p.name, () => 0);
        }
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Background Gradient & Radial Glow Spotlight (Top 35-40% of Home Page ONLY)
          if (_currentIndex == 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.40,
              child: Stack(
                children: [
                  // Soft diagonal gradient using main brand color fading into neutral background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.85),
                          AppColors.primary.withOpacity(0.35),
                          AppColors.background.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.45, 0.75, 1.0],
                      ),
                    ),
                  ),
                  // Spotlight / Radial Light Glow Circle (Top Right)
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Spotlight / Radial Light Glow Circle (Top Left)
                  Positioned(
                    top: 20,
                    left: -40,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.20),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Foreground Layer (Header + Page Content)
          Column(
            children: [
              // Page-Specific Dynamic Top Header Bar
              _buildTopHeader(),
              
              // Main Tab View Content
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeTab(),
                    _buildPOSTab(),
                    _buildOrderTab(),
                    _buildSettingTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          AnimatedBottomBarItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: _t('ទំព័រដើម', 'Home'),
          ),
          AnimatedBottomBarItem(
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            label: _t('លក់ (POS)', 'POS'),
          ),
          AnimatedBottomBarItem(
            icon: Icons.receipt_long_rounded,
            activeIcon: Icons.receipt_long_rounded,
            label: _t('ការកុម្ម៉ង់', 'Order'),
          ),
          AnimatedBottomBarItem(
            icon: Icons.settings_rounded,
            activeIcon: Icons.settings_rounded,
            label: _t('ការកំណត់', 'Setting'),
          ),
        ],
      ),
    );
  }

  // Helper to show language selection bottom sheet
  void _showLanguageSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Select Language / ជ្រើសរើសភាសា',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Choose your preferred display language',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Option 1: Khmer (Default)
                  _buildLanguageOptionTile(
                    flagEmoji: '🇰🇭',
                    title: 'Khmer',
                    nativeName: 'ភាសាខ្មែរ (Default)',
                    isSelected: selectedLanguage == 'Khmer',
                    onTap: () {
                      setState(() {
                        _selectedLanguage = 'Khmer';
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('បានប្តូរទៅជាភាសាខ្មែរ (Language changed to Khmer)'),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),

                  // Option 2: English (US)
                  _buildLanguageOptionTile(
                    flagEmoji: '🇬🇧',
                    title: 'English',
                    nativeName: 'English (US)',
                    isSelected: selectedLanguage == 'English',
                    onTap: () {
                      setState(() {
                        _selectedLanguage = 'English';
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Language updated to English'),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOptionTile({
    required String flagEmoji,
    required String title,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(flagEmoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      nativeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
            else
              const Icon(Icons.circle_outlined, color: AppColors.borderLight, size: 22),
          ],
        ),
      ),
    );
  }

  // Page-Specific Header Bar (Home, POS, Order, Setting)
  Widget _buildTopHeader() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    // TAB 0: Home Page Header (Transparent over background gradient)
    if (_currentIndex == 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 12.0, 20.0, 16.0),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.0),
                  ),
                  child: ClipOval(
                    child: _merchantImageUrl != null && _merchantImageUrl!.isNotEmpty
                        ? Image.network(
                            _merchantImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        : Image.network(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Text(
                                'US',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('សួស្តី ${_merchantName.split(" ").first}', 'Hello ${_merchantName.split(" ").first}'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _t('លេខសម្គាល់អាជីវករ: #9841', 'Merchant ID: #9841'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppIconButton(
              icon: Icons.language_rounded,
              iconColor: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
              onPressed: _showLanguageSelectionSheet,
            ),
          ],
        ),
      );
    }

    // Dynamic header configurations for POS, Order, and Setting tabs
    String title = _t('ស្ថានីយ POS', 'POS Terminal');
    String subtitle = _t('ស្ថានីយ #1 • សកម្ម', 'Terminal #1 • Active');
    IconData headerIcon = Icons.point_of_sale_rounded;
    IconData actionIcon = Icons.restart_alt_rounded;
    VoidCallback? onActionPressed;

    if (_currentIndex == 1) {
      title = _t('ស្ថានីយ POS', 'POS Terminal');
      subtitle = _t('ស្ថានីយ #1 • សកម្ម', 'Terminal #1 • Active');
      headerIcon = Icons.point_of_sale_rounded;
      actionIcon = Icons.restart_alt_rounded;
      onActionPressed = () {
        setState(() {
          _posQuantities.updateAll((key, val) => 0);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('បានកំណត់កន្ត្រកឡើងវិញដោយជោគជ័យ', 'Cart reset successfully'))),
        );
      };
    } else if (_currentIndex == 2) {
      title = _t('ការកុម្ម៉ង់ និង ប្រតិបត្តិការ', 'Orders & Transactions');
      subtitle = _t('ថ្ងៃនេះ: ${ordersList.length} ការកុម្ម៉ង់', 'Today: ${ordersList.length} Orders');
      headerIcon = Icons.receipt_long_rounded;
      actionIcon = Icons.refresh_rounded;
      onActionPressed = () {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('បានធ្វើបច្ចុប្បន្នភាពបញ្ជីការកុម្ម៉ង់', 'Orders list refreshed'))),
        );
      };
    } else if (_currentIndex == 3) {
      title = _t('ការកំណត់ និង ហាង', 'Settings & Store');
      subtitle = _t('លេខសម្គាល់អាជីវករ: #9841', 'Merchant ID: #9841');
      headerIcon = Icons.settings_rounded;
      actionIcon = Icons.logout_rounded;
      onActionPressed = () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      };
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 12.0, 20.0, 12.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(headerIcon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppIconButton(
            icon: actionIcon,
            iconColor: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            border: Border.all(color: AppColors.borderLight, width: 1.0),
            onPressed: onActionPressed,
          ),
        ],
      ),
    );
  }

  // TAB 1: Home Tab (Sales Report, Quick Actions, Products List, Today's Orders)
  // TAB 1: Home Tab (Sales Report, Quick Actions, Products List, Today's Orders)
  Widget _buildHomeTab() {
    final recentOrders = ordersList.take(5).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sales Report Card (Revenue Balance + Quick Stats)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportDashboardScreen(),
                      ),
                    );
                  },
                  child: AppCard(
                    isDark: true,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _t('សមតុល្យចំណូលលក់', 'Sales Revenue Balance'),
                              style: const TextStyle(
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
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, color: AppColors.success, size: 8),
                                  const SizedBox(width: 6),
                                  Text(
                                    _t('របាយការណ៍ផ្ទាល់', 'Live Report'),
                                    style: const TextStyle(
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
                        Text(
                          '\$${(_totalSalesRevenue ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Divider(color: Colors.white.withOpacity(0.15), thickness: 1.0),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _t('ធ្វើបច្ចុប្បន្នភាព 1 នាទីមុន', 'Last updated 1 min ago'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.pie_chart_rounded,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _t('មើលផ្ទាំងគ្រប់គ្រង', 'View Pie Dashboard'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.9),
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
                const SizedBox(height: 16.0),

                // Stat Cards Grid (Sales Today & Transactions Count)
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.trending_up_rounded,
                        label: _t('ការលក់ថ្ងៃនេះ', 'Sales Today'),
                        value: '\$${(_salesToday ?? 0.0).toStringAsFixed(2)}',
                        trendText: '+8.2%',
                        isTrendPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: StatCard(
                        icon: Icons.receipt_long_rounded,
                        label: _t('ការកុម្ម៉ង់ថ្ងៃនេះ', 'Today\'s Orders'),
                        value: _t('${_ordersTodayCount ?? 0} ការកុម្ម៉ង់', '${_ordersTodayCount ?? 0} Orders'),
                        trendText: '+4.5%',
                        isTrendPositive: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // 2. Quick Pages & Actions Grid
                Text(
                  _t('សកម្មភាពរហ័ស', 'Quick Actions'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    _buildQuickActionTile(
                      icon: Icons.point_of_sale_rounded,
                      label: _t('ស្ថានីយ POS', 'POS Terminal'),
                      color: const Color(0xFF2563EB),
                      bgColor: const Color(0xFFEFF6FF),
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionTile(
                      icon: Icons.inventory_2_rounded,
                      label: _t('ផលិតផល', 'Products'),
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFD1FAE5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageProductsScreen(
                              products: _products,
                              categories: _categories,
                              posQuantities: _posQuantities,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionTile(
                      icon: Icons.category_rounded,
                      label: _t('ប្រភេទទំនិញ', 'Categories'),
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFFF3E8FF),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageCategoriesScreen(
                              categories: _categories,
                              products: _products,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionTile(
                      icon: Icons.receipt_long_rounded,
                      label: _t('ការកុម្ម៉ង់', 'Orders'),
                      color: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFFFEF3C7),
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                // 3. Today's Orders List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('ការកុម្ម៉ង់ថ្ងៃនេះ', 'Today\'s Orders'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: Text(
                        _t('មើលទាំងអស់', 'View All'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ),

        // Lazy-loaded Slivers list for Today's Orders
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = recentOrders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ListItemCard(
                    title: order.title,
                    subtitle: order.subtitle,
                    trailingTitle: order.amount,
                    trailingSubtitle: order.status,
                    leadingIcon: order.icon,
                    leadingBgColor: order.leadingBgColor,
                    leadingIconColor: order.leadingIconColor,
                    isPositive: order.isPositive,
                  ),
                );
              },
              childCount: recentOrders.length,
            ),
          ),
        ),

        // Bottom spacing padding sliver
        const SliverToBoxAdapter(
          child: SizedBox(height: 24.0),
        ),
      ],
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: AppColors.softShadow,
            border: Border.all(color: AppColors.borderLight.withOpacity(0.6), width: 1.0),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8.0),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Helper to show rich product customization bottom sheet (Variant, Sugar %, Add-Ons / Extra Shot)
  void _showVariantSelectionSheet(ProductItem product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        ProductVariant? activeVariant = selectedVariants[product.name] ??
            (product.variants.isNotEmpty ? product.variants.first : null);
        String activeSugar = selectedSugarLevels[product.name] ??
            (product.sugarLevels.isNotEmpty ? product.sugarLevels.first : '100%');
        List<ProductVariant> activeAddOns = List.from(selectedAddOns[product.name] ?? []);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double variantPrice = activeVariant?.extraPrice ?? 0.0;
            final double addOnsPrice = activeAddOns.fold(0.0, (sum, item) => sum + item.extraPrice);
            final double calculatedPrice = product.price + variantPrice + addOnsPrice;

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(product.icon, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _t('តម្លៃដើម: \$${product.price.toStringAsFixed(2)}', 'Base Price: \$${product.price.toStringAsFixed(2)}'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            '\$${calculatedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Section 1: Variant Selection (Size / Shot serving)
                    if (product.variants.isNotEmpty) ...[
                      Text(
                        _t('ជម្រើសទំហំ / ការឆុង (Variant)', 'Size / Serving Variant'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.variants.map((v) {
                          final isSelected = activeVariant?.name == v.name;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                activeVariant = v;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight : AppColors.surface,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        size: 18,
                                        color: isSelected ? AppColors.primary : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    v.extraPrice > 0 ? '+\$${v.extraPrice.toStringAsFixed(2)}' : _t('ឥតគិតថ្លៃ', 'Free'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Section 2: Sugar Level Percent Selector
                    if (product.sugarLevels.isNotEmpty) ...[
                      Text(
                        _t('កម្រិតស្ករ (Sugar Level %)', 'Sugar Level Percent'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: product.sugarLevels.map((sugar) {
                            final isSelected = activeSugar == sugar;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    activeSugar = sugar;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    sugar,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    // Section 3: Add-Ons / Extra Shot Options
                    if (product.availableAddOns.isNotEmpty) ...[
                      Text(
                        _t('បន្ថែមកាហ្វេ ឬ គ្រឿងផ្សំ (Add Extra Shot / Add-Ons)', 'Add Extra Shot & Add-Ons'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.availableAddOns.map((addOn) {
                          final isChecked = activeAddOns.any((a) => a.name == addOn.name);
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  activeAddOns.removeWhere((a) => a.name == addOn.name);
                                } else {
                                  activeAddOns.add(addOn);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.primaryLight : AppColors.surface,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: isChecked ? AppColors.primary : AppColors.borderLight,
                                  width: isChecked ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                        size: 20,
                                        color: isChecked ? AppColors.primary : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        addOn.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                          color: isChecked ? AppColors.primary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '+\$${addOn.extraPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isChecked ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16.0),
                    ],

                    PrimaryButton(
                      text: _t('រក្សាទុកជម្រើស និង បន្ថែម (\$${calculatedPrice.toStringAsFixed(2)})', 'Confirm Options & Add (\$${calculatedPrice.toStringAsFixed(2)})'),
                      onPressed: () {
                        setState(() {
                          if (activeVariant != null) {
                            selectedVariants[product.name] = activeVariant!;
                          }
                          selectedSugarLevels[product.name] = activeSugar;
                          selectedAddOns[product.name] = List.from(activeAddOns);

                          final currentQty = _posQuantities[product.name] ?? 0;
                          if (currentQty == 0) {
                            _posQuantities[product.name] = 1;
                          }
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_t('ជម្រើស ${product.name} ត្រូវបានរក្សាទុក!', '${product.name} options updated cleanly!')),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper to show Print Invoice modal sheet when order is placed
  void _showPrintInvoiceDialog({
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
  }) {
    final double tax = totalAmount * 0.08;
    final double grandTotal = totalAmount + tax;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Invoice Header Icon & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('វិក្កយបត្រ #$orderId', 'Invoice #$orderId'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _t('ហាងកាហ្វេ និង នំប៉័ង POS • ស្ថានីយ #1', 'Coffee & Bakery POS • Terminal #1'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _t('រង់ចាំ', 'PENDING'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Divider(color: AppColors.borderLight, height: 1.0),
              const SizedBox(height: 16.0),

              // Items breakdown list
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['qty']}x ${item['name']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (item['variant'] != null)
                            Text(
                              _t('ជម្រើស: ${item['variant']}', 'Variant: ${item['variant']}'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '\$${(item['itemTotal'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12.0),
              const Divider(color: AppColors.borderLight, height: 1.0),
              const SizedBox(height: 12.0),

              // Summary breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('សរុបរង', 'Subtotal'), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('ពន្ធ (8%)', 'Tax (8%)'), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  Text('\$${tax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('ចំនួនទឹកប្រាក់សរុប', 'Total Amount'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(
                    '\$${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // Print Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: _t('បិទ', 'Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: PrimaryButton(
                      text: _t('បោះពុម្ពវិក្កយបត្រ', 'Print Invoice'),
                      icon: const Icon(Icons.print_rounded, size: 20, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_t('កំពុងបោះពុម្ពវិក្កយបត្រ #$orderId ទៅកាន់ម៉ាស៊ីនបោះពុម្ព...', 'Printing Invoice #$orderId to POS Thermal Printer...')),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 2: POS Tab (Product Terminal Checkout)
  Widget _buildPOSTab() {
    double totalCart = 0;
    int totalItemsCount = 0;

    _posQuantities.forEach((itemName, qty) {
      if (qty > 0) {
        final matchingIndex = _products.indexWhere((p) => p.name == itemName);
        if (matchingIndex != -1) {
          final p = _products[matchingIndex];
          final variant = selectedVariants[itemName];
          final variantExtra = variant?.extraPrice ?? 0.0;
          final addOns = selectedAddOns[itemName] ?? [];
          final addOnsExtra = addOns.fold(0.0, (sum, item) => sum + item.extraPrice);
          totalCart += qty * (p.price + variantExtra + addOnsExtra);
          totalItemsCount += qty;
        }
      }
    });

    final filteredProducts = _selectedPOSCategoryIndex == 0
        ? _products
        : _products.where((p) => p.category == _categories[_selectedPOSCategoryIndex - 1]).toList();

    return Column(
      children: [
        // Scrollable Products Area with CustomScrollView
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Horizontal Category Pills Sliver
              if (_categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: _categories.length + 1,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedPOSCategoryIndex;
                        final rawCategory = index == 0 ? 'All' : _categories[index - 1];
                        final text = index == 0
                            ? _t('ទាំងអស់', 'All')
                            : (rawCategory == 'Coffee'
                                ? _t('កាហ្វេ', 'Coffee')
                                : rawCategory == 'Bakery'
                                    ? _t('នំប៉័ង', 'Bakery')
                                    : rawCategory);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPOSCategoryIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Product Slivers or Empty State
              if (_isLoadingData)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _t('គ្មានផលិតផលក្នុងបញ្ជីទេ។\nសូមបន្ថែមផលិតផលក្នុងទំព័រគ្រប់គ្រង។', 'No products in catalog.\nAdd products in Settings to start.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              else if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _t('គ្មានផលិតផលក្នុងប្រភេទទំនិញនេះទេ។', 'No products in this category.'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        final qty = _posQuantities[product.name] ?? 0;
                        final selectedVariant = selectedVariants[product.name] ??
                            (product.variants.isNotEmpty ? product.variants.first : null);
                        final selectedSugar = selectedSugarLevels[product.name];
                        final currentAddOns = selectedAddOns[product.name] ?? [];

                        final double variantExtra = selectedVariant?.extraPrice ?? 0.0;
                        final double addOnsExtra = currentAddOns.fold(0.0, (sum, a) => sum + a.extraPrice);
                        final double itemFinalPrice = product.price + variantExtra + addOnsExtra;

                        final List<String> optionTexts = [];
                        if (selectedVariant != null) optionTexts.add(selectedVariant.name);
                        if (selectedSugar != null) optionTexts.add('Sugar $selectedSugar');
                        if (currentAddOns.isNotEmpty) {
                          optionTexts.add(currentAddOns.map((a) => a.name).join(', '));
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            onTap: () => _showVariantSelectionSheet(product),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Icon(product.icon, color: AppColors.primary, size: 24),
                                          ),
                                          const SizedBox(width: 14.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 2.0),
                                                Text(
                                                  '\$${itemFinalPrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Quantity Selector
                                    Row(
                                      children: [
                                        AppIconButton(
                                          icon: Icons.remove,
                                          size: 34,
                                          onPressed: qty > 0
                                              ? () => setState(() => _posQuantities[product.name] = qty - 1)
                                              : null,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        AppIconButton(
                                          icon: Icons.add,
                                          size: 34,
                                          onPressed: product.stock > 0
                                              ? () {
                                                  if (qty < product.stock) {
                                                    setState(() => _posQuantities[product.name] = qty + 1);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(_t('មិនអាចលើសពីចំនួនក្នុងស្តុក ${product.stock} បានទេ', 'Cannot exceed available stock of ${product.stock}')),
                                                        duration: const Duration(seconds: 1),
                                                      ),
                                                    );
                                                  }
                                                }
                                              : () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(_t('ផលិតផលនេះអស់ពីស្តុកហើយ', 'Item is out of stock')),
                                                      duration: const Duration(seconds: 1),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Customization option chip row
                                const SizedBox(height: 10.0),
                                const Divider(color: AppColors.borderLight, height: 1.0),
                                const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.tune_rounded, size: 14, color: AppColors.textSecondary),
                                          const SizedBox(width: 6.0),
                                          Expanded(
                                            child: Text(
                                              optionTexts.isNotEmpty
                                                  ? optionTexts.join(' • ')
                                                  : _t('ជម្រើស: ធម្មតា', 'Option: Standard'),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _showVariantSelectionSheet(product),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(20.0),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.0),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              _t('កែប្រែជម្រើស', 'Customize'),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.keyboard_arrow_right_rounded, size: 14, color: AppColors.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Cart Summary & Single Order & Print Invoice Action Button
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1.0),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _t('សរុបការកុម្ម៉ង់ ($totalItemsCount មុខ):', 'Order Total ($totalItemsCount items):'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                  Text(
                    '\$${totalCart.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              PrimaryButton(
                text: _t('កុម្ម៉ង់ និង បោះពុម្ពវិក្កយបត្រ', 'Order & Print Invoice'),
                icon: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.white),
                onPressed: totalCart > 0
                    ? () async {
                        final List<String> cartSummary = [];
                        final List<Map<String, dynamic>> invoiceItems = [];
                        final List<Map<String, dynamic>> orderItems = [];

                        _posQuantities.forEach((itemName, qty) {
                          if (qty > 0) {
                            final matchingIndex = _products.indexWhere((p) => p.name == itemName);
                            if (matchingIndex == -1) return;
                            final p = _products[matchingIndex];
                            final v = selectedVariants[itemName];
                            final sugar = selectedSugarLevels[itemName];
                            final addOns = selectedAddOns[itemName] ?? [];

                            final vExtra = v?.extraPrice ?? 0.0;
                            final addOnsExtra = addOns.fold(0.0, (sum, a) => sum + a.extraPrice);
                            final unitPrice = p.price + vExtra + addOnsExtra;

                            final List<String> opts = [];
                            if (v != null) opts.add(v.name);
                            if (sugar != null) opts.add('$sugar Sugar');
                            if (addOns.isNotEmpty) opts.add(addOns.map((a) => a.name).join(', '));
                            final optString = opts.isNotEmpty ? ' (${opts.join(", ")})' : '';

                            cartSummary.add('$qty x $itemName$optString');
                            invoiceItems.add({
                              'name': itemName,
                              'variant': opts.isNotEmpty ? opts.join(', ') : null,
                              'qty': qty,
                              'unitPrice': unitPrice,
                              'itemTotal': qty * unitPrice,
                            });
                            
                            orderItems.add({
                              'product_id': p.id,
                              'quantity': qty,
                              'price': unitPrice,
                            });
                          }
                        });

                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          final orderId = await ApiService.createOrder(
                            'Cash',
                            totalCart,
                            orderItems,
                          );

                          // Close loading indicator
                          if (mounted) Navigator.pop(context);

                          setState(() {
                            // Insert into local ordersList
                            ordersList.insert(
                              0,
                              OrderItemModel(
                                id: orderId.substring(0, 4), // shorthand order display
                                title: 'Order #${orderId.substring(0, 4)} • ${cartSummary.join(", ")}',
                                subtitle: 'Just now • Terminal #1 • $totalItemsCount Items',
                                amount: '+\$${totalCart.toStringAsFixed(2)}',
                                status: 'Pending',
                                icon: Icons.hourglass_top_rounded,
                                leadingBgColor: const Color(0xFFFEF3C7),
                                leadingIconColor: AppColors.warning,
                                isPositive: true,
                              ),
                            );
                            
                            // Reset cart quantities
                            _posQuantities.updateAll((key, val) => 0);
                            selectedVariants.clear();
                            selectedSugarLevels.clear();
                            selectedAddOns.clear();
                          });

                          // Reload data to reflect stock update
                          await _loadData();

                          if (mounted) {
                            _showPrintInvoiceDialog(
                              orderId: orderId.substring(0, 4),
                              items: invoiceItems,
                              totalAmount: totalCart,
                            );
                          }
                        } catch (e) {
                          // Close loading indicator if open
                          if (mounted) Navigator.pop(context);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Checkout failed: ${e.toString().replaceAll("Exception: ", "")}'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      }
                    : null,
              ),
            ],
          ),
        )
      ],
    );
  }

  // TAB 3: Order Tab (Recent Transactions & Filter by Pending/Completed/Refunded)
  Widget _buildOrderTab() {
    final List<OrderItemModel> filteredOrders = ordersList.where((order) {
      if (_activeOrderFilter == 1) return order.status == 'Pending';
      if (_activeOrderFilter == 2) return order.status == 'Completed';
      if (_activeOrderFilter == 3) return order.status == 'Refunded';
      return true; // Filter 0 = 'All'
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // Filter Pills Sliver
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: TabPills(
              tabs: [
                _t('ទាំងអស់', 'All'),
                _t('រង់ចាំ', 'Pending'),
                _t('បានបញ្ចប់', 'Completed'),
                _t('ប្រាក់សងវិញ', 'Refunds'),
              ],
              selectedIndex: _activeOrderFilter,
              onTabChanged: (val) {
                setState(() {
                  _activeOrderFilter = val;
                });
              },
            ),
          ),
        ),
        
        // Orders List Slivers or Empty State Sliver
        if (filteredOrders.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                _t('មិនមានការកុម្ម៉ង់ក្នុងស្ថានភាពនេះទេ។', 'No orders found for this status.'),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = filteredOrders[index];
                  final statusDisplay = order.status == 'Pending'
                      ? _t('រង់ចាំ', 'Pending')
                      : order.status == 'Completed'
                          ? _t('បានបញ្ចប់', 'Completed')
                          : _t('បានសងប្រាក់វិញ', 'Refunded');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      children: [
                        ListItemCard(
                          title: order.title,
                          subtitle: order.subtitle,
                          trailingTitle: order.amount,
                          trailingSubtitle: statusDisplay,
                          leadingIcon: order.icon,
                          leadingBgColor: order.leadingBgColor,
                          leadingIconColor: order.leadingIconColor,
                          isPositive: order.isPositive,
                        ),
                        if (order.status == 'Pending') ...[
                          const SizedBox(height: 6.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    final oIndex = ordersList.indexWhere((o) => o.id == order.id);
                                    if (oIndex != -1) {
                                      ordersList[oIndex] = OrderItemModel(
                                        id: order.id,
                                        title: order.title,
                                        subtitle: order.subtitle,
                                        amount: order.amount,
                                        status: 'Completed',
                                        icon: Icons.check_circle_rounded,
                                        leadingBgColor: const Color(0xFFEFF6FF),
                                        leadingIconColor: AppColors.primary,
                                        isPositive: true,
                                      );
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_t('${order.title} ត្រូវបានកំណត់ជា បានបញ្ចប់!', '${order.title} marked as Completed!')),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.payment_rounded, size: 14, color: Colors.white),
                                      const SizedBox(width: 6.0),
                                      Text(
                                        _t('បញ្ចប់ការកុម្ម៉ង់ និង ទូទាត់', 'Complete Order & Pay'),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
                childCount: filteredOrders.length,
              ),
            ),
          ),
      ],
    );
  }

  // TAB 4: Setting Tab (Configuration Settings)
  Widget _buildSettingTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Centered Profile Section (Matching image style)
          const SizedBox(height: 16.0),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.borderLight, width: 3.0),
                  ),
                  child: ClipOval(
                    child: _merchantImageUrl != null && _merchantImageUrl!.isNotEmpty
                        ? Image.network(
                            _merchantImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          )
                        : Image.network(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Center(
            child: Text(
              _merchantName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Center(
            child: Text(
              _merchantEmail,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Heading: General Settings
          Text(
            _t('ទូទៅ', 'General'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12.0),

          // Menu items inside separated cards pushing to separate screen pages
          _buildSettingTile(
            icon: Icons.person_rounded,
            title: _t('កែប្រែព័ត៌មានរូបថត', 'Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),

          _buildSettingTile(
            icon: Icons.inventory_2_rounded,
            title: _t('គ្រប់គ្រងផលិតផល', 'Manage Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageProductsScreen(
                    products: _products,
                    posQuantities: _posQuantities,
                    categories: _categories,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),

          _buildSettingTile(
            icon: Icons.category_rounded,
            title: _t('គ្រប់គ្រងប្រភេទទំនិញ', 'Manage Categories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageCategoriesScreen(
                    categories: _categories,
                    products: _products,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),

          _buildSettingTile(
            icon: Icons.notifications_rounded,
            title: _t('ការកំណត់ការជូនដំណឹង', 'Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 16.0),

          // Heading: Other
          Text(
            _t('ផ្សេងៗ', 'Other'),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12.0),

          _buildSettingTile(
            icon: Icons.help_center_rounded,
            title: _t('មជ្ឈមណ្ឌលជំនួយ', 'Help Center'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_t('ចុចលើមជ្ឈមណ្ឌលជំនួយ', 'Help Center pressed'))),
              );
            },
          ),

          _buildSettingTile(
            icon: Icons.info_rounded,
            title: _t('អំពីយើង', 'About Us'),
            isExpanded: _isAboutExpanded,
            onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
            expandedContent: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POS Terminal v1.2.4',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _t('កំណែប្រព័ន្ធប្រតិបត្តិការ (Rev. 84)\nប្រព័ន្ធសុវត្ថិភាព SSL • ច្រកទូទាត់ PCI', 'Production Build (Rev. 84)\nSecure SSL Encryption • PCI Compliant Gateway'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          _buildSettingTile(
            icon: Icons.logout_rounded,
            title: _t('ចាកចេញ', 'Log Out'),
            isDestructive: true,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    ),
  ),
],
);
  }

  // Floating list item card builder for settings
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    bool isExpanded = false,
    VoidCallback? onTap,
    Widget? expandedContent,
  }) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: isDestructive ? AppColors.error : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 14.0),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? AppColors.error : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (expandedContent != null)
                    Icon(
                      isExpanded 
                          ? Icons.keyboard_arrow_up_rounded 
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  else if (!isDestructive)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
              if (isExpanded && expandedContent != null) ...[
                const SizedBox(height: 12.0),
                const Divider(color: AppColors.borderLight, height: 1.0),
                const SizedBox(height: 12.0),
                expandedContent,
              ],
            ],
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  // Custom animated bottom bar helper configuration

}
