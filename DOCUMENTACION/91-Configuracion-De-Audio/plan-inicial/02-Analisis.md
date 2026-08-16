**Modelo:** Devin
**Plataforma:** Antigravity

# 02-Analisis.md — Módulo 91: Configuración de Audio

## 1. Análisis de los puntos del plan maestro (sección 90)

| # | Punto | Resolución |
|---|---|---|
| 1 | Volumen maestro | ✅ Slider de volumen maestro (0-100%) que controla todos los canales de audio |
| 2 | Música | ✅ Slider de volumen de música (0-100%) para música de fondo y cinemáticas |
| 3 | Efectos | ✅ Slider de volumen de efectos (0-100%) para efectos de juego (herramientas, craft, interacción) |
| 4 | Ambiente | ✅ Slider de volumen de ambiente (0-100%) para sonidos ambientales (viento, agua, pájaros) |
| 5 | Voces | ✅ Slider de volumen de voces (0-100%) para voces de NPCs y cinemáticas |
| 6 | UI | ✅ Slider de volumen de UI (0-100%) para sonidos de interfaz (hover, click, notificaciones) |
| 7 | Cinemáticas | ✅ Slider de volumen de cinemáticas (0-100%) para audio de cinemáticas (música, voces, efectos) |
| 8 | Audio 3D | ✅ Toggle de audio 3D con espacialización (HRTF) y oclusión (bloqueo de sonido por objetos) |
| 9 | Subtítulos | ✅ Toggle de subtítulos con configuración (tamaño, opacidad, fondo, color de texto) |
| 10 | Sonidos de interfaz | ✅ Toggle de sonidos de interfaz (hover, click, notificaciones, errores) |
| 11 | Rango dinámico | ✅ Selector de rango dinámico (quieto: compresión alta, medio: compresión media, dinámico: sin compresión) |
| 12 | Compresión | ✅ Toggle de compresión de audio (limitar picos de volumen para evitar clipping) |
| 13 | Dispositivo de salida | ✅ Selector de dispositivo de salida (predeterminado del sistema, auriculares, altavoces, HDMI) |
| 14 | Pruebas con auriculares | ✅ Pruebas de audio con auriculares (estéreo, espacial 3D, balance de canales) |
| 15 | Pruebas con altavoces | ✅ Pruebas de audio con altavoces (estéreo, 5.1, 7.1, balance de canales) |

## 2. Volumen maestro

**Volumen maestro:**
- Slider de 0% a 100%
- Controla todos los canales de audio (música, efectos, ambiente, voces, UI, cinemáticas)
- Valor por defecto: 80%
- Afecta a AudioServer.set_bus_volume()

**Implementación:**
- Bus maestro en AudioServer
- Otros buses anidados bajo el bus maestro
- Volumen maestro controla el bus maestro
- Conversión de slider 0-100 a dB (bus_volume_db = linear2db(valor/100))

## 3. Música

**Volumen de música:**
- Slider de 0% a 100%
- Controla música de fondo (BGM) y música de cinemáticas
- Valor por defecto: 70%
- Afecta al bus de música

**Implementación:**
- Bus de música en AudioServer
- Música de fondo (BGM) en el bus de música
- Música de cinemáticas en el bus de música
- Conversion de slider 0-100 a dB

## 4. Efectos

**Volumen de efectos:**
- Slider de 0% a 100%
- Controla efectos de juego (herramientas, craft, interacción, combate)
- Valor por defecto: 80%
- Afecta al bus de efectos

**Implementación:**
- Bus de efectos en AudioServer
- Efectos de herramientas en el bus de efectos
- Efectos de craft en el bus de efectos
- Efectos de interacción en el bus de efectos
- Conversión de slider 0-100 a dB

## 5. Ambiente

**Volumen de ambiente:**
- Slider de 0% a 100%
- Controla sonidos ambientales (viento, agua, pájaros, insectos)
- Valor por defecto: 60%
- Afecta al bus de ambiente

**Implementación:**
- Bus de ambiente en AudioServer
- Sonidos ambientales en el bus de ambiente
- Conversión de slider 0-100 a dB

## 6. Voces

**Volumen de voces:**
- Slider de 0% a 100%
- Controla voces de NPCs y cinemáticas
- Valor por defecto: 90%
- Afecta al bus de voces

**Implementación:**
- Bus de voces en AudioServer
- Voces de NPCs en el bus de voces
- Voces de cinemáticas en el bus de voces
- Conversión de slider 0-100 a dB

## 7. UI

**Volumen de UI:**
- Slider de 0% a 100%
- Controla sonidos de interfaz (hover, click, notificaciones, errores)
- Valor por defecto: 50%
- Afecta al bus de UI

**Implementación:**
- Bus de UI en AudioServer
- Sonidos de hover en el bus de UI
- Sonidos de click en el bus de UI
- Sonidos de notificaciones en el bus de UI
- Conversión de slider 0-100 a dB

## 8. Cinemáticas

**Volumen de cinemáticas:**
- Slider de 0% a 100%
- Controla audio de cinemáticas (música, voces, efectos)
- Valor por defecto: 80%
- Afecta al bus de cinemáticas

**Implementación:**
- Bus de cinemáticas en AudioServer
- Música de cinemáticas en el bus de cinemáticas
- Voces de cinemáticas en el bus de cinemáticas
- Efectos de cinemáticas en el bus de cinemáticas
- Conversión de slider 0-100 a dB

## 9. Audio 3D

**Audio 3D:**
- Toggle de audio 3D (on/off)
- Espacialización (HRTF para auriculares)
- Oclusión (bloqueo de sonido por objetos)
- Doppler effect (cambio de frecuencia por movimiento)
- Distancia de atenuación (rolloff)

**Implementación:**
- Audio3D nodes para sonidos espaciales
- AudioServer.set_bus_effect() para espacialización
- Raycast para oclusión de sonido
- PhysicsBody3D para bloqueo de sonido

## 10. Subtítulos

**Subtítulos:**
- Toggle de subtítulos (on/off)
- Tamaño de subtítulos (slider 0.5x a 2x)
- Opacidad de subtítulos (slider 0.2 a 1.0)
- Fondo de subtítulos (toggle + color)
- Color de texto (selector)
- Sincronización con audio

**Implementación:**
- RichTextLabel para subtítulos
- SubtitleManager para mostrar subtítulos
- Sincronización con AudioPlayer para cinemáticas
- Accesibilidad (M58) para ajustes de tamaño y contraste

## 11. Sonidos de interfaz

**Sonidos de interfaz:**
- Toggle de sonidos de interfaz (on/off)
- Sonidos de hover (cursor sobre botón)
- Sonidos de click (click en botón)
- Sonidos de notificaciones (notificaciones de logros, misiones)
- Sonidos de errores (error en acción)

**Implementación:**
- AudioPlayer para sonidos de interfaz
- Eventos de UI para trigger de sonidos
- AudioBus para control de volumen

## 12. Rango dinámico

**Rango dinámico:**
- Quiet: compresión alta (limitar diferencia entre sonidos suaves y fuertes)
- Medio: compresión media (balance entre quiet y dinámico)
- Dinámico: sin compresión (diferencia máxima entre sonidos suaves y fuertes)

**Implementación:**
- CompressorEffect en AudioServer
- Threshold (umbral de compresión)
- Ratio (proporción de compresión)
- Attack (tiempo de ataque)
- Release (tiempo de liberación)

## 13. Compresión

**Compresión:**
- Toggle de compresión (on/off)
- Limitar picos de volumen para evitar clipping
- Threshold (umbral de limitación)
- Ratio (proporción de limitación)

**Implementación:**
- LimiterEffect en AudioServer
- Threshold (umbral de limitación)
- Ceil (límite máximo de dB)
- Soft Clip (soft clipping para evitar clipping duro)

## 14. Dispositivo de salida

**Dispositivo de salida:**
- Predeterminado del sistema
- Auriculares
- Altavoces
- HDMI
- Bluetooth

**Implementación:**
- AudioServer.get_device_list() para lista de dispositivos
- AudioServer.set_device() para cambiar dispositivo
- Dropdown en settings para seleccionar dispositivo

## 15. Pruebas con auriculares

**Pruebas con auriculares:**
- Estéreo (izquierda/derecha)
- Espacial 3D (HRTF)
- Balance de canales (izquierda/derecha)
- Test de audio (sonido de prueba en cada canal)

**Implementación:**
- AudioPlayer2D para estero
- AudioPlayer3D para espacial 3D
- AudioServer.set_bus_volume() para balance de canales
- Test button en settings

## 16. Pruebas con altavoces

**Pruebas con altavoces:**
- Estéreo (izquierda/derecha)
- 5.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera)
- 7.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera, izquierda lateral, derecha lateral)
- Balance de canales
- Test de audio (sonido de prueba en cada canal)

**Implementación:**
- AudioServer.get_channel_count() para detectar canales
- AudioServer.set_bus_channel_count() para configurar canales
- Test button en settings

## 17. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaño de subtítulos (slider 0.5x a 2x)
- Alto contraste (toggle)
- Reducción de audio complejo (opción para simplificar audio)
- Audio descriptivo (opción para descripción visual en audio)

**Implementación:**
- Ajustes de accesibilidad en menú de configuración de audio
- Ajustes guardados en settings (M91)
- Ajustes aplicados en tiempo real

## 18. Integración con M87 (Internacionalización)

**Internacionalización:**
- Subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- Audio de voces en diferentes idiomas (si disponible)
- Localización de nombres de dispositivos de salida

**Implementación:**
- SubtitleManager con soporte multiidioma
- AudioPlayer con soporte multiidioma
- LocalizationManager para traducción

## 19. Integración con M61 (Rendimiento)

**Rendimiento:**
- Audio en streaming (para archivos grandes)
- Audio en memoria (para archivos pequeños)
- Pool de AudioPlayers para evitar GC
- Audio comprimido (OGG, MP3) para reducir tamaño

**Implementación:**
- AudioStreamPlayer para streaming
- AudioStreamPlayer2D/3D para memoria
- ObjectPool para AudioPlayers
- Compresión de audio en import settings
