import 'package:autismo_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'momento_chart.dart';

class EstadisticaRealChart extends StatefulWidget {
  final String genero;

  const EstadisticaRealChart({
    super.key,
    required this.genero,
  });

  @override
  State<EstadisticaRealChart> createState() => _EstadisticaRealChartState();
}

class _EstadisticaRealChartState extends State<EstadisticaRealChart> {
  Map<String, int> estadisticasManana = {};
  Map<String, int> estadisticasTarde = {};
  Map<String, int> estadisticasNoche = {};
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      cargando = true;
    });

    try {
      // Cargar estadisticas reales de cada momento
      final manana = await DataService.obtenerEstadisticasPorMomento('mañana');
      final tarde = await DataService.obtenerEstadisticasPorMomento('tarde');
      final noche = await DataService.obtenerEstadisticasPorMomento('noche');

      setState(() {
        estadisticasManana = manana;
        estadisticasTarde = tarde;
        estadisticasNoche = noche;
        cargando = false;
      });
    } catch (e) {
      print('❌ Error cargando estadisticas: $e');
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando estadísticas...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Botón para recargar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _cargarEstadisticas,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ),
          
          // Graficos de estadisticas reales
          MomentoChart(
            titulo: 'Mañana',
            conteo: estadisticasManana,
            color: Colors.orange,
          ),
          MomentoChart(
            titulo: 'Tarde',
            conteo: estadisticasTarde,
            color: Colors.blue,
          ),
          MomentoChart(
            titulo: 'Noche',
            conteo: estadisticasNoche,
            color: Colors.indigo,
          ),
          
          // Informacion adicional
          if (estadisticasManana.isEmpty && estadisticasTarde.isEmpty && estadisticasNoche.isEmpty)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 50, color: Colors.blue[300]),
                    const SizedBox(height: 8),
                    const Text(
                      'No hay actividades registradas hoy',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecciona algunas actividades para ver tus estadísticas',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
