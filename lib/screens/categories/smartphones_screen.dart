import 'package:flutter/material.dart';

class SmartphonesScreen extends StatelessWidget {
  const SmartphonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smartphones'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Smartphones Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
