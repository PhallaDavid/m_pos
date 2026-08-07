import 'dart:ui';
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
import '../widgets/app_toast.dart';
import '../widgets/fade_slide_in.dart';
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

    _textSlide =
        Tween<Offset>(
          begin: const Offset(-0.08, 0.0),
          end: Offset.zero,
        ).animate(
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
    final Color headerCardBg = widget.isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white.withOpacity(0.2);
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
        decoration: const BoxDecoration(color: Colors.transparent),
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
      decoration: const BoxDecoration(color: Colors.transparent),
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
                          child:
                              widget.merchantImageUrl != null &&
                                  widget.merchantImageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.merchantImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person_rounded,
                                        color: headerTitleColor,
                                        size: 24,
                                      ),
                                )
                              : Image.network(
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
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
                        widget.translate(
                          'ស្វាគមន៍ $firstName! 👋',
                          'Welcome, $firstName! 👋',
                        ),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headerTitleColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.translate(
                          'គ្រប់គ្រងហាង និងការលក់របស់អ្នក',
                          'Manage your store and sales',
                        ),
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
                            widget.selectedLanguage == 'English'
                                ? '🇬🇧'
                                : '🇰🇭',
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

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slide = Tween<Offset>(
      begin: const Offset(0.0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle) {
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

    final Color headerTitleColor = widget.isDarkMode
        ? Colors.white
        : AppColors.heading;
    final Color headerSubtitleColor = widget.isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;
    final Color headerIconBg = widget.isDarkMode
        ? const Color(0xFF0F2B66)
        : AppColors.primaryLight;
    final Color headerIconColor = widget.isDarkMode
        ? const Color(0xFF5CC8FF)
        : AppColors.primary;
    final Color headerCardBg = widget.isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white.withOpacity(0.8);
    final Color headerBorderColor = widget.isDarkMode
        ? const Color(0xFF334155)
        : AppColors.borderLight;

    return Container(
      padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 14.0, 20.0, 12.0),
      decoration: const BoxDecoration(color: Colors.transparent),
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
                    child: Icon(
                      widget.headerIcon,
                      color: headerIconColor,
                      size: 22,
                    ),
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
  final List<Map<String, dynamic>>? rawItems;

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
    this.rawItems,
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

  // Search & Category state filtering
  final TextEditingController _posSearchController = TextEditingController();
  String _posSearchQuery = '';
  int _selectedPOSCategoryIndex = 0;
  List<String> _categories = ['Coffee', 'Bakery'];
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

  Future<void> _loadData({bool silent = false}) async {
    if (!mounted) return;
    if (!silent && _products.isEmpty) {
      setState(() {
        _isLoadingData = true;
      });
    }
    try {
      print(
        'DEBUG [_loadData] Fetching data... ApiService.storeId = ${ApiService.storeId}',
      );
      final dbCats = await ApiService.getCategories(
        storeIdParam: ApiService.storeId,
      );
      print('DEBUG [_loadData] Fetched dbCats count: ${dbCats.length}');
      final products = await ApiService.getProducts(
        storeIdParam: ApiService.storeId,
      );
      print('DEBUG [_loadData] Fetched products count: ${products.length}');
      for (var p in products) {
        print(
          'DEBUG [_loadData] Product: ${p.name} | category: ${p.category} | price: \$${p.price}',
        );
      }

      // Fetch profile in parallel or secondary
      try {
        final profile = await ApiService.getProfile();
        _merchantName = profile['name'] != null && profile['name'].isNotEmpty
            ? profile['name']
            : 'Alexa Smith';
        _merchantEmail = ApiService.userEmail ?? 'alexa.smith@merchant.com';
        _merchantImageUrl = profile['image_url'];
      } catch (_) {}

      // Fetch dashboard metrics
      try {
        final stats = await ApiService.getDashboardStats(
          storeIdParam: ApiService.storeId,
        );
        _totalSalesRevenue =
            (stats['total_revenue'] as num?)?.toDouble() ?? 0.0;
        _totalOrdersCount = (stats['total_orders'] as num?)?.toInt() ?? 0;
      } catch (_) {}

      // Fetch recent orders
      try {
        final ordersData = await ApiService.getOrders(
          storeIdParam: ApiService.storeId,
        );
        final List<OrderItemModel> loadedOrders = [];
        double salesToday = 0.0;
        int ordersToday = 0;
        final now = DateTime.now();

        for (var item in ordersData) {
          final idStr = item['id'].toString().substring(0, 4).toUpperCase();
          final orderIdFull = item['id'].toString();
          final paymentMethod = item['payment_method'] as String? ?? 'Cash';
          final totalAmount = (item['total_amount'] as num?)?.toDouble() ?? 0.0;
          DateTime createdAtStr = DateTime.now();
          if (item['created_at_kh'] != null) {
            try {
              createdAtStr = DateTime.parse(
                item['created_at_kh'].toString().replaceAll(' ', 'T'),
              );
            } catch (_) {
              if (item['created_at'] != null) {
                createdAtStr = DateTime.parse(
                  item['created_at'].toString(),
                ).toLocal();
              }
            }
          } else if (item['created_at'] != null) {
            createdAtStr = DateTime.parse(
              item['created_at'].toString(),
            ).toLocal();
          }

          // Calculate today stats
          if (createdAtStr.year == now.year &&
              createdAtStr.month == now.month &&
              createdAtStr.day == now.day) {
            salesToday += totalAmount;
            ordersToday++;
          }

          // Parse order items for name list & invoice modal
          final itemsList = item['order_items'] as List<dynamic>? ?? [];
          final names = itemsList.map((oi) {
            final prod = oi['products'];
            return prod != null ? (prod['name'] as String? ?? 'Item') : 'Item';
          }).toList();

          final List<Map<String, dynamic>> parsedInvoiceItems = itemsList.map((
            oi,
          ) {
            final prod = oi['products'];
            final nameStr = prod != null
                ? (prod['name'] as String? ?? 'Item')
                : 'Item';
            final qty = (oi['quantity'] as num?)?.toInt() ?? 1;
            final unitPrice = (oi['price'] as num?)?.toDouble() ?? 0.0;
            final noteStr = oi['note'] as String?;
            return {
              'name': nameStr,
              'qty': qty,
              'unitPrice': unitPrice,
              'itemTotal': qty * unitPrice,
              'note': noteStr,
              'variant': noteStr,
            };
          }).toList();

          final String title =
              'Order #$idStr • ${names.isNotEmpty ? names.join(', ') : 'No Items'}';

          // Standardized YYYY-MM-DD HH:mm:ss Cambodia local time format
          final year = createdAtStr.year;
          final month = createdAtStr.month.toString().padLeft(2, '0');
          final day = createdAtStr.day.toString().padLeft(2, '0');
          final hour24 = createdAtStr.hour.toString().padLeft(2, '0');
          final minute = createdAtStr.minute.toString().padLeft(2, '0');
          final dateStr = '$year-$month-$day $hour24:$minute';

          final String subtitle =
              '$dateStr • $paymentMethod • ${itemsList.length} ${itemsList.length == 1 ? 'Item' : 'Items'}';

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
              rawItems: parsedInvoiceItems,
            ),
          );
        }

        _ordersList = loadedOrders;
        _salesToday = salesToday;
        _ordersTodayCount = ordersToday;
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        final catNames = dbCats.map((c) => c['name'] as String).toList();
        if (products.any((p) => p.category == 'Other') &&
            !catNames.contains('Other')) {
          catNames.add('Other');
        }

        _dbCategories = dbCats;
        _categories = catNames;
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
      AppToast.show(
        context,
        'Error loading data: ${e.toString().replaceAll("Exception: ", "")}',
        type: ToastType.error,
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
        extendBody: true,
        backgroundColor: _isDarkMode
            ? const Color(0xFF0F172A)
            : AppColors.background,
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
            if (_currentIndex == 0) return 0; // Home
            if (_currentIndex == 2) return 1; // Orders
            if (_currentIndex == 1) return 2; // POS
            if (_currentIndex == 3) return 3; // Settings
            return 0;
          }(),
          onTap: (index) {
            int targetTab = _currentIndex;
            if (index == 0) targetTab = 0; // Home
            if (index == 1) targetTab = 2; // Orders
            if (index == 2) targetTab = 1; // POS
            if (index == 3) targetTab = 3; // Settings
            setState(() {
              _currentIndex = targetTab;
            });
          },
          items: [
            AnimatedBottomBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: _t('ទំព័រដើម', 'Home'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.assignment_outlined,
              activeIcon: Icons.assignment_rounded,
              label: _t('ការកុម្ម៉ង់', 'Orders'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart_rounded,
              label: _t('លក់ POS', 'POS'),
            ),
            AnimatedBottomBarItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: _t('ការកំណត់', 'Settings'),
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
    IconData headerIcon = Icons.shopping_cart_rounded;
    IconData? actionIcon;
    VoidCallback? onActionPressed;

    if (_currentIndex == 1) {
      title = _t('ស្ថានីយ POS', 'POS Terminal');
      subtitle = _t('ស្ថានីយ #1 • សកម្ម', 'Terminal #1 • Active');
      headerIcon = Icons.shopping_cart_rounded;
      // Removed restart/refresh icon
      onActionPressed = null;
    } else if (_currentIndex == 2) {
      title = _t('ការកុម្ម៉ង់ និង ប្រតិបត្តិការ', 'Orders & Transactions');
      subtitle = _t(
        'ថ្ងៃនេះ: ${ordersList.length} ការកុម្ម៉ង់',
        'Today: ${ordersList.length} Orders',
      );
      headerIcon = Icons.assignment_rounded;
      // Removed refresh icon
      onActionPressed = null;
    } else if (_currentIndex == 3) {
      title = _t('ការកំណត់ និង ហាង', 'Settings & Store');
      subtitle = _t('លេខសម្គាល់អាជីវករ: #9841', 'Merchant ID: #9841');
      headerIcon = Icons.settings_rounded;
      actionIcon = Icons.logout_rounded;
      onActionPressed = () {
        final navBarHeight = 52.0 + MediaQuery.of(context).padding.bottom + 8;
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.45),
          builder: (ctx) {
            final bool isDark = _isDarkMode;
            return Padding(
              padding: EdgeInsets.only(bottom: navBarHeight),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 26,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _t('ចាកចេញពីគណនី', 'Sign Out'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _t(
                          'តើអ្នកប្រាកដជាចង់ចាកចេញ\nពីគណនីនេះមែនទេ?',
                          'Are you sure you want to\nsign out of your account?',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _t('បោះបង់', 'Cancel'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _t('ចាកចេញ', 'Sign Out'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
        headerSliver: SliverToBoxAdapter(child: _buildTopHeader()),
      );
    }

    final recentOrders = ordersList.take(5).toList();

    final bool isDark = _isDarkMode;
    final Color cardBgColor = isDark
        ? const Color(0xFF1E293B).withOpacity(0.65)
        : Colors.white.withOpacity(0.75);
    final Gradient? cardGradient = null;

    final List<BoxShadow> cardShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.20 : 0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

    final Color cardTitleColor = isDark ? Colors.white : AppColors.heading;
    final Color cardSubtitleColor = isDark
        ? Colors.white.withOpacity(0.70)
        : AppColors.textSecondary;
    final Color cardWalletIconColor = isDark ? Colors.white : AppColors.primary;
    final Color cardWalletIconBg = isDark
        ? Colors.white.withOpacity(0.12)
        : AppColors.primaryLight;
    final Color cardLiveBadgeBg = isDark
        ? Colors.white.withOpacity(0.10)
        : AppColors.successLight;
    final Border cardLiveBadgeBorder = Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.20)
          : AppColors.success.withOpacity(0.3),
      width: 0.8,
    );
    final Color cardValueColor = isDark ? Colors.white : AppColors.heading;
    final Color cardDividerColor = isDark
        ? Colors.white.withOpacity(0.12)
        : AppColors.borderLight;
    final Color cardFooterTimeColor = isDark
        ? Colors.white.withOpacity(0.70)
        : AppColors.textSecondary;

    final Color btnBgColor = isDark ? Colors.white : AppColors.primaryLight;
    final Color btnTextColor = isDark
        ? const Color(0xFF0F172A)
        : AppColors.primary;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(child: _buildTopHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Sales Report Card (Frosted Glass Blur Style)
                  FadeSlideIn(
                    delay: Duration.zero,
                    child: GestureDetector(
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
                          borderRadius: BorderRadius.circular(22.0),
                          boxShadow: cardShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 12.0,
                              sigmaY: 12.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                gradient: cardGradient,
                                borderRadius: BorderRadius.circular(22.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(22.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Row: Wallet Icon + Title & Live Badge
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: cardWalletIconBg,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons
                                                    .account_balance_wallet_rounded,
                                                color: cardWalletIconColor,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _t(
                                                    'សមតុល្យចំណូលលក់',
                                                    'Sales Revenue',
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: cardTitleColor,
                                                    letterSpacing: -0.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _t(
                                                    'ចំណូលសរុបហាង',
                                                    'Total Store Earnings',
                                                  ),
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: cardLiveBadgeBg,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F9F1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_upward_rounded,
                                                color: Color(0xFF16C784),
                                                size: 14,
                                              ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                              _t(
                                                'ធ្វើបច្ចុប្បន្នភាព 1 នាទីមុន',
                                                'Updated 1 min ago',
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: cardFooterTimeColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: btnBgColor,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                _t(
                                                  'មើលផ្ទាំងគ្រប់គ្រង',
                                                  'View Dashboard',
                                                ),
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
                        ),
                      ),
                    ),
                  ), // end FadeSlideIn revenue card
                  const SizedBox(height: 20.0),

                  // Stat Cards Grid (Sales Today & Transactions Count)
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
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
                            value: _t(
                              '$_ordersTodayCount ការកុម្ម៉ង់',
                              '$_ordersTodayCount Orders',
                            ),
                            trendText: '+4.5%',
                            isTrendPositive: true,
                          ),
                        ),
                      ],
                    ),
                  ), // end FadeSlideIn stat cards
                  const SizedBox(height: 24.0),

                  // 2. Quick Pages & Actions Grid
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('សកម្មភាពរហ័ស', 'Quick Actions'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode
                                ? Colors.white
                                : AppColors.heading,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14.0),
                        Column(
                          children: [
                            Row(
                              children: [
                                _buildQuickActionTile(
                                  icon: Icons.inventory_2_rounded,
                                  label: _t('ផលិតផល', 'Products'),
                                  subtitle: _t(
                                    '${_products.length} មុខ',
                                    '${_products.length} Items',
                                  ),
                                  accentColor: const Color(0xFF4F46E5),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ManageProductsScreen(
                                              products: _products,
                                              categories: _categories,
                                              posQuantities: _posQuantities,
                                            ),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildQuickActionTile(
                                  icon: Icons.category_rounded,
                                  label: _t('ប្រភេទទំនិញ', 'Categories'),
                                  subtitle: _t(
                                    '${_categories.length} ប្រភេទ',
                                    '${_categories.length} Types',
                                  ),
                                  accentColor: const Color(0xFF10B981),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ManageCategoriesScreen(
                                              categories: _categories,
                                              products: _products,
                                            ),
                                      ),
                                    ).then((_) => _loadData());
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildQuickActionTile(
                                  icon: Icons.receipt_long_rounded,
                                  label: _t('ការកុម្ម៉ង់', 'Orders'),
                                  subtitle: _t(
                                    '$_ordersTodayCount ថ្ងៃនេះ',
                                    '$_ordersTodayCount Today',
                                  ),
                                  accentColor: const Color(0xFFF59E0B),
                                  onTap: () =>
                                      setState(() => _currentIndex = 2),
                                ),
                                const SizedBox(width: 12),
                                _buildQuickActionTile(
                                  icon: Icons.analytics_rounded,
                                  label: _t('របាយការណ៍', 'Reports'),
                                  subtitle: _t('ស្ថិតិលក់', 'Analytics'),
                                  accentColor: const Color(0xFF8B5CF6),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ReportDashboardScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ), // end FadeSlideIn quick actions
                  const SizedBox(height: 24.0),

                  // 3. Today's Orders List Header
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _t('ការកុម្ម៉ង់ថ្ងៃនេះ', 'Today\'s Orders'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _currentIndex = 2),
                          child: Text(
                            _t('មើលទាំងអស់', 'View All'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode
                                  ? const Color(0xFF5CC8FF)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ), // end FadeSlideIn today's orders header
                  const SizedBox(height: 12.0),
                ],
              ),
            ),
          ),

          // Lazy-loaded Slivers list for Today's Orders
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
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
              }, childCount: recentOrders.length),
            ),
          ),

          // Bottom spacing padding sliver
          const SliverToBoxAdapter(child: SizedBox(height: 24.0)),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final Color tileBg = _isDarkMode
        ? const Color(0xFF1E293B).withOpacity(0.65)
        : Colors.white.withOpacity(0.80);
    final Color labelColor = _isDarkMode ? Colors.white : AppColors.heading;
    final Color subtitleColor = _isDarkMode
        ? Colors.white.withOpacity(0.65)
        : AppColors.textSecondary;
    final Color chevronColor = _isDarkMode
        ? Colors.white.withOpacity(0.40)
        : AppColors.textLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isDarkMode ? 0.20 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Row(
                  children: [
                    // Vibrant Accent Icon Container
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(
                          _isDarkMode ? 0.22 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        icon,
                        color: _isDarkMode
                            ? Color.lerp(accentColor, Colors.white, 0.25)
                            : accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    // Title & Subtitle Stack
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: labelColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: chevronColor,
                    ),
                  ],
                ),
              ),
            ),
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
        ProductVariant? activeVariant =
            selectedVariants[product.name] ??
            (product.variants.isNotEmpty ? product.variants.first : null);
        String activeSugar =
            selectedSugarLevels[product.name] ??
            (product.sugarLevels.isNotEmpty
                ? product.sugarLevels.first
                : '100%');
        List<ProductVariant> activeAddOns = List.from(
          selectedAddOns[product.name] ?? [],
        );

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double variantPrice = activeVariant?.extraPrice ?? 0.0;
            final double addOnsPrice = activeAddOns.fold(
              0.0,
              (sum, item) => sum + item.extraPrice,
            );
            final double calculatedPrice =
                product.price + variantPrice + addOnsPrice;

            return Container(
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? const Color(0xFF1E293B)
                    : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24.0),
                ),
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
                          color: _isDarkMode
                              ? const Color(0xFF334155)
                              : AppColors.borderLight,
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
                                color: _isDarkMode
                                    ? const Color(0xFF0F2B66)
                                    : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Icon(
                                product.icon,
                                color: _isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary,
                                size: 22,
                              ),
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
                                    color: _isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  _t(
                                    'តម្លៃដើម: \$${product.price.toStringAsFixed(2)}',
                                    'Base Price: \$${product.price.toStringAsFixed(2)}',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode
                                        ? const Color(0xFF94A3B8)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? const Color(0xFF0F2B66)
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: _isDarkMode
                                  ? const Color(0xFF5CC8FF).withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '\$${calculatedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode
                                  ? const Color(0xFF5CC8FF)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),

                    // Section 1: Variant Selection (Size / Shot serving)
                    if (product.variants.isNotEmpty) ...[
                      Text(
                        _t(
                          'ជម្រើសទំហំ / ការឆុង (Variant)',
                          'Size / Serving Variant',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.variants.map((v) {
                          final isSelected = activeVariant?.name == v.name;
                          final Color cardBg = isSelected
                              ? (_isDarkMode
                                    ? const Color(0xFF0F2B66)
                                    : AppColors.primaryLight)
                              : (_isDarkMode
                                    ? const Color(0xFF0F172A)
                                    : AppColors.surface);
                          final Color cardBorder = isSelected
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? const Color(0xFF334155)
                                    : AppColors.borderLight);
                          final Color cardTitle = isSelected
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimary);
                          final Color cardSub = isSelected
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.textSecondary);

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                activeVariant = v;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: cardBorder,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 18,
                                        color: cardTitle,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: cardTitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    v.extraPrice > 0
                                        ? '+\$${v.extraPrice.toStringAsFixed(2)}'
                                        : _t('ឥតគិតថ្លៃ', 'Free'),
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
                          color: _isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
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
                                : (_isDarkMode
                                      ? const Color(0xFF0F172A)
                                      : AppColors.surface);
                            final Color chipBorder = isSelected
                                ? AppColors.primary
                                : (_isDarkMode
                                      ? const Color(0xFF334155)
                                      : AppColors.borderLight);
                            final Color chipText = isSelected
                                ? Colors.white
                                : (_isDarkMode
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    activeSugar = sugar;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 8.0,
                                  ),
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
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
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
                        _t(
                          'បន្ថែមកាហ្វេ ឬ គ្រឿងផ្សំ (Add Extra Shot / Add-Ons)',
                          'Add Extra Shot & Add-Ons',
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: product.availableAddOns.map((addOn) {
                          final isChecked = activeAddOns.any(
                            (a) => a.name == addOn.name,
                          );
                          final Color cardBg = isChecked
                              ? (_isDarkMode
                                    ? const Color(0xFF0F2B66)
                                    : AppColors.primaryLight)
                              : (_isDarkMode
                                    ? const Color(0xFF0F172A)
                                    : AppColors.surface);
                          final Color cardBorder = isChecked
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? const Color(0xFF334155)
                                    : AppColors.borderLight);
                          final Color cardTitle = isChecked
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimary);
                          final Color cardSub = isChecked
                              ? (_isDarkMode
                                    ? const Color(0xFF5CC8FF)
                                    : AppColors.primary)
                              : (_isDarkMode
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.textSecondary);

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  activeAddOns.removeWhere(
                                    (a) => a.name == addOn.name,
                                  );
                                } else {
                                  activeAddOns.add(addOn);
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: cardBorder,
                                  width: isChecked ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isChecked
                                            ? Icons.check_box_rounded
                                            : Icons
                                                  .check_box_outline_blank_rounded,
                                        size: 20,
                                        color: cardTitle,
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text(
                                        addOn.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isChecked
                                              ? FontWeight.bold
                                              : FontWeight.w500,
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
                      text: _t(
                        'រក្សាទុកជម្រើស និង បន្ថែម (\$${calculatedPrice.toStringAsFixed(2)})',
                        'Confirm Options & Add (\$${calculatedPrice.toStringAsFixed(2)})',
                      ),
                      onPressed: () {
                        setState(() {
                          if (activeVariant != null) {
                            selectedVariants[product.name] = activeVariant!;
                          }
                          selectedSugarLevels[product.name] = activeSugar;
                          selectedAddOns[product.name] = List.from(
                            activeAddOns,
                          );

                          final currentQty = _posQuantities[product.name] ?? 0;
                          if (currentQty == 0) {
                            _posQuantities[product.name] = 1;
                          }
                        });
                        Navigator.pop(context);
                        AppToast.show(
                          context,
                          _t(
                            'ជម្រើស ${product.name} ត្រូវបានរក្សាទុក!',
                            '${product.name} options saved!',
                          ),
                          type: ToastType.success,
                          duration: const Duration(seconds: 1),
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
    final double grandTotal = totalAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final Color sheetBg = _isDarkMode
            ? const Color(0xFF1E293B)
            : AppColors.surface;
        final Color textTitle = _isDarkMode
            ? Colors.white
            : AppColors.textPrimary;
        final Color textSub = _isDarkMode
            ? const Color(0xFF94A3B8)
            : AppColors.textSecondary;
        final Color dividerColor = _isDarkMode
            ? const Color(0xFF334155)
            : AppColors.borderLight;
        final Color iconBg = _isDarkMode
            ? const Color(0xFF0F2B66)
            : AppColors.primaryLight;
        final Color iconColor = _isDarkMode
            ? const Color(0xFF5CC8FF)
            : AppColors.primary;
        final Color totalColor = _isDarkMode
            ? const Color(0xFF5CC8FF)
            : AppColors.primary;

        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
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
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('វិក្កយបត្រ #$orderId', 'Invoice #$orderId'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: textTitle,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _t(
                                  'ហាងកាហ្វេ និង នំប៉័ង POS • ស្ថានីយ #1',
                                  'Coffee & Bakery POS • Terminal #1',
                                ),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: textSub,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                final noteVal = item['note'] ?? item['variant'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['qty']}x ${item['name']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textTitle,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (noteVal != null &&
                                noteVal.toString().trim().isNotEmpty)
                              Text(
                                _t(
                                  'កំណត់ចំណាំ: ${noteVal.toString()}',
                                  'Note: ${noteVal.toString()}',
                                ),
                                style: TextStyle(fontSize: 12, color: textSub),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
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
                  Expanded(
                    child: Text(
                      _t('ចំនួនទឹកប្រាក់សរុប', 'Total Amount'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textTitle,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: totalColor,
                        ),
                      ),
                      Text(
                        '${(grandTotal * 4000).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: _isDarkMode
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                      icon: const Icon(
                        Icons.print_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        AppToast.show(
                          context,
                          _t(
                            'កំពុងបោះពុម្ពវិក្កយបត្រ #$orderId...',
                            'Printing Invoice #$orderId to POS Printer...',
                          ),
                          type: ToastType.info,
                          duration: const Duration(seconds: 2),
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
      return POSSkeleton(headerSliver: _buildTopHeader());
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
          final addOnsExtra = addOns.fold(
            0.0,
            (sum, item) => sum + item.extraPrice,
          );
          totalCart += qty * (p.price + variantExtra + addOnsExtra);
          totalItemsCount += qty;
        }
      }
    });

    final activeProducts = _products
        .where((p) => p.isActive && p.stock > 0)
        .toList();
    var filteredProducts = _selectedPOSCategoryIndex == 0
        ? activeProducts
        : activeProducts
              .where(
                (p) => p.category == _categories[_selectedPOSCategoryIndex - 1],
              )
              .toList();

    if (_posSearchQuery.trim().isNotEmpty) {
      final q = _posSearchQuery.trim().toLowerCase();
      filteredProducts = filteredProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q),
          )
          .toList();
    }

    return Container(
      color: _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // 1. Fixed Top Header Bar
          _buildTopHeader(),

          // 2. Fixed Wide Rounded Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: _isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(
                  color: _isDarkMode
                      ? const Color(0xFF334155)
                      : AppColors.borderLight.withOpacity(0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _posSearchController,
                onChanged: (val) {
                  setState(() {
                    _posSearchQuery = val;
                  });
                },
                style: TextStyle(
                  fontSize: 13.5,
                  color: _isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: _t(
                    'ស្វែងរកទំនិញតាមឈ្មោះ...',
                    'Search dishes by name...',
                  ),
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: _isDarkMode
                        ? const Color(0xFF64748B)
                        : AppColors.textSecondary,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 6.0),
                    child: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: _isDarkMode
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36),
                  suffixIcon: _posSearchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _posSearchController.clear();
                              _posSearchQuery = '';
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mic_none_rounded,
                            size: 16,
                            color: _isDarkMode
                                ? const Color(0xFF94A3B8)
                                : AppColors.textSecondary,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
          ),

          // 3. Fixed Horizontal Category Swiper Tabs
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 6.0,
                ),
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedPOSCategoryIndex;
                  final rawCategory = index == 0
                      ? 'All'
                      : _categories[index - 1];
                  final text = index == 0
                      ? _t('ទាំងអស់', 'All')
                      : (rawCategory == 'Coffee'
                            ? _t('កាហ្វេ', 'Coffee')
                            : rawCategory == 'Bakery'
                            ? _t('នំប៉័ង', 'Bakery')
                            : rawCategory);

                  // Category Card Background & Text Colors
                  final Color pillBg = isSelected
                      ? (_isDarkMode
                            ? const Color(0xFF008099)
                            : AppColors.primary)
                      : (_isDarkMode ? const Color(0xFF1E293B) : Colors.white);

                  final Color pillTextColor = isSelected
                      ? Colors.white
                      : (_isDarkMode
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPOSCategoryIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: pillBg,
                          borderRadius: BorderRadius.circular(22.0),
                          border: Border.all(
                            color: isSelected
                                ? (_isDarkMode
                                      ? const Color(0xFF5CC8FF)
                                      : AppColors.primary)
                                : (_isDarkMode
                                      ? const Color(0xFF334155)
                                      : AppColors.borderLight),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: pillTextColor,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            child: Text(text),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 4. Scrollable Product Cards Grid Area
          Expanded(
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    if (_products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            _t(
                              'គ្មានផលិតផលក្នុងបញ្ជីទេ។\nសូមបន្ថែមផលិតផលក្នុងទំព័រគ្រប់គ្រង។',
                              'No products in catalog.\nAdd products in Settings to start.',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: _isDarkMode
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textSecondary,
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
                            _t(
                              'គ្មានផលិតផលក្នុងប្រភេទទំនិញនេះទេ។',
                              'No products in this category.',
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              color: _isDarkMode
                                  ? const Color(0xFF94A3B8)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(12.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12.0,
                                crossAxisSpacing: 12.0,
                                mainAxisExtent: 220.0,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = filteredProducts[index];
                            final qty = _posQuantities[product.name] ?? 0;
                            final selectedVariant =
                                selectedVariants[product.name] ??
                                (product.variants.isNotEmpty
                                    ? product.variants.first
                                    : null);
                            final selectedSugar =
                                selectedSugarLevels[product.name];
                            final currentAddOns =
                                selectedAddOns[product.name] ?? [];

                            final double variantExtra =
                                selectedVariant?.extraPrice ?? 0.0;
                            final double addOnsExtra = currentAddOns.fold(
                              0.0,
                              (sum, a) => sum + a.extraPrice,
                            );
                            final double itemFinalPrice =
                                product.price + variantExtra + addOnsExtra;

                            final List<String> optionTexts = [];
                            if (selectedVariant != null) {
                              optionTexts.add(selectedVariant.name);
                            }
                            if (selectedSugar != null) {
                              optionTexts.add('Sugar $selectedSugar');
                            }
                            if (currentAddOns.isNotEmpty) {
                              optionTexts.add(
                                currentAddOns.map((a) => a.name).join(', '),
                              );
                            }

                            final Color itemIconBg = _isDarkMode
                                ? const Color(0xFF0F2B66)
                                : AppColors.primaryLight;
                            final Color itemIconColor = _isDarkMode
                                ? const Color(0xFF5CC8FF)
                                : AppColors.primary;
                            final Color itemTitleColor = _isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary;
                            final Color cardBg = _isDarkMode
                                ? const Color(0xFF1E293B)
                                : AppColors.surface;
                            final Color cardBorder = _isDarkMode
                                ? const Color(0xFF334155)
                                : AppColors.borderLight;
                            final Color customizeText = _isDarkMode
                                ? const Color(0xFF5CC8FF)
                                : AppColors.primary;

                            final bool hasImage =
                                product.imageUrl != null &&
                                product.imageUrl!.trim().isNotEmpty;

                            return GestureDetector(
                              onTap: () => _showVariantSelectionSheet(product),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: qty > 0
                                        ? AppColors.primary
                                        : cardBorder,
                                    width: qty > 0 ? 2.0 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        _isDarkMode ? 0.25 : 0.04,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Image Container with Badges
                                    Stack(
                                      children: [
                                        SizedBox(
                                          height: 105.0,
                                          width: double.infinity,
                                          child: hasImage
                                              ? Image.network(
                                                  product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        ctx,
                                                        err,
                                                        stack,
                                                      ) => Container(
                                                        color: itemIconBg,
                                                        child: Center(
                                                          child: Icon(
                                                            product.icon,
                                                            color:
                                                                itemIconColor,
                                                            size: 36,
                                                          ),
                                                        ),
                                                      ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: _isDarkMode
                                                          ? [
                                                              const Color(
                                                                0xFF1E293B,
                                                              ),
                                                              const Color(
                                                                0xFF0F2B66,
                                                              ),
                                                            ]
                                                          : [
                                                              const Color(
                                                                0xFFE2E8F0,
                                                              ),
                                                              const Color(
                                                                0xFFEEF5FB,
                                                              ),
                                                            ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      product.icon,
                                                      color: itemIconColor,
                                                      size: 36,
                                                    ),
                                                  ),
                                                ),
                                        ),

                                        // Options/Variants Pill (Top-Right)
                                        if (product.variants.isNotEmpty ||
                                            product.sugarLevels.isNotEmpty)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _showVariantSelectionSheet(
                                                    product,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: cardBg.withOpacity(
                                                    0.85,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: cardBorder,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.tune_rounded,
                                                  size: 14,
                                                  color: customizeText,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Details & Controls Section
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w700,
                                                    color: itemTitleColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 2.0),
                                                Text(
                                                  '\$${itemFinalPrice.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.w800,
                                                    color: _isDarkMode
                                                        ? const Color(
                                                            0xFF5CC8FF,
                                                          )
                                                        : AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // Quantity Controls (- qty +)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppIconButton(
                                                  icon: Icons.remove,
                                                  size: 26,
                                                  onPressed: qty > 0
                                                      ? () => setState(
                                                          () =>
                                                              _posQuantities[product
                                                                      .name] =
                                                                  qty - 1,
                                                        )
                                                      : null,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: qty > 0
                                                        ? AppColors.primary
                                                              .withOpacity(0.12)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$qty',
                                                    style: TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: qty > 0
                                                          ? AppColors.primary
                                                          : itemTitleColor,
                                                    ),
                                                  ),
                                                ),
                                                AppIconButton(
                                                  icon: Icons.add,
                                                  size: 26,
                                                  onPressed: product.stock > 0
                                                      ? () {
                                                          if (qty <
                                                              product.stock) {
                                                            setState(
                                                              () =>
                                                                  _posQuantities[product
                                                                          .name] =
                                                                      qty + 1,
                                                            );
                                                          } else {
                                                            AppToast.show(
                                                              context,
                                                              _t(
                                                                'មិនអាចលើសចំនួនស្តុក ${product.stock}',
                                                                'Cannot exceed stock of ${product.stock}',
                                                              ),
                                                              type: ToastType
                                                                  .warning,
                                                              duration:
                                                                  const Duration(
                                                                    seconds: 1,
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
                          }, childCount: filteredProducts.length),
                        ),
                      ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 140.0),
                    ),
                  ],
                ),

                // Cart Summary & Single Order & Print Invoice Action Button (Only show when at least 1 item is selected)
                if (totalItemsCount > 0)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        20.0,
                        16.0,
                        20.0,
                        MediaQuery.of(context).padding.bottom + 90.0,
                      ),
                      decoration: BoxDecoration(
                        color: _isDarkMode
                            ? const Color(0xFF1E293B)
                            : AppColors.surface,
                        border: Border(
                          top: BorderSide(
                            color: _isDarkMode
                                ? const Color(0xFF334155)
                                : AppColors.borderLight,
                            width: 1.0,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _t(
                                  'សរុបការកុម្ម៉ង់ ($totalItemsCount មុខ):',
                                  'Order Total ($totalItemsCount items):',
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '\$${totalCart.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _isDarkMode
                                      ? const Color(0xFF5CC8FF)
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          PrimaryButton(
                            text: _t(
                              'កុម្ម៉ង់ និង បោះពុម្ពវិក្កយបត្រ',
                              'Order & Print Invoice',
                            ),
                            icon: const Icon(
                              Icons.receipt_long_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: totalCart > 0
                                ? () async {
                                    final List<String> cartSummary = [];
                                    final List<Map<String, dynamic>>
                                    invoiceItems = [];
                                    final List<Map<String, dynamic>>
                                    orderItems = [];

                                    _posQuantities.forEach((itemName, qty) {
                                      if (qty > 0) {
                                        final matchingIndex = _products
                                            .indexWhere(
                                              (p) => p.name == itemName,
                                            );
                                        if (matchingIndex == -1) return;
                                        final p = _products[matchingIndex];
                                        final v = selectedVariants[itemName];
                                        final sugar =
                                            selectedSugarLevels[itemName];
                                        final addOns =
                                            selectedAddOns[itemName] ?? [];

                                        final vExtra = v?.extraPrice ?? 0.0;
                                        final addOnsExtra = addOns.fold(
                                          0.0,
                                          (sum, a) => sum + a.extraPrice,
                                        );
                                        final unitPrice =
                                            p.price + vExtra + addOnsExtra;

                                        final List<String> opts = [];
                                        if (v != null) opts.add(v.name);
                                        if (sugar != null)
                                          opts.add('$sugar Sugar');
                                        if (addOns.isNotEmpty)
                                          opts.add(
                                            addOns
                                                .map((a) => a.name)
                                                .join(', '),
                                          );

                                        cartSummary.add(itemName);
                                        invoiceItems.add({
                                          'name': itemName,
                                          'variant': opts.isNotEmpty
                                              ? opts.join(', ')
                                              : null,
                                          'qty': qty,
                                          'unitPrice': unitPrice,
                                          'itemTotal': qty * unitPrice,
                                        });

                                        orderItems.add({
                                          'product_id': p.id,
                                          'quantity': qty,
                                          'price': unitPrice,
                                          if (opts.isNotEmpty)
                                            'note': opts.join(', '),
                                        });
                                      }
                                    });

                                    try {
                                      // Show loading indicator
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      final orderId =
                                          await ApiService.createOrder(
                                            'Cash',
                                            totalCart,
                                            orderItems,
                                          );

                                      // Close loading indicator
                                      if (mounted) Navigator.pop(context);

                                      if (orderId.startsWith('OFF-') &&
                                          mounted) {
                                        AppToast.show(
                                          context,
                                          _t(
                                            'បានបង្កើតការកុម្ម៉ង់ក្នុងរបៀប Offline (គ្មានសេវាអ៊ីនធឺណិត)',
                                            'Order created in Offline mode (No internet connection)',
                                          ),
                                          type: ToastType.warning,
                                        );
                                      }

                                      final now = DateTime.now();
                                      final year = now.year;
                                      final month = now.month
                                          .toString()
                                          .padLeft(2, '0');
                                      final day = now.day.toString().padLeft(
                                        2,
                                        '0',
                                      );
                                      final hour24 = now.hour
                                          .toString()
                                          .padLeft(2, '0');
                                      final minute = now.minute
                                          .toString()
                                          .padLeft(2, '0');
                                      final timeStr =
                                          '$year-$month-$day $hour24:$minute';

                                      setState(() {
                                        // Insert into local ordersList
                                        ordersList.insert(
                                          0,
                                          OrderItemModel(
                                            id: orderId.length >= 4
                                                ? orderId.substring(0, 4)
                                                : orderId,
                                            title:
                                                'Order #${orderId.length >= 4 ? orderId.substring(0, 4) : orderId} • ${cartSummary.join(", ")}',
                                            subtitle:
                                                '$timeStr • Cash • $totalItemsCount Items',
                                            amount:
                                                '+\$${totalCart.toStringAsFixed(2)}',
                                            status: 'Pending',
                                            icon: Icons.hourglass_top_rounded,
                                            leadingBgColor: const Color(
                                              0xFFFEF3C7,
                                            ),
                                            leadingIconColor: AppColors.warning,
                                            isPositive: true,
                                            rawItems: List.from(invoiceItems),
                                          ),
                                        );

                                        // Reset cart quantities
                                        _posQuantities.updateAll(
                                          (key, val) => 0,
                                        );
                                        selectedVariants.clear();
                                        selectedSugarLevels.clear();
                                        selectedAddOns.clear();
                                      });

                                      if (mounted) {
                                        _showPrintInvoiceDialog(
                                          orderId: orderId.length >= 4
                                              ? orderId.substring(0, 4)
                                              : orderId,
                                          items: invoiceItems,
                                          totalAmount: totalCart,
                                        );
                                      }

                                      // Reload data in background to reflect stock update
                                      _loadData(silent: true);
                                    } catch (e) {
                                      // Close loading indicator if open
                                      if (mounted) Navigator.pop(context);

                                      if (mounted) {
                                        AppToast.show(
                                          context,
                                          'Checkout failed: ${e.toString().replaceAll("Exception: ", "")}',
                                          type: ToastType.error,
                                        );
                                      }
                                    }
                                  }
                                : null,
                          ),
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

  // TAB 3: Order Tab (Recent Transactions & Filter by All/Pending/Completed)
  Widget _buildOrderTab() {
    if (_isLoadingData) {
      return OrderSkeleton(
        headerSliver: SliverToBoxAdapter(child: _buildTopHeader()),
      );
    }

    final List<OrderItemModel> filteredOrders = ordersList.where((order) {
      if (_activeOrderFilter == 1) return order.status == 'Pending';
      if (_activeOrderFilter == 2) return order.status == 'Completed';
      return true; // Filter 0 = 'All'
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _buildTopHeader()),
        // Filter Pills Sliver
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: TabPills(
              tabs: [
                _t('ទាំងអស់', 'All'),
                _t('រង់ចាំ', 'Pending'),
                _t('បានបញ្ចប់', 'Completed'),
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
                _t(
                  'មិនមានការកុម្ម៉ង់ក្នុងស្ថានភាពនេះទេ។',
                  'No orders found for this status.',
                ),
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
              delegate: SliverChildBuilderDelegate((context, index) {
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
                      GestureDetector(
                        onTap: () {
                          final double amt =
                              double.tryParse(
                                order.amount.replaceAll(RegExp(r'[^\d.]'), ''),
                              ) ??
                              0.0;
                          _showPrintInvoiceDialog(
                            orderId: order.id,
                            items:
                                order.rawItems ??
                                [
                                  {
                                    'name': order.title,
                                    'qty': 1,
                                    'itemTotal': amt,
                                    'variant': null,
                                  },
                                ],
                            totalAmount: amt,
                          );
                        },
                        child: ListItemCard(
                          title: order.title,
                          subtitle: order.subtitle,
                          trailingTitle: order.amount,
                          trailingSubtitle: statusDisplay,
                          leadingIcon: order.icon,
                          leadingBgColor: order.leadingBgColor,
                          leadingIconColor: order.leadingIconColor,
                          isPositive: order.isPositive,
                        ),
                      ),
                      if (order.status == 'Pending') ...[
                        const SizedBox(height: 6.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final oIndex = ordersList.indexWhere(
                                    (o) => o.id == order.id,
                                  );
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
                                AppToast.show(
                                  context,
                                  _t(
                                    '${order.title} ត្រូវបានកំណត់ជា បានបញ្ចប់!',
                                    '${order.title} marked as Completed!',
                                  ),
                                  type: ToastType.success,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.payment_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      _t('ទូទាត់', 'Pay & Complete'),
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
              }, childCount: filteredOrders.length),
            ),
          ),
      ],
    );
  }

  // TAB 4: Setting Tab (Configuration Settings)
  Widget _buildSettingTab() {
    if (_isLoadingData) {
      return SettingsSkeleton(
        headerSliver: SliverToBoxAdapter(child: _buildTopHeader()),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(child: _buildTopHeader()),
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
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 3.0,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              _merchantImageUrl != null &&
                                  _merchantImageUrl!.isNotEmpty
                              ? Image.network(
                                  _merchantImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
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
                      color: _isDarkMode
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
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
                    color: _isDarkMode
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
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
                    ).then((_) => _loadData(silent: true));
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
                    ).then((_) => _loadData(silent: true));
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
                    ).then((_) => _loadData(silent: true));
                  },
                ),
                _buildSettingTile(
                  icon: Icons.analytics_rounded,
                  title: _t('របាយការណ៍', 'Reports'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportDashboardScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16.0),

                // Heading: Other
                Text(
                  _t('ផ្សេងៗ', 'Other'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12.0),

                _buildSettingTile(
                  icon: Icons.help_center_rounded,
                  title: _t('មជ្ឈមណ្ឌលជំនួយ', 'Help Center'),
                  onTap: () {
                    AppToast.show(
                      context,
                      _t('ចុចលើមជ្ឈមណ្ឌលជំនួយ', 'Help Center pressed'),
                      type: ToastType.info,
                    );
                  },
                ),

                _buildSettingTile(
                  icon: Icons.info_rounded,
                  title: _t('អំពីយើង', 'About Us'),
                  isExpanded: _isAboutExpanded,
                  onTap: () =>
                      setState(() => _isAboutExpanded = !_isAboutExpanded),
                  expandedContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS Terminal v1.2.4',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        _t(
                          'កំណែប្រព័ន្ធប្រតិបត្តិការ (Rev. 84)\nប្រព័ន្ធសុវត្ថិភាព SSL • ច្រកទូទាត់ PCI',
                          'Production Build (Rev. 84)\nSecure SSL Encryption • PCI Compliant Gateway',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isDarkMode
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
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
    final Color dividerColor = _isDarkMode
        ? const Color(0xFF334155)
        : AppColors.borderLight;
    final Color arrowColor = _isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;

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
                      Icon(icon, color: iconColor, size: 20),
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
