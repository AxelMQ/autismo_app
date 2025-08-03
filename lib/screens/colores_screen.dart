// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:autismo_app/screens/frutas_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';

class ColoresScreen extends StatelessWidget {
  ColoresScreen({super.key});

  final List<Map<String, dynamic>> colores = [
    {'nombre': 'Amarillo', 'color': Colors.yellow},
    {'nombre': 'Naranja', 'color': Colors.orange},
    {'nombre': 'Rojo', 'color': Colors.red},
    {'nombre': 'Verde', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('Colores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 800,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics:
                colores.length <= 4
                    ? const NeverScrollableScrollPhysics()
                    : null,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: colores.length,
            itemBuilder: (context, index) {
              final colorData = colores[index];
              return _buildColorCircle(
                context,
                colorData['nombre'],
                colorData['color'],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(BuildContext context, String nombre, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double diameter = constraints.maxWidth * 0.8;
        return InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Seleccionaste: $nombre'),
                duration: const Duration(seconds: 1),
              ),
            );

            await TtsService.speak(nombre);
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        FrutasScreen(colorNombre: nombre, color: color),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.black38, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
