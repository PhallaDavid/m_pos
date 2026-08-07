import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_item.dart';

class ApiService {
  static const String _productionUrl = 'https://m-pos-api.onrender.com';
  static bool useProduction = true;

  static String get baseUrl {
    if (useProduction) return _productionUrl;
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  static String? _token;
  static String? userEmail;
  static String? storeId;

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 1. Auth: Login
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
      storeId = resData['user']?['store_id'] ?? resData['store_id'] ?? resData['user']?['store']?['id'];
      return {
        'success': true,
        'user': resData['user'],
        'access_token': _token,
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
    storeId = null;
  }

  // 2. Stores: Create New Store & User Profile
  // Only name, store_name, email and password are required per the API spec.
  static Future<Map<String, dynamic>> createStore({
    required String email,
    required String password,
    required String name,
    required String storeName,
    String? phone,
    String? address,
    String? imageUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/stores');
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'name': name,
      'store_name': storeName,
    };
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (address != null && address.isNotEmpty) body['address'] = address;
    if (imageUrl != null && imageUrl.isNotEmpty) body['image_url'] = imageUrl;

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 || (response.statusCode == 200 && resData['status'] == 'success')) {
      return resData;
    } else {
      throw Exception(resData['message'] ?? 'Failed to create store');
    }
  }

  // Stores: List All Registered Stores
  static Future<Map<String, dynamic>> getStores() async {
    final url = Uri.parse('$baseUrl/api/stores');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to load stores');
    }
  }

  // Stores: Get All Store Data (Store Aggregator)
  static Future<Map<String, dynamic>> getStoreAllData([String? storeIdParam]) async {
    final targetStoreId = storeIdParam ?? storeId;
    if (targetStoreId == null || targetStoreId.isEmpty) {
      throw Exception('Store ID is required');
    }
    final url = Uri.parse('$baseUrl/api/stores/$targetStoreId/all');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to load store data');
    }
  }

  // 3. Categories: Get Categories (Filtered by Logged-in Store or store_id query param)
  static Future<List<Map<String, dynamic>>> getCategories({String? storeIdParam}) async {
    final targetStoreId = storeIdParam ?? storeId;
    String path = '$baseUrl/api/categories';
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      path += '?store_id=$targetStoreId';
    }
    final url = Uri.parse(path);
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Categories: Delete Category
  static Future<void> deleteCategory(String id) async {
    final url = Uri.parse('$baseUrl/api/categories/$id');
    final response = await http.delete(url, headers: _getHeaders());

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to delete category');
    }
  }

  // Categories: Create Category for Store
  static Future<Map<String, dynamic>> createCategory(String name, {String? storeIdParam}) async {
    final targetStoreId = storeIdParam ?? storeId;
    final url = Uri.parse('$baseUrl/api/categories');
    final Map<String, dynamic> body = {'name': name};
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      body['store_id'] = targetStoreId;
    }

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 && resData['status'] == 'success') {
      return resData['data'];
    } else {
      throw Exception(resData['message'] ?? 'Failed to create category');
    }
  }

  // 4. Products: Get Products (Filtered by Logged-in Store, store_id, and/or category_id)
  static Future<List<ProductItem>> getProducts({String? categoryId, String? storeIdParam}) async {
    final targetStoreId = storeIdParam ?? storeId;
    final List<String> queryParams = [];
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      queryParams.add('store_id=$targetStoreId');
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams.add('category_id=$categoryId');
    }

    String path = '$baseUrl/api/products';
    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }
    final url = Uri.parse(path);
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      // Fetch categories map to match category name
      final categories = await getCategories(storeIdParam: targetStoreId);
      final catMap = {for (var c in categories) c['id']: c['name']};

      return list.map((item) {
        final catId = item['category_id'] as String?;
        final catName = catMap[catId] ?? 'Other';
        
        // Map category names to icons
        IconData itemIcon;
        switch (catName.toLowerCase()) {
          case 'coffee':
          case 'hot coffee':
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
          imageUrl: item['image_url'],
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

  // Products: Create Product for Store
  static Future<ProductItem> createProduct(
    String name, double price, {int stock = 0, String? categoryId, String imageUrl = '', String? storeIdParam}
  ) async {
    final targetStoreId = storeIdParam ?? storeId;
    final url = Uri.parse('$baseUrl/api/products');
    final Map<String, dynamic> body = {
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
    };
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      body['store_id'] = targetStoreId;
    }

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
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
        category: '',
        categoryId: item['category_id'],
      );
    } else {
      throw Exception(resData['message'] ?? 'Failed to create product');
    }
  }

  // Products: Update Product
  static Future<void> updateProduct(
    String id, String name, double price, int stock, String? categoryId, {String imageUrl = ''}
  ) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final Map<String, dynamic> body = {
      'name': name,
      'price': price,
      'stock': stock,
    };
    if (categoryId != null) body['category_id'] = categoryId;
    if (imageUrl.isNotEmpty) body['image_url'] = imageUrl;

    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to update product');
    }
  }

  // Products: Delete Product
  static Future<void> deleteProduct(String id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(url, headers: _getHeaders());

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to delete product');
    }
  }

  // 5. Orders: Get Orders (filtered by bearer token — store determined server-side)
  static Future<List<dynamic>> getOrders({String? storeIdParam}) async {
    final url = Uri.parse('$baseUrl/api/orders');
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to load orders');
    }
  }

  // Orders: Create Order for Store
  static Future<String> createOrder(
    String paymentMethod, double totalAmount, List<Map<String, dynamic>> items, {String? storeIdParam}
  ) async {
    final targetStoreId = storeIdParam ?? storeId;
    final url = Uri.parse('$baseUrl/api/orders');
    final Map<String, dynamic> body = {
      'payment_method': paymentMethod,
      'total_amount': totalAmount,
      'items': items,
    };
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      body['store_id'] = targetStoreId;
    }

    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode == 201 && resData['status'] == 'success') {
      return resData['order_id'];
    } else {
      throw Exception(resData['message'] ?? 'Failed to place order');
    }
  }

  // Orders: Update Order Status (e.g. pending -> completed)
  static Future<void> updateOrderStatus(String orderId, String status) async {
    final url = Uri.parse('$baseUrl/api/orders/$orderId/status');
    final response = await http.patch(
      url,
      headers: _getHeaders(),
      body: jsonEncode({'status': status}),
    );

    final resData = jsonDecode(response.body);
    if (response.statusCode != 200 || resData['status'] != 'success') {
      throw Exception(resData['message'] ?? 'Failed to update order status');
    }
  }

  // Dashboard: Get statistics
  static Future<Map<String, dynamic>> getDashboardStats({String? storeIdParam}) async {
    final targetStoreId = storeIdParam ?? storeId;
    String path = '$baseUrl/api/dashboard/stats';
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      path += '?store_id=$targetStoreId';
    }
    final url = Uri.parse(path);
    final response = await http.get(url, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard stats');
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
