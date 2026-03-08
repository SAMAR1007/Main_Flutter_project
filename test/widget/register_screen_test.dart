import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/widgets/custom_textfield.dart';
import 'package:tech_hive/widgets/custom_button.dart';

void main() {
  group('RegisterScreen Widget Component Tests', () {
    testWidgets('Test 1: Name field component renders correctly', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Full Name',
                prefixIcon: Icons.person,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('Test 2: Email field component works', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Email Address',
                prefixIcon: Icons.email,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('Test 3: Password field is obscured', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Password',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'password123');
      expect(controller.text, 'password123');
    });

    testWidgets('Test 4: Phone number field component', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Phone Number',
                prefixIcon: Icons.phone,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '1234567890');
      expect(controller.text, '1234567890');
    });

    testWidgets('Test 5: Complete registration form simulation', (WidgetTester tester) async {
      final nameController = TextEditingController();
      final emailController = TextEditingController();
      final passwordController = TextEditingController();
      final phoneController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: phoneController,
                    hintText: 'Phone',
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Fill in the form
      await tester.enterText(find.byType(TextField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(2), 'password123');
      await tester.enterText(find.byType(TextField).at(3), '1234567890');
      await tester.pump();

      expect(nameController.text, 'John Doe');
      expect(emailController.text, 'john@example.com');
      expect(passwordController.text, 'password123');
      expect(phoneController.text, '1234567890');
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
