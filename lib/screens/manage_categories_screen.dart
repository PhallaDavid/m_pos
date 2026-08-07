import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_item.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';
import '../services/api_service.dart';
import '../widgets/app_toast.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final List<String> categories;
  final List<ProductItem> products;

  const ManageCategoriesScreen({
    super.key,
    required this.categories,
    required this.products,
  });

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<String> _categoryList = [];
  List<Map<String, dynamic>> _fetchedCategories = [];

  @override
  void initState() {
    super.initState();
    _categoryList = List.from(widget.categories);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories();
      if (mounted) {
        setState(() {
          _fetchedCategories = List<Map<String, dynamic>>.from(cats);
          _categoryList = _fetchedCategories
              .map((c) => c['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList();
        });
      }
    } catch (_) {}
  }

  void _showAddCategoryBottomSheet() {
    final categoryNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
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
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Create New Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Category Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                RoundedTextField(
                  controller: categoryNameController,
                  hintText: 'e.g. Desserts',
                  prefixIcon: Icons.category_rounded,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24.0),
                PrimaryButton(
                  text: 'Create Category',
                  onPressed: () async {
                    final name = categoryNameController.text.trim();
                    if (name.isNotEmpty) {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );
                        await ApiService.createCategory(name);
                        if (!context.mounted) return;
                        Navigator.pop(context); // close loader
                        setState(() {
                          if (!widget.categories.contains(name)) {
                            widget.categories.add(name);
                          }
                        });
                        Navigator.pop(context); // close sheet
                        AppToast.show(
                          context,
                          'Category "$name" created',
                          type: ToastType.success,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        Navigator.pop(context); // close loader
                        AppToast.show(
                          context,
                          'Create failed: ${e.toString().replaceAll("Exception: ", "")}',
                          type: ToastType.error,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subTextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
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
        title: Text(
          'Manage Categories',
          style: TextStyle(
            color: textColor,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddCategoryBottomSheet,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: isDark
                              ? const Color(0xFF5CC8FF)
                              : AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF5CC8FF)
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_categoryList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    'No categories defined.\nTap "Add Category" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: subTextColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = _categoryList[index];
                  final productCount = widget.products
                      .where((p) => p.category == category)
                      .length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F2B66)
                                      : AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Icon(
                                  Icons.category_rounded,
                                  color: isDark
                                      ? const Color(0xFF5CC8FF)
                                      : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    '$productCount Products',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  final categoryName = _categoryList[index];
                                  final matchIndex = _fetchedCategories
                                      .indexWhere(
                                        (c) => c['name'] == categoryName,
                                      );
                                  final bool isActive = matchIndex != -1
                                      ? (_fetchedCategories[matchIndex]['is_active'] ==
                                                null ||
                                            _fetchedCategories[matchIndex]['is_active'] ==
                                                true)
                                      : true;

                                  return GestureDetector(
                                    onTap: () async {
                                      final newActive = !isActive;
                                      if (matchIndex != -1) {
                                        setState(() {
                                          _fetchedCategories[matchIndex]['is_active'] =
                                              newActive;
                                        });
                                        final catId =
                                            _fetchedCategories[matchIndex]['id']
                                                ?.toString();
                                        if (catId != null) {
                                          try {
                                            await ApiService.updateCategory(
                                              catId,
                                              categoryName,
                                              isActive: newActive,
                                            );
                                            if (mounted) {
                                              AppToast.show(
                                                context,
                                                '"$categoryName" is now ${newActive ? "Active" : "Inactive"}',
                                                type: newActive
                                                    ? ToastType.success
                                                    : ToastType.warning,
                                              );
                                            }
                                          } catch (_) {
                                            if (mounted) {
                                              setState(() {
                                                _fetchedCategories[matchIndex]['is_active'] =
                                                    !newActive;
                                              });
                                            }
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.success.withOpacity(
                                                0.12,
                                              )
                                            : Colors.grey.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isActive
                                              ? AppColors.success.withOpacity(
                                                  0.4,
                                                )
                                              : Colors.grey.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? AppColors.success
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12.0),
                              GestureDetector(
                                onTap: () async {
                                  if (_categoryList.length <= 1) {
                                    AppToast.show(
                                      context,
                                      'At least one active category is required.',
                                      type: ToastType.warning,
                                    );
                                    return;
                                  }

                                  final categoryName = _categoryList[index];
                                  final matchIndex = _fetchedCategories
                                      .indexWhere(
                                        (c) => c['name'] == categoryName,
                                      );
                                  final categoryId = matchIndex != -1
                                      ? _fetchedCategories[matchIndex]['id']
                                            ?.toString()
                                      : null;

                                  if (categoryId != null &&
                                      categoryId.isNotEmpty) {
                                    try {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                      await ApiService.deleteCategory(
                                        categoryId,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context); // close loader
                                      }

                                      if (mounted) {
                                        setState(() {
                                          _categoryList.removeAt(index);
                                          if (matchIndex != -1 &&
                                              matchIndex <
                                                  _fetchedCategories.length) {
                                            _fetchedCategories.removeAt(
                                              matchIndex,
                                            );
                                          }
                                          widget.categories.removeWhere(
                                            (c) => c == categoryName,
                                          );
                                        });
                                        AppToast.show(
                                          context,
                                          'Category "$categoryName" deleted successfully.',
                                          type: ToastType.success,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.pop(context); // close loader
                                      }
                                      if (mounted) {
                                        String errorMsg = e
                                            .toString()
                                            .replaceAll("Exception: ", "");
                                        if (errorMsg.contains(
                                              "foreign key constraint",
                                            ) ||
                                            errorMsg.contains("products")) {
                                          errorMsg =
                                              "Cannot delete category linked to existing items.";
                                        }
                                        AppToast.show(
                                          context,
                                          errorMsg,
                                          type: ToastType.error,
                                        );
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      _categoryList.removeAt(index);
                                      widget.categories.removeWhere(
                                        (c) => c == categoryName,
                                      );
                                    });
                                    AppToast.show(
                                      context,
                                      'Category "$categoryName" deleted.',
                                      type: ToastType.success,
                                    );
                                  }
                                },
                                child: const Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _categoryList.length),
              ),
            ),
        ],
      ),
    );
  }
}
