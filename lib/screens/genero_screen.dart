import 'package:autismo_app/screens/home_screen.dart';
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
    setState(() {
      generoGuardado = genero;
    });

    // Puedes comentar esta línea si quieres quedarte en esta pantalla
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("¿Quién eres?")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (generoGuardado != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Género guardado: $generoGuardado",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Text("Selecciona el género del niño o niña:"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _guardarGenero('niño'),
              child: const Text("Soy niño"),
            ),
            ElevatedButton(
              onPressed: () => _guardarGenero('niña'),
              child: const Text("Soy niña"),
            ),
          ],
        ),
      ),
    );
  }
}
