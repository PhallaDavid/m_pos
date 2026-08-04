import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_item.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  static String? _token;
  static String? userEmail;

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth: Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 200 && resData['status'] == 'success') {
      _token = resData['session']['access_token'];
      userEmail = resData['user']['email'];
      return {
        'success': true,
        'user': resData['user'],
      };
    } else {
      throw Exception(resData['message'] ?? 'Login failed');
    }
  }

  // Auth: Logout
  static Future<void> logout() async {
    if (_token == null) return;
    final url = Uri.parse('$baseUrl/api/auth/logout');
    await http.post(url, headers: _getHeaders());
    _token = null;
    userEmail = null;
  }

  // Categories: Get all
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final url = Uri.parse('$baseUrl/api/categories');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Categories: Create
  static Future<Map<String, dynamic>> createCategory(String name) async {
    final url = Uri.parse('$baseUrl/api/categories');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({'name': name}),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 && resData['status'] == 'success') {
      return resData['data'];
    } else {
      throw Exception(resData['message'] ?? 'Failed to create category');
    }
  }

  // Products: Get all
  static Future<List<ProductItem>> getProducts({String? categoryId}) async {
    String path = '$baseUrl/api/products';
    if (categoryId != null) {
      path += '?category_id=$categoryId';
    }
    final url = Uri.parse(path);
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      // Fetch categories map to match category name
      final categories = await getCategories();
      final catMap = {for (var c in categories) c['id']: c['name']};

      return list.map((item) {
        final catId = item['category_id'] as String?;
        final catName = catMap[catId] ?? 'Other';
        
        // Map category names to icons
        IconData itemIcon;
        switch (catName.toLowerCase()) {
          case 'coffee':
            itemIcon = Icons.coffee_rounded;
            break;
          case 'bakery':
            itemIcon = Icons.bakery_dining_rounded;
            break;
          case 'meals':
            itemIcon = Icons.restaurant_rounded;
            break;
          case 'desserts':
            itemIcon = Icons.cookie_rounded;
            break;
          default:
            itemIcon = Icons.local_cafe_rounded;
        }

        return ProductItem(
          id: item['id'],
          name: item['name'],
          price: (item['price'] as num).toDouble(),
          stock: item['stock'] as int,
          icon: itemIcon,
          isInStock: (item['stock'] as int) > 0,
          category: catName,
          categoryId: catId,
          variants: const [
            ProductVariant(name: 'Regular Size', extraPrice: 0.0),
            ProductVariant(name: 'Large Size', extraPrice: 1.0),
          ],
          sugarLevels: const ['100%', '70%', '50%', '30%', '0%'],
          availableAddOns: const [
            ProductVariant(name: 'Extra Shot', extraPrice: 1.00),
            ProductVariant(name: 'Vanilla Syrup', extraPrice: 0.50),
          ],
        );
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Products: Create
  static Future<ProductItem> createProduct(
    String name, double price, int stock, String? categoryId, {String imageUrl = ''}
  ) async {
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'image_url': imageUrl,
      }),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 && resData['status'] == 'success') {
      final item = resData['data'];
      return ProductItem(
        id: item['id'],
        name: item['name'],
        price: (item['price'] as num).toDouble(),
        stock: item['stock'] as int,
        icon: Icons.local_cafe_rounded,
        isInStock: (item['stock'] as int) > 0,
        category: '', // will be populated when loading all list
        categoryId: item['category_id'],
      );
    } else {
      throw Exception(resData['message'] ?? 'Failed to create product');
    }
  }

  // Products: Update
  static Future<void> updateProduct(
    String id, String name, double price, int stock, String? categoryId, {String imageUrl = ''}
  ) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'image_url': imageUrl,
      }),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to update product');
    }
  }

  // Products: Delete
  static Future<void> deleteProduct(String id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(url, headers: _getHeaders());

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to delete product');
    }
  }

  // Orders: Place order
  static Future<String> createOrder(
    String paymentMethod, double totalAmount, List<Map<String, dynamic>> items
  ) async {
    final url = Uri.parse('$baseUrl/api/orders');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode({
        'payment_method': paymentMethod,
        'total_amount': totalAmount,
        'items': items,
      }),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 && resData['status'] == 'success') {
      return resData['order_id'];
    } else {
      throw Exception(resData['message'] ?? 'Failed to place order');
    }
  }

  // Dashboard: Get statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final url = Uri.parse('$baseUrl/api/dashboard/stats');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  // Orders: Get list of orders
  static Future<List<dynamic>> getOrders() async {
    final url = Uri.parse('$baseUrl/api/orders');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to load orders');
    }
  }

  // Profile: Get details
  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/api/profile');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to load profile');
    }
  }

  // Profile: Update details
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? storeName,
    String? address,
    String? phone,
    String? imageUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/profile');
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (storeName != null) body['store_name'] = storeName;
    if (address != null) body['address'] = address;
    if (phone != null) body['phone'] = phone;
    if (imageUrl != null) body['image_url'] = imageUrl;

    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 200 && resData['status'] == 'success') {
      return resData['data'];
    } else {
      throw Exception(resData['message'] ?? 'Failed to update profile');
    }
  }

  // Upload: Upload image file bytes
  static Future<String> uploadImage(List<int> bytes, String filename) async {
    final url = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', url);
    
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final resData = jsonDecode(response.body);
    if (response.statusCode == 200 && resData['status'] == 'success') {
      return resData['url'] as String;
    } else {
      throw Exception(resData['message'] ?? 'Failed to upload image');
    }
  }
}
