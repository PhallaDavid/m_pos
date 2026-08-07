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
import 'manage_products_screen.dart';
import 'manage_categories_screen.dart';
import 'report_dashboard_screen.dart';
import '../theme/app_translations.dart';
import '../services/api_service.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/pos_skeleton.dart';
import '../widgets/order_skeleton.dart';
import '../widgets/settings_skeleton.dart';
import '../widgets/skeleton_loader.dart';

// ==========================================
// ANIMATED HEADER WIDGETS
// ==========================================

class AnimatedHomeHeader extends StatefulWidget {
  final String merchantName;
  final String? merchantImageUrl;
  final String selectedLanguage;
  final VoidCallback onLanguageTap;
  final VoidCallback? onAvatarTap;
  final bool isDarkMode;
  final bool isLoading;
  final String Function(String khmerText, String englishText) translate;

  const AnimatedHomeHeader({
    super.key,
    required this.merchantName,
    this.merchantImageUrl,
    required this.selectedLanguage,
    required this.onLanguageTap,
    this.onAvatarTap,
    required this.isDarkMode,
    required this.isLoading,
    required this.translate,
  });

  @override
  State<AnimatedHomeHeader> createState() => _AnimatedHomeHeaderState();
}

class _AnimatedHomeHeaderState extends State<AnimatedHomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  
  late Animation<double> _avatarScale;
  late Animation<double> _fadeOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _avatarScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(-0.08, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    const Color headerTitleColor = Colors.white;
    final Color headerSubtitleColor = Colors.white.withOpacity(0.85);
    final Color headerCardBg = widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.2);
    final String firstName = widget.merchantName.split(" ").first;

    if (widget.isLoading) {
      final Color skeletonBaseColor = widget.isDarkMode 
          ? Colors.white.withOpacity(0.08) 
          : const Color(0xFFE2E8F0);
      final Color skeletonHighlightColor = widget.isDarkMode 
          ? Colors.white.withOpacity(0.18) 
          : const Color(0xFFF8FAFC);

      return Container(
        padding: EdgeInsets.fromLTRB(24.0, statusBarHeight + 12.0, 24.0, 16.0),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Shimmer Avatar circle skeleton
                AppShimmer(
                  baseColor: skeletonBaseColor,
                  highlightColor: skeletonHighlightColor,
                  child: const SkeletonCircle(size: 44),
                ),
                const SizedBox(width: 14.0),
                
                // Shimmer Text skeleton
                AppShimmer(
                  baseColor: skeletonBaseColor,
                  highlightColor: skeletonHighlightColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonText(width: 140, height: 18, borderRadius: 6),
                      SizedBox(height: 6),
                      SkeletonText(width: 180, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
            
            // Shimmer Language flag skeleton (matches rectangular flag shape 46x32)
            AppShimmer(
              baseColor: skeletonBaseColor,
              highlightColor: skeletonHighlightColor,
              child: const SkeletonBox(width: 46, height: 32, borderRadius: 6),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24.0, statusBarHeight + 12.0, 24.0, 16.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Animated Avatar (Clickable to Settings)
              GestureDetector(
                onTap: widget.onAvatarTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ScaleTransition(
                    scale: _avatarScale,
                    child: FadeTransition(
                      opacity: _fadeOpacity,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: headerCardBg,
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: widget.merchantImageUrl != null &&
                                  widget.merchantImageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.merchantImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person_rounded,
                                    color: headerTitleColor,
                                    size: 24,
                                  ),
                                )
                              : Image.network(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      'AX',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: headerTitleColor,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              
              // Animated Text Section (Greeting & Subtitle)
              FadeTransition(
                opacity: _fadeOpacity,
                child: SlideTransition(
                  position: _textSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.translate('ស្វាគមន៍ $firstName! 👋', 'Welcome, $firstName! 👋'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headerTitleColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.translate('គ្រប់គ្រងហាង និងការលក់របស់អ្នក', 'Manage your store and sales'),
                        style: TextStyle(
                          fontSize: 12,
                          color: headerSubtitleColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Animated Language Switcher Button (Full rectangular Wikipedia Flags)
          ScaleTransition(
            scale: _avatarScale,
            child: FadeTransition(
              opacity: _fadeOpacity,
              child: GestureDetector(
                onTap: widget.onLanguageTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.selectedLanguage == 'English'
                            ? 'https://flagcdn.com/w160/gb.png'
                            : 'https://flagcdn.com/w160/kh.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            widget.selectedLanguage == 'English' ? '🇬🇧' : '🇰🇭',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPageHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData headerIcon;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final bool isDarkMode;

  const AnimatedPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    this.actionIcon,
    this.onActionPressed,
    required this.isDarkMode,
  });

  @override
  State<AnimatedPageHeader> createState() => _AnimatedPageHeaderState();
}

class _AnimatedPageHeaderState extends State<AnimatedPageHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(begin: const Offset(0.0, -0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title || oldWidget.subtitle != widget.subtitle) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    const Color headerTitleColor = Colors.white;
    final Color headerSubtitleColor = Colors.white.withOpacity(0.85);
    final Color headerIconBg = widget.isDarkMode ? const Color(0xFF0F2B66) : Colors.white.withOpacity(0.2);
    final Color headerIconColor = widget.isDarkMode ? const Color(0xFF5CC8FF) : Colors.white;
    final Color headerCardBg = widget.isDarkMode ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.2);
    final Color headerBorderColor = widget.isDarkMode ? const Color(0xFF334155) : Colors.white.withOpacity(0.3);

    return Container(
      padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 12.0, 20.0, 12.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: headerIconBg,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: headerIconColor.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(widget.headerIcon, color: headerIconColor, size: 22),
                  ),
                  const SizedBox(width: 14.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headerTitleColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: headerSubtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.actionIcon != null)
                AppIconButton(
                  icon: widget.actionIcon!,
                  iconColor: headerTitleColor,
                  backgroundColor: headerCardBg,
                  border: Border.all(color: headerBorderColor, width: 1.0),
                  onPressed: widget.onActionPressed,
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

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
  
  // Selected display language (default English, hot-reload safe)
  String? _selectedLanguage = 'English';

  String get selectedLanguage {
    _selectedLanguage ??= 'English';
    return _selectedLanguage!;
  }

  // Translation helper shorthand
  String _t(String khmerText, String englishText) {
    return AppTranslations.tr(selectedLanguage, khmerText, englishText);
  }

  // State for POS terminal settings expansion
  bool _isAboutExpanded = false;
  bool _isDarkMode = false;
  
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
      final dbCats = await ApiService.getCategories(storeIdParam: ApiService.storeId);
      final products = await ApiService.getProducts(storeIdParam: ApiService.storeId);
      
      // Fetch profile in parallel or secondary
      try {
        final profile = await ApiService.getProfile();
        _merchantName = profile['name'] != null && profile['name'].isNotEmpty ? profile['name'] : 'Alexa Smith';
        _merchantEmail = ApiService.userEmail ?? 'alexa.smith@merchant.com';
        _merchantImageUrl = profile['image_url'];
      } catch (_) {}

      // Fetch dashboard metrics
      try {
        final stats = await ApiService.getDashboardStats(storeIdParam: ApiService.storeId);
        _totalSalesRevenue = (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
        _totalOrdersCount = (stats['total_orders'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      // Fetch recent orders
      try {
        final ordersData = await ApiService.getOrders(storeIdParam: ApiService.storeId);
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
    return Theme(
      data: AppTheme.getTheme(isDark: _isDarkMode, language: selectedLanguage),
      child: Scaffold(
        backgroundColor: _isDarkMode ? const Color(0xFF0F172A) : AppColors.background,
        body: Stack(
          children: [
            if (!_isDarkMode)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E40AF),
                        Color(0xFF3B82F6),
                        Color(0xFFF8FAFC), // Fades to light page background
                      ],
                      stops: [0.0, 0.7, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            Positioned.fill(
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
        bottomNavigationBar: AnimatedBottomBar(
          currentIndex: () {
            if (_currentIndex == 0) return 0;
            if (_currentIndex == 1) return 2; // POS center
            if (_currentIndex == 2) return 1; // Orders
            if (_currentIndex == 3) return 4; // Settings
            return 0;
          }(),
          onTap: (index) {
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReportDashboardScreen(),
                ),
              );
            } else {
              int targetTab = _currentIndex;
              if (index == 0) targetTab = 0;
              if (index == 1) targetTab = 2; // Orders
              if (index == 2) targetTab = 1; // POS
              if (index == 4) targetTab = 3; // Settings
              setState(() {
                _currentIndex = targetTab;
              });
            }
          },
          items: [
            AnimatedBottomBarItem(
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_rounded,
              label: _t('ទំព័រដើម', 'Home'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: _t('ការកុម្ម៉ង់', 'Order'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.point_of_sale_outlined,
              activeIcon: Icons.point_of_sale_rounded,
              label: _t('លក់ (POS)', 'POS'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics_rounded,
              label: _t('របាយការណ៍', 'Reports'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: _t('ការកំណត់', 'Setting'),
            ),
          ],
        ),
      ),
    );
  }

  // Directly toggles the language between English and Khmer (Cambodian)
  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = (selectedLanguage == 'English') ? 'Khmer' : 'English';
    });
    final bool isEn = selectedLanguage == 'English';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn ? 'Language updated to English' : 'បានប្តូរទៅជាភាសាខ្មែរជោគជ័យ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Page-Specific Header Bar (Home, POS, Order, Setting)
  Widget _buildTopHeader() {
    // TAB 0: Home Page Header
    if (_currentIndex == 0) {
      return AnimatedHomeHeader(
        merchantName: _merchantName,
        merchantImageUrl: _merchantImageUrl,
        selectedLanguage: selectedLanguage,
        onLanguageTap: _toggleLanguage,
        onAvatarTap: () {
          setState(() {
            _currentIndex = 3;
          });
        },
        isDarkMode: _isDarkMode,
        isLoading: _isLoadingData,
        translate: _t,
      );
    }

    // Dynamic header configurations for POS, Order, and Setting tabs
    String title = _t('ស្ថានីយ POS', 'POS Terminal');
    String subtitle = _t('ស្ថានីយ #1 • សកម្ម', 'Terminal #1 • Active');
    IconData headerIcon = Icons.point_of_sale_rounded;
    IconData? actionIcon;
    VoidCallback? onActionPressed;

    if (_currentIndex == 1) {
      title = _t('ស្ថានីយ POS', 'POS Terminal');
      subtitle = _t('ស្ថានីយ #1 • សកម្ម', 'Terminal #1 • Active');
      headerIcon = Icons.point_of_sale_rounded;
      // Removed restart/refresh icon
      onActionPressed = null;
    } else if (_currentIndex == 2) {
      title = _t('ការកុម្ម៉ង់ និង ប្រតិបត្តិការ', 'Orders & Transactions');
      subtitle = _t('ថ្ងៃនេះ: ${ordersList.length} ការកុម្ម៉ង់', 'Today: ${ordersList.length} Orders');
      headerIcon = Icons.receipt_long_rounded;
      // Removed refresh icon
      onActionPressed = null;
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

    return AnimatedPageHeader(
      title: title,
      subtitle: subtitle,
      headerIcon: headerIcon,
      actionIcon: actionIcon,
      onActionPressed: onActionPressed,
      isDarkMode: _isDarkMode,
    );
  }
  Widget _buildHomeTab() {
    if (_isLoadingData) {
      return HomeSkeleton(
        headerSliver: SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
      );
    }

    final recentOrders = ordersList.take(5).toList();

    final bool isDark = _isDarkMode;
    final Color cardBgColor = isDark ? Colors.transparent : Colors.white;
    final Gradient? cardGradient = isDark 
        ? const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    final Border cardBorder = Border.all(
      color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
      width: 1.0,
    );
    final List<BoxShadow> cardShadow = isDark 
        ? [] 
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ];

    final Color cardTitleColor = isDark ? Colors.white : AppColors.heading;
    final Color cardSubtitleColor = isDark ? Colors.white.withOpacity(0.70) : AppColors.textSecondary;
    final Color cardWalletIconColor = isDark ? Colors.white : AppColors.primary;
    final Color cardWalletIconBg = isDark ? Colors.white.withOpacity(0.12) : AppColors.primaryLight;
    final Color cardLiveBadgeBg = isDark ? Colors.white.withOpacity(0.10) : AppColors.successLight;
    final Border cardLiveBadgeBorder = Border.all(
      color: isDark ? Colors.white.withOpacity(0.20) : AppColors.success.withOpacity(0.3),
      width: 0.8,
    );
    final Color cardValueColor = isDark ? Colors.white : AppColors.heading;
    final Color cardDividerColor = isDark ? Colors.white.withOpacity(0.12) : AppColors.borderLight;
    final Color cardFooterTimeColor = isDark ? Colors.white.withOpacity(0.70) : AppColors.textSecondary;
    
    final Color btnBgColor = isDark ? Colors.white : AppColors.primaryLight;
    final Color btnTextColor = isDark ? const Color(0xFF0F172A) : AppColors.primary;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _buildTopHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Sales Report Card (Sleek SaaS Style - Consistent with other cards)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportDashboardScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(22.0),
                        border: cardBorder,
                        boxShadow: cardShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Wallet Icon + Title & Live Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: cardWalletIconBg,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: cardWalletIconColor,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _t('សមតុល្យចំណូលលក់', 'Sales Revenue'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: cardTitleColor,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _t('ចំណូលសរុបហាង', 'Total Store Earnings'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cardSubtitleColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Live Report Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: cardLiveBadgeBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: cardLiveBadgeBorder,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF16C784),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _t('ផ្ទាល់', 'Live'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF16C784),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),

                            // Revenue Balance Value + Green Growth Chip Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${_totalSalesRevenue.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: cardValueColor,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F9F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_upward_rounded, color: Color(0xFF16C784), size: 14),
                                      SizedBox(width: 3),
                                      Text(
                                        '+14.8%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16C784),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18.0),
                            Divider(
                              color: cardDividerColor,
                              thickness: 1.0,
                            ),
                            const SizedBox(height: 12.0),

                            // Footer with Time & View Dashboard CTA Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: cardFooterTimeColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _t('ធ្វើបច្ចុប្បន្នភាព 1 នាទីមុន', 'Updated 1 min ago'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cardFooterTimeColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: btnBgColor,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        _t('មើលផ្ទាំងគ្រប់គ្រង', 'View Dashboard'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: btnTextColor,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: btnTextColor,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Stat Cards Grid (Sales Today & Transactions Count)
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.trending_up_rounded,
                          label: _t('ការលក់ថ្ងៃនេះ', 'Sales Today'),
                          value: '\$${_salesToday.toStringAsFixed(2)}',
                          trendText: '+8.2%',
                          isTrendPositive: true,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: StatCard(
                          icon: Icons.receipt_long_rounded,
                          label: _t('ការកុម្ម៉ង់ថ្ងៃនេះ', 'Today\'s Orders'),
                          value: _t('$_ordersTodayCount ការកុម្ម៉ង់', '$_ordersTodayCount Orders'),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : AppColors.heading,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    children: [
                      _buildQuickActionTile(
                        icon: Icons.inventory_2_rounded,
                        label: _t('ផលិតផល', 'Products'),
                        color: AppColors.primary,
                        bgColor: const Color(0xFFEEF5FB),
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
                        color: AppColors.primary,
                        bgColor: const Color(0xFFEEF5FB),
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
                        color: AppColors.primary,
                        bgColor: const Color(0xFFEEF5FB),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _currentIndex = 2),
                        child: Text(
                          _t('មើលទាំងអស់', 'View All'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary,
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
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final Color tileBg = _isDarkMode ? const Color(0xFF1E293B) : AppColors.surface;
    final Color tileBorder = _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight;
    final Color effectiveIconBg = _isDarkMode ? const Color(0xFF0F2B66) : bgColor;
    final Color effectiveIconColor = _isDarkMode ? const Color(0xFF5CC8FF) : color;
    final Color labelColor = _isDarkMode ? Colors.white : AppColors.heading;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: tileBorder, width: 1.0),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 22),
              ),
              const SizedBox(height: 10.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                  letterSpacing: -0.2,
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
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF1E293B) : AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
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
                          color: _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight,
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
                                color: _isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(product.icon, color: _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _t('តម្លៃដើម: \$${product.price.toStringAsFixed(2)}', 'Base Price: \$${product.price.toStringAsFixed(2)}'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: _isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: _isDarkMode ? const Color(0xFF5CC8FF).withOpacity(0.3) : AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            '\$${calculatedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.variants.map((v) {
                          final isSelected = activeVariant?.name == v.name;
                          final Color cardBg = isSelected 
                              ? (_isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight) 
                              : (_isDarkMode ? const Color(0xFF0F172A) : AppColors.surface);
                          final Color cardBorder = isSelected 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? const Color(0xFF334155) : AppColors.borderLight);
                          final Color cardTitle = isSelected 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? Colors.white : AppColors.textPrimary);
                          final Color cardSub = isSelected 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary);

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
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: cardBorder,
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
                                        color: cardTitle,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: cardTitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    v.extraPrice > 0 ? '+\$${v.extraPrice.toStringAsFixed(2)}' : _t('ឥតគិតថ្លៃ', 'Free'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: cardSub,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: product.sugarLevels.map((sugar) {
                            final isSelected = activeSugar == sugar;
                            final Color chipBg = isSelected 
                                ? AppColors.primary 
                                : (_isDarkMode ? const Color(0xFF0F172A) : AppColors.surface);
                            final Color chipBorder = isSelected 
                                ? AppColors.primary 
                                : (_isDarkMode ? const Color(0xFF334155) : AppColors.borderLight);
                            final Color chipText = isSelected 
                                ? Colors.white 
                                : (_isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary);

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
                                    color: chipBg,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: chipBorder,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    sugar,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: chipText,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.availableAddOns.map((addOn) {
                          final isChecked = activeAddOns.any((a) => a.name == addOn.name);
                          final Color cardBg = isChecked 
                              ? (_isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight) 
                              : (_isDarkMode ? const Color(0xFF0F172A) : AppColors.surface);
                          final Color cardBorder = isChecked 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? const Color(0xFF334155) : AppColors.borderLight);
                          final Color cardTitle = isChecked 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? Colors.white : AppColors.textPrimary);
                          final Color cardSub = isChecked 
                              ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary) 
                              : (_isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary);

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
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: cardBorder,
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
                                        color: cardTitle,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        addOn.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                                          color: cardTitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '+\$${addOn.extraPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: cardSub,
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
        final Color sheetBg = _isDarkMode ? const Color(0xFF1E293B) : AppColors.surface;
        final Color textTitle = _isDarkMode ? Colors.white : AppColors.textPrimary;
        final Color textSub = _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary;
        final Color dividerColor = _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight;
        final Color iconBg = _isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight;
        final Color iconColor = _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary;
        final Color totalColor = _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
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
                    color: dividerColor,
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
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: iconColor, size: 24),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('វិក្កយបត្រ #$orderId', 'Invoice #$orderId'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textTitle,
                            ),
                          ),
                          Text(
                            _t('ហាងកាហ្វេ និង នំប៉័ង POS • ស្ថានីយ #1', 'Coffee & Bakery POS • Terminal #1'),
                            style: TextStyle(
                              fontSize: 12,
                              color: textSub,
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
              Divider(color: dividerColor, height: 1.0),
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textTitle,
                            ),
                          ),
                          if (item['variant'] != null)
                            Text(
                              _t('ជម្រើស: ${item['variant']}', 'Variant: ${item['variant']}'),
                              style: TextStyle(
                                fontSize: 12,
                                color: textSub,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '\$${(item['itemTotal'] as double).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textTitle,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12.0),
              Divider(color: dividerColor, height: 1.0),
              const SizedBox(height: 12.0),

              // Summary breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('សរុបរង', 'Subtotal'), style: TextStyle(fontSize: 13, color: textSub)),
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textTitle)),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('ពន្ធ (8%)', 'Tax (8%)'), style: TextStyle(fontSize: 13, color: textSub)),
                  Text('\$${tax.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textTitle)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('ចំនួនទឹកប្រាក់សរុប', 'Total Amount'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textTitle)),
                  Text(
                    '\$${grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: totalColor),
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
    if (_isLoadingData) {
      return POSSkeleton(
        headerSliver: SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
      );
    }

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

    return Container(
      color: _isDarkMode ? const Color(0xFF0F172A) : AppColors.background,
      child: Column(
        children: [
          _buildTopHeader(),
        // Main Content Area: Left Sidebar (Categories) + Right Content (Product Cards Grid)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Left Vertical Category Navigation Sidebar (Compact 72px Width)
              if (_categories.isNotEmpty)
                SizedBox(
                  width: 72,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 12.0, left: 4.0, right: 4.0),
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

                      final Color tileBg = isSelected
                          ? (_isDarkMode ? const Color(0xFF0F2B66) : const Color(0xFFEEF5FB))
                          : (_isDarkMode ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white.withOpacity(0.5));
                      final Color tileBorder = isSelected
                          ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary)
                          : (_isDarkMode ? const Color(0xFF334155).withOpacity(0.4) : AppColors.borderLight.withOpacity(0.6));
                      final Color iconColor = isSelected
                          ? (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary)
                          : (_isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary);
                      final Color textColor = isSelected
                          ? (_isDarkMode ? Colors.white : AppColors.primary)
                          : (_isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary);

                      IconData categoryIcon = Icons.grid_view_rounded;
                      if (rawCategory == 'Coffee') {
                        categoryIcon = Icons.local_cafe_rounded;
                      } else if (rawCategory == 'Bakery') {
                        categoryIcon = Icons.bakery_dining_rounded;
                      } else if (rawCategory == 'Tea') {
                        categoryIcon = Icons.emoji_food_beverage_rounded;
                      } else if (rawCategory == 'Juice') {
                        categoryIcon = Icons.local_drink_rounded;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPOSCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: tileBg,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: tileBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  categoryIcon,
                                  color: iconColor,
                                  size: 20,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  text,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: textColor,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 2. Right Side Product Cards Scroll Area
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Product Slivers or Empty State
                    if (_products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            _t('គ្មានផលិតផលក្នុងបញ្ជីទេ។\nសូមបន្ថែមផលិតផលក្នុងទំព័រគ្រប់គ្រង។', 'No products in catalog.\nAdd products in Settings to start.'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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
                            style: TextStyle(
                              fontSize: 15,
                              color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(12.0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12.0,
                            crossAxisSpacing: 12.0,
                            mainAxisExtent: 220.0,
                          ),
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

                              final Color itemIconBg = _isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight;
                              final Color itemIconColor = _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary;
                              final Color itemTitleColor = _isDarkMode ? Colors.white : AppColors.textPrimary;
                              final Color cardBg = _isDarkMode ? const Color(0xFF1E293B) : AppColors.surface;
                              final Color cardBorder = _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight;
                              final Color customizeBg = _isDarkMode ? const Color(0xFF0F2B66) : AppColors.primaryLight;
                              final Color customizeText = _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary;

                              final bool hasImage = product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;

                              return GestureDetector(
                                onTap: () => _showVariantSelectionSheet(product),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: cardBorder, width: 1.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Full-Width Image Container Fitting the Card
                                      Stack(
                                        children: [
                                          SizedBox(
                                            height: 105.0,
                                            width: double.infinity,
                                            child: hasImage
                                                ? Image.network(
                                                    product.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => Container(
                                                      color: itemIconBg,
                                                      child: Center(
                                                        child: Icon(product.icon, color: itemIconColor, size: 36),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: _isDarkMode
                                                            ? [const Color(0xFF1E293B), const Color(0xFF0F2B66)]
                                                            : [const Color(0xFFE2E8F0), const Color(0xFFEEF5FB)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(product.icon, color: itemIconColor, size: 36),
                                                    ),
                                                  ),
                                          ),
                                          if (product.variants.isNotEmpty || product.sugarLevels.isNotEmpty)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () => _showVariantSelectionSheet(product),
                                                child: Container(
                                                  padding: const EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(
                                                    color: customizeBg.withOpacity(0.9),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: cardBorder, width: 1),
                                                  ),
                                                  child: Icon(Icons.tune_rounded, size: 14, color: customizeText),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      // Details Section
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: itemTitleColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2.0),
                                                  Text(
                                                    '\$${itemFinalPrice.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w800,
                                                      color: _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Bottom Row: Quantity Selector (- qty +)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  AppIconButton(
                                                    icon: Icons.remove,
                                                    size: 26,
                                                    onPressed: qty > 0
                                                        ? () => setState(() => _posQuantities[product.name] = qty - 1)
                                                        : null,
                                                  ),
                                                  Text(
                                                    '$qty',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: itemTitleColor,
                                                    ),
                                                  ),
                                                  AppIconButton(
                                                    icon: Icons.add,
                                                    size: 26,
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
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
            ],
          ),
        ),
        
        // Cart Summary & Single Order & Print Invoice Action Button (Only show when at least 1 item is selected)
        if (totalItemsCount > 0)
          Container(
            padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: _isDarkMode ? const Color(0xFF1E293B) : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight, 
                width: 1.0,
              ),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _t('សរុបការកុម្ម៉ង់ ($totalItemsCount មុខ):', 'Order Total ($totalItemsCount items):'),
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '\$${totalCart.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: _isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary,
                    ),
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
      ),
    );
  }

  // TAB 3: Order Tab (Recent Transactions & Filter by Pending/Completed/Refunded)
  Widget _buildOrderTab() {
    if (_isLoadingData) {
      return OrderSkeleton(
        headerSliver: SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
      );
    }

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
        SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
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
    if (_isLoadingData) {
      return SettingsSkeleton(
        headerSliver: SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: _buildTopHeader(),
        ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          Center(
            child: Text(
              _merchantEmail,
              style: TextStyle(
                fontSize: 13,
                color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Heading: General Settings
          Text(
            _t('ទូទៅ', 'General'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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

          const SizedBox(height: 16.0),

          // Heading: Other
          Text(
            _t('ផ្សេងៗ', 'Other'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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
                Text(
                  'POS Terminal v1.2.4',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _t('កំណែប្រព័ន្ធប្រតិបត្តិការ (Rev. 84)\nប្រព័ន្ធសុវត្ថិភាព SSL • ច្រកទូទាត់ PCI', 'Production Build (Rev. 84)\nSecure SSL Encryption • PCI Compliant Gateway'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary,
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
    final Color iconColor = isDestructive 
        ? AppColors.error 
        : (_isDarkMode ? const Color(0xFF5CC8FF) : AppColors.primary);
    final Color titleColor = isDestructive 
        ? AppColors.error 
        : (_isDarkMode ? Colors.white : AppColors.textPrimary);
    final Color dividerColor = _isDarkMode ? const Color(0xFF334155) : AppColors.borderLight;
    final Color arrowColor = _isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondary;

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
                        color: iconColor,
                        size: 20,
                      ),
                      const SizedBox(width: 14.0),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  if (expandedContent != null)
                    Icon(
                      isExpanded 
                          ? Icons.keyboard_arrow_up_rounded 
                          : Icons.keyboard_arrow_down_rounded,
                      color: arrowColor,
                      size: 20,
                    )
                  else if (!isDestructive)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: arrowColor,
                      size: 20,
                    ),
                ],
              ),
              if (isExpanded && expandedContent != null) ...[
                const SizedBox(height: 12.0),
                Divider(color: dividerColor, height: 1.0),
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
}
