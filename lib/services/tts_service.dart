import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();

  static Map<String, List<Map<String, String>>> vocesSeleccionadas = {
    'niño': [
      {'name': 'es-us-x-esd-local', 'locale': 'es-US'},
      {'name': 'es-es-x-eef-local', 'locale': 'es-ES'},
      {'name': 'es-us-x-esf-local', 'locale': 'es-US'},
      {'name': 'es-es-x-eed-local', 'locale': 'es-ES'},
      {'name': 'es-us-x-esf-network', 'locale': 'es-US'},
      {'name': 'es-es-x-eed-network', 'locale': 'es-ES'},
      {'name': 'es-us-x-esd-network', 'locale': 'es-US'},
    ],

    'niña': [
      {'name': 'es-us-languaje', 'locale': 'es-US'},
      {'name': 'es-us-x-sfb-network', 'locale': 'es-US'},
      {'name': 'es-us-x-esc-network', 'locale': 'es-US'},
      {'name': 'es-es-x-eee-local', 'locale': 'es-ES'},
      {'name': 'es-es-x-eec-network', 'locale': 'es-ES'},
      {'name': 'es-es-x-eea-local', 'locale': 'es-ES'},
      {'name': 'es-es-x-eea-network', 'locale': 'es-ES'},
      {'name': 'es-us-x-esc-local', 'locale': 'es-US'},
      {'name': 'es-us-x-sfb-local', 'locale': 'es-US'},
      {'name': 'es-Es-languaje', 'locale': 'es-ES'},
      {'name': 'es-es-x-eec-local', 'locale': 'es-ES'},
    ],
  };

  static Future<void> setVoiceByData(Map<String, String> voice) async {
    try {
      await _flutterTts.setLanguage(voice['locale'] ?? 'es-US');
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVoice(voice);
      debugPrint("✅ Voz aplicada manualmente: ${voice['name']}");
    } catch (e) {
      debugPrint("❌ Error al aplicar voz: $e");
    }
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('voz_seleccionada');
    final locale = prefs.getString('voz_locale');

    if (name != null && locale != null) {
      await setVoiceByData({'name': name, 'locale': locale});
    } else {
      debugPrint("⚠️ No hay voz guardada");
    }
  }

  static Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("❌ Error en TTS: $e");
    }
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
