import 'package:autismo_app/models/actividad.dart';

final Map<String, List<Actividad>> actividadesBoy = {
  'mañana': [
    Actividad(texto: 'Me desperté', ruta: 'assets/hacer/boy/manana/desperte.png'),
    Actividad(texto: 'Me vestí', ruta: 'assets/hacer/boy/manana/vesti.png'),
    Actividad(texto: 'Me cepillé los dientes', ruta: 'assets/hacer/boy/manana/dientes.png'),
    Actividad(texto: 'Desayuné', ruta: 'assets/hacer/boy/manana/desayune.png'),
  ],
  'tarde': [
    Actividad(texto: 'Almorcé', ruta: 'assets/hacer/boy/tarde/almorce.png'),
    Actividad(texto: 'Fui al colegio', ruta: 'assets/hacer/boy/tarde/colegio.png'),
    Actividad(texto: 'Hice tarea', ruta: 'assets/hacer/boy/tarde/boy_tarea.png'),
    Actividad(texto: 'Jugué', ruta: 'assets/hacer/boy/tarde/jugue.png'),
  ],
  'noche': [
    Actividad(texto: 'Cené', ruta: 'assets/hacer/boy/noche/cene.png'),
    Actividad(texto: 'Leí un libro', ruta: 'assets/hacer/boy/noche/libro.png'),
    Actividad(texto: 'Vi la televisión', ruta: 'assets/hacer/boy/noche/tele.png'),
    Actividad(texto: 'Me acosté', ruta: 'assets/hacer/boy/noche/acoste.jpg'),
  ],
};

final Map<String, List<Actividad>> actividadesGirl = {
  'mañana': [
    Actividad(texto: 'Me desperté', ruta: 'assets/hacer/girl/manana/desperte.png'),
    Actividad(texto: 'Me vestí', ruta: 'assets/hacer/girl/manana/vesti.png'),
    Actividad(texto: 'Me cepillé los dientes', ruta: 'assets/hacer/girl/manana/dientes.png'),
    Actividad(texto: 'Desayuné', ruta: 'assets/hacer/girl/manana/desayune.png'),
  ],
  'tarde': [
    Actividad(texto: 'Almorcé', ruta: 'assets/hacer/girl/tarde/almorce.png'),
    Actividad(texto: 'Fui al colegio', ruta: 'assets/hacer/girl/tarde/colegio.png'),
    Actividad(texto: 'Hice tarea', ruta: 'assets/hacer/girl/tarde/tarea.png'),
    Actividad(texto: 'Jugué', ruta: 'assets/hacer/girl/tarde/jugue.png'),
  ],
  'noche': [
    Actividad(texto: 'Cené', ruta: 'assets/hacer/girl/noche/cene.png'),
    Actividad(texto: 'Leí un libro', ruta: 'assets/hacer/girl/noche/libro.png'),
    Actividad(texto: 'Vi la televisión', ruta: 'assets/hacer/girl/noche/tele.png'),
    Actividad(texto: 'Me acosté', ruta: 'assets/hacer/girl/noche/acoste.jpg'),
  ],
};
