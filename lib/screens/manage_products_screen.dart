import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product_item.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icon_button.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/rounded_text_field.dart';
import '../services/api_service.dart';

class ManageProductsScreen extends StatefulWidget {
  final List<ProductItem> products;
  final Map<String, int> posQuantities;
  final List<String> categories;

  const ManageProductsScreen({
    super.key,
    required this.products,
    required this.posQuantities,
    required this.categories,
  });

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  bool _isCreatingProduct = false;
  bool _isEditingProduct = false;
  int? _editingProductIndex;
  String? _selectedCategory;

  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productStockController = TextEditingController();

  List<Map<String, dynamic>> _dbCategories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        _dbCategories = cats;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _productStockController.dispose();
    super.dispose();
  }

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
                  hintText: 'e.g. Beverages',
                  prefixIcon: Icons.category_rounded,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24.0),
                PrimaryButton(
                  text: 'Create Category',
                  onPressed: () {
                    final name = categoryNameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        if (!widget.categories.contains(name)) {
                          widget.categories.add(name);
                        }
                        _selectedCategory = name;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Category "$name" created'),
                          backgroundColor: AppColors.success,
                        ),
                      );
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
          'Product Catalog',
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
              child: _isCreatingProduct || _isEditingProduct
                  ? _buildProductForm()
                  : _buildProductList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'All Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCreatingProduct = true;
                  _isEditingProduct = false;
                  _editingProductIndex = null;
                  _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : 'Coffee';
                  _productNameController.clear();
                  _productPriceController.clear();
                  _productStockController.clear();
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 4.0),
                  Text(
                    'Add New',
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
        const SizedBox(height: 16.0),
        if (widget.products.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No products in catalog.\nTap "+ Add New" to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.products.length,
            itemBuilder: (context, index) {
              final product = widget.products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(product.icon, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          product.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Qty: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: product.isInStock ? AppColors.textSecondary : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: product.isInStock ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingProduct = true;
                                _isCreatingProduct = false;
                                _editingProductIndex = index;
                                _selectedCategory = product.category;
                                _productNameController.text = product.name;
                                _productPriceController.text = product.price.toString();
                                _productStockController.text = product.stock.toString();
                              });
                            },
                            child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 14.0),
                          GestureDetector(
                            onTap: () async {
                              final productToDelete = widget.products[index];
                              if (productToDelete.id != null) {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(child: CircularProgressIndicator()),
                                  );
                                  await ApiService.deleteProduct(productToDelete.id!);
                                  Navigator.pop(context); // close loader
                                  setState(() {
                                    widget.products.removeAt(index);
                                    widget.posQuantities.remove(productToDelete.name);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Product deleted successfully')),
                                  );
                                } catch (e) {
                                  Navigator.pop(context); // close loader
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Delete failed: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.redAccent),
                                  );
                                }
                              } else {
                                setState(() {
                                  widget.products.removeAt(index);
                                  widget.posQuantities.remove(productToDelete.name);
                                });
                              }
                            },
                            child: const Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isCreatingProduct ? 'Create New Product' : 'Edit Product Details',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16.0),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Name',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8.0),
              RoundedTextField(
                controller: _productNameController,
                hintText: 'e.g. Espresso Coffee',
                prefixIcon: Icons.shopping_bag_rounded,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Price (\$)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8.0),
              RoundedTextField(
                controller: _productPriceController,
                hintText: 'e.g. 3.50',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Stock Count',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8.0),
              RoundedTextField(
                controller: _productStockController,
                hintText: 'e.g. 42',
                prefixIcon: Icons.inventory_2_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              
              // Category wrap block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  GestureDetector(
                    onTap: _showAddCategoryBottomSheet,
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: AppColors.primary, size: 16),
                        SizedBox(width: 4.0),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppColors.surface : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                        width: 1.0,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32.0),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Cancel',
                onPressed: () {
                  setState(() {
                    _isCreatingProduct = false;
                    _isEditingProduct = false;
                    _editingProductIndex = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: PrimaryButton(
                text: 'Save Product',
                onPressed: () async {
                  final name = _productNameController.text.trim();
                  final price = double.tryParse(_productPriceController.text.trim()) ?? 0.0;
                  final stock = int.tryParse(_productStockController.text.trim()) ?? 0;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a product name')),
                    );
                    return;
                  }

                  // Find categoryId
                  final categoryMap = _dbCategories.firstWhere(
                    (c) => c['name'] == _selectedCategory,
                    orElse: () => <String, dynamic>{},
                  );
                  final categoryId = categoryMap['id'] as String?;

                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    if (_isCreatingProduct) {
                      final newProduct = await ApiService.createProduct(name, price, stock, categoryId);
                      Navigator.pop(context); // close loader
                      setState(() {
                        widget.products.add(
                          ProductItem(
                            id: newProduct.id,
                            name: name,
                            price: price,
                            stock: stock,
                            icon: Icons.coffee_rounded,
                            isInStock: stock > 0,
                            category: _selectedCategory ?? 'Coffee',
                            categoryId: categoryId,
                          ),
                        );
                        widget.posQuantities[name] = 0;
                        _isCreatingProduct = false;
                        _productNameController.clear();
                        _productPriceController.clear();
                        _productStockController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product created successfully'), backgroundColor: AppColors.success),
                      );
                    } else if (_isEditingProduct && _editingProductIndex != null) {
                      final product = widget.products[_editingProductIndex!];
                      await ApiService.updateProduct(product.id!, name, price, stock, categoryId);
                      Navigator.pop(context); // close loader
                      setState(() {
                        final oldName = product.name;
                        product.name = name;
                        product.price = price;
                        product.stock = stock;
                        product.isInStock = stock > 0;
                        product.category = _selectedCategory ?? 'Coffee';
                        product.categoryId = categoryId;

                        if (oldName != name) {
                          final oldQty = widget.posQuantities[oldName] ?? 0;
                          widget.posQuantities.remove(oldName);
                          widget.posQuantities[name] = oldQty;
                        }

                        _isEditingProduct = false;
                        _editingProductIndex = null;
                        _productNameController.clear();
                        _productPriceController.clear();
                        _productStockController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product updated successfully'), backgroundColor: AppColors.success),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context); // close loader
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Operation failed: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.redAccent),
                    );
                  }
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
