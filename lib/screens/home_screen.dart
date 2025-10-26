// ignore_for_file: use_build_context_synchronously

import 'package:autismo_app/screens/colores_screen.dart';
import 'package:autismo_app/screens/emociones_screen.dart';
import 'package:autismo_app/screens/familia_screen.dart';
import 'package:autismo_app/screens/genero_screen.dart';
import 'package:autismo_app/screens/hacer_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final buttonSize = isTablet 
        ? Size(180, 200) 
        : Size(150, 180);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Yo te hablo?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF2C3E50)),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('genero_nino');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GeneroScreen()),
                    );
                  },
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    // Primera fila de botones
                    _buildButtonRow(
                      context: context,
                      buttons: [
                        _buildCategoryButton(
                          context: context,
                          text: 'EMOCIONES',
                          color: const Color(0xFFFF6B35),
                          size: buttonSize,
                          destination: const EmocionesScreen(),
                          imagePath: 'assets/imgs/emociones.png',
                          delay: 0,
                        ),
                        _buildCategoryButton(
                          context: context,
                          text: 'COLORES',
                          color: const Color(0xFF8E44AD),
                          size: buttonSize,
                          destination: ColoresScreen(),
                          imagePath: 'assets/imgs/colores.png',
                          delay: 100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Segunda fila de botones
                    _buildButtonRow(
                      context: context,
                      buttons: [
                        _buildCategoryButton(
                          context: context,
                          text: 'FAMILIA',
                          color: const Color(0xFF3498DB),
                          size: buttonSize,
                          destination: const FamiliaScreen(),
                          imagePath: 'assets/imgs/familia.png',
                          delay: 200,
                        ),
                        _buildCategoryButton(
                          context: context,
                          text: 'HACER',
                          color: const Color(0xFF27AE60),
                          size: buttonSize,
                          destination: const HacerScreen(),
                          imagePath: 'assets/imgs/hacer.png',
                          delay: 300,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Texto inferior con animación
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
                                  const Color(0xFF2C3E50).withOpacity(0.1),
                                  const Color(0xFF3498DB).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2C3E50).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'AUTISMO',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonRow({
    required BuildContext context,
    required List<Widget> buttons,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }

  Widget _buildCategoryButton({
    required BuildContext context,
    required String text,
    required Color color,
    required Size size,
    required Widget? destination,
    String? imagePath,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = Curves.easeOut.transform(
          (_animationController.value - (delay / 1000)).clamp(0.0, 1.0),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                shadowColor: color.withOpacity(0.3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: destination != null
                      ? () => _navigateToScreen(context, destination)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Texto con sombra
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                        // Imagen con animación
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: imagePath != null
                              ? Image.asset(
                                imagePath,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderIcon();
                                },
                              )
                              : _buildPlaceholderIcon(),
                        ),
                        // Indicador de interacción
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
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

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.image,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    // Animación de transición suave
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
