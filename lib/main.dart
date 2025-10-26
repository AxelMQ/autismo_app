import 'package:autismo_app/screens/genero_screen.dart';
import 'package:autismo_app/screens/home_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(const MyApp());
void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await TtsService.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _decidirPantallaInicial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final generoNino = prefs.getString('genero_nino');

      // Validar que el género sea válido
      if (generoNino == null || (generoNino != 'niño' && generoNino != 'niña')) {
        debugPrint("🔍 No hay género guardado o es inválido: $generoNino");
        // Opción 1: Mostrar pantalla de selección (actual)
        return GeneroScreen();
        
        // Opción 2: Género por defecto (descomenta si quieres)
        // await prefs.setString('genero_nino', 'niño');
        // return HomeScreen();
      } else {
        debugPrint("✅ Género guardado encontrado: $generoNino");
        return HomeScreen();
      }
    } catch (e) {
      debugPrint("❌ Error en _decidirPantallaInicial: $e");
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 50, color: Colors.red),
            SizedBox(height: 16),
            Text("Error al cargar datos", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Reinicia la aplicación", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFF8E1),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 248, 235, 190), // Fondo crema
          foregroundColor: Colors.black, // Color del texto y los íconos
          elevation: 0, // Opcional: sin sombra
        ),
      ),
      home: FutureBuilder<Widget>(
        future: _decidirPantallaInicial(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else if (snapshot.hasError) {
              return Center(child: Text("Ocurrió un error: ${snapshot.error}"));
            } else {
              return const Center(child: Text("Cargando..."));
            }
          }
        },
      ),
    );
  }
}
