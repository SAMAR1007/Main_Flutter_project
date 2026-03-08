// lib/screens/categories_page.dart
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Categories Page',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
