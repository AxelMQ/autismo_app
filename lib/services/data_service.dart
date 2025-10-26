import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DataService {
  // Claves para SharedPreferences
  static const String _keyActividades = 'actividades_usuario';
  
  /// Guarda una actividad seleccionada por el usuario
  static Future<void> guardarActividad({
    required String momento,
    required String ruta,
    required String texto,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fecha = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      final key = '${_keyActividades}_$fecha';
      
      // Obtener actividades existentes del día
      final actividadesJson = prefs.getString(key) ?? '[]';
      final List<dynamic> actividades = json.decode(actividadesJson);
      
      // Agregar nueva actividad
      actividades.add({
        'momento': momento,
        'ruta': ruta,
        'texto': texto,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Guardar actualizado
      await prefs.setString(key, json.encode(actividades));
      
          debugPrint('✅ Actividad guardada: $texto en $momento');
    } catch (e) {
      debugPrint('❌ Error guardando actividad: $e');
    }
  }
  
  /// Obtiene las actividades de un día específico
  static Future<List<Map<String, dynamic>>> obtenerActividadesDelDia(String fecha) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_keyActividades}_$fecha';
      final actividadesJson = prefs.getString(key) ?? '[]';
      final List<dynamic> actividades = json.decode(actividadesJson);
      
      return actividades.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('❌ Error obteniendo actividades: $e');
      return [];
    }
  }
  
  /// Obtiene las actividades de los últimos 7 días
  static Future<Map<String, List<Map<String, dynamic>>>> obtenerActividadesSemana() async {
    try {
      final Map<String, List<Map<String, dynamic>>> semana = {};
      final hoy = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final fecha = hoy.subtract(Duration(days: i));
        final fechaStr = fecha.toIso8601String().split('T')[0];
        final actividades = await obtenerActividadesDelDia(fechaStr);
        
        if (actividades.isNotEmpty) {
          semana[fechaStr] = actividades;
        }
      }
      
      return semana;
    } catch (e) {
      debugPrint('❌ Error obteniendo semana: $e');
      return {};
    }
  }
  
  /// Obtiene estadísticas reales del usuario
  static Future<Map<String, int>> obtenerEstadisticasPorMomento(String momento) async {
    try {
      final actividades = await obtenerActividadesDelDia(DateTime.now().toIso8601String().split('T')[0]);
      final Map<String, int> conteo = {};
      
      for (var actividad in actividades) {
        if (actividad['momento'] == momento.toLowerCase()) {
          final texto = actividad['texto'] as String;
          conteo[texto] = (conteo[texto] ?? 0) + 1;
        }
      }
      
      return conteo;
    } catch (e) {
      debugPrint('❌ Error obteniendo estadísticas: $e');
      return {};
    }
  }
  
  /// Limpia datos antiguos (más de 30 días)
  static Future<void> limpiarDatosAntiguos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final hoy = DateTime.now();
      
      for (String key in keys) {
        if (key.startsWith(_keyActividades)) {
          final fechaStr = key.replaceFirst('${_keyActividades}_', '');
          final fecha = DateTime.parse(fechaStr);
          
          if (hoy.difference(fecha).inDays > 30) {
            await prefs.remove(key);
            debugPrint('🗑️ Datos antiguos eliminados: $fechaStr');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error limpiando datos: $e');
    }
  }
}
