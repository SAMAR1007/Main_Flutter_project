import 'package:flutter/material.dart';

class GamingScreen extends StatelessWidget {
  const GamingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaming'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Gaming Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
