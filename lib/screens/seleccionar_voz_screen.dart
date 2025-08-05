import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class SeleccionarVozScreen extends StatelessWidget {
  final String genero;

  const SeleccionarVozScreen({super.key, required this.genero});

  Future<void> _guardarVoz(Map<String, String> voz) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voz_seleccionada', voz['name']!);
    await prefs.setString('voz_locale', voz['locale']!);
  }

  @override
  Widget build(BuildContext context) {
    final voces = TtsService.vocesSeleccionadas[genero] ?? [];

   return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona una voz"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: voces.length,
          itemBuilder: (context, index) {
            final voz = voces[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Opción ${index + 1}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Nombre: ${voz['name']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Idioma: ${voz['locale']}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await TtsService.setVoiceByData(voz);
                            await TtsService.speak("Hola, soy una voz de $genero");
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Probar"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await TtsService.setVoiceByData(voz);
                            await _guardarVoz(voz);
                            Navigator.pushReplacement(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Seleccionar"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}