import 'package:autismo_app/models/actividad.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:autismo_app/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback

class MomentoDetalleScreen extends StatefulWidget {
  final String genero;
  final String momento;
  final Map<String, List<Actividad>> actividades;
  final List<String> seleccionadas; 

  const MomentoDetalleScreen({
    super.key,
    required this.momento,
    required this.genero,
    required this.actividades,
    required this.seleccionadas,
  });

  @override
  State<MomentoDetalleScreen> createState() => _MomentoDetalleScreenState();
}

class _MomentoDetalleScreenState extends State<MomentoDetalleScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<String> seleccionadas;

  @override
  void initState() {
    super.initState();
    seleccionadas = List.from(widget.seleccionadas);
    _setupAnimations();
    _speakTextoInicial();
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

  Future<void> _speakTextoInicial() async {
    await TtsService.speak("¿Qué hiciste en la ${widget.momento}?");
  }

  void seleccionarImagen(Actividad actividad) {
    if (!seleccionadas.contains(actividad.ruta) && seleccionadas.length < 4) {
      HapticFeedback.lightImpact(); // Feedback háptico al seleccionar
      
      setState(() {
        seleccionadas.add(actividad.ruta);
      });
      
      // 🔊 Reproducir audio
      TtsService.speak(actividad.texto);
      
      // 💾 Guardar actividad en persistencia
      DataService.guardarActividad(
        momento: widget.momento,
        ruta: actividad.ruta,
        texto: actividad.texto,
      );
    }
  }

  int? obtenerOrden(String ruta) {
    if (seleccionadas.contains(ruta)) {
      return seleccionadas.indexOf(ruta) + 1;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadesDelMomento = widget.actividades[widget.momento]!;

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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.momento.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 1.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    widget.genero == 'niño' ? Icons.face : Icons.face_3,
                    size: 28,
                    color: const Color(0xFF2C3E50),
                  ),
                ],
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: () {
            Navigator.pop(context, seleccionadas);
          },
        ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Título con animación
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
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
                              child: Text(
                                '¿Qué hiciste en la ${widget.momento}?',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      // Grid de actividades con animaciones
                      _buildActividadesGrid(actividadesDelMomento),
                      const SizedBox(height: 20),
                      // Indicador de progreso mejorado
                      if (seleccionadas.isNotEmpty)
                        _buildProgresoIndicator(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActividadesGrid(List<Actividad> actividades) {
    return Row(
      children: [
        // Columna de imágenes de actividades
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: actividades.asMap().entries.map((entry) {
              final index = entry.key;
              final actividad = entry.value;
              return _buildActividadCard(actividad, index);
            }).toList(),
          ),
        ),
        // Columna de orden numérico
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: actividades.asMap().entries.map((entry) {
              final index = entry.key;
              final actividad = entry.value;
              return _buildNumeroCard(actividad, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActividadCard(Actividad actividad, int index) {
    final yaSeleccionada = seleccionadas.contains(actividad.ruta);
    
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20), // Más flexible que circular
                onTap: () => seleccionarImagen(actividad),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: yaSeleccionada 
                        ? [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.2),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(0xFF2C3E50).withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                    border: yaSeleccionada 
                        ? Border.all(
                            color: Colors.green.withValues(alpha: 0.8),
                            width: 4,
                          )
                        : Border.all(
                            color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
                            width: 2,
                          ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      actividad.ruta,
                      height: 130,
                      width: 130,
                      fit: BoxFit.contain, // Para PNGs sin fondo
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
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

  Widget _buildNumeroCard(Actividad actividad, int index) {
    final orden = obtenerOrden(actividad.ruta);
    
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 130,
                width: 130,
                child: orden == null
                    ? const SizedBox()
                    : Image.asset(
                        'assets/hacer/numeros/$orden.png',
                        fit: BoxFit.contain, // Para PNGs sin fondo
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '$orden',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
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

  Widget _buildProgresoIndicator() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            shadowColor: Colors.green.withValues(alpha: 0.3),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${seleccionadas.length} actividad${seleccionadas.length == 1 ? '' : 'es'} seleccionada${seleccionadas.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
