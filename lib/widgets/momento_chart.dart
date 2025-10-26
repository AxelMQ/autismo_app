import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback

class MomentoChart extends StatefulWidget {
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
  State<MomentoChart> createState() => _MomentoChartState();
}

class _MomentoChartState extends State<MomentoChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Más tiempo para animación de barras
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _barAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conteo.isEmpty) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(20),
                shadowColor: widget.color.withValues(alpha: 0.3),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.1),
                        widget.color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.titulo,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Icon(
                        Icons.hourglass_empty,
                        size: 60,
                        color: widget.color.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No registraste actividades",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: widget.color.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    final actividades = widget.conteo.keys.toList();
    final valores = widget.conteo.values.toList();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              shadowColor: widget.color.withValues(alpha: 0.3),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco simple
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.2), // Borde más sutil
                      width: 1,
                    ),
                  ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Título con texto de ayuda
                        Column(
                          children: [
                            Text(
                              widget.titulo,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50), // Color neutro
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Toca las barras para ver detalles',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF2C3E50).withValues(alpha: 0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Gráfico mejorado con altura flexible
                        Flexible(
                          child: SizedBox(
                            height: 250, // Altura aumentada para texto completo
                            child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (valores.reduce((a, b) => a > b ? a : b)).toDouble() + 1,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${actividades[group.x]}:\n${rod.toY.toInt()} veces',
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  if (response?.spot != null) {
                                    HapticFeedback.lightImpact(); // Feedback háptico al tocar
                                  }
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 16, // Más grande para mejor legibilidad
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2C3E50), // Color más contrastante
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < actividades.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0), // Más espacio vertical
                                          child: Transform.rotate(
                                            angle: -0.5,
                                            child: Text(
                                              actividades[index],
                                              style: const TextStyle(
                                                fontSize: 14, // Reducido para que quepa mejor
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C3E50), // Color más contrastante
                                              ),
                                            ),
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
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 1,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              barGroups: List.generate(actividades.length, (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: valores[index].toDouble() * _barAnimation.value,
                                      color: widget.color,
                                      width: 32, // Más ancho para mejor toque
                                      borderRadius: BorderRadius.circular(8),
                                      // Sin gradiente para menos saturación visual
                                    ),
                                  ],
                                  showingTooltipIndicators: [], // Sin tooltips por defecto
                                );
                              }),
                            ),
                          ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
