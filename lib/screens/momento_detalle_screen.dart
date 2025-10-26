import 'package:autismo_app/models/actividad.dart';
import 'package:autismo_app/services/tts_service.dart';
import 'package:autismo_app/services/data_service.dart';
import 'package:flutter/material.dart';

class MomentoDetalleScreen extends StatefulWidget {
  final String genero;
  final String momento;
  final Map<String, List<Actividad>> actividades;
  final List<String> seleccionadas; 

  const MomentoDetalleScreen({
    super.key,
    required this.momento,
    required this.genero,
    required this.actividades,
    required this.seleccionadas,
  });

  @override
  State<MomentoDetalleScreen> createState() => _MomentoDetalleScreenState();
}

class _MomentoDetalleScreenState extends State<MomentoDetalleScreen> {
  late List<String> seleccionadas;

  @override
  void initState() {
    super.initState();
    seleccionadas = List.from(widget.seleccionadas);
    _speakTextoInicial();
  }

  Future<void> _speakTextoInicial() async {
    await TtsService.speak("¿Qué hiciste en la ${widget.momento}?");
  }

  void seleccionarImagen(Actividad actividad) {
    if (!seleccionadas.contains(actividad.ruta) && seleccionadas.length < 4) {
      setState(() {
        seleccionadas.add(actividad.ruta);
      });
      
      // 🔊 Reproducir audio
      TtsService.speak(actividad.texto);
      
      // 💾 Guardar actividad en persistencia
      DataService.guardarActividad(
        momento: widget.momento,
        ruta: actividad.ruta,
        texto: actividad.texto,
      );
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
    TtsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actividadesDelMomento = widget.actividades[widget.momento]!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.momento.toUpperCase(),
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
              // Columna de imágenes de actividades
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actividadesDelMomento.map((actividad) {
                    final yaSeleccionada = seleccionadas.contains(actividad.ruta);
                    return GestureDetector(
                      onTap: () => seleccionarImagen(actividad),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Opacity(
                          opacity: yaSeleccionada ? 0.75 : 1.0,
                          child: Image.asset(actividad.ruta, height: 130, width: 130),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Columna de orden numérico
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: actividadesDelMomento.map((actividad) {
                    final orden = obtenerOrden(actividad.ruta);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 130,
                        width: 130,
                        child: orden == null
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
