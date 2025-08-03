import 'package:autismo_app/screens/genero_screen.dart';
import 'package:autismo_app/screens/home_screen.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() => runApp(const MyApp());
void main () async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // final prefs = await SharedPreferences.getInstance();
  // final genero = prefs.getString('genero_nino') ?? 'niño'; // Por defecto 'niño'

  await TtsService.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _decidirPantallaInicial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final generoNino = prefs.getString('genero_nino');

      if (generoNino == null) {
        return GeneroScreen();
      } else {
        return HomeScreen();
      }
    } catch (e) {
      // print("Error en _decidirPantallaInicial: $e");
      return Center(child: Text("Error al cargar datos"));
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
