// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:autismo_app/screens/frutas_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColoresScreen extends StatefulWidget {
  const ColoresScreen({super.key});

  @override
  State<ColoresScreen> createState() => _ColoresScreenState();
}

class _ColoresScreenState extends State<ColoresScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> colores = [
    {'nombre': 'Amarillo', 'color': Colors.yellow},
    {'nombre': 'Naranja', 'color': Colors.orange},
    {'nombre': 'Rojo', 'color': Colors.red},
    {'nombre': 'Verde', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
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
    super.dispose();
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
                'Colores',
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
                  child: _buildResponsiveGrid(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
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
      crossAxisCount = 2;
      childAspectRatio = 1.0;
      spacing = 20;
    } else if (isLargePhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.9;
      spacing = 18;
    } else if (isSmallPhone) {
      crossAxisCount = 2;
      childAspectRatio = 0.8;
      spacing = 12;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
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
      itemCount: colores.length,
      itemBuilder: (context, index) {
        final colorData = colores[index];
        return _buildColorCircle(
          context,
          colorData['nombre'],
          colorData['color'],
          index,
        );
      },
    );
  }

  Widget _buildColorCircle(BuildContext context, String nombre, Color color, int index) {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double diameter = constraints.maxWidth * 0.8;
                return InkWell(
                  borderRadius: BorderRadius.circular(100),
                    onTap: () async {
                      // Feedback háptico al tocar color
                      HapticFeedback.lightImpact();
                      await TtsService.speak(nombre);
                      
                      // Transición suave a FrutasScreen
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              FrutasScreen(colorNombre: nombre, color: color),
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
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: diameter,
                          height: diameter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color, // Color sólido sin gradiente
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 1.2,
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
                      ],
                    ),
                  );
              },
            ),
          ),
        );
      },
    );
  }
}
