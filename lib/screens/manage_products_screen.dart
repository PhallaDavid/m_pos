import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  XFile? _selectedImageFile;
  String? _productImageUrl;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _selectedImageFile = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Select Product Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F2B66) : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 28, color: isDark ? const Color(0xFF5CC8FF) : AppColors.primary),
                            const SizedBox(height: 8.0),
                            Text(
                              'Take Photo',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F2B66) : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_rounded, size: 28, color: isDark ? const Color(0xFF5CC8FF) : AppColors.primary),
                            const SizedBox(height: 8.0),
                            Text(
                              'Choose Gallery',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
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
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
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
                      color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;

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
          'Product Catalog',
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final Color primaryAccent = isDark ? const Color(0xFF5CC8FF) : AppColors.primary;
    final Color primaryContainer = isDark ? const Color(0xFF0F2B66) : AppColors.primaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Products',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
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
                  _selectedImageFile = null;
                  _productImageUrl = null;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: primaryAccent, size: 18),
                  const SizedBox(width: 4.0),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        if (widget.products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'No products in catalog.\nTap "+ Add New" to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subTextColor,
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
              final bool hasImage = product.imageUrl != null && product.imageUrl!.trim().isNotEmpty;

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
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: primaryContainer,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: hasImage
                                  ? Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Icon(product.icon, color: primaryAccent, size: 22),
                                    )
                                  : Icon(product.icon, color: primaryAccent, size: 22),
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
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: primaryContainer,
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: primaryAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor,
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
                              color: product.isInStock ? subTextColor : AppColors.error,
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
                                _selectedImageFile = null;
                                _productImageUrl = product.imageUrl;
                              });
                            },
                            child: Icon(Icons.edit_rounded, size: 18, color: subTextColor),
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textPrimary;
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final Color primaryAccent = isDark ? const Color(0xFF5CC8FF) : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isCreatingProduct ? 'Create New Product' : 'Edit Product Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16.0),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Image',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: _showImageSourcePicker,
                child: Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : AppColors.background,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                      width: 1.0,
                    ),
                  ),
                  child: _selectedImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: kIsWeb
                              ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover, width: double.infinity)
                              : Image.file(File(_selectedImageFile!.path), fit: BoxFit.cover, width: double.infinity),
                        )
                      : (_productImageUrl != null && _productImageUrl!.trim().isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(_productImageUrl!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 32, color: primaryAccent),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Upload or Take Photo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryAccent,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Product Name',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8.0),
              RoundedTextField(
                controller: _productNameController,
                hintText: 'e.g. Espresso Coffee',
                prefixIcon: Icons.shopping_bag_rounded,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Price (\$)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8.0),
              RoundedTextField(
                controller: _productPriceController,
                hintText: 'e.g. 3.50',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Stock Count',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
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
                  Text(
                    'Category',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  GestureDetector(
                    onTap: _showAddCategoryBottomSheet,
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, color: primaryAccent, size: 16),
                        const SizedBox(width: 4.0),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryAccent,
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
                        color: isSelected ? Colors.white : subTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF334155) : AppColors.borderLight),
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

                    String finalImageUrl = _productImageUrl ?? '';
                    if (_selectedImageFile != null) {
                      final bytes = await _selectedImageFile!.readAsBytes();
                      final uploadedUrl = await ApiService.uploadImage(bytes, _selectedImageFile!.name);
                      finalImageUrl = uploadedUrl;
                    }

                    if (_isCreatingProduct) {
                      final newProduct = await ApiService.createProduct(
                        name, price, stock, categoryId, imageUrl: finalImageUrl
                      );
                      if (mounted) Navigator.pop(context); // close loader
                      setState(() {
                        widget.products.add(
                          ProductItem(
                            id: newProduct.id,
                            name: name,
                            price: price,
                            stock: stock,
                            icon: Icons.coffee_rounded,
                            imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
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
                        _selectedImageFile = null;
                        _productImageUrl = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product created successfully'), backgroundColor: AppColors.success),
                        );
                      }
                    } else if (_isEditingProduct && _editingProductIndex != null) {
                      final product = widget.products[_editingProductIndex!];
                      await ApiService.updateProduct(
                        product.id!, name, price, stock, categoryId, imageUrl: finalImageUrl
                      );
                      if (mounted) Navigator.pop(context); // close loader
                      setState(() {
                        final oldName = product.name;
                        product.name = name;
                        product.price = price;
                        product.stock = stock;
                        product.imageUrl = finalImageUrl.isNotEmpty ? finalImageUrl : null;
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
                        _selectedImageFile = null;
                        _productImageUrl = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product updated successfully'), backgroundColor: AppColors.success),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // close loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Operation failed: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.redAccent),
                      );
                    }
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
