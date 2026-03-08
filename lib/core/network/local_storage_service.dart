import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _ensurePrefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Token management
  Future<void> saveToken(String token) async {
    final prefs = await _ensurePrefs;
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await _ensurePrefs;
    return prefs.getString('auth_token');
  }

  Future<void> removeToken() async {
    final prefs = await _ensurePrefs;
    await prefs.remove('auth_token');
  }

  // User data management
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await _ensurePrefs;
    await prefs.setString('user_data', jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _ensurePrefs;
    final userJson = prefs.getString('user_data');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> removeUser() async {
    final prefs = await _ensurePrefs;
    await prefs.remove('user_data');
  }

  // Login state
  Future<void> setLoggedIn(bool value) async {
    final prefs = await _ensurePrefs;
    await prefs.setBool('is_logged_in', value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await _ensurePrefs;
    return prefs.getBool('is_logged_in') ?? false;
  }

  // Product cache
  Future<void> cacheProducts(String json) async {
    final prefs = await _ensurePrefs;
    await prefs.setString('cached_products', json);
  }

  Future<String?> getCachedProducts() async {
    final prefs = await _ensurePrefs;
    return prefs.getString('cached_products');
  }

  Future<void> cacheDeals(String json) async {
    final prefs = await _ensurePrefs;
    await prefs.setString('cached_deals', json);
  }

  Future<String?> getCachedDeals() async {
    final prefs = await _ensurePrefs;
    return prefs.getString('cached_deals');
  }

  // Cart cache (offline cart)
  Future<void> cacheCart(String json) async {
    final prefs = await _ensurePrefs;
    await prefs.setString('cached_cart', json);
  }

  Future<String?> getCachedCart() async {
    final prefs = await _ensurePrefs;
    return prefs.getString('cached_cart');
  }

  // Clear everything
  Future<void> clearAll() async {
    final prefs = await _ensurePrefs;
    await prefs.clear();
  }
}
