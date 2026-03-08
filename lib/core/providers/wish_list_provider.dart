import 'package:flutter/material.dart';

class WishListItem {
  final String id; // product _id from backend
  final String name;
  final double price;
  final String? imageUrl;
  final double rating;

  WishListItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.rating = 0,
  });
}

class WishListProvider extends ChangeNotifier {
  final List<WishListItem> _items = [];

  List<WishListItem> get items => _items;

  int get itemCount => _items.length;

  bool isInWishList(String id) {
    return _items.any((item) => item.id == id);
  }

  void addToWishList(WishListItem item) {
    if (!isInWishList(item.id)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeFromWishList(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleWishList(WishListItem item) {
    if (isInWishList(item.id)) {
      removeFromWishList(item.id);
    } else {
      addToWishList(item);
    }
  }

  void clearWishList() {
    _items.clear();
    notifyListeners();
  }
}
