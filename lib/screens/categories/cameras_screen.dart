import 'package:flutter/material.dart';

class CamerasScreen extends StatelessWidget {
  const CamerasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cameras'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Cameras Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
