// ignore_for_file: deprecated_member_use

import 'package:autismo_app/data/actividad_data.dart';
import 'package:autismo_app/models/actividad.dart';
import 'package:autismo_app/screens/momento_detalle_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:autismo_app/widgets/estadistica_chart.dart';
import 'package:autismo_app/widgets/estadistica_semanal_chart.dart';
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

  // Simula una semana (Lunes..Domingo) usando tus actividades existentes.
  // No modifica seleccionPorDia; es solo datos de prueba.
  Map<String, Map<String, List<String>>> _simularSemana() {
    final days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    final momentos = ['mañana', 'tarde', 'noche'];

    final actividadesMap = genero == 'niño' ? actividadesBoy : actividadesGirl;

    final Map<String, Map<String, List<String>>> semana = {};

    for (var di = 0; di < days.length; di++) {
      final dayName = days[di];
      semana[dayName] = {};
      for (var m in momentos) {
        final lista = actividadesMap[m] ?? [];
        final rutas = <String>[];

        // patrón determinista para la demo: 1..3 actividades según el índice del día
        final pickCount = 1 + (di % 3); // 1,2,3 repetido
        for (var i = 0; i < pickCount; i++) {
          if (lista.isEmpty) break;
          final idx = (di + i) % lista.length;
          rutas.add(lista[idx].ruta);
        }

        semana[dayName]![m] = rutas;
      }
    }

    // opcional: inyectar lo que el usuario seleccionó hoy (si hay) en Lunes para que la demo se parezca a lo real
    if (seleccionPorDia.isNotEmpty) {
      // guardo la "mañana" del primer día con los seleccionados actuales (solo como ejemplo)
      final firstDay = days[0];
      semana[firstDay]!['mañana'] = List.from(seleccionPorDia['mañana'] ?? []);
    }

    return semana;
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
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              return FractionallySizedBox(
                heightFactor: 0.78, // 78% de la pantalla
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
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
                        const TabBar(
                          labelColor: Colors.black,
                          tabs: [Tab(text: 'Hoy'), Tab(text: 'Semana')],
                        ),
                        const SizedBox(height: 8),

                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SizedBox(
                                height: constraints.maxHeight,
                                child: TabBarView(
                                  children: [
                                    // Tab 1: gráfico diario
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: EstadisticasChart(
                                          seleccionPorDia: seleccionPorDia,
                                          actividadesBoy: actividadesBoy,
                                          actividadesGirl: actividadesGirl,
                                          genero: genero ?? 'niño',
                                        ),
                                      ),
                                    ),

                                    // Tab 2: gráfico semanal
                                    SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: EstadisticaSemanalChart(
                                          semana: _simularSemana(),
                                          actividadesBoy: actividadesBoy,
                                          actividadesGirl: actividadesGirl,
                                          genero: genero ?? 'niño',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
