import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/core/providers/cart_provider.dart';

void main() {
  group('CartItem Unit Tests', () {
    test('Test 1: CartItem toJson produces correct map', () {
      final item = CartItem(
        id: 'p1',
        name: 'Laptop',
        price: 999.99,
        imageUrl: 'https://example.com/laptop.jpg',
        rating: 4.5,
        quantity: 2,
      );

      final json = item.toJson();

      expect(json['id'], 'p1');
      expect(json['name'], 'Laptop');
      expect(json['price'], 999.99);
      expect(json['imageUrl'], 'https://example.com/laptop.jpg');
      expect(json['rating'], 4.5);
      expect(json['quantity'], 2);
    });

    test('Test 2: CartItem fromJson restores object correctly', () {
      final json = {
        'id': 'p2',
        'name': 'Phone',
        'price': 599.0,
        'imageUrl': 'https://example.com/phone.jpg',
        'rating': 4.0,
        'quantity': 3,
      };

      final item = CartItem.fromJson(json);

      expect(item.id, 'p2');
      expect(item.name, 'Phone');
      expect(item.price, 599.0);
      expect(item.imageUrl, 'https://example.com/phone.jpg');
      expect(item.rating, 4.0);
      expect(item.quantity, 3);
    });

    test('Test 3: CartItem fromJson handles missing optional fields', () {
      final json = {
        'id': 'p3',
        'name': 'Cable',
        'price': 9.99,
      };

      final item = CartItem.fromJson(json);

      expect(item.imageUrl, isNull);
      expect(item.rating, 0);
      expect(item.quantity, 1);
    });

    test('Test 4: CartItem roundtrip toJson/fromJson preserves data', () {
      final original = CartItem(
        id: 'p4',
        name: 'Headphones',
        price: 149.50,
        imageUrl: null,
        rating: 3.8,
        quantity: 5,
      );

      final restored = CartItem.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.price, original.price);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.rating, original.rating);
      expect(restored.quantity, original.quantity);
    });

    test('Test 5: CartItem defaults quantity to 1', () {
      final item = CartItem(
        id: 'p5',
        name: 'Mouse',
        price: 29.99,
      );

      expect(item.quantity, 1);
      expect(item.rating, 0);
      expect(item.imageUrl, isNull);
    });
  });
}
