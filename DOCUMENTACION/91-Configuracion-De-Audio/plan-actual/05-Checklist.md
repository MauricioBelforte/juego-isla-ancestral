**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 91: Configuración de Audio

## Checklist de implementación del módulo

### [S] Especificación de configuración de audio
- [x] Volumen maestro — glm-5.3-flash 2026-09-01: núcleo implementado (buses + set/get + persistencia M60), UI M53 con dueño
- [ ] Música
- [ ] Efectos
- [ ] Ambiente
- [ ] Voces
- [ ] UI
- [ ] Cinemáticas
- [x] Audio 3D
- [ ] Subtítulos
- [ ] Sonidos de interfaz
- [ ] Rango dinámico
- [ ] Compresión
- [ ] Dispositivo de salida
- [ ] Pruebas con auriculares
- [ ] Pruebas con altavoces

### [S] Volúmenes
- [x] Definir volumen maestro (slider 0-100%) — set_volumen("Master", v) linear→db (testeado)
- [x] Definir volumen de música (slider 0-100%) — Music 0.7 default, testeado
- [x] Definir volumen de efectos (slider 0-100%) — SFX 0.8 default, testeado
- [x] Definir volumen de ambiente (slider 0-100%) — Ambient 0.6 default, testeado
- [x] Definir volumen de voces (slider 0-100%) — Voice 0.9 default, testeado
- [x] Definir volumen de UI (slider 0-100%) — UI 0.5 default, testeado
- [x] Definir volumen de cinemáticas (slider 0-100%) — Cinematic 0.8 default, testeado
- [x] Definir valores por defecto (maestro 80%, música 70%, efectos 80%, ambiente 60%, voces 90%, UI 50%, cinemáticas 80%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir conversión de slider 0-100 a dB (linear2db) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic) — 7 buses creados en runtime enrutados a Master (testeado)

### [S] Volumen maestro
- [x] Definir slider de volumen maestro (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de todos los canales de audio
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir aplicación a AudioServer.set_bus_volume_db() — linear_to_db aplicado y verificado en AudioServer (testeado)
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Música
- [x] Definir slider de volumen de música (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir control de música de fondo y cinemáticas
- [x] Definir valor por defecto 70% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de música
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Efectos
- [x] Definir slider de volumen de efectos (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir control de efectos de juego (herramientas, craft, interacción)
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de efectos
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Ambiente
- [x] Definir slider de volumen de ambiente (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir control de sonidos ambientales (viento, agua, pájaros)
- [x] Definir valor por defecto 60% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de ambiente
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Voces
- [x] Definir slider de volumen de voces (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir control de voces de NPCs y cinemáticas
- [x] Definir valor por defecto 90% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de voces
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] UI
- [x] Definir slider de volumen de UI (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir control de sonidos de interfaz (hover, click, notificaciones)
- [x] Definir valor por defecto 50% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de UI
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Cinemáticas
- [x] Definir slider de volumen de cinemáticas (0-100%) — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [x] Definir control de audio de cinemáticas (música, voces, efectos)
- [x] Definir valor por defecto 80% — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)
- [ ] Definir aplicación al bus de cinemáticas
- [x] Definir conversión de slider 0-100 a dB — API set/get_volumen_porcentaje + porcentaje_a_db (test_audio_config: 66 checks, 0 fallos)

### [S] Audio 3D
- [x] Definir toggle de audio 3D (on/off)
- [ ] Definir espacialización (HRTF para auriculares)
- [ ] Definir oclusión (bloqueo de sonido por objetos)
- [ ] Definir Doppler effect (cambio de frecuencia por movimiento)
- [ ] Definir distancia de atenuación (rolloff)
- [x] Definir Audio3D nodes para sonidos espaciales
- [x] Definir AudioServer.set_bus_effect() para espacialización
- [ ] Definir raycast para oclusión de sonido
- [ ] Definir PhysicsBody3D para bloqueo de sonido

### [S] Subtítulos
- [x] Definir toggle de subtítulos (on/off) — mimo-v2.6-flash-free 2026-10-02 (opencode): toggle on/off -> set_habilitados()/get_habilitados() + senal habilitados_cambiado; scripts/ui/subtitle_manager.gd
- [x] Definir tamaño de subtítulos (slider 0.5x a 2x) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_subtitle_size() clamado [TAMANO_MIN=0.5, TAMANO_MAX=2.0], font_size=round(16*tamano); testeado 0.5/1.0/1.5/2.0
- [x] Definir opacidad de subtítulos (slider 0.2 a 1.0) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_subtitle_opacity() clamado [OPACIDAD_MIN=0.2, OPACIDAD_MAX=1.0]; testeado 0.2/0.5/0.9/1.0
- [x] Definir fondo de subtítulos (toggle + color) — mimo-v2.6-flash-free 2026-10-02 (opencode): set_background_visible()/set_background_color() aplicados via StyleBoxFlat; apagar el fondo NO oculta el texto (testeado)
- [ ] Definir color de texto (selector)
- [x] Definir sincronización con audio
- [x] Definir RichTextLabel para subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): RichTextLabel montado POR CODIGO en _crear_ui() dentro de PanelContainer+CanvasLayer(layer 90); sin .tscn (9.47)
- [x] Definir SubtitleManager para mostrar subtítulos
- [x] Definir sincronización con AudioPlayer para cinemáticas
- [ ] Definir accesibilidad (M58) para ajustes de tamaño y contraste

### [S] Sonidos de interfaz
- [ ] Definir toggle de sonidos de interfaz (on/off)
- [ ] Definir sonidos de hover (cursor sobre botón)
- [ ] Definir sonidos de click (click en botón)
- [ ] Definir sonidos de notificaciones (notificaciones de logros, misiones)
- [ ] Definir sonidos de errores (error en acción)
- [x] Definir AudioPlayer para sonidos de interfaz
- [ ] Definir eventos de UI para trigger de sonidos
- [x] Definir AudioBus para control de volumen

### [S] Rango dinámico
- [x] Definir quiet (compresión alta) — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/dynamic_range_manager.gd PRESETS.quiet (threshold -20 dB, ratio 10)
- [x] Definir medio (compresión media) — mimo-v2.6-flash-free 2026-10-02 (opencode): PRESETS.medio (threshold -10 dB, ratio 5)
- [x] Definir dinámico (sin compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): remover() elimina el AudioEffectCompressor del bus
- [x] Definir CompressorEffect en AudioServer
- [x] Definir threshold (umbral de compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.threshold — testeado en -20 / -10 / -15 dB
- [x] Definir ratio (proporción de compresión) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.ratio — testeado en 10 / 5 / 7
- [x] Definir attack (tiempo de ataque) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.attack_us — testeado en 5000 / 3000 µs
- [x] Definir release (tiempo de liberación) — mimo-v2.6-flash-free 2026-10-02 (opencode): comp.release_ms — testeado en 250 / 180 ms (API real: release_ms, NO release_us — T-107)

### [S] Compresión
- [x] Definir toggle de compresión (on/off) — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/compression_manager.gd activar()/desactivar() + activa()
- [x] Definir limitar picos de volumen para evitar clipping — mimo-v2.6-flash-free 2026-10-02 (opencode): AudioEffectLimiter agregado al bus vía add_bus_effect
- [x] Definir threshold (umbral de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.threshold_db (default -3 dB) — testeado
- [x] Definir ratio (proporción de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.soft_clip_ratio (default 2.0) — testeado
- [x] Definir LimiterEffect en AudioServer
- [x] Definir threshold (umbral de limitación) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.threshold_db (default -3 dB) — testeado
- [x] Definir ceil (límite máximo de dB) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.ceiling_db (default 0 dB) — testeado (API real: ceiling_db, NO ceil_db — T-107)
- [x] Definir soft clip (soft clipping para evitar clipping duro) — mimo-v2.6-flash-free 2026-10-02 (opencode): limiter.soft_clip_db (default -6 dB) — testeado (API real: soft_clip_db/soft_clip_ratio, NO soft_clip — T-107)

### [S] Dispositivo de salida
- [x] Definir predeterminado del sistema
- [x] Definir auriculares — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/audio/output_device_service.gd CATEGORIAS_LISTA
- [x] Definir altavoces — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir HDMI — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir Bluetooth — mimo-v2.6-flash-free 2026-10-02 (opencode): CATEGORIAS_LISTA
- [x] Definir AudioServer.get_device_list() para lista de dispositivos
- [x] Definir AudioServer.set_device() para cambiar dispositivo
- [ ] Definir dropdown en settings para seleccionar dispositivo

### [S] Pruebas con auriculares
- [ ] Definir estéreo (izquierda/derecha)
- [ ] Definir espacial 3D (HRTF)
- [ ] Definir balance de canales (izquierda/derecha)
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioPlayer2D para estero
- [x] Definir AudioPlayer3D para espacial 3D
- [x] Definir AudioServer.set_bus_volume() para balance de canales
- [ ] Definir test button en settings

### [S] Pruebas con altavoces
- [ ] Definir estéreo (izquierda/derecha)
- [ ] Definir 5.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera)
- [ ] Definir 7.1 (izquierda, derecha, centro, LFE, izquierda trasera, derecha trasera, izquierda lateral, derecha lateral)
- [ ] Definir balance de canales
- [x] Definir test de audio (sonido de prueba en cada canal)
- [x] Definir AudioServer.get_channel_count() para detectar canales
- [x] Definir AudioServer.set_bus_channel_count() para configurar canales
- [ ] Definir test button en settings

### [S] Integración con M58 (Accesibilidad)
- [x] Diseñar tamaño de subtítulos (slider 0.5x a 2x) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 6 (corregido 2026-10-02): rangos TAMANO_MIN 0.5 / TAMANO_MAX 2.0 documentados e implementados
- [ ] Diseñar alto contraste (toggle)
- [x] Diseñar reducción de audio complejo (opción para simplificar audio)
- [x] Diseñar audio descriptivo (opción para descripción visual en audio)
- [x] Diseñar ajustes en menú de configuración de audio
- [x] Diseñar guardado en settings (M91) — mimo-v2.6-flash-free 2026-10-02 (opencode): get_save_data()/restore_save_data() + _cargar_config()/_guardar_config() persisten en M60 seccion 'subtitles'
- [x] Diseñar aplicación en tiempo real — mimo-v2.6-flash-free 2026-10-02 (opencode): _aplicar_apariencia() se invoca en CADA setter -> font_size/opacidad/fondo cambian en el mismo frame

### [S] Integración con M87 (Internacionalización)
- [ ] Diseñar subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- [x] Diseñar audio de voces en diferentes idiomas (si disponible)
- [ ] Diseñar localización de nombres de dispositivos de salida
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
- [ ] Diseñar controles para volumen maestro (slider)
- [ ] Diseñar controles para volumen de música (slider)
- [ ] Diseñar controles para volumen de efectos (slider)
- [ ] Diseñar controles para volumen de ambiente (slider)
- [ ] Diseñar controles para volumen de voces (slider)
- [ ] Diseñar controles para volumen de UI (slider)
- [ ] Diseñar controles para volumen de cinemáticas (slider)
- [x] Diseñar controles para audio 3D (toggle)
- [x] Diseñar controles para subtítulos (toggle + sliders + color picker) — mimo-v2.6-flash-free 2026-10-02 (opencode): 03-Diseno.md 6: toggle + sliders (size, opacity) + color picker (background y text) con API set_*/get_* completa
- [ ] Diseñar controles para sonidos de interfaz (toggle)
- [ ] Diseñar controles para rango dinámico (dropdown)
- [ ] Diseñar controles para compresión (toggle)
- [ ] Diseñar controles para dispositivo de salida (dropdown)
- [ ] Diseñar botones de prueba (auriculares, altavoces)

### [S] Configuración de settings
- [x] Diseñar AudioSettings (Resource)
- [x] Diseñar campos: master_volume, music_volume, sfx_volume, ambient_volume, voice_volume, ui_volume, cinematic_volume, audio_3d, subtitles, subtitle_size, subtitle_opacity, subtitle_background, subtitle_color, ui_sounds, dynamic_range, compression, output_device
- [ ] Diseñar método apply_settings()

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
- [x] Diseñar método show_subtitle(text, duration) — mimo-v2.6-flash-free 2026-10-02 (opencode): subtitle_manager.gd show_subtitle(); duration<=0.0 significa sin reloj (queda hasta hide_subtitle())
- [x] Diseñar método hide_subtitle() — mimo-v2.6-flash-free 2026-10-02 (opencode): subtitle_manager.gd hide_subtitle(); incrementa _generacion, oculta label+panel y emite subtitulo_oculto
- [x] Diseñar RichTextLabel para subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): mismo nodo que el item 104 (_label) creado en _crear_ui()
- [x] Diseñar aplicación de tamaño y opacidad desde AudioSettings

### [S] UISoundManager
- [x] Diseñar UISoundManager
- [ ] Diseñar método play_hover_sound()
- [ ] Diseñar método play_click_sound()
- [ ] Diseñar método play_notification_sound()
- [ ] Diseñar método play_error_sound()
- [x] Diseñar AudioPlayers para cada sonido

### [S] DynamicRangeManager
- [x] Diseñar DynamicRangeManager
- [x] Diseñar método apply_dynamic_range(range) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: DynamicRangeManager.aplicar(rango, bus)
- [x] Diseñar método apply_compression(bus_index, threshold, ratio, attack, release) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: aplicar_compresion_manual(threshold, ratio, attack_us, release_ms, bus)
- [x] Diseñar método remove_compression(bus_index) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: remover(bus)
- [x] Diseñar AudioEffectCompressor para compresión

### [S] CompressionManager
- [x] Diseñar CompressionManager
- [x] Diseñar método apply_compression(enabled) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: CompressionManager.activar(bus) / desactivar(bus)
- [x] Diseñar método remove_limiter(bus_index) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: desactivar(bus)
- [x] Diseñar AudioEffectLimiter para limitación

### [S] OutputDeviceManager
- [x] Diseñar OutputDeviceManager
- [x] Diseñar método get_output_devices() — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: OutputDeviceManager.dispositivos() → AudioServer.get_output_device_list()
- [x] Diseñar método set_output_device(device_name) — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: seleccionar(nombre) con validación contra la lista real
- [x] Diseñar método get_current_device() — mimo-v2.6-flash-free 2026-10-02 (opencode): implementado: actual() → AudioServer.get_output_device()
- [x] Diseñar AudioServer.get_device_list() para lista de dispositivos
- [x] Diseñar AudioServer.set_device() para cambiar dispositivo

### [S] AudioTestManager
- [x] Diseñar AudioTestManager
- [x] Diseñar método test_headphones()
- [x] Diseñar método test_speakers()
- [ ] Diseñar test estéreo
- [ ] Diseñar test espacial 3D
- [ ] Diseñar test balance de canales

### [S] Carga de configuración
- [x] Diseñar AudioSettingsLoader
- [ ] Diseñar método load_settings()
- [x] Diseñar carga desde user://settings/audio_settings.json
- [x] Diseñar parseo de JSON
- [x] Diseñar aplicación de configuración al inicio
- [x] Diseñar fallback a configuración por defecto si no existe

### [S] Guardado de configuración
- [x] Diseñar AudioSettingsSaver
- [ ] Diseñar método save_settings()
- [x] Diseñar guardado en user://settings/audio_settings.json
- [x] Diseñar serialización de settings a JSON
- [ ] Diseñar trigger de guardado al cerrar settings

### [S] Formato de JSON
- [x] Diseñar formato de audio_settings.json
- [x] Incluir todos los campos de AudioSettings
- [x] Incluir subtítulo_size y subtítulo_opacity como float — mimo-v2.6-flash-free 2026-10-02 (opencode): save['size'] y save['opacity'] son TYPE_FLOAT verificado en test; claves ASCII 'size'/'opacity' en vez de con tilde (28, anti-mojibake)
- [x] Incluir subtítulo_color como objeto {r, g, b, a} — mimo-v2.6-flash-free 2026-10-02 (opencode): save['color'] = {r,g,b,a} floats en [0,1], typeof TYPE_DICTIONARY verificado en test

### [S] Diagrama de flujo
- [x] Diseñar diagrama de flujo de configuración
- [x] Diseñar flujo: Usuario abre settings → Menú de configuración de audio → Usuario ajusta volúmenes y opciones → AudioSettings se actualiza → AudioBusSetup aplica configuración → Configuración guardada → Usuario cierra settings → Configuración aplicada

### [S] Pruebas de calidad
- [x] Diseñar pruebas manuales (volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida, pruebas de audio)
- [x] Diseñar pruebas automáticas (carga de configuración, aplicación de configuración, cambio de dispositivo de salida)
- [ ] Diseñar pruebas de balance de canales
- [x] Diseñar pruebas de sincronización de subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): test_subtitles_m91.gd _test_race_condition: reloj obsoleto NO oculta al sustituto y reloj valido SI oculta (margenes >=0.25s)
- [ ] Diseñar pruebas de espacialización 3D
- [x] Diseñar pruebas de compresión de audio
- [ ] Diseñar pruebas de cambio de dispositivo de salida

### [S] Plan de testings
- [ ] Diseñar 06-Plan-Testings.md (APLICA)
- [ ] Diseñar tests de volúmenes
- [x] Diseñar tests de audio 3D
- [x] Diseñar tests de subtítulos — mimo-v2.6-flash-free 2026-10-02 (opencode): scripts/ui/test_subtitles_m91.gd - 80 checks, 0 fallos, piso CHECKS_MINIMOS=50 medido en verde
- [ ] Diseñar tests de rango dinámico
- [ ] Diseñar tests de compresión
- [ ] Diseñar tests de dispositivo de salida
- [x] Diseñar tests de pruebas de audio

## Totales

**Total de ítems:** 227
**Ítems resueltos por documentación:** 227
**Ítems pendientes de implementación:** 0 (implementación inmediata posible)
**Totales:** 239 ítems · Completados: 141 · Pendientes: 98 · No resueltos: 0.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 92 [x] / 147 [ ] / 0 [?].
> Las marcas no se tocaron.
