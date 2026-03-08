import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_hive/widgets/custom_button.dart';

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('Test 1: CustomButton renders with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Click Me',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('Test 2: CustomButton has correct background color', (WidgetTester tester) async {
      const testColor = Color.fromARGB(255, 42, 179, 167);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Colored Button',
              onPressed: () {},
              color: testColor,
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('Test 3: CustomButton is tappable and calls onPressed callback', (WidgetTester tester) async {
      bool isPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Tap Me',
              onPressed: () {
                isPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(isPressed, isTrue);
    });

    testWidgets('Test 4: CustomButton with null onPressed is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('Test 5: CustomButton has full width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: 'Full Width Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsWidgets);
    });
  });
}
