import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/data/models/user.dart';

void main() {
  group('User Model Unit Tests', () {
    test('Test 1: User model can be created with required fields', () {
      final user = User(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        password: 'password123',
      );

      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.phone, '1234567890');
      expect(user.password, 'password123');
    });

    test('Test 2: User model can be created with profilePicture', () {
      final user = User(
        name: 'Jane Doe',
        email: 'jane@example.com',
        phone: '9876543210',
        password: 'pass456',
        profilePicture: 'https://example.com/profile.jpg',
      );

      expect(user.profilePicture, 'https://example.com/profile.jpg');
    });

    test('Test 3: User model profilePicture defaults to null', () {
      final user = User(
        name: 'Bob Smith',
        email: 'bob@example.com',
        phone: '5555555555',
        password: 'bobpass',
      );

      expect(user.profilePicture, isNull);
    });

    test('Test 4: User email can be validated', () {
      final validUser = User(
        name: 'Test User',
        email: 'test@example.com',
        phone: '1111111111',
        password: 'test',
      );

      expect(validUser.email, contains('@'));
      expect(validUser.email, contains('.'));
    });

    test('Test 5: User password should not be empty', () {
      final user = User(
        name: 'Security Test',
        email: 'secure@example.com',
        phone: '2222222222',
        password: 'strongpass123',
      );

      expect(user.password, isNotEmpty);
      expect(user.password.length, greaterThan(0));
    });
  });
}
