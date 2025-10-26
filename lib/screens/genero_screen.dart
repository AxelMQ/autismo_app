import 'package:autismo_app/screens/home_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> with TickerProviderStateMixin {
  String? generoGuardado;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _cargarGenero();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Consistente con HomeScreen
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
    super.dispose();
  }

  Future<void> _cargarGenero() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      generoGuardado = prefs.getString('genero_nino');
    });
  }

  Future<void> _guardarGenero(String genero) async {
    // Feedback háptico al seleccionar
    HapticFeedback.lightImpact();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('genero_nino', genero);

    // Obtenenemos la 3ra voz del género seleccionado
    final voces = TtsService.vocesSeleccionadas[genero];
    if (voces != null && voces.length >= 3) {
      final vozPreSeleccionada = voces[2];

      // Guardamos la voz seleccionada
      await prefs.setString('voz_seleccionada', vozPreSeleccionada['name']!);
      await prefs.setString('voz_locale', vozPreSeleccionada['locale']!);
      await TtsService.setVoiceByData(vozPreSeleccionada);
    } else {
      debugPrint("⚠️ No hay voces disponibles para el género: $genero");
    }

    if (mounted) {
      // Transición suave y predecible
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Responsive design para diferentes tipos de pantallas
    final isTablet = screenWidth > 600;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400 && screenWidth <= 600;
    
    // Tamaños adaptativos para diferentes dispositivos
    Size cardSize;
    double fontSize;
    double iconSize;
    
    if (isTablet) {
      // Tablets
      cardSize = Size(180, 220);
      fontSize = 20;
      iconSize = 60;
    } else if (isLargePhone) {
      // Teléfonos grandes (iPhone Plus, Galaxy Note, etc.)
      cardSize = Size(140, 170);
      fontSize = 18;
      iconSize = 50;
    } else if (isSmallPhone) {
      // Teléfonos pequeños (iPhone SE, etc.)
      cardSize = Size(100, 130);
      fontSize = 16;
      iconSize = 40;
    } else {
      // Teléfonos estándar
      cardSize = Size(120, 150);
      fontSize = 18;
      iconSize = 50;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Consistente con HomeScreen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                "¿Quién eres?",
                style: TextStyle(
                  fontSize: isTablet ? 32 : (isSmallPhone ? 24 : 28),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                                "Selecciona tu género:",
                                style: TextStyle(
                                  fontSize: isTablet ? 26 : (isSmallPhone ? 18 : 22),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Botones de género con animaciones escalonadas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildGeneroCard(
                            context,
                            genero: 'niño',
                            color: const Color(0xFF3498DB),
                            icon: Icons.face,
                            size: cardSize,
                            fontSize: fontSize,
                            iconSize: iconSize,
                            delay: 0,
                          ),
                          _buildGeneroCard(
                            context,
                            genero: 'niña',
                            color: const Color(0xFFE91E63),
                            icon: Icons.face_3,
                            size: cardSize,
                            fontSize: fontSize,
                            iconSize: iconSize,
                            delay: 200,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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

  Widget _buildGeneroCard(
    BuildContext context, {
    required String genero,
    required Color color,
    required IconData icon,
    required Size size,
    required double fontSize,
    required double iconSize,
    int delay = 0,
  }) {
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
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                shadowColor: color.withValues(alpha: 0.3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _guardarGenero(genero),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Icono con sombra
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: iconSize,
                            color: Colors.white,
                          ),
                        ),
                        // Texto con sombra
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            genero.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: const [
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
                          width: 8,
                          height: 8,
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
          ),
        );
      },
    );
  }
}
