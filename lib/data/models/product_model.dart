import '../../core/network/api_endpoints.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String brand;
  final String description;
  final String? image;
  final double rating;
  final int reviews;
  final bool isDeal;
  final String? dealType;
  final double discountPercent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.brand = '',
    this.description = '',
    this.image,
    this.rating = 0,
    this.reviews = 0,
    this.isDeal = false,
    this.dealType,
    this.discountPercent = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: (json['reviews'] ?? 0).toInt(),
      isDeal: json['isDeal'] ?? false,
      dealType: json['dealType'],
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'brand': brand,
      'description': description,
      'image': image,
      'rating': rating,
      'reviews': reviews,
      'isDeal': isDeal,
      'dealType': dealType,
      'discountPercent': discountPercent,
    };
  }

  String get imageUrl => ApiEndpoints.imageUrl(image);

  double get discountedPrice {
    if (isDeal && discountPercent > 0) {
      return price * (1 - discountPercent / 100);
    }
    return price;
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? brand,
    String? description,
    String? image,
    double? rating,
    int? reviews,
    bool? isDeal,
    String? dealType,
    double? discountPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isDeal: isDeal ?? this.isDeal,
      dealType: dealType ?? this.dealType,
      discountPercent: discountPercent ?? this.discountPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Category icon mapping
  static const Map<String, int> categoryIcons = {
    'Smartphones': 0xe1e3, // Icons.phone_android
    'Laptops': 0xe37c, // Icons.laptop_mac
    'Audio': 0xe310, // Icons.headphones_rounded
    'Wearables': 0xf06bb, // Icons.watch_rounded
    'Cameras': 0xe3af, // Icons.camera_alt_rounded
    'Gaming': 0xf0562, // Icons.sports_esports_rounded
  };
}
