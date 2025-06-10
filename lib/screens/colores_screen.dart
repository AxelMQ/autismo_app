import 'package:flutter/material.dart';

class ColoresScreen extends StatelessWidget {
  const ColoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Colores Screen")
      ),
    );
  }
}