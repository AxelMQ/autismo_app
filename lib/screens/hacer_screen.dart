// ignore_for_file: deprecated_member_use

import 'package:autismo_app/screens/momento_detalle_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HacerScreen extends StatefulWidget {
  const HacerScreen({super.key});

  @override
  State<HacerScreen> createState() => _HacerScreenState();
}

class _HacerScreenState extends State<HacerScreen> {
  String? genero;
  String? momentoSeleccionado;
  Map<String, List<String>> seleccionPorDia = {};

  @override
  void initState() {
    super.initState();
    _cargarGenero();
  }

  @override
  void dispose() {
    TtsService.stop(); // Detener cualquier reproducción activa
    super.dispose();
  }

  final Map<String, List<String>> textosActividadesBoy = {
    'mañana': ['Me desperté', 'Me vestí', 'Me cepillé los dientes', 'Desayuné'],
    'tarde': ['Almorcé', 'Fui al colegio', 'Hice tarea', 'Jugué'],
    'noche': ['Cené', 'Leí un libro', 'Vi la televisión', 'Me acosté'],
  };

  final Map<String, List<String>> textosActividadesGirl = {
    'mañana': ['Me desperté', 'Me vestí', 'Me cepillé los dientes', 'Desayuné'],
    'tarde': ['Almorcé', 'Fui al colegio', 'Hice tarea', 'Jugué'],
    'noche': ['Cené', 'Leí un libro', 'Vi la televisión', 'Me acosté'],
  };

  final Map<String, List<String>> actividadesBoy = {
    'mañana': [
      'assets/hacer/boy/manana/desperte.png',
      'assets/hacer/boy/manana/vesti.png',
      'assets/hacer/boy/manana/dientes.png',
      'assets/hacer/boy/manana/desayune.png',
    ],
    'tarde': [
      'assets/hacer/boy/tarde/almorce.png',
      'assets/hacer/boy/tarde/colegio.png',
      'assets/hacer/boy/tarde/boy_tarea.png',
      'assets/hacer/boy/tarde/jugue.png',
    ],
    'noche': [
      'assets/hacer/boy/noche/cene.png',
      'assets/hacer/boy/noche/libro.png',
      'assets/hacer/boy/noche/tele.png',
      'assets/hacer/boy/noche/acoste.jpg',
    ],
  };

  final Map<String, List<String>> actividadesGirl = {
    'mañana': [
      'assets/hacer/girl/manana/desperte.png',
      'assets/hacer/girl/manana/vesti.png',
      'assets/hacer/girl/manana/dientes.png',
      'assets/hacer/girl/manana/desayune.png',
    ],
    'tarde': [
      'assets/hacer/girl/tarde/almorce.png',
      'assets/hacer/girl/tarde/colegio.png',
      'assets/hacer/girl/tarde/tarea.png',
      'assets/hacer/girl/tarde/jugue.png',
    ],
    'noche': [
      'assets/hacer/girl/noche/cene.png',
      'assets/hacer/girl/noche/libro.png',
      'assets/hacer/girl/noche/tele.png',
      'assets/hacer/girl/noche/acoste.jpg',
    ],
  };
  void seleccionarImagen(String ruta) {
    if (momentoSeleccionado == null || genero == null) return; // null

    final momento = momentoSeleccionado!.toLowerCase();

    final actividades =
        genero == 'niño' ? actividadesBoy[momento]! : actividadesGirl[momento]!;

    final textos =
        genero == 'niño'
            ? textosActividadesBoy[momento]
            : textosActividadesGirl[momento];

    if (textos == null) return;

    final index = actividades.indexOf(ruta);
    if (index == -1 || index >= textos.length) return;

    final texto = textos[index];

    seleccionPorDia.putIfAbsent(momento, () => []);

    if (!seleccionPorDia[momento]!.contains(ruta) &&
        seleccionPorDia[momento]!.length < 4) {
      setState(() {
        seleccionPorDia[momento]!.add(ruta);
      });

      TtsService.speak(texto); // 🔊 Decir el texto correspondiente
    }
  }

  int? obtenerOrden(String ruta) {
    if (momentoSeleccionado == null) return null;

    final momento = momentoSeleccionado!.toLowerCase();
    final seleccionadas = seleccionPorDia[momento];
    if (seleccionadas != null && seleccionadas.contains(ruta)) {
      return seleccionadas.indexOf(ruta) + 1;
    }
    return null;
  }

  Future<void> _cargarGenero() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      genero = prefs.getString('genero_nino');
    });
  }

  Widget _buildMomentoDelDia(String momento, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          momento,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          if (genero == null) return;

          final actividades =
              genero == 'niño' ? actividadesBoy : actividadesGirl;
          final textos =
              genero == 'niño' ? textosActividadesBoy : textosActividadesGirl;

          final seleccionadas = seleccionPorDia[momento.toLowerCase()] ?? [];

          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MomentoDetalleScreen(
                    genero: genero!,
                    momento: momento.toLowerCase(),
                    actividades: actividades,
                    textos: textos,
                    seleccionadas: seleccionadas,
                  ),
            ),
          );

          if (resultado != null && resultado is List<String>) {
            setState(() {
              seleccionPorDia[momento.toLowerCase()] = resultado;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(genero == 'niño' ? Icons.face : Icons.face_3),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final nuevoGenero = genero == 'niño' ? 'niña' : 'niño';

              await prefs.setString('genero_nino', nuevoGenero);

              setState(() {
                genero = nuevoGenero;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMomentoDelDia("Mañana", Icons.wb_sunny, Colors.orange),
            _buildMomentoDelDia("Tarde", Icons.cloud, Colors.blue),
            _buildMomentoDelDia("Noche", Icons.nights_stay, Colors.indigo),
          ],
        ),
      ),
    );
  }
}
