import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_item.dart';

class ApiService {
  static const String _productionUrl = 'https://m-pos-api.onrender.com';
  static bool useProduction = true;

  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _storeIdKey = 'store_id';

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
  static const String defaultStoreId = '7bca151b-7a69-4a5e-8695-f4ad62c45991';

  static String get activeStoreId {
    if (storeId != null && storeId!.isNotEmpty) {
      return storeId!;
    }
    return defaultStoreId;
  }

  static Future<bool> initSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        _token = token;
        userEmail = prefs.getString(_userEmailKey);
        storeId = prefs.getString(_storeIdKey);
        return true;
      }
    } catch (e) {
      print('Error initializing session: $e');
    }
    return false;
  }

  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 1. Auth: Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
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
      storeId =
          resData['user']?['store_id'] ??
          resData['store_id'] ??
          resData['user']?['store']?['id'];

      try {
        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString(_tokenKey, _token!);
        if (userEmail != null) await prefs.setString(_userEmailKey, userEmail!);
        if (storeId != null) await prefs.setString(_storeIdKey, storeId!);
      } catch (e) {
        print('Error saving session: $e');
      }

      return {'success': true, 'user': resData['user'], 'access_token': _token};
    } else {
      throw Exception(resData['message'] ?? 'Login failed');
    }
  }

  // Auth: Logout
  static Future<void> logout() async {
    if (_token != null) {
      try {
        final url = Uri.parse('$baseUrl/api/auth/logout');
        await http.post(url, headers: _getHeaders());
      } catch (_) {}
    }
    _token = null;
    userEmail = null;
    storeId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_storeIdKey);
    } catch (e) {
      print('Error clearing session: $e');
    }
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
    if (response.statusCode == 201 ||
        (response.statusCode == 200 && resData['status'] == 'success')) {
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
  static Future<Map<String, dynamic>> getStoreAllData([
    String? storeIdParam,
  ]) async {
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
  static Future<List<Map<String, dynamic>>> getCategories({
    String? storeIdParam,
  }) async {
    final targetStoreId = (storeIdParam != null && storeIdParam.isNotEmpty)
        ? storeIdParam
        : activeStoreId;
    final url = Uri.parse('$baseUrl/api/categories?store_id=$targetStoreId');
    print('DEBUG [ApiService.getCategories] URL: $url');
    final response = await http.get(url, headers: _getHeaders());
    print(
      'DEBUG [ApiService.getCategories] Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        list = decoded['data'] ?? decoded['categories'] ?? [];
      }
      return list.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Categories: Delete Category
  static Future<void> deleteCategory(String id) async {
    final url = Uri.parse('$baseUrl/api/categories/$id');
    final response = await http.delete(url, headers: _getHeaders());

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }
    try {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to delete category');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to delete category (${response.statusCode})');
    }
  }

  // Categories: Create Category for Store
  static Future<Map<String, dynamic>> createCategory(
    String name, {
    bool isActive = true,
    String? storeIdParam,
  }) async {
    final targetStoreId = (storeIdParam != null && storeIdParam.isNotEmpty)
        ? storeIdParam
        : activeStoreId;
    final url = Uri.parse('$baseUrl/api/categories');
    final Map<String, dynamic> body = {
      'name': name,
      'store_id': targetStoreId,
      'is_active': isActive,
    };

    print('DEBUG [ApiService.createCategory] URL: $url, Body: $body');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    print(
      'DEBUG [ApiService.createCategory] Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = jsonDecode(response.body);
      if (resData is Map<String, dynamic>) {
        if (resData.containsKey('data') &&
            resData['data'] is Map<String, dynamic>) {
          return resData['data'];
        }
        return resData;
      }
      return {'name': name, 'store_id': targetStoreId, 'is_active': isActive};
    } else {
      try {
        final resData = jsonDecode(response.body);
        throw Exception(
          resData['message'] ??
              'Failed to create category (${response.statusCode})',
        );
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to create category (${response.statusCode})');
      }
    }
  }

  // Categories: Update Category
  static Future<void> updateCategory(
    String id,
    String name, {
    bool isActive = true,
    String? storeIdParam,
  }) async {
    final targetStoreId = (storeIdParam != null && storeIdParam.isNotEmpty)
        ? storeIdParam
        : activeStoreId;
    final url = Uri.parse('$baseUrl/api/categories/$id');
    final Map<String, dynamic> body = {
      'name': name,
      'is_active': isActive,
      'store_id': targetStoreId,
    };

    final response = await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    try {
      final resData = jsonDecode(response.body);
      throw Exception(resData['message'] ?? 'Failed to update category');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update category (${response.statusCode})');
    }
  }

  // 4. Products: Get Products (Filtered by Logged-in Store, store_id, and/or category_id)
  static Future<List<ProductItem>> getProducts({
    String? categoryId,
    String? storeIdParam,
  }) async {
    final targetStoreId = (storeIdParam != null && storeIdParam.isNotEmpty)
        ? storeIdParam
        : activeStoreId;
    final List<String> queryParams = ['store_id=$targetStoreId'];
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams.add('category_id=$categoryId');
    }

    final url = Uri.parse('$baseUrl/api/products?${queryParams.join('&')}');
    print('DEBUG [ApiService.getProducts] URL: $url');
    final response = await http.get(url, headers: _getHeaders());
    print(
      'DEBUG [ApiService.getProducts] Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        list = decoded['data'] ?? decoded['products'] ?? [];
      }

      // Fetch categories map to match category name
      final categories = await getCategories(storeIdParam: targetStoreId);
      final catMap = {for (var c in categories) c['id']: c['name']};

      return list.map((item) {
        final catId = item['category_id']?.toString();
        final catName = (catId != null && catMap.containsKey(catId))
            ? catMap[catId]!
            : 'Other';

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

        final double rawPrice = item['price'] != null
            ? (double.tryParse(item['price'].toString()) ?? 0.0)
            : 0.0;
        final int rawStock = item['stock'] != null
            ? (int.tryParse(item['stock'].toString()) ?? 0)
            : 0;
        final String? rawImg = item['image_url']?.toString();

        final bool rawActive =
            item['is_active'] == null ||
            item['is_active'] == true ||
            item['active'] == true;

        return ProductItem(
          id: item['id']?.toString(),
          name: item['name']?.toString() ?? 'Unnamed Product',
          price: rawPrice,
          stock: rawStock,
          icon: itemIcon,
          imageUrl: (rawImg != null && rawImg.isNotEmpty) ? rawImg : null,
          isInStock: rawStock > 0,
          isActive: rawActive,
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
    String name,
    double price, {
    int stock = 0,
    String? categoryId,
    String imageUrl = '',
    bool isActive = true,
    String? storeIdParam,
  }) async {
    String? targetStoreId = storeIdParam ?? storeId;
    if (targetStoreId == null || targetStoreId.isEmpty) {
      targetStoreId = '7bca151b-7a69-4a5e-8695-f4ad62c45991';
    }
    final url = Uri.parse('$baseUrl/api/products');
    final Map<String, dynamic> body = {
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_active': isActive,
      'store_id': targetStoreId,
    };

    print('DEBUG [ApiService.createProduct] URL: $url, Body: $body');
    final response = await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
    print(
      'DEBUG [ApiService.createProduct] Status: ${response.statusCode}, Body: ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = jsonDecode(response.body);
      final item =
          (resData is Map<String, dynamic> && resData.containsKey('data'))
          ? resData['data']
          : resData;
      return ProductItem(
        id: item['id']?.toString(),
        name: item['name']?.toString() ?? name,
        price: (item['price'] as num?)?.toDouble() ?? price,
        stock: (item['stock'] as int?) ?? stock,
        icon: Icons.local_cafe_rounded,
        imageUrl:
            (item['image_url'] != null &&
                item['image_url'].toString().isNotEmpty)
            ? item['image_url'].toString()
            : null,
        isInStock: ((item['stock'] as int?) ?? stock) > 0,
        isActive: item['is_active'] ?? isActive,
        category: 'Other',
        categoryId: item['category_id']?.toString(),
      );
    } else {
      try {
        final resData = jsonDecode(response.body);
        throw Exception(
          resData['message'] ??
              'Failed to create product (${response.statusCode})',
        );
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Failed to create product (${response.statusCode})');
      }
    }
  }

  // Products: Update Product
  static Future<void> updateProduct(
    String id,
    String name,
    double price,
    int stock,
    String? categoryId, {
    String imageUrl = '',
    bool isActive = true,
    String? storeIdParam,
  }) async {
    final targetStoreId = storeIdParam ?? storeId;
    final url = Uri.parse('$baseUrl/api/products/$id');
    final Map<String, dynamic> body = {
      'name': name,
      'price': price,
      'stock': stock,
      'is_active': isActive,
    };
    if (categoryId != null) body['category_id'] = categoryId;
    if (imageUrl.isNotEmpty) body['image_url'] = imageUrl;
    if (targetStoreId != null && targetStoreId.isNotEmpty) {
      body['store_id'] = targetStoreId;
    }

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
    String paymentMethod,
    double totalAmount,
    List<Map<String, dynamic>> items, {
    String? storeIdParam,
  }) async {
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

    try {
      print(
        'DEBUG [createOrder] Sending request to $url with body: ${jsonEncode(body)}',
      );
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 5));

      print(
        'DEBUG [createOrder] Response: ${response.statusCode} - ${response.body}',
      );
      final resData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final orderId =
            resData['order_id']?.toString() ??
            resData['id']?.toString() ??
            resData['order']?['id']?.toString() ??
            resData['data']?['id']?.toString() ??
            'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        return orderId;
      } else {
        final offlineId =
            'OFF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        print(
          'DEBUG [createOrder] API error status ${response.statusCode}. Fallback ID: $offlineId',
        );
        return offlineId;
      }
    } catch (e) {
      // Offline fallback when host lookup or network fails
      final offlineId =
          'OFF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      print(
        'DEBUG [createOrder] Network failed ($e). Offline order generated: $offlineId',
      );
      return offlineId;
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
  static Future<Map<String, dynamic>> getDashboardStats({
    String? storeIdParam,
  }) async {
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
      http.MultipartFile.fromBytes('image', bytes, filename: filename),
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
