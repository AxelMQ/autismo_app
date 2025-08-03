import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';

class FrutasScreen extends StatelessWidget {
  final String colorNombre;
  final Color color;

  const FrutasScreen({super.key, required this.colorNombre, required this.color});

  List<Map<String, String>> _getFrutasPorColor(String colorNombre) {
    switch (colorNombre) {
      case 'Amarillo':
        return [
          {
            'nombre': 'Maracuyá',
            'imagen': 'assets/frutas/amarrillo/maracuya.png',
          },
          {'nombre': 'Choclo', 'imagen': 'assets/frutas/amarrillo/choclo.png'},
          {'nombre': 'Banana', 'imagen': 'assets/frutas/amarrillo/banana.png'},
          {'nombre': 'Piña', 'imagen': 'assets/frutas/amarrillo/piña.png'},
        ];
      case 'Naranja':
        return [
          {
            'nombre': 'Mandarina',
            'imagen': 'assets/frutas/naranja/mandarina.png',
          },
          {'nombre': 'Zapallo', 'imagen': 'assets/frutas/naranja/zapallo.png'},
          {
            'nombre': 'Zanahoria',
            'imagen': 'assets/frutas/naranja/zanahoria.png',
          },
          {'nombre': 'Papaya', 'imagen': 'assets/frutas/naranja/papaya.png'},
        ];
      case 'Rojo':
        return [
          {'nombre': 'Cereza', 'imagen': 'assets/frutas/rojo/cereza.png'},
          {'nombre': 'Fresa', 'imagen': 'assets/frutas/rojo/fresa.png'},
          {'nombre': 'Sandía', 'imagen': 'assets/frutas/rojo/sandia.png'},
          {'nombre': 'Tomate', 'imagen': 'assets/frutas/rojo/tomate.png'},
          {'nombre': 'Manzana', 'imagen': 'assets/frutas/rojo/manzana.png'},
        ];
      case 'Verde':
        return [
          {
            'nombre': 'Manzana Verde',
            'imagen': 'assets/frutas/verde/manzana.png',
          },
          {'nombre': 'Apio', 'imagen': 'assets/frutas/verde/apio.png'},
          {'nombre': 'Arveja', 'imagen': 'assets/frutas/verde/arveja.png'},
          {'nombre': 'Brócoli', 'imagen': 'assets/frutas/verde/brocoli.png'},
          {'nombre': 'Lechuga', 'imagen': 'assets/frutas/verde/lechuga.png'},
          {'nombre': 'Pepino', 'imagen': 'assets/frutas/verde/pepino.png'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final frutas = _getFrutasPorColor(colorNombre);

    return Scaffold(
      appBar: AppBar(
        title: Text('Frutas $colorNombre'),
        backgroundColor: color,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 1000),
          child: GridView.builder(
            shrinkWrap: true,
            physics:
                frutas.length <= 4
                    ? const NeverScrollableScrollPhysics()
                    : null,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: frutas.length,
            itemBuilder: (context, index) {
              final fruta = frutas[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    TtsService.speak(fruta['nombre']!);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            fruta['imagen']!,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          fruta['nombre']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
