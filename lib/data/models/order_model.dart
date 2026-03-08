class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final ShippingAddress shippingAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    this.paymentMethod = 'cash_on_delivery',
    this.paymentStatus = 'pending',
    this.transactionId,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] ?? ''),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      shippingAddress: ShippingAddress.fromJson(json['shippingAddress'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      transactionId: json['transactionId'],
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }
}

class OrderItem {
  final String productId;
  final String? productName;
  final String? productImage;
  final int quantity;
  final double priceAtPurchase;
  final double subtotal;

  OrderItem({
    required this.productId,
    this.productName,
    this.productImage,
    required this.quantity,
    required this.priceAtPurchase,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    String productId;
    String? productName;
    String? productImage;

    if (product is String) {
      productId = product;
    } else if (product is Map<String, dynamic>) {
      productId = product['_id'] ?? '';
      productName = product['name'];
      productImage = product['image'];
    } else {
      productId = '';
    }

    return OrderItem(
      productId: productId,
      productName: productName,
      productImage: productImage,
      quantity: (json['quantity'] ?? 1).toInt(),
      priceAtPurchase: (json['priceAtPurchase'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}

class ShippingAddress {
  final String fullName;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  ShippingAddress({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'Nepal',
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'Nepal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }
}
