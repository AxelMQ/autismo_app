// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FamiliaScreen extends StatefulWidget {
  const FamiliaScreen({super.key});

  @override
  State<FamiliaScreen> createState() => _FamiliaScreenState();
}

class _FamiliaScreenState extends State<FamiliaScreen> {
  final FlutterTts flutterTts = FlutterTts();

  final List<Map<String, String>> familia = const [
    {'nombre': 'Abuelo', 'img': 'assets/familia/abuelo.png'},
    {'nombre': 'Abuela', 'img': 'assets/familia/abuela.png'},
    {'nombre': 'Papá', 'img': 'assets/familia/papa.png'},
    {'nombre': 'Mamá', 'img': 'assets/familia/mama.png'},
    {'nombre': 'Hermano', 'img': 'assets/familia/hermano.png'},
    {'nombre': 'Hermana', 'img': 'assets/familia/hermana.png'},
  ];

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 800),
          child: GridView.builder(
            shrinkWrap: true,
            physics:
                familia.length <= 4
                    ? const NeverScrollableScrollPhysics()
                    : null,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 5,
              childAspectRatio: 0.85,
            ),
            itemCount: familia.length,
            itemBuilder: (context, index) {
              final miembro = familia[index];
              return _buildFamiliaCard(
                context,
                miembro['nombre']!,
                miembro['img']!,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFamiliaCard(
    BuildContext context,
    String nombre,
    String imgPath,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seleccionaste: $nombre'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await _speak(nombre);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seleccionaste: $nombre'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.black26, width: 3),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(imgPath, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
