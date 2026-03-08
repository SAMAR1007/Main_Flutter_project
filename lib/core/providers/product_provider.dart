import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/local_storage_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final LocalStorageService storageService;

  ProductProvider({required this.apiClient, required this.storageService});

  List<ProductModel> _products = [];
  List<ProductModel> _deals = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;

  List<ProductModel> get products => _products;
  List<ProductModel> get deals => _deals;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  /// Get unique brands from loaded products
  List<String> get brands {
    final brandSet = <String>{};
    for (final p in _products) {
      if (p.brand.isNotEmpty) {
        brandSet.add(p.brand);
      }
    }
    return brandSet.toList()..sort();
  }

  /// Get products by brand
  List<ProductModel> getProductsByBrand(String brand) {
    return _products.where((p) => p.brand.toLowerCase() == brand.toLowerCase()).toList();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Fetch all public products, optionally filtered by category and brand
  Future<void> fetchProducts({String? category, String? brand}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (brand != null && brand.isNotEmpty) {
        queryParams['brand'] = brand;
      }

      final response = await apiClient.get(
        endpoint: ApiEndpoints.products,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response['data'] as List<dynamic>;
      _products = data.map((json) => ProductModel.fromJson(json)).toList();
      // Cache for offline use
      await storageService.cacheProducts(jsonEncode(data));
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Fetch Products Error: $e');
      }
      // Load from cache if network fails
      if (_products.isEmpty) {
        await _loadCachedProducts();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch deal products (isDeal = true)
  Future<void> fetchDeals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.deals,
      );

      final data = response['data'] as List<dynamic>;
      _deals = data.map((json) => ProductModel.fromJson(json)).toList();
      // Cache for offline use
      await storageService.cacheDeals(jsonEncode(data));
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Fetch Deals Error: $e');
      }
      // Load from cache if network fails
      if (_deals.isEmpty) {
        await _loadCachedDeals();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single product by ID
  Future<void> fetchProductById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.get(
        endpoint: ApiEndpoints.productById(id),
      );

      _selectedProduct = ProductModel.fromJson(response['data']);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Fetch Product Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedProducts() async {
    final cached = await storageService.getCachedProducts();
    if (cached != null) {
      final data = jsonDecode(cached) as List<dynamic>;
      _products = data.map((json) => ProductModel.fromJson(json)).toList();
      _errorMessage = null;
    }
  }

  Future<void> _loadCachedDeals() async {
    final cached = await storageService.getCachedDeals();
    if (cached != null) {
      final data = jsonDecode(cached) as List<dynamic>;
      _deals = data.map((json) => ProductModel.fromJson(json)).toList();
      _errorMessage = null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
