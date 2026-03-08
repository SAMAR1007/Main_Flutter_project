import 'package:flutter/material.dart';

class WearablesScreen extends StatelessWidget {
  const WearablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearables'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Wearables Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
