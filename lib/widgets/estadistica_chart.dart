import 'package:autismo_app/models/actividad.dart';
import 'package:flutter/material.dart';
import 'momento_chart.dart';

class EstadisticasChart extends StatelessWidget {
  final Map<String, List<String>> seleccionPorDia;
  final Map<String, List<Actividad>> actividadesBoy;
  final Map<String, List<Actividad>> actividadesGirl;
  final String genero;

  const EstadisticasChart({
    super.key,
    required this.seleccionPorDia,
    required this.actividadesBoy,
    required this.actividadesGirl,
    required this.genero,
  });

  Map<String, int> _conteoPorMomento(String momento) {
    final conteo = <String, int>{};
    final rutas = seleccionPorDia[momento.toLowerCase()] ?? [];

    final actividades =
        genero == 'niño'
            ? actividadesBoy[momento.toLowerCase()]!
            : actividadesGirl[momento.toLowerCase()]!;

    for (var ruta in rutas) {
      final nombre =
          actividades
              .firstWhere(
                (a) => a.ruta == ruta,
                orElse: () => Actividad(texto: 'Desconocido', ruta: ruta),
              )
              .texto;
      conteo[nombre] = (conteo[nombre] ?? 0) + 1;
    }

    return conteo;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MomentoChart(
            titulo: 'Mañana',
            conteo: _conteoPorMomento('Mañana'),
            color: Colors.orange,
          ),
          MomentoChart(
            titulo: 'Tarde',
            conteo: _conteoPorMomento('Tarde'),
            color: Colors.blue,
          ),
          MomentoChart(
            titulo: 'Noche',
            conteo: _conteoPorMomento('Noche'),
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}
