import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmocionesScreen extends StatefulWidget {
  const EmocionesScreen({super.key});

  @override
  State<EmocionesScreen> createState() => _EmocionesScreenState();
}

class _EmocionesScreenState extends State<EmocionesScreen> {
  bool? isBoy; // true = niño, false = niña
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _cargarGeneroGuardado();
  }

  Future<void> _cargarGeneroGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final genero = prefs.getString('genero_nino');
    setState(() {
      isBoy = (genero == 'niño'); // true si es niño, false si es niña
    });
  }

  final Map<String, Map<String, dynamic>> emocionesBoy = {
    'Feliz': {
      'emoji': '😊',
      'color': Colors.yellow,
      'imagen': 'assets/emociones/boy_feliz.png',
    },
    'Miedo': {
      'emoji': '😢',
      'color': Colors.blue,
      'imagen': 'assets/emociones/boy_miedoso.png',
    },
    'Enojado': {
      'emoji': '😠',
      'color': Colors.red,
      'imagen': 'assets/emociones/boy_enojado.png',
    },
    'Sorprendido': {
      'emoji': '😲',
      'color': Colors.orange,
      'imagen': 'assets/emociones/boy_sorprendido.png',
    },
    'Tranquilo': {
      'emoji': '😨',
      'color': Colors.purple,
      'imagen': 'assets/emociones/boy_tranquilo.png',
    },
    'Triste': {
      'emoji': '😴',
      'color': Colors.grey,
      'imagen': 'assets/emociones/boy_triste.png',
    },
  };

  final Map<String, Map<String, dynamic>> emocionesGirl = {
    'Feliz': {
      'emoji': '😊',
      'color': Colors.green,
      'imagen': 'assets/emociones/girl_feliz.png',
    },
    'Triste': {
      'emoji': '😢',
      'color': Colors.blue,
      'imagen': 'assets/emociones/girl_triste.png',
    },
    'Enojada': {
      'emoji': '😠',
      'color': Colors.red,
      'imagen': 'assets/emociones/girl_enojada.png',
    },
    'Sorprendida': {
      'emoji': '😲',
      'color': const Color.fromARGB(255, 53, 52, 51),
      'imagen': 'assets/emociones/girl_sorprendida.png',
    },
    'Asustada': {
      'emoji': '😨',
      'color': Colors.purple,
      'imagen': 'assets/emociones/girl_miedosa.png',
    },
    'Tranquila': {
      'emoji': '😴',
      'color': Colors.grey,
      'imagen': 'assets/emociones/girl_tranquila.png',
    },
  };

  @override
  void dispose() {
    TtsService.stop(); // Liberar el TTS al cerrar la pantalla
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await TtsService.speak(text);
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isBoy == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final emociones = isBoy! ? emocionesBoy : emocionesGirl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emociones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón de selección niño/niña
          IconButton(
            icon: Icon(isBoy! ? Icons.face : Icons.face_3),
            onPressed: () {
              // Funcionalidad futura: cambio de género
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: emociones.length,
        itemBuilder: (context, index) {
          final key = emociones.keys.elementAt(index);
          final emocion = emociones[key]!;
          return _buildEmocionCard(
            context,
            key,
            emocion['emoji'] as String,
            emocion['color'] as Color,
            emocion['imagen'] as String,
          );
        },
      ),
    );
  }

  Widget _buildEmocionCard(
    BuildContext context,
    String nombre,
    String emoji,
    Color color,
    String imagenPath,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _speak(nombre);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar imagen si existe, sino mostrar emoji
            imagenPath.isNotEmpty
                ? Image.asset(
                  imagenPath,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(emoji, style: const TextStyle(fontSize: 50));
                  },
                )
                : Text(emoji, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
