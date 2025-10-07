import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MomentoChart extends StatelessWidget {
  final String titulo;
  final Map<String, int> conteo;
  final Color color;

  const MomentoChart({
    super.key,
    required this.titulo,
    required this.conteo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (conteo.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.hourglass_empty, size: 50, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                "No registraste actividades",
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    final actividades = conteo.keys.toList();
    final valores = conteo.values.toList();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height:
                      constraints.maxHeight > 250
                          ? 250
                          : constraints.maxHeight * 0.6,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY:
                          (valores.reduce((a, b) => a > b ? a : b)).toDouble() +
                          1,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < actividades.length) {
                                return Transform.rotate(
                                  angle: -0.7,
                                  child: Text(
                                    actividades[index],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(actividades.length, (index) {
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: valores[index].toDouble(),
                              color: color,
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
