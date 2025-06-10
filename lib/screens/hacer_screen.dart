import 'package:flutter/material.dart';

class HacerScreen extends StatelessWidget {
  const HacerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Hacer Screen"),
      ),
    );
  }
}