import 'package:autismo_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
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

class _EstadisticaRealChartState extends State<EstadisticaRealChart> with TickerProviderStateMixin {
  Map<String, int> estadisticasManana = {};
  Map<String, int> estadisticasTarde = {};
  Map<String, int> estadisticasNoche = {};
  bool cargando = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _cargarEstadisticas();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Consistente con otras pantallas
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
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

      // Mostrar feedback de actualización exitosa
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Estadísticas actualizadas'),
            backgroundColor: const Color(0xFF2C3E50),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error cargando estadisticas: $e');
      setState(() {
        cargando = false;
      });

      // Mostrar error si falla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al actualizar estadísticas'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Center(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF2C3E50).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cargando estadísticas...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Botón de actualizar simple
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF2C3E50).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Toca las barras para ver detalles',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF2C3E50).withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _cargarEstadisticas();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C3E50),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Graficos de estadisticas reales con animaciones
                  _buildAnimatedChart(
                    'Mañana',
                    estadisticasManana,
                    const Color(0xFFFF9500), // Naranja más vibrante
                    0,
                  ),
                  _buildAnimatedChart(
                    'Tarde',
                    estadisticasTarde,
                    const Color(0xFF007AFF), // Azul más vibrante
                    100,
                  ),
                  _buildAnimatedChart(
                    'Noche',
                    estadisticasNoche,
                    const Color(0xFF5856D6), // Púrpura más vibrante
                    200,
                  ),
                  
                  // Informacion adicional mejorada
                  if (estadisticasManana.isEmpty && estadisticasTarde.isEmpty && estadisticasNoche.isEmpty)
                    _buildEmptyState(),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }

  Widget _buildAnimatedChart(String titulo, Map<String, int> conteo, Color color, int delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeInOut.transform(
          (_animationController.value - (delay / 1000)).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: MomentoChart(
              titulo: titulo,
              conteo: conteo,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2C3E50).withValues(alpha: 0.1),
                  const Color(0xFF3498DB).withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2C3E50).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 60,
                  color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay actividades registradas hoy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona algunas actividades para ver tus estadísticas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
