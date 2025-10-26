// ignore_for_file: deprecated_member_use

import 'package:autismo_app/data/actividad_data.dart';
import 'package:autismo_app/models/actividad.dart';
import 'package:autismo_app/screens/momento_detalle_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:autismo_app/services/data_service.dart';
import 'package:autismo_app/widgets/estadistica_semanal_chart.dart';
import 'package:autismo_app/widgets/estadistica_real_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:shared_preferences/shared_preferences.dart';

class HacerScreen extends StatefulWidget {
  const HacerScreen({super.key});

  @override
  State<HacerScreen> createState() => _HacerScreenState();
}

class _HacerScreenState extends State<HacerScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String? genero;
  String? momentoSeleccionado;
  Map<String, List<String>> seleccionPorDia = {};

  @override
  void initState() {
    super.initState();
    _cargarGenero();
    _setupAnimations();
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

  @override
  void dispose() {
    _animationController.dispose();
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

      // 🔊 Reproducir audio
      TtsService.speak(actividad.texto);
      
      // 💾 Guardar actividad en persistencia
      DataService.guardarActividad(
        momento: momento,
        ruta: ruta,
        texto: actividad.texto,
      );
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

  Widget _buildMomentoDelDia(String momento, IconData icon, Color color, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 100; // Animación escalonada
        final animationValue = Curves.easeInOut.transform(
          (_animationController.value - (delay / 1000)).clamp(0.0, 1.0),
        );
        
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Material(
              elevation: seleccionPorDia[momento.toLowerCase()]?.isNotEmpty == true ? 12 : 8,
              borderRadius: BorderRadius.circular(24),
              shadowColor: color.withValues(alpha: 0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  HapticFeedback.lightImpact(); // Feedback háptico al tocar momento
                  if (genero == null) return;

                  final actividades =
                      genero == 'niño'
                          ? actividadesBoy[momento.toLowerCase()]!
                          : actividadesGirl[momento.toLowerCase()]!;

                  final seleccionadas = seleccionPorDia[momento.toLowerCase()] ?? [];

                  final resultado = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          MomentoDetalleScreen(
                            genero: genero!,
                            momento: momento.toLowerCase(),
                            actividades: {momento.toLowerCase(): actividades},
                            seleccionadas: seleccionadas,
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );

                  if (resultado != null && resultado is List<String>) {
                    setState(() {
                      seleccionPorDia[momento.toLowerCase()] = resultado;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: seleccionPorDia[momento.toLowerCase()]?.isNotEmpty == true 
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.2),
                      width: seleccionPorDia[momento.toLowerCase()]?.isNotEmpty == true ? 3 : 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Icono del momento
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Texto del momento
                        Expanded(
                          child: Text(
                            momento,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Indicador de progreso y navegación
                        Row(
                          children: [
                            // Indicador de progreso
                            if (seleccionPorDia[momento.toLowerCase()]?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${seleccionPorDia[momento.toLowerCase()]!.length}/4',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            // Indicador de navegación
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Consistente con otras pantallas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Hacer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: IconButton(
                  icon: Icon(
                    genero == 'niño' ? Icons.face : Icons.face_3,
                    color: const Color(0xFF2C3E50),
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact(); // Feedback háptico al cambiar género
                    final prefs = await SharedPreferences.getInstance();
                    final nuevoGenero = genero == 'niño' ? 'niña' : 'niño';

                    await prefs.setString('genero_nino', nuevoGenero);

                    setState(() {
                      genero = nuevoGenero;
                    });
                  },
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildMomentoDelDia("Mañana", Icons.wb_sunny, Colors.orange, 0),
                      const SizedBox(height: 16),
                      _buildMomentoDelDia("Tarde", Icons.cloud, Colors.blue, 1),
                      const SizedBox(height: 16),
                      _buildMomentoDelDia("Noche", Icons.nights_stay, Colors.indigo, 2),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF2C3E50),
              child: const Icon(Icons.insights, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact(); // Feedback háptico al tocar estadísticas
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
                                          // Tab 1: estadísticas reales del día
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: EstadisticaRealChart(
                                                genero: genero ?? 'niño',
                                              ),
                                            ),
                                          ),

                                          // Tab 2: gráfico semanal (mantenemos simulado por ahora)
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
        },
      ),
    );
  }
}
