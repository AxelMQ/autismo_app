import 'package:autismo_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          foregroundColor: Colors.black,      // Color del texto y los íconos
          elevation: 0,                       // Opcional: sin sombra
        ),
      ),
      home: const HomeScreen(),
    );
  }
}