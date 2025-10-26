import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmocionesScreen extends StatefulWidget {
  const EmocionesScreen({super.key});

  @override
  State<EmocionesScreen> createState() => _EmocionesScreenState();
}

class _EmocionesScreenState extends State<EmocionesScreen> with TickerProviderStateMixin {
  bool? isBoy; // true = niño, false = niña
  final FlutterTts flutterTts = FlutterTts();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cargarGeneroGuardado();
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
    TtsService.stop(); // Liberar el TTS al cerrar la pantalla
    super.dispose();
  }

  Future<void> _cargarGeneroGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final genero = prefs.getString('genero_nino');
    setState(() {
      isBoy = (genero == 'niño'); // true si es niño, false si es niña
    });
  }

  final Map<String, Map<String, dynamic>> emocionesBoy = {
    'Feliz': {
      'emoji': '😊',
      'color': Colors.yellow,
      'imagen': 'assets/emociones/boy_feliz.png',
    },
    'Miedo': {
      'emoji': '😢',
      'color': Colors.blue,
      'imagen': 'assets/emociones/boy_miedoso.png',
    },
    'Enojado': {
      'emoji': '😠',
      'color': Colors.red,
      'imagen': 'assets/emociones/boy_enojado.png',
    },
    'Sorprendido': {
      'emoji': '😲',
      'color': Colors.orange,
      'imagen': 'assets/emociones/boy_sorprendido.png',
    },
    'Tranquilo': {
      'emoji': '😨',
      'color': Colors.purple,
      'imagen': 'assets/emociones/boy_tranquilo.png',
    },
    'Triste': {
      'emoji': '😴',
      'color': Colors.grey,
      'imagen': 'assets/emociones/boy_triste.png',
    },
  };

  final Map<String, Map<String, dynamic>> emocionesGirl = {
    'Feliz': {
      'emoji': '😊',
      'color': Colors.green,
      'imagen': 'assets/emociones/girl_feliz.png',
    },
    'Triste': {
      'emoji': '😢',
      'color': Colors.blue,
      'imagen': 'assets/emociones/girl_triste.png',
    },
    'Enojada': {
      'emoji': '😠',
      'color': Colors.red,
      'imagen': 'assets/emociones/girl_enojada.png',
    },
    'Sorprendida': {
      'emoji': '😲',
      'color': const Color.fromARGB(255, 53, 52, 51),
      'imagen': 'assets/emociones/girl_sorprendida.png',
    },
    'Asustada': {
      'emoji': '😨',
      'color': Colors.purple,
      'imagen': 'assets/emociones/girl_miedosa.png',
    },
    'Tranquila': {
      'emoji': '😴',
      'color': Colors.grey,
      'imagen': 'assets/emociones/girl_tranquila.png',
    },
  };


  Future<void> _speak(String text) async {
    try {
      // Feedback háptico al tocar emoción
      HapticFeedback.lightImpact();
      await TtsService.speak(text);
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isBoy == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final emociones = isBoy! ? emocionesBoy : emocionesGirl;

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
                'Emociones',
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
          // Botón de selección niño/niña
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: IconButton(
                  icon: Icon(
                    isBoy! ? Icons.face : Icons.face_3,
                    color: const Color(0xFF2C3E50),
                  ),
                  onPressed: () {
                    // Funcionalidad futura: cambio de género
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
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildResponsiveGrid(context, emociones),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, Map<String, Map<String, dynamic>> emociones) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Responsive design para diferentes tipos de pantallas
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400 && screenWidth <= 600;
    
    // Configuración del grid según dispositivo
    int crossAxisCount;
    double childAspectRatio;
    double spacing;
    
    if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
      spacing = 20;
    } else if (isLargePhone) {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
      spacing = 18;
    } else if (isSmallPhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
      spacing = 12;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.0;
      spacing = 16;
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: emociones.length,
      itemBuilder: (context, index) {
        final key = emociones.keys.elementAt(index);
        final emocion = emociones[key]!;
        return _buildEmocionCard(
          context,
          key,
          emocion['emoji'] as String,
          emocion['color'] as Color,
          emocion['imagen'] as String,
          index,
        );
      },
    );
  }

  Widget _buildEmocionCard(
    BuildContext context,
    String nombre,
    String emoji,
    Color color,
    String imagenPath,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 50; // Animación escalonada más rápida
        final animationValue = Curves.easeInOut.transform(
          (_animationController.value - (delay / 1000)).clamp(0.0, 1.0),
        );
        
        // Asegurar que todas las emociones alcancen opacidad completa
        final finalOpacity = animationValue > 0.8 ? 1.0 : animationValue;
        
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: finalOpacity,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(24),
              shadowColor: color.withValues(alpha: 0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _speak(nombre),
                child: Container(
                  decoration: BoxDecoration(
                    color: color, // Color sólido sin gradiente
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Imagen o emoji con animación
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: imagenPath.isNotEmpty
                            ? Image.asset(
                              imagenPath,
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 50),
                                );
                              },
                            )
                            : Text(
                              emoji,
                              style: const TextStyle(fontSize: 50),
                            ),
                      ),
                      // Texto con sombra
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 18,
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Indicador de interacción
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
