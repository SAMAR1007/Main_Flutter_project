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

    test('Test 2: Email validation - email contains @ symbol', () {
      final user = User(
        name: 'Test User',
        email: 'test@example.com',
        phone: '1111111111',
        password: 'testpass',
      );

      expect(user.email.contains('@'), isTrue);
      expect(user.email.contains('.'), isTrue);
    });

    test('Test 3: Phone number is stored correctly', () {
      final user = User(
        name: 'Phone Test',
        email: 'phone@example.com',
        phone: '9876543210',
        password: 'phonepass',
      );

      expect(user.phone, '9876543210');
      expect(user.phone.length, greaterThanOrEqualTo(10));
    });

    test('Test 4: Password should not be empty', () {
      final user = User(
        name: 'Pass Test',
        email: 'pass@example.com',
        phone: '5555555555',
        password: 'securepass123',
      );

      expect(user.password, isNotEmpty);
      expect(user.password.length, greaterThanOrEqualTo(6));
    });

    test('Test 5: User profilePicture can be set and retrieved', () {
      final user = User(
        name: 'Profile Test',
        email: 'profile@example.com',
        phone: '3333333333',
        password: 'profilepass',
        profilePicture: 'https://example.com/pic.jpg',
      );

      expect(user.profilePicture, 'https://example.com/pic.jpg');
      
      // Update profile picture
      user.profilePicture = 'https://example.com/newpic.jpg';
      expect(user.profilePicture, 'https://example.com/newpic.jpg');
    });
  });
}
