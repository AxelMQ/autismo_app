// ignore_for_file: use_build_context_synchronously

import 'package:autismo_app/screens/colores_screen.dart';
import 'package:autismo_app/screens/emociones_screen.dart';
import 'package:autismo_app/screens/familia_screen.dart';
import 'package:autismo_app/screens/genero_screen.dart';
import 'package:autismo_app/screens/hacer_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonSize = Size(
      150,
      180,
    ); // Mismo ancho y alto para todos los botones

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yo te hablo?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('genero_nino');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => GeneroScreen()),
              );
            },
          ),
        ],

        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Primera fila de botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryButton(
                  context: context,
                  text: 'EMOCIONES',
                  color: Colors.orange,
                  size: buttonSize,
                  destination: const EmocionesScreen(),
                  imagePath: 'assets/imgs/emociones.png',
                ),
                const SizedBox(width: 20),
                _buildCategoryButton(
                  context: context,
                  text: 'COLORES',
                  color: Colors.purple,
                  size: buttonSize,
                  destination: ColoresScreen(),
                  imagePath: 'assets/imgs/colores.png',
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Segunda fila de botones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryButton(
                  context: context,
                  text: 'FAMILIA',
                  color: const Color.fromARGB(255, 23, 108, 177),
                  size: buttonSize,
                  destination: const FamiliaScreen(),
                  imagePath: 'assets/imgs/familia.png',
                ),
                const SizedBox(width: 20),
                _buildCategoryButton(
                  context: context,
                  text: 'HACER',
                  color: Colors.green,
                  size: buttonSize,
                  destination: const HacerScreen(),
                  imagePath: 'assets/imgs/hacer.png',
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Texto inferior
            const Text(
              'AUTISMO',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required String text,
    required Color color,
    required Size size,
    required Widget? destination,
    String? imagePath,
  }) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ElevatedButton(
        onPressed:
            destination != null
                ? () => _navigateToScreen(context, destination)
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          padding: const EdgeInsets.all(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            // Mostrar imagen si está disponible, sino mostrar icono por defecto
            imagePath != null
                ? Image.asset(
                  imagePath,
                  width: 110,
                  height: 110,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderIcon();
                  },
                )
                : _buildPlaceholderIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.image, color: Colors.white, size: 40),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
