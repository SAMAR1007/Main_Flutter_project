import 'dart:convert';
import 'package:flutter/material.dart';
import '../network/local_storage_service.dart';

class CartItem {
  final String id; // product _id from backend
  final String name;
  final double price; // numeric price
  final String? imageUrl; // full image URL
  final double rating;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.rating = 0,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'rating': rating,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

class CartProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final List<CartItem> _items = [];

  CartProvider({required LocalStorageService storageService})
      : _storageService = storageService {
    _loadCart();
  }

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalItemCount {
    int total = 0;
    for (var item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addToCart(CartItem item) {
    final existingIndex = _items.indexWhere((element) => element.id == item.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(item);
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  /// Convert cart items to order format for backend
  List<Map<String, dynamic>> toOrderItems() {
    return _items.map((item) => {
      'productId': item.id,
      'quantity': item.quantity,
    }).toList();
  }

  Future<void> _loadCart() async {
    final json = await _storageService.getCachedCart();
    if (json != null && json.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(json);
        _items.clear();
        _items.addAll(
          decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)),
        );
        notifyListeners();
      } catch (_) {
        // Corrupted cache — ignore
      }
    }
  }

  Future<void> _saveCart() async {
    final json = jsonEncode(_items.map((e) => e.toJson()).toList());
    await _storageService.cacheCart(json);
  }
}
