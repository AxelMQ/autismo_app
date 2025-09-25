// ignore_for_file: deprecated_member_use

import 'package:autismo_app/data/actividad_data.dart';
import 'package:autismo_app/models/actividad.dart';
import 'package:autismo_app/screens/momento_detalle_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:autismo_app/widgets/estadistica_chart.dart';
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

  void seleccionarImagen(String ruta) {
    if (momentoSeleccionado == null || genero == null) return;

    final momento = momentoSeleccionado!.toLowerCase();
    final actividades =
        genero == 'niño' ? actividadesBoy[momento]! : actividadesGirl[momento]!;

    final actividad = actividades.firstWhere(
      (a) => a.ruta == ruta,
      orElse: () => Actividad(texto: 'Desconocido', ruta: ruta),
    );

    seleccionPorDia.putIfAbsent(momento, () => []);

    if (!seleccionPorDia[momento]!.contains(ruta) &&
        seleccionPorDia[momento]!.length < 4) {
      setState(() {
        seleccionPorDia[momento]!.add(ruta);
      });

      TtsService.speak(actividad.texto); // 🔊 ahora usamos el modelo
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
              genero == 'niño'
                  ? actividadesBoy[momento.toLowerCase()]!
                  : actividadesGirl[momento.toLowerCase()]!;

          final seleccionadas = seleccionPorDia[momento.toLowerCase()] ?? [];

          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => MomentoDetalleScreen(
                    genero: genero!,
                    momento: momento.toLowerCase(),
                    actividades: {momento.toLowerCase(): actividades},
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.insights),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            isScrollControlled: true,
            builder:
                (_) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        "📊 Estadísticas del día",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EstadisticasChart(
                        seleccionPorDia: seleccionPorDia,
                        actividadesBoy: actividadesBoy,
                        actividadesGirl: actividadesGirl,
                        genero: genero ?? 'niño', // fallback por si es null
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }
}
