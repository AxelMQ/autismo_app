import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FrutasScreen extends StatefulWidget {
  final String colorNombre;
  final Color color;

  const FrutasScreen({super.key, required this.colorNombre, required this.color});

  @override
  State<FrutasScreen> createState() => _FrutasScreenState();
}

class _FrutasScreenState extends State<FrutasScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

  /// Crea un fondo temático sutil que no sea abrumador
  Color _getThematicBackground() {
    // Crear un fondo que combine el color base con el color temático
    final baseColor = const Color(0xFFFFF8E1); // Color base de la app
    final thematicColor = widget.color;
    
    // Mezclar el color temático con el base (11% de color temático para mejor visibilidad)
    return Color.lerp(baseColor, thematicColor, 0.11) ?? baseColor;
  }

  /// Calcula un color de alto contraste para el texto
  Color _getContrastColor(Color backgroundColor) {
    // Calcular el brillo del color de fondo
    final brightness = backgroundColor.computeLuminance();
    
    // Si el fondo es claro, usar texto oscuro; si es oscuro, usar texto claro
    if (brightness > 0.5) {
      return Colors.black87; // Texto oscuro para fondos claros
    } else {
      return Colors.white; // Texto claro para fondos oscuros
    }
  }

  List<Map<String, String>> _getFrutasPorColor(String colorNombre) {
    switch (colorNombre) {
      case 'Amarillo':
        return [
          {
            'nombre': 'Maracuyá',
            'imagen': 'assets/frutas/amarrillo/maracuya.png',
          },
          {'nombre': 'Choclo', 'imagen': 'assets/frutas/amarrillo/choclo.png'},
          {'nombre': 'Banana', 'imagen': 'assets/frutas/amarrillo/banana.png'},
          {'nombre': 'Piña', 'imagen': 'assets/frutas/amarrillo/piña.png'},
        ];
      case 'Naranja':
        return [
          {
            'nombre': 'Mandarina',
            'imagen': 'assets/frutas/naranja/mandarina.png',
          },
          {'nombre': 'Zapallo', 'imagen': 'assets/frutas/naranja/zapallo.png'},
          {
            'nombre': 'Zanahoria',
            'imagen': 'assets/frutas/naranja/zanahoria.png',
          },
          {'nombre': 'Papaya', 'imagen': 'assets/frutas/naranja/papaya.png'},
        ];
      case 'Rojo':
        return [
          {'nombre': 'Cereza', 'imagen': 'assets/frutas/rojo/cereza.png'},
          {'nombre': 'Fresa', 'imagen': 'assets/frutas/rojo/fresa.png'},
          {'nombre': 'Sandía', 'imagen': 'assets/frutas/rojo/sandia.png'},
          {'nombre': 'Tomate', 'imagen': 'assets/frutas/rojo/tomate.png'},
          {'nombre': 'Manzana', 'imagen': 'assets/frutas/rojo/manzana.png'},
        ];
      case 'Verde':
        return [
          {
            'nombre': 'Manzana Verde',
            'imagen': 'assets/frutas/verde/manzana.png',
          },
          {'nombre': 'Apio', 'imagen': 'assets/frutas/verde/apio.png'},
          {'nombre': 'Arveja', 'imagen': 'assets/frutas/verde/arveja.png'},
          {'nombre': 'Brócoli', 'imagen': 'assets/frutas/verde/brocoli.png'},
          {'nombre': 'Lechuga', 'imagen': 'assets/frutas/verde/lechuga.png'},
          {'nombre': 'Pepino', 'imagen': 'assets/frutas/verde/pepino.png'},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final frutas = _getFrutasPorColor(widget.colorNombre);

    return Scaffold(
      backgroundColor: _getThematicBackground(), // Fondo temático sutil
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                widget.colorNombre, // Solo el nombre del color
                style: const TextStyle(
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
                  child: _buildResponsiveGrid(context, frutas),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, List<Map<String, String>> frutas) {
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
      itemCount: frutas.length,
      itemBuilder: (context, index) {
        final fruta = frutas[index];
        return _buildFrutaCard(
          context,
          fruta['nombre']!,
          fruta['imagen']!,
          index,
        );
      },
    );
  }

  Widget _buildFrutaCard(BuildContext context, String nombre, String imagen, int index) {
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
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(24),
              shadowColor: widget.color.withValues(alpha: 0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  // Feedback háptico al tocar fruta
                  HapticFeedback.lightImpact();
                  await TtsService.speak(nombre);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.5), // Borde más visible
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Imagen de la fruta
                      Expanded(
                        flex: 3, // Más espacio para la imagen
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            imagen,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: widget.color,
                              );
                            },
                          ),
                        ),
                      ),
                      // Espaciado entre imagen y texto
                      const SizedBox(height: 8),
                      // Nombre de la fruta
                      Expanded(
                        flex: 1, // Menos espacio para el texto
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            nombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getContrastColor(Colors.white), // Contraste basado en el fondo blanco de la tarjeta
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Indicador de interacción
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.8), // Color temático para el indicador
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Espaciado inferior
                      const SizedBox(height: 8),
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
