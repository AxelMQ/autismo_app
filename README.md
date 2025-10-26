# 🧩 Autismo App

Una aplicación educativa y terapéutica desarrollada en Flutter para niños con autismo, diseñada para facilitar el aprendizaje y la comunicación a través de elementos visuales, audio y actividades interactivas.

## 📱 Descripción

Autismo App es una aplicación multiplataforma que proporciona herramientas educativas especializadas para niños con autismo. La aplicación incluye módulos para el reconocimiento de emociones, colores, familia, actividades diarias y frutas, todo integrado con un sistema de texto a voz (TTS) para mejorar la experiencia de aprendizaje.

## ✨ Características Principales

### 🎯 Módulos Educativos
- **Emociones**: Reconocimiento de 6 emociones básicas con imágenes diferenciadas por género
- **Colores**: Aprendizaje de 4 colores fundamentales con frutas asociadas
- **Familia**: Identificación de 6 miembros familiares principales
- **Actividades**: Rutinas diarias organizadas por momentos (mañana, tarde, noche)

### 🔊 Sistema de Texto a Voz
- Múltiples voces predefinidas por género
- Configuración automática según preferencias del usuario
- Reproducción de audio al interactuar con elementos

### 📊 Sistema de Estadísticas
- Gráficos de barras para actividades diarias
- Análisis semanal con datos simulados
- Visualización de actividades más frecuentes
- Seguimiento del progreso del usuario

### 🎨 Diseño Accesible
- Interfaz intuitiva y colorida
- Botones grandes y fáciles de usar
- Elementos visuales claros y distintivos
- Personalización por género (niño/niña)

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/                     # Modelos de datos
│   └── actividad.dart          # Modelo para actividades
├── data/                       # Datos estáticos
│   └── actividad_data.dart     # Datos de actividades por género
├── screens/                    # Pantallas de la aplicación
│   ├── genero_screen.dart      # Selección de género
│   ├── home_screen.dart        # Pantalla principal
│   ├── emociones_screen.dart   # Módulo de emociones
│   ├── colores_screen.dart     # Módulo de colores
│   ├── familia_screen.dart     # Módulo de familia
│   ├── hacer_screen.dart       # Módulo de actividades
│   ├── frutas_screen.dart      # Frutas por color
│   └── momento_detalle_screen.dart # Detalle de actividades
├── services/                   # Servicios
│   ├── tts_service.dart        # Servicio de texto a voz
│   └── data_service.dart       # Servicio de persistencia de datos
└── widgets/                    # Widgets personalizados
    ├── estadistica_chart.dart  # Gráfico de estadísticas
    ├── estadistica_semanal_chart.dart # Gráfico semanal
    ├── estadistica_real_chart.dart # Gráfico con datos reales
    └── momento_chart.dart      # Gráfico por momento
```

## 🎨 Assets y Recursos

### Estructura de Assets
```
assets/
├── emociones/          # 12 imágenes (6 niño + 6 niña)
├── familia/           # 6 miembros familiares
├── frutas/            # Organizadas por color
│   ├── amarrillo/     # 4 frutas amarillas
│   ├── naranja/       # 4 frutas naranjas
│   ├── rojo/          # 5 frutas rojas
│   └── Verde/         # 6 frutas verdes
├── hacer/             # Actividades por género y momento
│   ├── boy/           # Actividades para niño
│   ├── girl/          # Actividades para niña
│   └── numeros/       # Números 1-5
└── imgs/              # Iconos de categorías
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (versión 3.7.0 o superior)
- Dart SDK
- Android Studio / VS Code
- Git

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/AxelMQ/autismo_app.git
   cd autismo_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

### Configuración por Plataforma

#### Android
- SDK mínimo: API 21 (Android 5.0)
- Permisos de audio para TTS

#### iOS
- iOS 11.0 o superior
- Configuración de TTS en Info.plist

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_tts: ^4.2.3          # Texto a voz
  shared_preferences: ^2.5.3   # Persistencia local
  fl_chart: ^0.68.0           # Gráficos

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🎯 Funcionalidades Detalladas

### 1. Sistema de Género
- Selección inicial entre niño/niña
- Personalización de voces TTS según género
- Persistencia de preferencias con SharedPreferences

### 2. Módulo de Emociones
- 6 emociones básicas: Feliz, Triste, Enojado, Sorprendido, Tranquilo, Miedo
- Imágenes diferenciadas por género
- Reproducción de audio al seleccionar

### 3. Módulo de Colores
- 4 colores fundamentales: Amarillo, Naranja, Rojo, Verde
- Navegación a frutas por color
- Interfaz visual atractiva

### 4. Módulo de Familia
- 6 miembros: Abuelo, Abuela, Papá, Mamá, Hermano, Hermana
- Imágenes circulares y accesibles
- Audio descriptivo

### 5. Módulo de Actividades
- Organización por momentos del día
- Actividades diferenciadas por género
- Sistema de selección secuencial (máximo 4)
- Numeración visual del orden

### 6. Sistema de Estadísticas
- Gráficos de barras interactivos
- Análisis diario y semanal
- Seguimiento de progreso
- **Persistencia real de datos** - Las actividades se guardan automáticamente
- **Estadísticas reales** - Basadas en actividades reales del usuario

## 🎨 Diseño y UX

### Paleta de Colores
- Fondo principal: `#FFF8E1` (crema suave)
- AppBar: `#F8EBBE` (crema más oscuro)
- Colores temáticos por módulo

### Elementos Visuales
- Botones grandes y accesibles (150x180px)
- Imágenes circulares para familia
- Gradientes y sombras para profundidad
- Iconos Material Design

## 🔧 Desarrollo

### Estructura de Código
- **Models**: Definición de estructuras de datos
- **Screens**: Pantallas de la aplicación
- **Services**: Lógica de negocio y servicios externos
- **Widgets**: Componentes reutilizables
- **Data**: Datos estáticos y configuración

### Convenciones de Código
- Nombres descriptivos en español
- Comentarios en español
- Estructura modular
- Separación de responsabilidades

## 📊 Métricas del Proyecto

- **Líneas de código**: ~1,500 líneas
- **Pantallas**: 8 pantallas principales
- **Widgets personalizados**: 3 widgets de gráficos
- **Assets**: 50+ imágenes organizadas
- **Dependencias**: 4 dependencias principales

## 🚀 Roadmap y Mejoras Futuras

### Corto Plazo
- [x] **Implementar persistencia de datos** - Las actividades ahora se guardan automáticamente
- [x] **Estadísticas reales** - Reemplazadas las simuladas por datos reales del usuario
- [ ] Limpiar código comentado
- [ ] Mejorar manejo de errores
- [ ] Optimizar carga de imágenes
- [ ] Agregar validaciones de entrada

### Mediano Plazo
- [ ] Implementar Provider para estado global
- [ ] Agregar animaciones suaves
- [ ] Implementar modo offline
- [ ] Mejorar sistema de estadísticas

### Largo Plazo
- [ ] Backend para sincronización
- [ ] Múltiples perfiles de usuario
- [ ] Sistema de progreso gamificado
- [ ] Integración con terapeutas

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👥 Autores

- **AxelMQ** - *Desarrollo inicial* - [@AxelMQ](https://github.com/AxelMQ)

## 🙏 Agradecimientos

- Comunidad Flutter por el excelente framework
- Desarrolladores de las dependencias utilizadas
- Comunidad de desarrollo para autismo por la inspiración

## 📞 Contacto

- **Email**: axelmamaniquispia@gmail.com
- **GitHub**: [@AxelMQ](https://github.com/AxelMQ)

---

⭐ Si este proyecto te ha sido útil, ¡no olvides darle una estrella!