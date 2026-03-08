import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/data/models/product_model.dart';
import 'package:tech_hive/data/models/order_model.dart';

void main() {
  group('ProductModel Unit Tests', () {
    test('Test 1: ProductModel fromJson parses all fields', () {
      final json = {
        '_id': 'prod1',
        'name': 'Gaming Laptop',
        'price': 1499,
        'category': 'Laptops',
        'brand': 'TechBrand',
        'description': 'High-end gaming laptop',
        'image': 'laptop.jpg',
        'rating': 4.7,
        'reviews': 120,
        'isDeal': true,
        'dealType': 'flash',
        'discountPercent': 15,
        'createdAt': '2025-06-15T10:00:00.000Z',
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'prod1');
      expect(product.name, 'Gaming Laptop');
      expect(product.price, 1499.0);
      expect(product.category, 'Laptops');
      expect(product.brand, 'TechBrand');
      expect(product.isDeal, isTrue);
      expect(product.discountPercent, 15.0);
      expect(product.rating, 4.7);
      expect(product.reviews, 120);
    });

    test('Test 2: ProductModel discountedPrice calculates correctly', () {
      final product = ProductModel(
        id: 'prod2',
        name: 'Smartphone',
        price: 1000.0,
        category: 'Smartphones',
        isDeal: true,
        discountPercent: 20,
      );

      expect(product.discountedPrice, 800.0);
    });

    test('Test 3: ProductModel discountedPrice returns full price when no deal', () {
      final product = ProductModel(
        id: 'prod3',
        name: 'Keyboard',
        price: 75.0,
        category: 'Gaming',
        isDeal: false,
        discountPercent: 10,
      );

      expect(product.discountedPrice, 75.0);
    });
  });

  group('OrderModel & ShippingAddress Unit Tests', () {
    test('Test 4: ShippingAddress toJson produces correct map', () {
      final address = ShippingAddress(
        fullName: 'John Doe',
        phoneNumber: '9841234567',
        street: '123 Main St',
        city: 'Kathmandu',
        state: 'Bagmati',
        postalCode: '44600',
      );

      final json = address.toJson();

      expect(json['fullName'], 'John Doe');
      expect(json['phoneNumber'], '9841234567');
      expect(json['city'], 'Kathmandu');
      expect(json['country'], 'Nepal');
    });

    test('Test 5: OrderModel fromJson parses order with items', () {
      final json = {
        '_id': 'order1',
        'user': 'user123',
        'items': [
          {
            'product': 'prod1',
            'quantity': 2,
            'priceAtPurchase': 500,
            'subtotal': 1000,
          },
        ],
        'totalAmount': 1000,
        'shippingAddress': {
          'fullName': 'Jane Doe',
          'phoneNumber': '9800000000',
          'street': '456 Market Rd',
          'city': 'Pokhara',
          'state': 'Gandaki',
          'postalCode': '33700',
          'country': 'Nepal',
        },
        'paymentMethod': 'cash_on_delivery',
        'status': 'pending',
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, 'order1');
      expect(order.userId, 'user123');
      expect(order.items.length, 1);
      expect(order.items.first.productId, 'prod1');
      expect(order.items.first.quantity, 2);
      expect(order.totalAmount, 1000.0);
      expect(order.shippingAddress.city, 'Pokhara');
      expect(order.status, 'pending');
    });
  });
}
