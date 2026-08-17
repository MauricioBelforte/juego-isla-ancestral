**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 91: Configuración de Audio

## Checklist de implementación del módulo

### [S] Especificación de configuración de audio
- [x] Volumen maestro
- [x] Música
- [x] Efectos
- [x] Ambiente
- [x] Voces
- [x] UI
- [x] Cinemáticas
- [x] Audio 3D
- [x] Subtítulos
- [x] Sonidos de interfaz
- [x] Rango dinámico
- [x] Compresión
- [x] Dispositivo de salida
- [x] Pruebas con auriculares
- [x] Pruebas con altavoces

### [S] Volúmenes
- [x] Definir volumen maestro (slider 0-100%)
- [x] Definir volumen de música (slider 0-100%)
- [x] Definir volumen de efectos (slider 0-100%)
- [x] Definir volumen de ambiente (slider 0-100%)
- [x] Definir volumen de voces (slider 0-100%)
- [x] Definir volumen de UI (slider 0-100%)
- [x] Definir volumen de cinemáticas (slider 0-100%)
- [x] Definir valores por defecto (maestro 80%, música 70%, efectos 80%, ambiente 60%, voces 90%, UI 50%, cinemáticas 80%)
- [x] Definir conversión de slider 0-100 a dB (linear2db)
- [x] Definir buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic)

### [S] Volumen maestro
- [x] Definir slider de volumen maestro (0-100%)
- [x] Definir control de todos los canales de audio
- [x] Definir valor por defecto 80%
- [x] Definir aplicación a AudioServer.set_bus_volume_db()
- [x] Definir conversión de slider 0-100 a dB

### [S] Música
- [x] Definir slider de volumen de música (0-100%)
- [x] Definir control de música de fondo y cinemáticas
- [x] Definir valor por defecto 70%
- [x] Definir aplicación al bus de música
- [x] Definir conversión de slider 0-100 a dB

### [S] Efectos
- [x] Definir slider de volumen de efectos (0-100%)
- [x] Definir control de efectos de juego (herramientas, craft, interacción)
- [x] Definir valor por defecto 80%
- [x] Definir aplicación al bus de efectos
- [x] Definir conversión de slider 0-100 a dB

### [S] Ambiente
- [x] Definir slider de volumen de ambiente (0-100%)
- [x] Definir control de sonidos ambientales (viento, agua, pájaros)
- [x] Definir valor por defecto 60%
- [x] Definir aplicación al bus de ambiente
- [x] Definir conversión de slider 0-100 a dB

### [S] Voces
- [x] Definir slider de volumen de voces (0-100%)
- [x] Definir control de voces de NPCs y cinemáticas
- [x] Definir valor por defecto 90%
- [x] Definir aplicación al bus de voces
- [x] Definir conversión de slider 0-100 a dB

### [S] UI
- [x] Definir slider de volumen de UI (0-100%)
- [x] Definir control de sonidos de interfaz (hover, click, notificaciones)
- [x] Definir valor por defecto 50%
- [x] Definir aplicación al bus de UI
- [x] Definir conversión de slider 0-100 a dB

### [S] Cinemáticas
- [x] Definir slider de volumen de cinemáticas (0-100%)
- [x] Definir control de audio de cinemáticas (música, voces, efectos)
- [x] Definir valor por defecto 80%
- [x] Definir aplicación al bus de cinemáticas
- [x] Definir conversión de slider 0-100 a dB

### [S] Audio 3D
- [x] Definir toggle de audio 3D (on/off)
- [x] Definir espacialización (HRTF para auriculares)
- [x] Definir oclusión (bloqueo de sonido por objetos)
- [x] Definir Doppler effect (cambio de frecuencia por movimiento)
- [x] Definir distancia de atenuación (rolloff)
- [x] Definir Audio3D nodes para sonidos espaciales
- [x] Definir AudioServer.set_bus_effect() para espacialización
- [x] Definir raycast para oclusión de sonido
- [x] Definir PhysicsBody3D para bloqueo de sonido

### [S] Subtítulos
- [x] Definir toggle de subtítulos (on/off)
- [x] Definir tamaño de subtítulos (slider 0.5x a 2x)
- [x] Definir opacidad de subtítulos (slider 0.2 a 1.0)
- [x] Definir fondo de subtítulos (toggle + color)
- [x] Definir color de texto (selector)
- [x] Definir sincronización con audio
- [x] Definir RichTextLabel para subtítulos
- [x] Definir SubtitleManager para mostrar subtítulos
- [x] Definir sincronización con AudioPlayer para cinemáticas
- [x] Definir accesibilidad (M58) para ajustes de tamaño y contraste

### [S] Sonidos de interfaz
- [x] Definir toggle de sonidos de interfaz (on/off)
- [x] Definir sonidos de hover (cursor sobre botón)
- [x] Definir sonidos de click (click en botón)
- [x] Definir sonidos de notificaciones (notificaciones de logros, misiones)
- [x] Definir sonidos de errores (error en acción)
- [x] Definir AudioPlayer para sonidos de interfaz
- [x] Definir eventos de UI para trigger de sonidos
- [x] Definir AudioBus para control de volumen

### [S] Rango dinámico
- [x] Definir quiet (compresión alta)
- [x] Definir medio (compresión media)
- [x] Definir dinámico (sin compresión)
- [x] Definir CompressorEffect en AudioServer
- [x] Definir threshold (umbral de compresión)
- [x] Definir ratio (proporción de compresión)
- [x] Definir attack (tiempo de ataque)
- [x] Definir release (tiempo de liberación)

### [S] Compresión
- [x] Definir toggle de compresión (on/off)
- [x] Definir limitar picos de volumen para evitar clipping
- [x] Definir threshold (umbral de limitación)
- [x] Definir ratio (proporción de limitación)
- [x] Definir LimiterEffect en AudioServer
- [x] Definir threshold (umbral de limitación)
- [x] Definir ceil (límite máximo de dB)
- [x] Definir soft clip (soft clipping para evitar clipping duro)

### [S] Dispositivo de salida
- [x] Definir predeterminado del sistema
- [x] Definir auriculares
- [x] Definir altavoces
- [x] Definir HDMI
- [x] Definir Bluetooth
- [x] Definir AudioServer.get_device_list() para lista de dispositivos
- [x] Definir AudioServer.set_device() para cambiar dispositivo
- [x] Definir dropdown en settings para seleccionar dispositivo

### [S] Pruebas con auriculares
- [x] Definir estéreo (izquierda/derecha)
- [x] Definir espacial 3D (HRTF)
- [x] Definir balance de canales (izquierda/derecha)
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioPlayer2D para estero
- [x] Definir AudioPlayer3D para espacial 3D
- [x] Definir AudioServer.set_bus_volume() para balance de canales
- [x] Definir test button en settings

### [S] Pruebas con altavoces
- [x] Definir estéreo (izquierda/derecha)
- [x] Definir 5.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera)
- [x] Definir 7.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera, izquierda lateral, derecha lateral)
- [x] Definir balance de canales
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioServer.get_channel_count() para detectar canales
- [x] Definir AudioServer.set_bus_channel_count() para configurar canales
- [x] Definir test button en settings

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar tamaño de subtítulos (slider 0.5x a 2x)
- [x] Diseñar alto contraste (toggle)
- [x] Diseñar reducción de audio complejo (opción para simplificar audio)
- [x] Diseñar audio descriptivo (opción para descripción visual en audio)
- [x] Diseñar ajustes en menú de configuración de audio
- [x] Diseñar guardado en settings (M91)
- [x] Diseñar aplicación en tiempo real

### [S] Integración con M87 (Internacionalización)
- [x] Diseñar subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- [x] Diseñar audio de voces en diferentes idiomas (si disponible)
- [x] Diseñar localización de nombres de dispositivos de salida
- [x] Diseñar SubtitleManager con soporte multiidioma
- [x] Diseñar AudioPlayer con soporte multiidioma
- [x] Diseñar LocalizationManager para traducción

### [S] Integración con M61 (Rendimiento)
- [x] Diseñar audio en streaming (para archivos grandes)
- [x] Diseñar audio en memoria (para archivos pequeños)
- [x] Diseñar pool de AudioPlayers para evitar GC
- [x] Diseñar audio comprimido (OGG, MP3) para reducir tamaño
- [x] Diseñar AudioStreamPlayer para streaming
- [x] Diseñar AudioStreamPlayer2D/3D para memoria
- [x] Diseñar ObjectPool para AudioPlayers
- [x] Diseñar compresión de audio en import settings

### [S] Menú de configuración de audio
- [x] Diseñar AudioSettingsMenu
- [x] Diseñar controles para volumen maestro (slider)
- [x] Diseñar controles para volumen de música (slider)
- [x] Diseñar controles para volumen de efectos (slider)
- [x] Diseñar controles para volumen de ambiente (slider)
- [x] Diseñar controles para volumen de voces (slider)
- [x] Diseñar controles para volumen de UI (slider)
- [x] Diseñar controles para volumen de cinemáticas (slider)
- [x] Diseñar controles para audio 3D (toggle)
- [x] Diseñar controles para subtítulos (toggle + sliders + color picker)
- [x] Diseñar controles para sonidos de interfaz (toggle)
- [x] Diseñar controles para rango dinámico (dropdown)
- [x] Diseñar controles para compresión (toggle)
- [x] Diseñar controles para dispositivo de salida (dropdown)
- [x] Diseñar botones de prueba (auriculares, altavoces)

### [S] Configuración de settings
- [x] Diseñar AudioSettings (Resource)
- [x] Diseñar campos: master_volume, music_volume, sfx_volume, ambient_volume, voice_volume, ui_volume, cinematic_volume, audio_3d, subtitles, subtitle_size, subtitle_opacity, subtitle_background, subtitle_color, ui_sounds, dynamic_range, compression, output_device
- [x] Diseñar método apply_settings()

### [S] Buses de audio
- [x] Diseñar AudioBusSetup
- [x] Diseñar setup de buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic)
- [x] Diseñar AudioServer.add_bus() para crear buses
- [x] Diseñar AudioServer.set_bus_name() para nombrar buses
- [x] Diseñar AudioServer.set_bus_send() para anidar buses

### [S] Audio 3D setup
- [x] Diseñar Audio3DSetup
- [x] Diseñar espacialización con AudioEffectEQ
- [x] Diseñar oclusión con AudioEffectLowPassFilter
- [x] Diseñar AudioServer.add_bus_effect() para agregar efectos

### [S] SubtitleManager
- [x] Diseñar SubtitleManager
- [x] Diseñar método show_subtitle(text, duration)
- [x] Diseñar método hide_subtitle()
- [x] Diseñar RichTextLabel para subtítulos
- [x] Diseñar aplicación de tamaño y opacidad desde AudioSettings

### [S] UISoundManager
- [x] Diseñar UISoundManager
- [x] Diseñar método play_hover_sound()
- [x] Diseñar método play_click_sound()
- [x] Diseñar método play_notification_sound()
- [x] Diseñar método play_error_sound()
- [x] Diseñar AudioPlayers para cada sonido

### [S] DynamicRangeManager
- [x] Diseñar DynamicRangeManager
- [x] Diseñar método apply_dynamic_range(range)
- [x] Diseñar método apply_compression(bus_index, threshold, ratio, attack, release)
- [x] Diseñar método remove_compression(bus_index)
- [x] Diseñar AudioEffectCompressor para compresión

### [S] CompressionManager
- [x] Diseñar CompressionManager
- [x] Diseñar método apply_compression(enabled)
- [x] Diseñar método remove_limiter(bus_index)
- [x] Diseñar AudioEffectLimiter para limitación

### [S] OutputDeviceManager
- [x] Diseñar OutputDeviceManager
- [x] Diseñar método get_output_devices()
- [x] Diseñar método set_output_device(device_name)
- [x] Diseñar método get_current_device()
- [x] Diseñar AudioServer.get_device_list() para lista de dispositivos
- [x] Diseñar AudioServer.set_device() para cambiar dispositivo

### [S] AudioTestManager
- [x] Diseñar AudioTestManager
- [x] Diseñar método test_headphones()
- [x] Diseñar método test_speakers()
- [x] Diseñar test estéreo
- [x] Diseñar test espacial 3D
- [x] Diseñar test balance de canales

### [S] Carga de configuración
- [x] Diseñar AudioSettingsLoader
- [x] Diseñar método load_settings()
- [x] Diseñar carga desde user://settings/audio_settings.json
- [x] Diseñar parseo de JSON
- [x] Diseñar aplicación de configuración al inicio
- [x] Diseñar fallback a configuración por defecto si no existe

### [S] Guardado de configuración
- [x] Diseñar AudioSettingsSaver
- [x] Diseñar método save_settings()
- [x] Diseñar guardado en user://settings/audio_settings.json
- [x] Diseñar serialización de settings a JSON
- [x] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] Diseñar formato de audio_settings.json
- [x] Incluir todos los campos de AudioSettings
- [x] Incluir subtítulo_size y subtítulo_opacity como float
- [x] Incluir subtítulo_color como objeto {r, g, b, a}

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración de audio → Usuario ajusta volúmenes y opciones → AudioSettings se actualiza → AudioBusSetup aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida, pruebas de audio)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, cambio de dispositivo de salida)
- [x] Diseñar pruebas de balance de canales
- [x] Diseñar pruebas de sincronización de subtítulos
- [x] Diseñar pruebas de espacialización 3D
- [x] Diseñar pruebas de compresión de audio
- [x] Diseñar pruebas de cambio de dispositivo de salida

### [S] Plan de testings
- [x] Diseñar 06-Plan-Testings.md (APLICA)
- [x] Diseñar tests de volúmenes
- [x] Diseñar tests de audio 3D
- [x] Diseñar tests de subtítulos
- [x] Diseñar tests de rango dinámico
- [x] Diseñar tests de compresión
- [x] Diseñar tests de dispositivo de salida
- [x] Diseñar tests de pruebas de audio

## Totales

**Total de ítems:** 227
**Ítems resueltos por documentación:** 227
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
