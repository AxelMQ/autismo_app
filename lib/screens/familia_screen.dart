// ignore_for_file: use_build_context_synchronously

import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback

class FamiliaScreen extends StatefulWidget {
  const FamiliaScreen({super.key});

  @override
  State<FamiliaScreen> createState() => _FamiliaScreenState();
}

class _FamiliaScreenState extends State<FamiliaScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> familia = const [
    {'nombre': 'Abuelo', 'img': 'assets/familia/abuelo.png'},
    {'nombre': 'Abuela', 'img': 'assets/familia/abuela.png'},
    {'nombre': 'Papá', 'img': 'assets/familia/papa.png'},
    {'nombre': 'Mamá', 'img': 'assets/familia/mama.png'},
    {'nombre': 'Hermano', 'img': 'assets/familia/hermano.png'},
    {'nombre': 'Hermana', 'img': 'assets/familia/hermana.png'},
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
    TtsService.stop();
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
                'Familia',
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
      crossAxisCount = 3;
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
      itemCount: familia.length,
      itemBuilder: (context, index) {
        final miembro = familia[index];
        return _buildFamiliaCard(
          context,
          miembro['nombre']!,
          miembro['img']!,
          index,
        );
      },
    );
  }

  Widget _buildFamiliaCard(
    BuildContext context,
    String nombre,
    String imgPath,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 50; // Animación escalonada más rápida
        final animationValue = Curves.easeInOut.transform(
          (_animationController.value - (delay / 1000)).clamp(0.0, 1.0),
        );
        
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: InkWell(
              borderRadius: BorderRadius.circular(100), // Circular para mejor feedback
              splashColor: const Color(0xFF2C3E50).withValues(alpha: 0.1), // Efecto de toque sutil
              highlightColor: const Color(0xFF2C3E50).withValues(alpha: 0.05), // Efecto de highlight
              onTap: () async {
                HapticFeedback.lightImpact(); // Feedback háptico al tocar familia
                await TtsService.speak(nombre);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen circular de la familia (diseño más personal)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF2C3E50).withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          imgPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 48,
                              color: const Color(0xFF2C3E50),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Espaciado entre imagen y texto
                  const SizedBox(height: 12),
                  // Nombre de la familia
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.5,
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
                  // Espaciado entre texto e indicador
                  const SizedBox(height: 8),
                  // Indicador de interacción
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
