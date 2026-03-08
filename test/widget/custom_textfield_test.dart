import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/widgets/custom_textfield.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('Test 1: CustomTextField renders with hint text', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: controller,
                hintText: 'Enter email',
                prefixIcon: Icons.email,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('Test 2: CustomTextField accepts text input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: controller,
                hintText: 'Type here',
                prefixIcon: Icons.text_fields,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, 'Hello World');
    });

    testWidgets('Test 3: CustomTextField with obscureText hides input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
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

    testWidgets('Test 4: CustomTextField renders with prefix icon', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: controller,
                hintText: 'Search',
                prefixIcon: Icons.search,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Test 5: CustomTextField with suffix icon renders correctly', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                controller: controller,
                hintText: 'Search',
                prefixIcon: Icons.search,
                suffixIcon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });
}
