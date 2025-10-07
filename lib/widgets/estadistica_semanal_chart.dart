import 'package:autismo_app/models/actividad.dart';
import 'package:flutter/material.dart';
import 'momento_chart.dart';

typedef OnActividadSeleccionada = void Function(String dia, String momento, String texto);

class EstadisticaSemanalChart extends StatefulWidget {
  final Map<String, Map<String, List<String>>> semana; // 'Lunes' -> {'mañana': [rutas], ...}
  final Map<String, List<Actividad>> actividadesBoy;
  final Map<String, List<Actividad>> actividadesGirl;
  final String genero;

  const EstadisticaSemanalChart({
    super.key,
    required this.semana,
    required this.actividadesBoy,
    required this.actividadesGirl,
    required this.genero,
  });

  @override
  State<EstadisticaSemanalChart> createState() => _EstadisticaSemanalChartState();
}

class _EstadisticaSemanalChartState extends State<EstadisticaSemanalChart> {
  late Map<String, int> daily; // conteo por día
  late Map<String, int> topActs; // top actividades

  @override
  void initState() {
    super.initState();
    _calcularConteos();
  }

  void _calcularConteos() {
    daily = {};
    topActs = {};

    widget.semana.forEach((day, momentos) {
      int total = 0;
      momentos.forEach((momento, rutas) {
        total += rutas.length;

        final actividadesMap = widget.genero == 'niño' ? widget.actividadesBoy : widget.actividadesGirl;
        for (var ruta in rutas) {
          final texto = actividadesMap[momento]!
                  .firstWhere((a) => a.ruta == ruta, orElse: () => Actividad(texto: 'Desconocido', ruta: ruta))
                  .texto;
          topActs[texto] = (topActs[texto] ?? 0) + 1;
        }
      });
      daily[day] = total;
    });

    // ordenar topActivities y tomar top 8
    final sorted = topActs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    topActs = {for (var i = 0; i < sorted.length && i < 8; i++) sorted[i].key: sorted[i].value};
  }

  // Función para incrementar el conteo de un día y actividad
  void incrementarActividad(String dia, String momento, String texto) {
    setState(() {
      daily[dia] = (daily[dia] ?? 0) + 1;
      topActs[texto] = (topActs[texto] ?? 0) + 1;

      // mantener solo top 8
      final sorted = topActs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      topActs = {for (var i = 0; i < sorted.length && i < 8; i++) sorted[i].key: sorted[i].value};
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Resumen semanal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: 240,
              child: MomentoChart(
                titulo: 'Actividades por día',
                conteo: daily,
                color: Colors.teal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: SizedBox(
              height: 240,
              child: MomentoChart(
                titulo: 'Actividades más frecuentes (semana)',
                conteo: topActs,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
