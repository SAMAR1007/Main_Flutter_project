import 'package:flutter/material.dart';

class LaptopsScreen extends StatelessWidget {
  const LaptopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laptops'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Laptops Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
