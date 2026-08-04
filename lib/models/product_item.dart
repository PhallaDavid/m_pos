import 'package:flutter/material.dart';

class ProductVariant {
  final String name;
  final double extraPrice;

  const ProductVariant({
    required this.name,
    this.extraPrice = 0.0,
  });
}

class ProductItem {
  String? id;
  String name;
  double price;
  int stock;
  IconData icon;
  bool isInStock;
  String category;
  String? categoryId;
  List<ProductVariant> variants;
  List<String> sugarLevels;
  List<ProductVariant> availableAddOns;

  ProductItem({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
    required this.isInStock,
    required this.category,
    this.categoryId,
    this.variants = const [],
    this.sugarLevels = const ['100%', '70%', '50%', '30%', '0%'],
    this.availableAddOns = const [],
  });
}
