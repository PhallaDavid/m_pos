import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_item.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';
import '../services/api_service.dart';

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
  void _showAddCategoryBottomSheet() {
    final categoryNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
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
                const SizedBox(height: 20.0),
                const Text(
                  'Create New Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Category Name',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        await ApiService.createCategory(name);
                        Navigator.pop(context); // close loader
                        setState(() {
                          if (!widget.categories.contains(name)) {
                            widget.categories.add(name);
                          }
                        });
                        Navigator.pop(context); // close sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Category "$name" created'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context); // close loader
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Create failed: ${e.toString().replaceAll("Exception: ", "")}'),
                            backgroundColor: Colors.redAccent,
                          ),
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
          'Manage Categories',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddCategoryBottomSheet,
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 4.0),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.categories.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    'No categories defined.\nTap "Add Category" to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
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
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = widget.categories[index];
                    final productCount = widget.products.where((p) => p.category == category).length;

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
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 14.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      '$productCount Products',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                if (widget.categories.length <= 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('At least one active category is required.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }

                                final fallbackCategory = widget.categories[index == 0 ? 1 : 0];

                                setState(() {
                                  widget.categories.removeAt(index);
                                  for (var product in widget.products) {
                                    if (product.category == category) {
                                      product.category = fallbackCategory;
                                    }
                                  }
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Category "$category" deleted. Affected products moved to "$fallbackCategory".'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              child: const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: widget.categories.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
