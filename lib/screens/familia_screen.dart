import 'package:flutter/material.dart';

class FamiliaScreen extends StatelessWidget {
  const FamiliaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Familia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Familia Screen"),
      ),
    );
  }
}