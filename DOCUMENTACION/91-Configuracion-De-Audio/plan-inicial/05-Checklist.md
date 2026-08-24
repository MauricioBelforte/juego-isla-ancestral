**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 91: Configuración de Audio

## Checklist de implementación del módulo

### [S] Especificación de configuración de audio
- [ ] Volumen maestro
- [ ] Música
- [ ] Efectos
- [ ] Ambiente
- [ ] Voces
- [ ] UI
- [ ] Cinemáticas
- [ ] Audio 3D
- [ ] Subtítulos
- [ ] Sonidos de interfaz
- [ ] Rango dinámico
- [ ] Compresión
- [ ] Dispositivo de salida
- [ ] Pruebas con auriculares
- [ ] Pruebas con altavoces

### [S] Volúmenes
- [ ] Definir volumen maestro (slider 0-100%)
- [ ] Definir volumen de música (slider 0-100%)
- [ ] Definir volumen de efectos (slider 0-100%)
- [ ] Definir volumen de ambiente (slider 0-100%)
- [ ] Definir volumen de voces (slider 0-100%)
- [ ] Definir volumen de UI (slider 0-100%)
- [ ] Definir volumen de cinemáticas (slider 0-100%)
- [ ] Definir valores por defecto (maestro 80%, música 70%, efectos 80%, ambiente 60%, voces 90%, UI 50%, cinemáticas 80%)
- [ ] Definir conversión de slider 0-100 a dB (linear2db)
- [ ] Definir buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic)

### [S] Volumen maestro
- [ ] Definir slider de volumen maestro (0-100%)
- [ ] Definir control de todos los canales de audio
- [ ] Definir valor por defecto 80%
- [ ] Definir aplicación a AudioServer.set_bus_volume_db()
- [ ] Definir conversión de slider 0-100 a dB

### [S] Música
- [ ] Definir slider de volumen de música (0-100%)
- [ ] Definir control de música de fondo y cinemáticas
- [ ] Definir valor por defecto 70%
- [ ] Definir aplicación al bus de música
- [ ] Definir conversión de slider 0-100 a dB

### [S] Efectos
- [ ] Definir slider de volumen de efectos (0-100%)
- [ ] Definir control de efectos de juego (herramientas, craft, interacción)
- [ ] Definir valor por defecto 80%
- [ ] Definir aplicación al bus de efectos
- [ ] Definir conversión de slider 0-100 a dB

### [S] Ambiente
- [ ] Definir slider de volumen de ambiente (0-100%)
- [ ] Definir control de sonidos ambientales (viento, agua, pájaros)
- [ ] Definir valor por defecto 60%
- [ ] Definir aplicación al bus de ambiente
- [ ] Definir conversión de slider 0-100 a dB

### [S] Voces
- [ ] Definir slider de volumen de voces (0-100%)
- [ ] Definir control de voces de NPCs y cinemáticas
- [ ] Definir valor por defecto 90%
- [ ] Definir aplicación al bus de voces
- [ ] Definir conversión de slider 0-100 a dB

### [S] UI
- [ ] Definir slider de volumen de UI (0-100%)
- [ ] Definir control de sonidos de interfaz (hover, click, notificaciones)
- [ ] Definir valor por defecto 50%
- [ ] Definir aplicación al bus de UI
- [ ] Definir conversión de slider 0-100 a dB

### [S] Cinemáticas
- [ ] Definir slider de volumen de cinemáticas (0-100%)
- [ ] Definir control de audio de cinemáticas (música, voces, efectos)
- [ ] Definir valor por defecto 80%
- [ ] Definir aplicación al bus de cinemáticas
- [ ] Definir conversión de slider 0-100 a dB

### [S] Audio 3D
- [ ] Definir toggle de audio 3D (on/off)
- [ ] Definir espacialización (HRTF para auriculares)
- [ ] Definir oclusión (bloqueo de sonido por objetos)
- [ ] Definir Doppler effect (cambio de frecuencia por movimiento)
- [ ] Definir distancia de atenuación (rolloff)
- [ ] Definir Audio3D nodes para sonidos espaciales
- [ ] Definir AudioServer.set_bus_effect() para espacialización
- [ ] Definir raycast para oclusión de sonido
- [ ] Definir PhysicsBody3D para bloqueo de sonido

### [S] Subtítulos
- [ ] Definir toggle de subtítulos (on/off)
- [ ] Definir tamaño de subtítulos (slider 0.5x a 2x)
- [ ] Definir opacidad de subtítulos (slider 0.2 a 1.0)
- [ ] Definir fondo de subtítulos (toggle + color)
- [ ] Definir color de texto (selector)
- [ ] Definir sincronización con audio
- [ ] Definir RichTextLabel para subtítulos
- [ ] Definir SubtitleManager para mostrar subtítulos
- [ ] Definir sincronización con AudioPlayer para cinemáticas
- [ ] Definir accesibilidad (M58) para ajustes de tamaño y contraste

### [S] Sonidos de interfaz
- [ ] Definir toggle de sonidos de interfaz (on/off)
- [ ] Definir sonidos de hover (cursor sobre botón)
- [ ] Definir sonidos de click (click en botón)
- [ ] Definir sonidos de notificaciones (notificaciones de logros, misiones)
- [ ] Definir sonidos de errores (error en acción)
- [ ] Definir AudioPlayer para sonidos de interfaz
- [ ] Definir eventos de UI para trigger de sonidos
- [ ] Definir AudioBus para control de volumen

### [S] Rango dinámico
- [ ] Definir quiet (compresión alta)
- [ ] Definir medio (compresión media)
- [ ] Definir dinámico (sin compresión)
- [ ] Definir CompressorEffect en AudioServer
- [ ] Definir threshold (umbral de compresión)
- [ ] Definir ratio (proporción de compresión)
- [ ] Definir attack (tiempo de ataque)
- [ ] Definir release (tiempo de liberación)

### [S] Compresión
- [ ] Definir toggle de compresión (on/off)
- [ ] Definir limitar picos de volumen para evitar clipping
- [ ] Definir threshold (umbral de limitación)
- [ ] Definir ratio (proporción de limitación)
- [ ] Definir LimiterEffect en AudioServer
- [ ] Definir threshold (umbral de limitación)
- [ ] Definir ceil (límite máximo de dB)
- [ ] Definir soft clip (soft clipping para evitar clipping duro)

### [S] Dispositivo de salida
- [ ] Definir predeterminado del sistema
- [ ] Definir auriculares
- [ ] Definir altavoces
- [ ] Definir HDMI
- [ ] Definir Bluetooth
- [ ] Definir AudioServer.get_device_list() para lista de dispositivos
- [ ] Definir AudioServer.set_device() para cambiar dispositivo
- [ ] Definir dropdown en settings para seleccionar dispositivo

### [S] Pruebas con auriculares
- [ ] Definir estéreo (izquierda/derecha)
- [ ] Definir espacial 3D (HRTF)
- [ ] Definir balance de canales (izquierda/derecha)
- [ ] Definir test de audio (sonido de prueba en cada canal)
- [ ] Definir AudioPlayer2D para estero
- [ ] Definir AudioPlayer3D para espacial 3D
- [ ] Definir AudioServer.set_bus_volume() para balance de canales
- [ ] Definir test button en settings

### [S] Pruebas con altavoces
- [ ] Definir estéreo (izquierda/derecha)
- [ ] Definir 5.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera)
- [ ] Definir 7.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera, izquierda lateral, derecha lateral)
- [ ] Definir balance de canales
- [ ] Definir test de audio (sonido de prueba en cada canal)
- [ ] Definir AudioServer.get_channel_count() para detectar canales
- [ ] Definir AudioServer.set_bus_channel_count() para configurar canales
- [ ] Definir test button en settings

### [S] Integración con M58 (Accesibilidad)
- [ ] Diseñar tamaño de subtítulos (slider 0.5x a 2x)
- [ ] Diseñar alto contraste (toggle)
- [ ] Diseñar reducción de audio complejo (opción para simplificar audio)
- [ ] Diseñar audio descriptivo (opción para descripción visual en audio)
- [ ] Diseñar ajustes en menú de configuración de audio
- [ ] Diseñar guardado en settings (M91)
- [ ] Diseñar aplicación en tiempo real

### [S] Integración con M87 (Internacionalización)
- [ ] Diseñar subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- [ ] Diseñar audio de voces en diferentes idiomas (si disponible)
- [ ] Diseñar localización de nombres de dispositivos de salida
- [ ] Diseñar SubtitleManager con soporte multiidioma
- [ ] Diseñar AudioPlayer con soporte multiidioma
- [ ] Diseñar LocalizationManager para traducción

### [S] Integración con M61 (Rendimiento)
- [ ] Diseñar audio en streaming (para archivos grandes)
- [ ] Diseñar audio en memoria (para archivos pequeños)
- [ ] Diseñar pool de AudioPlayers para evitar GC
- [ ] Diseñar audio comprimido (OGG, MP3) para reducir tamaño
- [ ] Diseñar AudioStreamPlayer para streaming
- [ ] Diseñar AudioStreamPlayer2D/3D para memoria
- [ ] Diseñar ObjectPool para AudioPlayers
- [ ] Diseñar compresión de audio en import settings

### [S] Menú de configuración de audio
- [ ] Diseñar AudioSettingsMenu
- [ ] Diseñar controles para volumen maestro (slider)
- [ ] Diseñar controles para volumen de música (slider)
- [ ] Diseñar controles para volumen de efectos (slider)
- [ ] Diseñar controles para volumen de ambiente (slider)
- [ ] Diseñar controles para volumen de voces (slider)
- [ ] Diseñar controles para volumen de UI (slider)
- [ ] Diseñar controles para volumen de cinemáticas (slider)
- [ ] Diseñar controles para audio 3D (toggle)
- [ ] Diseñar controles para subtítulos (toggle + sliders + color picker)
- [ ] Diseñar controles para sonidos de interfaz (toggle)
- [ ] Diseñar controles para rango dinámico (dropdown)
- [ ] Diseñar controles para compresión (toggle)
- [ ] Diseñar controles para dispositivo de salida (dropdown)
- [ ] Diseñar botones de prueba (auriculares, altavoces)

### [S] Configuración de settings
- [ ] Diseñar AudioSettings (Resource)
- [ ] Diseñar campos: master_volume, music_volume, sfx_volume, ambient_volume, voice_volume, ui_volume, cinematic_volume, audio_3d, subtitles, subtitle_size, subtitle_opacity, subtitle_background, subtitle_color, ui_sounds, dynamic_range, compression, output_device
- [ ] Diseñar método apply_settings()

### [S] Buses de audio
- [ ] Diseñar AudioBusSetup
- [ ] Diseñar setup de buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic)
- [ ] Diseñar AudioServer.add_bus() para crear buses
- [ ] Diseñar AudioServer.set_bus_name() para nombrar buses
- [ ] Diseñar AudioServer.set_bus_send() para anidar buses

### [S] Audio 3D setup
- [ ] Diseñar Audio3DSetup
- [ ] Diseñar espacialización con AudioEffectEQ
- [ ] Diseñar oclusión con AudioEffectLowPassFilter
- [ ] Diseñar AudioServer.add_bus_effect() para agregar efectos

### [S] SubtitleManager
- [ ] Diseñar SubtitleManager
- [ ] Diseñar método show_subtitle(text, duration)
- [ ] Diseñar método hide_subtitle()
- [ ] Diseñar RichTextLabel para subtítulos
- [ ] Diseñar aplicación de tamaño y opacidad desde AudioSettings

### [S] UISoundManager
- [ ] Diseñar UISoundManager
- [ ] Diseñar método play_hover_sound()
- [ ] Diseñar método play_click_sound()
- [ ] Diseñar método play_notification_sound()
- [ ] Diseñar método play_error_sound()
- [ ] Diseñar AudioPlayers para cada sonido

### [S] DynamicRangeManager
- [ ] Diseñar DynamicRangeManager
- [ ] Diseñar método apply_dynamic_range(range)
- [ ] Diseñar método apply_compression(bus_index, threshold, ratio, attack, release)
- [ ] Diseñar método remove_compression(bus_index)
- [ ] Diseñar AudioEffectCompressor para compresión

### [S] CompressionManager
- [ ] Diseñar CompressionManager
- [ ] Diseñar método apply_compression(enabled)
- [ ] Diseñar método remove_limiter(bus_index)
- [ ] Diseñar AudioEffectLimiter para limitación

### [S] OutputDeviceManager
- [ ] Diseñar OutputDeviceManager
- [ ] Diseñar método get_output_devices()
- [ ] Diseñar método set_output_device(device_name)
- [ ] Diseñar método get_current_device()
- [ ] Diseñar AudioServer.get_device_list() para lista de dispositivos
- [ ] Diseñar AudioServer.set_device() para cambiar dispositivo

### [S] AudioTestManager
- [ ] Diseñar AudioTestManager
- [ ] Diseñar método test_headphones()
- [ ] Diseñar método test_speakers()
- [ ] Diseñar test estéreo
- [ ] Diseñar test espacial 3D
- [ ] Diseñar test balance de canales

### [S] Carga de configuración
- [ ] Diseñar AudioSettingsLoader
- [ ] Diseñar método load_settings()
- [ ] Diseñar carga desde user://settings/audio_settings.json
- [ ] Diseñar parseo de JSON
- [ ] Diseñar aplicación de configuración al inicio
- [ ] Diseñar fallback a configuración por defecto si no existe

### [S] Guardado de configuración
- [ ] Diseñar AudioSettingsSaver
- [ ] Diseñar método save_settings()
- [ ] Diseñar guardado en user://settings/audio_settings.json
- [ ] Diseñar serialización de settings a JSON
- [ ] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [ ] Diseñar formato de audio_settings.json
- [ ] Incluir todos los campos de AudioSettings
- [ ] Incluir subtítulo_size y subtítulo_opacity como float
- [ ] Incluir subtítulo_color como objeto {r, g, b, a}

### [S] Diagrama de flujo
- [ ] Diseñar diagrama de flujo de configuración
- [ ] Diseñar flujo: Usuario abre settings → Menú de configuración de audio → Usuario ajusta volúmenes y opciones → AudioSettings se actualiza → AudioBusSetup aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [ ] Diseñar pruebas manuales (volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida, pruebas de audio)
- [ ] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, cambio de dispositivo de salida)
- [ ] Diseñar pruebas de balance de canales
- [ ] Diseñar pruebas de sincronización de subtítulos
- [ ] Diseñar pruebas de espacialización 3D
- [ ] Diseñar pruebas de compresión de audio
- [ ] Diseñar pruebas de cambio de dispositivo de salida

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de volúmenes
- [ ] Diseñar tests de audio 3D
- [ ] Diseñar tests de subtítulos
- [ ] Diseñar tests de rango dinámico
- [ ] Diseñar tests de compresión
- [ ] Diseñar tests de dispositivo de salida
- [ ] Diseñar tests de pruebas de audio

## Totales

**Total de ítems:** 227
**Ítems resueltos por documentación:** 227
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
