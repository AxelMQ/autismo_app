import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MomentoDetalleScreen extends StatefulWidget {
  final String genero;
  final String momento;
  final Map<String, List<String>> actividades;
  final Map<String, List<String>> textos;
  final List<String> seleccionadas;

  const MomentoDetalleScreen({
    super.key,
    required this.momento,
    required this.genero,
    required this.actividades,
    required this.textos,
    required this.seleccionadas,
  });

  @override
  State<MomentoDetalleScreen> createState() => _MomentoDetalleScreenState();
}

class _MomentoDetalleScreenState extends State<MomentoDetalleScreen> {
  late List<String> seleccionadas;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    seleccionadas = List.from(widget.seleccionadas);
    _speakTextoInicial();
  }

  Future<void> _speak(String text) async {
    try {
      await flutterTts.setLanguage("es-ES");
      await flutterTts.setSpeechRate(0.5); // Velocidad normal
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error en TTS: $e');
    }
  }

  Future<void> _speakTextoInicial() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.5); // Velocidad normal
    await flutterTts.speak("¿Qué hiciste en la ${widget.momento}?");
  }

  void seleccionarImagen(String ruta, int index) {
    if (!seleccionadas.contains(ruta) && seleccionadas.length < 4) {
      setState(() {
        seleccionadas.add(ruta);
      });
      _speak(widget.textos[widget.momento]![index]);
    }
  }

  int? obtenerOrden(String ruta) {
    if (seleccionadas.contains(ruta)) {
      return seleccionadas.indexOf(ruta) + 1;
    }
    return null;
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadesDelMomento = widget.actividades[widget.momento]!;
    // final textosDelMomento = widget.textos[widget.momento]!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${widget.momento.toUpperCase()}',
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(widget.genero == 'niño' ? Icons.face : Icons.face_3, size: 28),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, seleccionadas);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¿Qué hiciste en la ${widget.momento}?',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      actividadesDelMomento.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ruta = entry.value;
                        final yaSeleccionada = seleccionadas.contains(ruta);
                        return GestureDetector(
                          onTap: () => seleccionarImagen(ruta, index),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Opacity(
                              opacity: yaSeleccionada ? 0.75 : 1.0,
                              child: Image.asset(ruta, height: 150, width: 150),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      actividadesDelMomento.map((ruta) {
                        final orden = obtenerOrden(ruta);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child:
                                orden == null
                                    ? const SizedBox()
                                    : Image.asset(
                                      'assets/hacer/numeros/$orden.png',
                                      fit: BoxFit.contain,
                                    ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
