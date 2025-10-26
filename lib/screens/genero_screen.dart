import 'package:autismo_app/screens/home_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  String? generoGuardado;

  @override
  void initState() {
    super.initState();
    _cargarGenero();
  }

  Future<void> _cargarGenero() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      generoGuardado = prefs.getString('genero_nino');
    });
  }

  Future<void> _guardarGenero(String genero) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('genero_nino', genero);

    // Obtenenemos la 3ra voz del género seleccionado
    final voces = TtsService.vocesSeleccionadas[genero];
    if (voces != null && voces.length >= 3) {
      final vozPreSeleccionada = voces[2];

      // Guardamos la voz seleccionada
      await prefs.setString('voz_seleccionada', vozPreSeleccionada['name']!);
      await prefs.setString('voz_locale', vozPreSeleccionada['locale']!);
      await TtsService.setVoiceByData(vozPreSeleccionada);
    } else {
      debugPrint("⚠️ No hay voces disponibles para el género: $genero");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen()
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text("¿Quién eres?"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Selecciona:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGeneroCard(
                  context,
                  genero: 'niño',
                  color: Colors.blue[300]!,
                  icon: Icons.boy,
                ),
                _buildGeneroCard(
                  context,
                  genero: 'niña',
                  color: Colors.pink[300]!,
                  icon: Icons.girl,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroCard(
    BuildContext context, {
    required String genero,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _guardarGenero(genero),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color,
        child: SizedBox(
          width: 120,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                genero.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
