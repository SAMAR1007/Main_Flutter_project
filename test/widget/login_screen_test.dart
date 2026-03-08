import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/widgets/custom_textfield.dart';
import 'package:tech_hive/widgets/custom_button.dart';

void main() {
  group('LoginScreen Widget Component Tests', () {
    testWidgets('Test 1: CustomTextfield renders with email icon', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Email',
                prefixIcon: Icons.email,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('Test 2: CustomTextfield with password obscuring', (WidgetTester tester) async {
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

      await tester.enterText(find.byType(TextField), 'secret123');
      expect(controller.text, 'secret123');
    });

    testWidgets('Test 3: CustomButton renders and is clickable', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Sign In',
                onPressed: () => buttonPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(buttonPressed, isTrue);
    });

    testWidgets('Test 4: Email field accepts user input', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: controller,
                hintText: 'Enter Email',
                prefixIcon: Icons.email,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'user@example.com');
      expect(controller.text, 'user@example.com');
    });

    testWidgets('Test 5: Multiple input fields can work together', (WidgetTester tester) async {
      final emailController = TextEditingController();
      final passwordController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Sign In',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
