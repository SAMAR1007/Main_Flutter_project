// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/widgets/custom_button.dart';
import 'package:tech_hive/widgets/custom_textfield.dart';

void main() {
  testWidgets('CustomButton and TextField integration test', (WidgetTester tester) async {
    // Build a minimal test app with CustomButton and CustomTextField
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool buttonPressed = false;

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
                  text: 'Login',
                  onPressed: () {
                    buttonPressed = true;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that text fields are rendered
    expect(find.byType(TextField), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Test entering email
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    expect(emailController.text, 'test@example.com');

    // Test entering password
    await tester.enterText(find.byType(TextField).last, 'password123');
    expect(passwordController.text, 'password123');

    // Verify button exists
    expect(find.text('Login'), findsOneWidget);

    // Tap the button and verify it was pressed
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(buttonPressed, isTrue);
  });
}

