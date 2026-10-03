**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 04-Codigo.md — Módulo 91: Configuración de Audio

## 1. Carácter del Componente

Módulo de **configuración de audio** que define menú de settings de audio, volúmenes, audio 3D, subtítulos, sonidos de interfaz, rango dinámico, compresión, dispositivo de salida y pruebas de audio. Implementable inmediatamente (depende de M61 para rendimiento, M58 para accesibilidad, M87 para internacionalización). Es un módulo de UI y settings.

**06-Plan-Testings.md:** APLICA (sistema de UI con múltiples opciones de audio, requiere testing de volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida, pruebas de audio).

## 2. Archivos involucrados (implementación)

```
res://ui/settings/
├── audio_settings_menu.gd                     → Menú de configuración de audio
└── subtitles/  (ruta de diseño, NO existe)
    └── ✅ REAL 2026-10-02: scripts/ui/subtitle_manager.gd → autoload SubtitleManager

res://audio/
├── audio_bus_setup.gd                         → Setup de buses de audio
├── audio_3d_setup.gd                          → Setup de audio 3D
├── ui_sound_manager.gd                         → Manager de sonidos de interfaz
├── dynamic_range_manager.gd                   → Manager de rango dinámico
├── compression_manager.gd                     → Manager de compresión
├── output_device_manager.gd                   → Manager de dispositivo de salida
└── audio_test_manager.gd                      → Manager de pruebas de audio

res://settings/
├── audio_settings.gd                          → Configuración de audio (Resource)
├── audio_settings_loader.gd                   → Carga de configuración al inicio
└── audio_settings_saver.gd                    → Guardado de configuración al cerrar

user://settings/
└── audio_settings.json                         → Configuración guardada

06-Plan-Testings.md                            → Plan de testings (APLICA)
07-Resultados-Testings.md                       → Resultados de testings (APLICA)
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M58 (Accesibilidad):** Tamaño de subtítulos, alto contraste, reducción de audio complejo, audio descriptivo
- **M87 (Internacionalización):** Subtítulos en diferentes idiomas, audio de voces en diferentes idiomas
- **M61 (Rendimiento):** Audio en streaming, pool de AudioPlayers, audio comprimido

### Entrada (desde otros módulos)
- **M58 (Accesibilidad):** AccessibilitySettings para ajustes de accesibilidad
- **M87 (Internacionalización):** LocalizationManager para traducción
- **M61 (Rendimiento):** Recomendaciones de settings según performance

### Configuración
- `res://settings/audio_settings.gd` define configuración de audio actual
- `user://settings/audio_settings.json` guarda configuración

## 4. Implementación de audio_settings_menu.gd (esqueleto)

```gdscript
# res://ui/settings/audio_settings_menu.gd
class_name AudioSettingsMenu
extends Control

@onready var master_volume_slider = $MasterVolumeSlider
@onready var music_volume_slider = $MusicVolumeSlider
@onready var sfx_volume_slider = $SFXVolumeSlider
@onready var ambient_volume_slider = $AmbientVolumeSlider
@onready var voice_volume_slider = $VoiceVolumeSlider
@onready var ui_volume_slider = $UIVolumeSlider
@onready var cinematic_volume_slider = $CinematicVolumeSlider
@onready var audio_3d_toggle = $Audio3DToggle
@onready var subtitles_toggle = $SubtitlesToggle
@onready var subtitle_size_slider = $SubtitleSizeSlider
@onready var subtitle_opacity_slider = $SubtitleOpacitySlider
@onready var subtitle_background_toggle = $SubtitleBackgroundToggle
@onready var subtitle_color_picker = $SubtitleColorPicker
@onready var ui_sounds_toggle = $UISoundsToggle
@onready var dynamic_range_option_button = $DynamicRangeOptionButton
@onready var compression_toggle = $CompressionToggle
@onready var output_device_option_button = $OutputDeviceOptionButton
@onready var test_headphones_button = $TestHeadphonesButton
@onready var test_speakers_button = $TestSpeakersButton

func _ready():
    load_current_settings()
    populate_dropdowns()

func load_current_settings():
    master_volume_slider.value = AudioSettings.master_volume * 100
    music_volume_slider.value = AudioSettings.music_volume * 100
    sfx_volume_slider.value = AudioSettings.sfx_volume * 100
    ambient_volume_slider.value = AudioSettings.ambient_volume * 100
    voice_volume_slider.value = AudioSettings.voice_volume * 100
    ui_volume_slider.value = AudioSettings.ui_volume * 100
    cinematic_volume_slider.value = AudioSettings.cinematic_volume * 100
    audio_3d_toggle.button_pressed = AudioSettings.audio_3d
    subtitles_toggle.button_pressed = AudioSettings.subtitles
    subtitle_size_slider.value = AudioSettings.subtitle_size
    subtitle_opacity_slider.value = AudioSettings.subtitle_opacity
    subtitle_background_toggle.button_pressed = AudioSettings.subtitle_background
    subtitle_color_picker.color = AudioSettings.subtitle_color
    ui_sounds_toggle.button_pressed = AudioSettings.ui_sounds
    dynamic_range_option_button.selected = get_dynamic_range_index(AudioSettings.dynamic_range)
    compression_toggle.button_pressed = AudioSettings.compression
    output_device_option_button.selected = get_output_device_index(AudioSettings.output_device)

func populate_dropdowns():
    dynamic_range_option_button.add_item("Quiet")
    dynamic_range_option_button.add_item("Medio")
    dynamic_range_option_button.add_item("Dinámico")
    
    var devices = OutputDeviceManager.get_output_devices()
    for device in devices:
        output_device_option_button.add_item(device)

func _on_master_volume_slider_value_changed(value: float):
    AudioSettings.master_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(AudioSettings.master_volume))

func _on_music_volume_slider_value_changed(value: float):
    AudioSettings.music_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(AudioSettings.music_volume))

func _on_sfx_volume_slider_value_changed(value: float):
    AudioSettings.sfx_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(AudioSettings.sfx_volume))

func _on_ambient_volume_slider_value_changed(value: float):
    AudioSettings.ambient_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), linear2db(AudioSettings.ambient_volume))

func _on_voice_volume_slider_value_changed(value: float):
    AudioSettings.voice_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear2db(AudioSettings.voice_volume))

func _on_ui_volume_slider_value_changed(value: float):
    AudioSettings.ui_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(AudioSettings.ui_volume))

func _on_cinematic_volume_slider_value_changed(value: float):
    AudioSettings.cinematic_volume = value / 100
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Cinematic"), linear2db(AudioSettings.cinematic_volume))

func _on_audio_3d_toggle_toggled(pressed: bool):
    AudioSettings.audio_3d = pressed
    Audio3DSetup.setup_audio_3d()

func _on_subtitles_toggle_toggled(pressed: bool):
    AudioSettings.subtitles = pressed

func _on_subtitle_size_slider_value_changed(value: float):
    AudioSettings.subtitle_size = value

func _on_subtitle_opacity_slider_value_changed(value: float):
    AudioSettings.subtitle_opacity = value

func _on_subtitle_background_toggle_toggled(pressed: bool):
    AudioSettings.subtitle_background = pressed

func _on_subtitle_color_picker_color_changed(color: Color):
    AudioSettings.subtitle_color = color

func _on_ui_sounds_toggle_toggled(pressed: bool):
    AudioSettings.ui_sounds = pressed

func _on_dynamic_range_option_button_item_selected(index: int):
    match index:
        0: AudioSettings.dynamic_range = "quiet"
        1: AudioSettings.dynamic_range = "medio"
        2: AudioSettings.dynamic_range = "dinamico"
    DynamicRangeManager.apply_dynamic_range(AudioSettings.dynamic_range)

func _on_compression_toggle_toggled(pressed: bool):
    AudioSettings.compression = pressed
    CompressionManager.apply_compression(pressed)

func _on_output_device_option_button_item_selected(index: int):
    var devices = OutputDeviceManager.get_output_devices()
    AudioSettings.output_device = devices[index]
    OutputDeviceManager.set_output_device(AudioSettings.output_device)

func _on_test_headphones_button_pressed():
    AudioTestManager.test_headphones()

func _on_test_speakers_button_pressed():
    AudioTestManager.test_speakers()
```

## 5. Implementación de audio_settings.gd (esqueleto)

```gdscript
# res://settings/audio_settings.gd
class_name AudioSettings
extends Resource

var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ambient_volume: float = 0.6
var voice_volume: float = 0.9
var ui_volume: float = 0.5
var cinematic_volume: float = 0.8
var audio_3d: bool = true
var subtitles: bool = true
var subtitle_size: float = 1.0
var subtitle_opacity: float = 0.8
var subtitle_background: bool = true
var subtitle_color: Color = Color.WHITE
var ui_sounds: bool = true
var dynamic_range: String = "medio"
var compression: bool = true
var output_device: String = "predeterminado"

func apply_settings():
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), linear2db(ambient_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear2db(voice_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(ui_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Cinematic"), linear2db(cinematic_volume))
    DynamicRangeManager.apply_dynamic_range(dynamic_range)
    CompressionManager.apply_compression(compression)
    OutputDeviceManager.set_output_device(output_device)
```

## 6. Implementación de audio_bus_setup.gd (esqueleto)

```gdscript
# res://audio/audio_bus_setup.gd
class_name AudioBusSetup
extends Node

func _ready():
    setup_audio_buses()

func setup_audio_buses():
    var master_bus = AudioServer.get_bus_index("Master")
    
    var music_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(music_bus, "Music")
    AudioServer.set_bus_send(music_bus, master_bus)
    
    var sfx_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(sfx_bus, "SFX")
    AudioServer.set_bus_send(sfx_bus, master_bus)
    
    var ambient_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(ambient_bus, "Ambient")
    AudioServer.set_bus_send(ambient_bus, master_bus)
    
    var voice_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(voice_bus, "Voice")
    AudioServer.set_bus_send(voice_bus, master_bus)
    
    var ui_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(ui_bus, "UI")
    AudioServer.set_bus_send(ui_bus, master_bus)
    
    var cinematic_bus = AudioServer.add_bus()
    AudioServer.set_bus_name(cinematic_bus, "Cinematic")
    AudioServer.set_bus_send(cinematic_bus, master_bus)
```

## 7. Implementación de subtitle_manager.gd

> ✅ **Implementado 2026-10-02 (mimo-v2.6-flash-free / opencode).**
> El esqueleto original se retiró por cuatro defectos (detallados en
> `03-Diseno.md` §6 y en la Trampa **T-107**): ruta `res://ui/subtitles/…`
> inexistente, clase `AudioSettings` inexistente (la real es el autoload
> `AudioConfig`), `@onready $SubtitleLabel` que exigía un `.tscn` cuando este
> proyecto monta la UI por código (§9.47), y un `await` con **race condition**
> (el reloj del primer subtítulo ocultaba al segundo).
>
> - **Implementación real:** `scripts/ui/subtitle_manager.gd` → autoload
>   `SubtitleManager` (sin `class_name`, pitfall §9.17).
> - **Tests:** `scripts/ui/test_subtitles_m91.gd` — 80 checks, 0 fallos,
>   piso `CHECKS_MINIMOS = 50`.
> - **API y persistencia:** `03-Diseno.md` §6 (corregido).

```gdscript
# Consumo desde M53 (menú de settings)
SubtitleManager.set_habilitados(pressed)      # toggle on/off
SubtitleManager.set_subtitle_size(v)          # slider 0.5 .. 2.0  (clamado)
SubtitleManager.set_subtitle_opacity(v)       # slider 0.2 .. 1.0  (clamado)
SubtitleManager.set_background_visible(v)     # toggle del fondo
SubtitleManager.set_background_color(c)       # color del fondo
SubtitleManager.set_text_color(c)

# la UI escucha las señales para reflejar el estado
SubtitleManager.habilitados_cambiado.connect(func(v): ...)
SubtitleManager.config_subtitulos_cambiada.connect(func(): ...)

# narrativa / diálogos: el llamador resuelve la cadena con Localization
SubtitleManager.show_subtitle(Localization.tr("dialogo_01"), 4.0)
SubtitleManager.hide_subtitle()

# NO hay AudioSettings: la persistencia vive en M60, sección "subtitles"
# (claves ASCII: enabled / size / opacity / background / color / text_color)
```

## 8. Implementación de ui_sound_manager.gd (esqueleto)

```gdscript
# res://audio/ui_sound_manager.gd
class_name UISoundManager
extends Node

@onready var hover_sound = $HoverSound
@onready var click_sound = $ClickSound
@onready var notification_sound = $NotificationSound
@onready var error_sound = $ErrorSound

func play_hover_sound():
    if AudioSettings.ui_sounds:
        hover_sound.play()

func play_click_sound():
    if AudioSettings.ui_sounds:
        click_sound.play()

func play_notification_sound():
    if AudioSettings.ui_sounds:
        notification_sound.play()

func play_error_sound():
    if AudioSettings.ui_sounds:
        error_sound.play()
```

## 9. Implementación de dynamic_range_manager.gd (esqueleto)

```gdscript
# res://audio/dynamic_range_manager.gd
class_name DynamicRangeManager
extends Node

func apply_dynamic_range(range: String):
    var master_bus = AudioServer.get_bus_index("Master")
    
    match range:
        "quiet":
            apply_compression(master_bus, threshold=-20, ratio=10, attack=0.01, release=0.1)
        "medio":
            apply_compression(master_bus, threshold=-10, ratio=5, attack=0.01, release=0.1)
        "dinamico":
            remove_compression(master_bus)

func apply_compression(bus_index: int, threshold: float, ratio: float, attack: float, release: float):
    var compressor = AudioEffectCompressor.new()
    compressor.threshold = threshold
    compressor.ratio = ratio
    compressor.attack_us = attack * 1000000
    compressor.release_us = release * 1000000
    AudioServer.add_bus_effect(bus_index, compressor, 0)

func remove_compression(bus_index: int):
    var effect_count = AudioServer.get_bus_effect_count(bus_index)
    for i in range(effect_count):
        if AudioServer.get_bus_effect(bus_index, i) is AudioEffectCompressor:
            AudioServer.remove_bus_effect(bus_index, i)
            break
```

## 10. Implementación de compression_manager.gd (esqueleto)

```gdscript
# res://audio/compression_manager.gd
class_name CompressionManager
extends Node

func apply_compression(enabled: bool):
    var master_bus = AudioServer.get_bus_index("Master")
    
    if enabled:
        var limiter = AudioEffectLimiter.new()
        limiter.threshold_db = -3
        limiter.ceil_db = 0
        limiter.soft_clip = true
        AudioServer.add_bus_effect(master_bus, limiter, 0)
    else:
        remove_limiter(master_bus)

func remove_limiter(bus_index: int):
    var effect_count = AudioServer.get_bus_effect_count(bus_index)
    for i in range(effect_count):
        if AudioServer.get_bus_effect(bus_index, i) is AudioEffectLimiter:
            AudioServer.remove_bus_effect(bus_index, i)
            break
```

## 11. Implementación de output_device_manager.gd (esqueleto)

```gdscript
# res://audio/output_device_manager.gd
class_name OutputDeviceManager
extends Node

func get_output_devices() -> Array:
    return AudioServer.get_device_list()

func set_output_device(device_name: String):
    AudioServer.set_device(device_name)

func get_current_device() -> String:
    return AudioServer.get_device()
```

## 12. Implementación de audio_test_manager.gd (esqueleto)

```gdscript
# res://audio/audio_test_manager.gd
class_name AudioTestManager
extends Node

@onready var test_sound = $TestSound

func test_headphones():
    # Test estéreo
    test_sound.play()
    # Test espacial 3D
    # Test balance de canales

func test_speakers():
    # Test estéreo
    test_sound.play()
    # Test 5.1
    # Test 7.1
    # Test balance de canales
```

## 13. Implementación de audio_settings_loader.gd (esqueleto)

```gdscript
# res://settings/audio_settings_loader.gd
class_name AudioSettingsLoader
extends Node

func _ready():
    load_settings()

func load_settings():
    var file = FileAccess.open("user://settings/audio_settings.json", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json.error == OK:
            var settings = json.result
            AudioSettings.master_volume = settings["master_volume"]
            AudioSettings.music_volume = settings["music_volume"]
            AudioSettings.sfx_volume = settings["sfx_volume"]
            AudioSettings.ambient_volume = settings["ambient_volume"]
            AudioSettings.voice_volume = settings["voice_volume"]
            AudioSettings.ui_volume = settings["ui_volume"]
            AudioSettings.cinematic_volume = settings["cinematic_volume"]
            AudioSettings.audio_3d = settings["audio_3d"]
            AudioSettings.subtitles = settings["subtitles"]
            AudioSettings.subtitle_size = settings["subtitle_size"]
            AudioSettings.subtitle_opacity = settings["subtitle_opacity"]
            AudioSettings.subtitle_background = settings["subtitle_background"]
            AudioSettings.subtitle_color = Color(settings["subtitle_color"]["r"], settings["subtitle_color"]["g"], settings["subtitle_color"]["b"], settings["subtitle_color"]["a"])
            AudioSettings.ui_sounds = settings["ui_sounds"]
            AudioSettings.dynamic_range = settings["dynamic_range"]
            AudioSettings.compression = settings["compression"]
            AudioSettings.output_device = settings["output_device"]
            AudioSettings.apply_settings()
        file.close()
    else:
        # Configuración por defecto
        AudioSettings.apply_settings()
```

## 14. Implementación de audio_settings_saver.gd (esqueleto)

```gdscript
# res://settings/audio_settings_saver.gd
class_name AudioSettingsSaver
extends Node

func save_settings():
    var settings = {
        "master_volume": AudioSettings.master_volume,
        "music_volume": AudioSettings.music_volume,
        "sfx_volume": AudioSettings.sfx_volume,
        "ambient_volume": AudioSettings.ambient_volume,
        "voice_volume": AudioSettings.voice_volume,
        "ui_volume": AudioSettings.ui_volume,
        "cinematic_volume": AudioSettings.cinematic_volume,
        "audio_3d": AudioSettings.audio_3d,
        "subtitles": AudioSettings.subtitles,
        "subtitle_size": AudioSettings.subtitle_size,
        "subtitle_opacity": AudioSettings.subtitle_opacity,
        "subtitle_background": AudioSettings.subtitle_background,
        "subtitle_color": {"r": AudioSettings.subtitle_color.r, "g": AudioSettings.subtitle_color.g, "b": AudioSettings.subtitle_color.b, "a": AudioSettings.subtitle_color.a},
        "ui_sounds": AudioSettings.ui_sounds,
        "dynamic_range": AudioSettings.dynamic_range,
        "compression": AudioSettings.compression,
        "output_device": AudioSettings.output_device
    }
    
    var file = FileAccess.open("user://settings/audio_settings.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(settings))
    file.close()
```

## 15. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear res://ui/settings/audio_settings_menu.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://audio/audio_bus_setup.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://audio/audio_3d_setup.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://audio/ui_sound_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://audio/dynamic_range_manager.gd | ~~**IMPLEMENTACIÓN INMEDIATA**~~ ✅ **HECHO 2026-10-02** (mimo-v2.6-flash-free) → `scripts/audio/dynamic_range_manager.gd` |
| Crear res://audio/compression_manager.gd | ~~**IMPLEMENTACIÓN INMEDIATA**~~ ✅ **HECHO 2026-10-02** (mimo-v2.6-flash-free) → `scripts/audio/compression_manager.gd` |
| Crear res://audio/output_device_manager.gd | ~~**IMPLEMENTACIÓN INMEDIATA**~~ ✅ **HECHO 2026-10-02** (mimo-v2.6-flash-free) → `scripts/audio/output_device_manager.gd` |
| Crear res://audio/audio_test_manager.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://ui/subtitles/subtitle_manager.gd | ~~**IMPLEMENTACIÓN INMEDIATA**~~ ✅ **HECHO 2026-10-02** (mimo-v2.6-flash-free) → `scripts/ui/subtitle_manager.gd` (autoload `SubtitleManager`) + `scripts/ui/test_subtitles_m91.gd` |
| Crear res://settings/audio_settings.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/audio_settings_loader.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/audio_settings_saver.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Integrar con M58 (Accesibilidad) para ajustes de accesibilidad | **M58 (Accesibilidad)** |
| Integrar con M87 (Internacionalización) para subtítulos multiidioma | **M87 (Internacionalización)** |
| Integrar con M61 (Rendimiento) para streaming y pool de AudioPlayers | **M61 (Rendimiento)** |
| Crear 06-Plan-Testings.md | **IMPLEMENTACIÓN INMEDIATA** |
| Ejecutar 07-Resultados-Testings.md | **M58 (Accesibilidad) / M61 (Rendimiento)** |

## 16. Notas del Agente

**Modelo:** SWE-1.6
**Plataforma:** Devin
**Fecha:** 2026-08-17 00:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 15 puntos de la sección 90 del plan maestro.
- Definí volúmenes (maestro, música, efectos, ambiente, voces, UI, cinemáticas) con sliders 0-100%.
- Definí audio 3D con espacialización (HRTF) y oclusión.
- Definí subtítulos con toggle, tamaño, opacidad, fondo, color de texto.
- Definí sonidos de interfaz (hover, click, notificaciones, errores).
- Definí rango dinámico (quiet, medio, dinámico) con compresión.
- Definí compresión de audio con limiter.
- Definí dispositivo de salida (predeterminado, auriculares, altavoces, HDMI, Bluetooth).
- Definí pruebas con auriculares (estéreo, espacial 3D, balance de canales).
- Definí pruebas con altavoces (estéreo, 5.1, 7.1, balance de canales).
- Diseñé menú de configuración de audio con todos los controles (sliders, toggles, dropdowns).
- Diseñé AudioSettings (Resource) para configuración actual.
- Diseñé AudioBusSetup para setup de buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic).
- Diseñé Audio3DSetup para espacialización y oclusión.
- Diseñé SubtitleManager para mostrar subtítulos.
- Diseñé UISoundManager para sonidos de interfaz.
- Diseñé DynamicRangeManager para rango dinámico con compresión.
- Diseñé CompressionManager para compresión de audio con limiter.
- Diseñé OutputDeviceManager para dispositivo de salida.
- Diseñé AudioTestManager para pruebas de audio.
- Diseñé AudioSettingsLoader para carga de configuración al inicio.
- Diseñé AudioSettingsSaver para guardado de configuración al cerrar.
- Diseñé integración con M58 (Accesibilidad) para ajustes de accesibilidad.
- Diseñé integración con M87 (Internacionalización) para subtítulos multiidioma.
- Diseñé integración con M61 (Rendimiento) para streaming y pool de AudioPlayers.

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos de Godot (escenas, scripts) — requiere implementación real.
- Implementar audio 3D con espacialización y oclusión en Godot Engine — requiere integración con AudioServer y physics.
- Implementar pruebas de audio con auriculares y altavoces — requiere hardware real para testear.
- Ejecutar tests de volúmenes, audio 3D, subtítulos, rango dinámico, compresión, dispositivo de salida — requiere código real para testear.

### Recomendaciones para el primer agente (implementador)
- Implementar AudioSettingsMenu en Godot Editor con todos los controles (sliders, toggles, dropdowns).
- Implementar AudioSettings como Resource en Godot.
- Implementar AudioBusSetup para setup de buses de audio (Master, Music, SFX, Ambient, Voice, UI, Cinematic).
- Implementar Audio3DSetup para espacialización y oclusión.
- ~~Implementar SubtitleManager para mostrar subtítulos.~~ ✅ **HECHO 2026-10-02** (mimo-v2.6-flash-free) → `scripts/ui/subtitle_manager.gd` + test 80 checks
- Implementar UISoundManager para sonidos de interfaz.
- Implementar DynamicRangeManager para rango dinámico con compresión.
- Implementar CompressionManager para compresión de audio con limiter.
- Implementar OutputDeviceManager para dispositivo de salida.
- Implementar AudioTestManager para pruebas de audio.
- Implementar AudioSettingsLoader para carga de configuración al inicio.
- Implementar AudioSettingsSaver para guardado de configuración al cerrar.
- Integrar con M58 (Accesibilidad) para ajustes de accesibilidad.
- Integrar con M87 (Internacionalización) para subtítulos multiidioma.
- Integrar con M61 (Rendimiento) para streaming y pool de AudioPlayers.
- Probar volúmenes en diferentes escenarios.
- Probar audio 3D con auriculares y altavoces.
- Probar subtítulos en diferentes idiomas.
- Probar rango dinámico (quiet, medio, dinámico).
- Probar compresión de audio.
- Probar cambio de dispositivo de salida.
- Probar sonidos de interfaz.


---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 24:05:00
**Estado:** Parcial (núcleo de configuración de audio implementado y verificado; módulo liberado 🟡)

### Lo que hice
- AudioConfigService autoload (scripts/audio/audio_config_service.gd): 7 buses de audio creados en runtime enrutados a Master (Master/Music/SFX/Ambient/Voice/UI/Cinematic — §4), set_volumen/get_volumen con clamp y linear→db, set_mute/esta_muteado, defaults del diseño §3 coherentes con GestorConfig DEFAULTS_BASE de M60 (Master 0.8/Music 0.7/SFX 0.8/Ambient 0.6/Voice 0.9/UI 0.5/Cinematic 0.8), persistencia automática en cada set vía M60 GestorConfig sección "audio" (ya existía en DEFAULTS_BASE desde mi iter. 2 de M87), señales volumen_cambiado/mute_cambiado para UI M53 y M41-M44.
- Provider ISaveProvider M59 sección "audio_config" (volúmenes + mutes por sesión).
- Test test_audio_config.gd: buses creados y enrutados, defaults, set/clamp, AudioServer refleja db, mute/unmute, persistencia M60 round-trip, coherencia con GestorConfig → **0 fallos a la primera**.
- Regresiones: test_datos_m60 66/0, test_localizacion_iter2 M87 0 fallos.
- Checklist: progreso relevado (ítems del núcleo).

### Lo que NO pude hacer (honestidad obligatoria)
- Menú de sliders (audio_settings_menu.gd): UI M53 con dueño (las señales/API están listas).
- Audio 3D HRTF/oclusión, subtítulos, rango dinámico, compresión, dispositivo de salida: iteraciones V2 (requieren AudioEffect3D real en escenas y UI).
- Buses reales de música/SFX reproduciendo contenido: M41-M44 (los buses ya existen para cuando reproduzcan).

### Recomendaciones para el próximo agente
- M53: sliders usan set_volumen(bus, valor) y escuchan volumen_cambiado; buses_disponibles() devuelve las claves.
- M41-M44: reproducir contenido por bus con AudioServer.get_bus_index("Music"/"SFX"/"Ambient"/"Voice") — ya creados.
- M58: "Sin truenos" puede mutear SFX vía set_mute("SFX", true) parcial (o filtrar por stream).
- La persistencia es automática en cada set (GestorConfig M60) — no duplicar en el menú.

---

## Notas del Agente — Iteración 2: efectos de bus (historial, no borra las anteriores)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial (lote 1 de 5: rango dinámico + compresión + dispositivo de salida, implementado y verificado)

### Lo que hice

Tres subsistemas nuevos, **stateless** (el estado se deriva de `AudioServer`,
sin nodos ni coste por frame), en `game/isla-ancestral/scripts/audio/`:

| Archivo | `class_name` | Cubre |
|---|---|---|
| `dynamic_range_manager.gd` | `DynamicRangeManager` | perfiles quiet/medio/dinámico + knobs manuales (threshold, ratio, attack, release) |
| `compression_manager.gd` | `CompressionManager` | limiter con threshold/ceiling/soft_clip (on/off) |
| `output_device_manager.gd` | `OutputDeviceManager` | `dispositivos()` / `actual()` / `seleccionar()` + 5 categorías de UI |

- Test nuevo `scripts/audio/test_audio_effects_m91.gd`: **82 checks, 0 fallos**,
  con piso `CHECKS_MINIMOS := 82` **medido en verde** (patrón M105, no estimado).
- Suite base `test_audio_config.gd`: **0 fallos** (regresión nula — se verificó en cada iteración).
- `tools/ci/run_tests.py --module m91` → **1 OK, 0 FAIL** (auto-descubre el test).
- Checklist: **92 → 118 `[x]`** (26 ítems), totales recalculados, 239 ítems intactos.

### ⚠️ API real de Godot 4.7.2 — los esqueletos de este documento están MAL (T-107)

Este `04-Codigo.md` (§9/§10/§11, escrito por Devin/SWE-1.6) cita **nombres de
API inexistentes en Godot 4.7**. Se sondearon por reflexión antes de codificar;
la guía queda registrada en `GUIA-GODOT/06-registro-errores.md` **T-107**:

| § del documento | Afirmación del diseño | **Real en Godot 4.7.2** |
|---|---|---|
| §11 | `AudioServer.get_device_list()` | **`get_output_device_list()`** |
| §11 | `AudioServer.set_device(n)` | **`set_output_device(n)`** |
| §11 | `AudioServer.get_device()` | **`get_output_device()`** |
| §9 | `compressor.release_us` | **`release_ms`** (milisegundos, no µs) |
| §9 | `compressor.output_gain` | **`gain`** |
| §10 | `limiter.ceil_db` | **`ceiling_db`** |
| §10 | `limiter.soft_clip = true` | **`soft_clip_db`** + **`soft_clip_ratio`** (no booleano) |

Los esqueletos §4-§14 **NO deben copiarse tal cual**: fallan al compilar.

### Arquitectura: qué NO crear (evitar duplicación, §9/§21.4)

El esqueleto §2/§15 pide 12 archivos, pero **4 ya están resueltos** por el núcleo
de `audio_config_service.gd` (Iteración 1). Crearlos duplicaría estado:

| Diseñado | Estado real | Decisión |
|---|---|---|
| `audio_bus_setup.gd` | `_crear_buses()` ya crea y enruta los 7 buses | **NO crear** |
| `audio_settings.gd` (Resource) | `_volumenes` / `_mutes` en `AudioConfigService` | **NO crear** |
| `audio_settings_loader.gd` | `_cargar_config()` (M60 sección `audio`) | **NO crear** |
| `audio_settings_saver.gd` | `_guardar_config()` (automático en cada `set_volumen`) | **NO crear** |

También: las **rutas del §2 son incorrectas** (`res://audio/`, `res://ui/`,
`res://settings/`) — la convención real del proyecto es
`game/isla-ancestral/scripts/audio/`, `scripts/ui/…`.

### Lo que NO pude hacer (honestidad obligatoria)

- **Sliders y menú de settings** (`audio_settings_menu.gd`, 13 ítems de "Menú de
  configuración de audio"): la UI es de **M53** (§16 Iteración 1 lo establece;
  las señales `volumen_cambiado` y `buses_disponibles()` ya están listas).
  Quedó pendiente el glue 0-100% ↔ 0-1 en `AudioConfigService`.
- **Subtítulos** (`subtitle_manager.gd`), **sonidos de interfaz**
  (`ui_sound_manager.gd`), **audio 3D** (`audio_3d_setup.gd`), **pruebas de
  audio** (`audio_test_manager.gd`): 0 código; requieren escenas/streams.
- **Integración M58 / M87 / M61** (dueños: esos módulos, ver §15).
- **`06-Plan-Testings.md`** no existe todavía en `plan-actual/`.
- **Pruebas con auriculares/altavoces** (5.1/7.1, HRTF): requieren hardware
  real; solo se puede verificar la API headless.

### Recomendaciones para el próximo agente

- **No dupliques buses ni persistencia**: `AudioConfigService` ya lo hace todo.
  Usa `DynamicRangeManager` / `CompressionManager` / `OutputDeviceManager`
  (son stateless, se llaman directo, sin instanciar).
- **M53**: `set_volumen(bus, valor)` toma 0-1; si el slider va 0-100, divide
  antes. Escuchá `volumen_cambiado`. Para el dropdown de salida:
  `OutputDeviceManager.dispositivos()` (lista real) y `categorias()` (etiquetas).
- **Antes de copiar cualquier esqueleto de este documento, sondeá la API** con
  `--check-only` + un script de reflexión sobre `get_property_list()`
  (T-105: `--check-only` NO valida métodos del motor; T-107: nombres de
  propiedades nativas).
- **`class_name` requiere el caché de clases**: tras crear un `.gd` con
  `class_name`, regenerar con
  `godot --headless --editor --quit --path game/isla-ancestral`
  **borrando antes** `.godot/global_script_class_cache.cfg` (si no, la caché
  vieja marca los archivos como escaneados y no registra la clase nueva).
  `.godot/` no está versionado, es seguro regenerarlo.

---

## Notas del Agente — Lote 2: API de porcentaje 0-100 (sliders de M53)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Completado — commit `9afa2d0` (lote 1) + lote 2 pendiente de commit

### Lo que hice

Añadido a `scripts/audio/audio_config_service.gd` (autoload `AudioConfig`),
**sin tocar la lógica existente** (los 7 buses, mute, persistencia M60 y las
señales siguen intactos):

| Función | Tipo | Qué hace |
|---|---|---|
| `porcentaje_a_lineal(p)` | `static` | slider 0-100 → lineal 0-1 (clamp incluido) |
| `lineal_a_porcentaje(v)` | `static` | lineal 0-1 → slider 0-100 |
| `porcentaje_a_db(p)` | `static` | slider 0-100 → dB vía `linear_to_db`, piso -80 dB |
| `db_a_porcentaje(db)` | `static` | inversa (vía `db_to_linear`) |
| `set_volumen_porcentaje(bus, p)` | instancia | fija volumen desde el slider (reutiliza `set_volumen`) |
| `get_volumen_porcentaje(bus)` | instancia | devuelve el valor 0-100 del slider |

**Decisión de diseño:** el estado interno **sigue siendo lineal 0-1**. El
porcentaje es solo la capa de presentación, así persistencia (M60), señales
(`volumen_cambiado`) y mute **no cambian de semántica** y no hay dos fuentes
de verdad. `set_volumen_porcentaje` delega en `set_volumen`, así que
persiste y emite señal automáticamente.

### Verificación

- `--check-only` del autoload: **EXIT 0**, sin parse errors.
- **Sondeo T-107 antes de codificar** (no adivinar): se ejecutaron
  `linear_to_db(0.5) = -6.02` y `db_to_linear(-6.0) = 0.501` en headless
  para confirmar que existen y dan lo esperado.
- `test_audio_config.gd`: **66 checks, 0 fallos**, EXIT 0 — piso
  `CHECKS_MINIMOS := 66` **medido en verde**.
- `test_audio_effects_m91.gd`: **82 checks, 0 fallos** (regresión nula).
- `tools/ci/run_tests.py --module m91`: **1 OK, 0 FAIL**.
- Checklist: **118 → 141 `[x]`** (+23), 98 `[ ]`, 0 `[?]`, total 239 intacto.

### Qué cubren los 23 ítems marcados

Los ítems `Definir valores por defecto`, `Definir slider de volumen de X
(0-100%)`, `Definir valor por defecto NN%` y `Definir conversión de slider
0-100 a dB` de las 7 secciones (maestro, música, efectos, ambiente, voces,
UI, cinemáticas) — más los ítems 33/34 del bloque general.

Los defaults ya existían en `DEFAULTS` (80/70/80/60/90/50/80 %) y ahora
están **testeados expresados en porcentaje**.

### Lo que NO marqué (honestidad)

- `Definir control de música/efectos/ambiente/voces/UI de fondo` → requiere
  los motores M41/M42/M43 (lote 4, integración).
- `Definir aplicación al bus de X` (6 ítems) → ahora mismo solo está verificado
  el **estado inicial** de cada bus y el cambio dinámico de **Music**; lo
  correcto es un test que cambie cada bus y compruebe el dB resultante.
  Queda para el lote 4 con tests dedicados por bus, **no** se marca "por hacer".
- Sliders reales en pantalla (`Diseñar controles para volumen … slider`,
  líneas 198-204) → **dueño M53**; acá está la API que esa UI va a consumir.

### Nota sobre CI

`tools/ci/run_tests.py --module m91` solo descubre
`test-audio_effects_m91.gd`, **no** `test_audio_config.gd`. La suite base se
verifica ejecutándola directamente. Vale la pena revisar el descubrimiento
del runner en el lote 4.

### Recomendaciones para el próximo agente (M53)

```gdscript
# En el menú de settings:
slider.value = AudioConfig.get_volumen_porcentaje("Music")   # ya 0-100
slider.value_changed.connect(func(v): AudioConfig.set_volumen_porcentaje("Music", v))
AudioConfig.volumen_cambiado.connect(func(bus, vol): ...)    # 0-1 lineal
# Si querés mostrar dB en la UI:
label.text = "%.1f dB" % AudioConfig.porcentaje_a_db(slider.value)
```

---

## Notas del Agente — Iteración 3 (Lote 3: subtítulos)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial — subtítulos implementados y verificados; sonidos de
interfaz **bloqueados** (0 assets de audio en el proyecto).

### Archivos tocados en este lote

| Archivo | Qué pasó |
|---|---|
| `scripts/ui/subtitle_manager.gd` | **Nuevo.** Autoload `SubtitleManager` |
| `scripts/ui/test_subtitles_m91.gd` | **Nuevo.** 80 checks, 0 fallos, piso 50 |
| `project.godot` | **+1 línea:** autoload `SubtitleManager` (verificado: diff `1 0`) |
| `03-Diseno.md` §6 | **Reescrito:** rutas/claves/código real + los 4 defectos del esqueleto |
| `03-Diseno.md` §7 | **Nota de bloqueo:** `UISoundManager` sin implementar y sin assets |
| `04-Codigo.md` §2/§7/§15/§16 | Ruta corregida, esqueleto retirado, fila y recomendación marcadas |
| `05-Checklist.md` | **141 → 157 `[x]`** (16 ítems), 82 `[ ]`, 0 `[?]`, total 239 intacto |
| `GUIA-GODOT/06-registro-errores.md` | **T-109** agregada (cabecera → T-105 a T-109) |

### Descubrimiento nuevo: T-109

Un test `--script` que `await`ea relojes tarda **~60 s en vez de 3** y reporta
**393** ObjectDB leaks donde los tests sin `await` reportan 66. Medí la curva:

| awaits | tiempo de juego | wall clock |
|---|---|---|
| 0 | 0,00 s | 2,9 s |
| 1 | 0,02 s | 2,9 s |
| 3 | 0,15 s | **56,6 s** |
| 3 | 0,70 s | **48,7 s** |

No es lineal: es un **umbral fijo** (los autoloads de mundo generan terreno y
al salir hay que liberarlo). Dos consecuencias prácticas:

1. **Acortar los `await` no mejora el tiempo** — no reescribas duraciones.
2. **El recuento bruto de ObjectDB leaks no es señal de regresión propia.**
   Hay que comparar **por tipo**: con `--verbose`, mis
   `CanvasLayer`/`PanelContainer`/`RichTextLabel` dieron **0** — todo el
   excedente era `MeshInstance3D`/`ArrayMesh`/`Node3D` de mundo.

Bonus: los **márgenes de tiempo son gratis** (el coste es de umbral), así que
ampliarlos es puro beneficio contra flakiness con frames de ~80 ms.

### Sobre el CI (refinamiento de la nota anterior)

`run_tests.py --module m91` filtra por **substring de la ruta**, no por módulo
real. Por eso `test_audio_config.gd` quedaba fuera: su nombre no contiene
`"m91"`. `test_subtitles_m91.gd` sí entra (y ahora CI reporta **2 OK, 0 FAIL**).
Arreglar el descubrimiento sigue siendo lote 4.

### Lo que NO pude hacer (honestidad obligatoria)

- **Sonidos de interfaz** (ítems 18, 74, 110-113, 207, 240-242): el proyecto
  tiene **0 archivos `.wav`/`.ogg`/`.mp3`**. No hay nada que reproducir.
  `03-Diseno.md` §7 queda con nota de bloqueo en vez de ítems `[x]`.
- **Ítem 179** — subtítulos en 6 idiomas: solo existen `es`/`en`/`pt`
  (`data/localizacion/`). El mecanismo multiidioma está listo, el contenido no.
- **Ítem 107** — accesibilidad M58: es otro módulo, no lo toqué.
- **Ítem 17** (umbrella "Subtítulos") queda `[ ]` mientras 107 y 179 sigan
  abiertos (mismo criterio que "Rango dinámico", ya implementado y aún `[ ]`).
- **Ítems 48/55/62/69/76/83** ("aplicación al bus de X") y **46/53/60/67/74**
  ("control de X") → lote 4, tal como quedó anotado en la iteración 2.

### Recomendaciones para el próximo agente

- **M53** ya puede cablear los sliders de subtítulos contra
  `SubtitleManager` (ver §7 arriba). No hace falta nada más en M91.
- Para **sonidos de interfaz**: primero conseguir samples (importar 4 cortos)
  o decidir síntesis con `AudioStreamWAV` procedural. Recién después codificar.
- El **coste de 60 s** del test de subtítulos es aceptable dentro del
  `--timeout 180`. Si algún día se arregla (que los autoloads de mundo no
  generen en `--script`), eso es tarea de los   módulos de mundo, no de M91.

---

## Notas del Agente — Iteración 4 (Lote 4: aplicación/control por bus)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial — checklist **157 → 168 `[x]`**, **71 `[ ]`**, **0 `[?]`**,
total 239 intacto.

### Archivos tocados

| Archivo | Qué |
|---|---|
| `scripts/audio/test_audio_config.gd` | +`_test_aplicacion_y_control_por_bus()` (37 checks); piso **66 → 103** |
| `03-Diseno.md` §4 | +**Tabla de enrutamiento** y nota de la implementación real |
| `05-Checklist.md` | **11 ítems** `[ ]` → `[x]` (delta verificado) |

### Los 11 ítems

**"Aplicación al bus de X" (6 — L48/55/62/69/76/83).** Para cada bus hijo el
test comprueba que `set_volumen_porcentaje(bus, p)` llega al `volume_db`
**de esa instancia**, que el estado interno lineal lo sigue, y que `Master`
(bus padre) aplica igual.

**"Control de X" (5 — L46/53/60/67/74).** El diseño estaba incompleto: no
existía ninguna parte que dijera **qué familia de sonido va a qué bus**. Se
añadió la tabla en `03-Diseno.md` §4:

| Familia | Bus |
|---|---|
| Música de fondo | `Music` |
| Audio de cinemáticas | `Cinematic` |
| Herramientas / craft / interacción | `SFX` |
| Viento / agua / pájaros | `Ambient` |
| Voces de NPCs y de cinemáticas | `Voice` |
| Hover / click / notificaciones | `UI` |

Más la regla de **independencia**, verificada empíricamente: mover `Music`
deja intactos los otros 5 buses, y el mute de `UI` no contamina a `Voice`.
Por eso L46 son **dos** controles (`Music` y `Cinematic`), no uno.

### Descubrimiento

`03-Diseno.md` §4 todavía presentaba `audio_bus_setup.gd` como implementación.
**Ese archivo nunca existió.** Los 7 buses los crea
`AudioConfig._crear_buses()` (`audio_config_service.gd:48`), de forma
idempotente (solo `add_bus` si el nombre aún no existe). Quedó documentado.

### Verificación

`test_audio_config.gd` → **103 checks, 0 fallos, EXIT 0**, y el piso
`CHECKS_MINIMOS = 103` pasa (medido en verde, dos corridas seguidas).

### Reparto de los 71 ítems que quedan

| # | Grupo | Por qué |
|---|---|---|
| 13 | Especificación (L10-23) | revisar/contrastar con `01-Requerimientos` |
| 12 | Menú de configuración (L198-211) | **dueño M53** — ahí vive la UI |
| 10 | Sonidos de interfaz (6) + UISoundManager (4) | **bloqueado:** 0 assets de audio |
| 9 | Pruebas con auriculares (4) / altavoces (5) | **requieren hardware del usuario** |
| 6 | Audio 3D (L88-95) | subsistema propio |
| 5 | Plan de testings (L310-316) | `06-Plan-Testings.md` → lote 5 |
| 3 | AudioTestManager (L271-273) | depende de ese manager (no creado) |
| 3 | Pruebas de calidad (L303/305/307) | balance de canales / espacial 3D / dispositivo |
| 2 | Subtítulos (L102, L107) | selector de color (M53) y M58 |
| 2 | M87 (L179, L181) | 6 idiomas (solo hay es/en/pt) y localización de dispositivos |
| 2 | Guardado (L285, L288) | `save_settings()` / trigger al cerrar |
| 1+1+1+1 | `apply_settings` (L216), `load_settings` (L277), `dropdown` de dispositivo (L147), alto contraste M58 (L171) | sueltos |

### Recomendaciones para el próximo agente

- **Lote 5 natural:** `06-Plan-Testings.md` (5 ítems) — ya existe cobertura
  real que documentar: volúmenes (`test_audio_config`), rango dinámico y
  compresión (`test_audio_effects_m91`), subtítulos (`test_subtitles_m91`).
- **M53** puede cablear los 7 sliders con la API ya probada; los ítems
  L198-211 son suyos, no míos.
- **No marcar** los 10 de sonidos de interfaz ni los 9 de hardware: son
  bloqueos reales, no deudas de implementación.

---

## Notas del Agente — Iteración 5 (Lote 5: plan de testings)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial — checklist **168 → 173 `[x]`**, **66 `[ ]`**, **0 `[?]`**,
total 239.

### Archivos creados (nuevos)

| Archivo | Qué |
|---|---|
| `plan-actual/06-Plan-Testings.md` | Plan: alcance, 3 suites, ~30 escenarios con criterio de éxito, casos límite, definición de "pasa", rendimiento, huecos y comandos |
| `plan-actual/07-Resultados-Testings.md` | Resultados reales: **265 checks, 0 fallos** en las tres suites |

Con esto el módulo 91 pasa de 5 a 7 archivos en `plan-actual/` (los 2 de
testing que la metodología marca como opcionales — §3 y §11).

### Los 5 ítems marcados

| Ítem | Evidencia |
|---|---|
| L310 `Diseñar 06-Plan-Testings.md (APLICA)` | archivo creado, 8 secciones |
| L311 tests de volúmenes | escenarios V1–V10 → `test_audio_config.gd` 103/0 |
| L314 tests de rango dinámico | R1–R4 → `_test_rango_dinamico` |
| L315 tests de compresión | C1–C4 → `_test_compresion` |
| L316 tests de dispositivo de salida | D1–D4 → `_test_dispositivo_salida` |

### Evidencia de la corrida (2026-10-02)

```
=== TEST M91 AUDIO:     103 checks, 0 fallo(s) ===   exit=0
=== TEST M91 EFECTOS:    82 checks, 0 fallo(s) ===   exit=0
=== TEST M91 SUBTITULOS:  80 checks, 0 fallo(s) ===   exit=0
TOTAL: 265 checks, 0 fallos
```

### Corrección de la línea de Totales

La línea `**Totales:**` de `05-Checklist.md` decía **141/98** (estado del
lote 2) — quedó stale en los lotes 3 y 4. Ahora dice **173/66**. Ojo con eso
al futuro: hay que moverla en cada lote.

### Lo que NO se marcó (y por qué)

- **L303 balance de canales**, **L305 espacialización 3D**,
  **L307 cambio de dispositivo** (3 ítems de "Pruebas de calidad"): los
  primeros dos requieren hardware/oyente humano; el tercero depende del
  dropdown de M53 que no existe. Sí están documentados en el plan §3.2–3.4,
  pero **sin ejecución real no se marcan**.
- **Los 9 ítems de auriculares/altavoces** (§1.2 del plan): mismo motivo.
- El resto de los **66 `[ ]`** queda repartido como se detalla en las notas
  de la iteración 4 (13 especificación, 12 M53, 10 bloqueados por 0 assets
  de audio, 6 audio 3D, M58/M87/guardado/AudioTestManager sueltos).

### Recomendaciones para el próximo agente

- **H-1 (CI):** corregir `tools/ci/run_tests.py` para que `--module` no filtre
  por substring de ruta; hoy `test_audio_config.gd` queda fuera del CI.
  Es trabajo del módulo de CI, no de M91.
- **H-2 (leaks):** leer **T-109** antes de concluir que un test fuga — comparar
  por tipo de instancia, no por total.
- Los 66 ítems que quedan son en su mayoría **bloqueos reales** (hardware,
  assets, otros módulos). Marcar cualquiera de ellos exige resolver ese
  bloqueo primero.

---

## Notas del Agente — Iteración 6 (Lote 6: contraste de Especificación)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial — checklist **173 → 187 `[x]`**, **52 `[ ]`**, **0 `[?]`**,
total 239.

### Qué se hizo

Este lote **no tocó código**: fue la revisión que la iteración 4 había
asignado a la sección "Especificación de configuración de audio"
(*"revisar/contrastar con `01-Requerimientos`"*).

La sección `### [S] Especificación de configuración de audio` son ítems
**rollup**: uno por categoría, mapeados **1:1 con RF1–RF15** de
`01-Requerimientos.md`:

| Ítem | RF | Verificación |
|---|---|---|
| L9 Volumen maestro | RF1 | ya `[x]` |
| L10–L15 Música/Efectos/Ambiente/Voces/UI/Cinemáticas | RF2–RF7 | bus + default + `set_volumen_porcentaje` → `test_audio_config` (103/0) |
| L16 Audio 3D | RF8 | ya `[x]` |
| L17 Subtítulos | RF9 | toggle + tamaño + opacidad + fondo + color → `test_subtitles_m91` (80/0) |
| L18 Sonidos de interfaz | RF10 | **sigue `[ ]`** — 0 assets de audio |
| L19 Rango dinámico | RF11 | pide selector (quieto/medio/dinámico) → `DynamicRangeManager.RANGOS=["quiet","medio","dinamico"]` + `PRESETS` + `aplicar_rango()`/`rango_actual()` |
| L20 Compresión | RF12 | pide toggle → `CompressionManager.activar()/desactivar()/esta_activa()` |
| L21 Dispositivo de salida | RF13 | pide selector → `CATEGORIAS_LISTA=["predeterminado","auriculares","altavoces","HDMI","Bluetooth"]` + `seleccionar_dispositivo()` |
| L22–L23 Pruebas | RF14–RF15 | **siguen `[ ]`** — requieren hardware |

Cada verificación se hizo **leyendo el código real**, no suponiendo:
`RANGOS`, `CATEGORIAS_LISTA`, `activar()/desactivar()` etc. se comprobaron
en los tres managers antes de marcar nada.

### Los 14 ítems marcados

**Especificación (10):** L10, L11, L12, L13, L14, L15, L17, L19, L20, L21.

**Subtítulos (1):**
- **L102** `Definir color de texto (selector)` → `set_text_color()` /
  `get_text_color()` implementados **y testeados**
  (`_test_defaults` default `Color(1,1,1,1)` + `_test_fondo` round-trip).
  El *selector* de color es UI de M53, igual que en L101.

**Sueltos (3)** — aquí **corrijo mi propia clasificación de la iteración 4**,
donde los puse como pendientes sin haberlos leído:

| Ítem | Qué hay realmente |
|---|---|
| L216 `apply_settings()` | esqueleto con cuerpo en `04-Codigo.md` §12; equivalente real `AudioConfig._aplicar_todo()` |
| L277 `load_settings()` | esqueleto en §13 (`AudioSettingsLoader`); real `_cargar_config()` vía M60 |
| L285 `save_settings()` | esqueleto en §14 (`AudioSettingsSaver`); real `_guardar_config()` vía M60 |

Se marcaron `[x]` porque el ítem dice **"Diseñar"** y el diseño existe, con
**evidencia transparente** que dice qué es esqueleto y qué es implementación
real. Sus hermanos de sección (L214, L215, L276, L278, L286, L287) ya estaban
`[x]` con los mismos esqueletos: dejar estos tres `[ ]` habría sido
inconsistente. **L288** (trigger al cerrar settings) **sí sigue `[ ]`**:
no tiene esqueleto, es un evento de la UI de M53.

### Reparto de los 52 `[ ]` restantes

| # | Grupo | Motivo |
|---:|---|---|
| 12 | Menú (L198-211) | **dueño M53** |
| 10 | Sonidos de interfaz (6) + UISoundManager (4) | **bloqueado**: 0 `.wav`/`.ogg`/`.mp3` en el proyecto |
| 9 | Pruebas con auriculares (4) / altavoces (5) | **hardware del usuario** |
| 6 | Audio 3D (L88-95) | subsistema propio sin diseñar |
| 3 | AudioTestManager (L271-273) | depende de ese manager (no creado) |
| 3 | Pruebas de calidad (L303/305/307) | balance / espacial 3D / dispositivo |
| 3 | Especificación (L18, L22, L23) | los 3 bloqueos de arriba, en rollup |
| 2 | M87 (L179, L181) | 6 idiomas (solo hay es/en/pt) y localización de nombres de dispositivo |
| 2 | Guardado (L288) + M58 (L171) | evento de M53 / M58 |
| 2 | Subtítulos (L107) + M58 | M58 |

### Recomendaciones para el próximo agente

- **No quedan lotes de bajo riesgo**: los 52 restantes son bloqueos reales
  (hardware, assets, otros módulos). El siguiente avance viene **desde M53**
  cableando sliders a una API ya probada, o del usuario aportando assets de
  audio.
- El único pendiente técnico propio es **H-1**: `tools/ci/run_tests.py`
  no descubre `test_audio_config.gd` (dueño: módulo de CI, no M91).

## Notas del Agente — Iteración 7 (Lote 7: Audio 3D)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Parcial — 5 de 6 ítems en `[x]`; **L88 queda `[?]` (honesto)**

### Lo que hice

1. **Reescribí `03-Diseno.md` §5 "Audio 3D"** (20 → 119 líneas). El
   esqueleto anterior era **incorrecto**: usaba `AudioEffectEQ` como
   "espacialización", cuando `AudioEffectEQ` **ecualiza, no espacializa**.
2. **Sondeo de la API real (lección T-107)** en Godot 4.7.2, dos pasadas
   (`ClassDB.class_get_integer_constant_list` + `get_property_list()`).
   El script de sondeo (`_probe_a3d.gd`) se **borró** al terminar: no se
   deja basura en el repo.
3. **Marcé 5 ítems `[x]`** — L89 oclusión, L90 Doppler, L91 atenuación,
   L94 raycast, L95 PhysicsBody3D — y **L88 → `[?]`**.
4. **Corregí el ítem L227** del checklist: decía «Diseñar espacialización
   con AudioEffectEQ» y estaba en `[x]` — API falsa marcada como hecha.
   Texto nuevo con el diseño real; el original sigue intacto en
   `plan-inicial/05-Checklist.md:227` (nunca se modifica).

### Hallazgo importante: Godot 4.7.2 NO tiene HRTF

| Pregunta | Resultado del sondeo |
|---|---|
| `panning_mode` en `AudioStreamPlayer3D` | **no existe** — 67 propiedades, solo `panning_strength` |
| `AudioServer` expone HRTF / room | **no** — 0 propiedades coincidentes |
| ¿Algún `AudioEffect*` espacial? | **no** — 29 clases; `AudioEffectPanner` es solo pan estéreo |

Consecuencia: **L88 (HRTF para auriculares) no es alcanzable con el motor
stock.** Las 3 opciones reales quedan documentadas en `03-Diseno` §5.1.1:
GDExtension de terceros (Resonance / Steam Audio), DSP propio como
`AudioEffect`, o aceptar pan equilibrado + atenuación.

> ⚠️ **Impacto en el estado del módulo:** mientras L88 esté en `[?]`, M91
> **no puede cerrarse en `✅`**; al liberarse pasaría a `🟡 Con dudas`.
> Es una decisión real, no un descuido.

### APIs sí verificadas (las de los 5 `[x]`)

- `attenuation_model` → `ATTENUATION_INVERSE_SQUARE_DISTANCE(1)` ·
  `unit_size` 0.1–100 · `max_db` −24..+6 dB · `max_distance` 0–4096 m
- `doppler_tracking` → `DOPPLER_TRACKING_PHYSICS_STEP(2)`
- `PhysicsRayQueryParameters3D`: `collision_mask`, `collide_with_bodies`,
  `collide_with_areas`
- `AudioEffectLowPassFilter.cutoff_hz` → 20–20500 Hz

### Errores propios corregidos en el camino

1. El script de marcado escribía `"[x] ..."` en vez de `"- [x] ..."`:
   6 líneas quedaron **sin el guion** y el conteo cayó a 233. **Reparado**
   inmediatamente → 192/46/1 = 239. Lección: verificar el conteo
   **después** de escribir, no dar por bueno un `replace`.
2. Una aserción exigía que `AudioEffectEQ` no apareciera en el texto nuevo,
   pero lo menciono **a propósito** para explicar el error. La aserción era
   demasiado estricta, no el contenido.

### Reparto de los 46 `[ ]` restantes (+1 `[?]`)

| # | Grupo | Motivo |
|---:|---|---|
| 12 | Menú (L198-211) | **dueño M53** |
| 10 | Sonidos de interfaz (6) + UISoundManager (4) | **bloqueado**: 0 `.wav`/`.ogg`/`.mp3` en el proyecto |
| 9 | Pruebas con auriculares (4) / altavoces (5) | **hardware del usuario** |
| 3 | AudioTestManager (L271-273) | manager no creado |
| 3 | Pruebas de calidad (L303/305/307) | balance / espacial 3D / dispositivo |
| 3 | Especificación (L18, L22, L23) | rollup de los bloqueos de arriba |
| 2 | M87 (L179, L181) | 6 idiomas (solo hay es/en/pt) y localización de nombres |
| 2 | Guardado (L288) + M58 (L171) | evento de M53 / M58 |
| 2 | Subtítulos (L107) + M58 | M58 |
| **1** | **L88 HRTF** | **`[?]` — no existe en el motor** |
| **46** | | |

### Recomendaciones para el próximo agente

- **H-1 sigue abierto** (dueño: módulo de CI): `tools/ci/run_tests.py
  --module` no descubre `test_audio_config.gd`. Alternativa propia:
  renombrar a `test_audio_config_m91.gd` y actualizar `06-Plan-Testings.md`,
  `07-Resultados-Testings.md` y `04-Codigo.md`.
- **Ningún script usa `AudioStreamPlayer3D` todavía.** Cuando entre la
  primera fuente 3D, implementar `03-Diseno` §5.7: bus propio por
  reproductor + `AudioEffectLowPassFilter` + raycast desde el oído.
- **Decisión pendiente del usuario:** HRTF (GDExtension / DSP propio /
  aceptar pan+atenuación). Marcar L88 solo cuando se elija.
- El resto de pendientes es de **M53, M58, M87 o hardware**: no queda
  trabajo técnico propio salvo H-1.


## Notas del Agente — Iteración 8 (Lote 8: H-1 resuelto)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02
**Estado:** Completado — **sin cambios de checklist** (192/46/1/239)

### Qué era H-1

`tools/ci/run_tests.py --module m91` no ejecutaba `test_audio_config.gd`.
Quedó anotado en el lote 5 como «dueño del módulo de CI, no de M91».

### Qué era en realidad

No era un problema de **descubrimiento**, sino de **etiqueta**:

- `find_test_files()` busca `test_*.gd` recursivo bajo `scripts/` y `tests/`
  → `scripts/audio/test_audio_config.gd` **sí se encuentra**.
- `--module X` filtra con `X in ruta_completa`: la cadena `"m91"` no está en
  la ruta de S1 (`test_audio_config.gd`), aunque sí en las otras dos.

### Evidencia (ejecutado 2026-10-02, 0 fallos)

| Comando | Resultado |
|---|---|
| `run_tests.py --module audio --timeout 180` | **8 OK, 0 FAIL** en 20.8 s — `test-audio_config` (**S1**, 103 checks), `test-audio_effects_m91` (**S2**, 82) y además M41/M42/M43/M44/M84/M150 |
| `run_tests.py --module subtitle --timeout 180` | **1 OK, 0 FAIL** en 63.9 s — `test-subtitles_m91` (**S3**, 80) |

`out/test-report.json` ya estaba en `.gitignore` (línea 183): sin artefactos.

### Decisión: NO renombrar el archivo

La alternativa que yo mismo había anotado (renombrar a
`test_audio_config_m91.gd`) habría **roto**
`scripts/editor/_colector_sintaxis.gd:38` — `const _g28 := preload(
"res://scripts/audio/test_audio_config.gd")` — y obligado a tocar ~15
referencias en documentos. **No hacía falta**: la suite ya se descubre.

### Hallazgo adicional (para el dueño del módulo de CI)

`.github/workflows/testing.yml` **no usa** `run_tests.py`: corre GdUnit4
sobre `res://tests` y **todos** sus pasos terminan en `|| true`, así que ese
workflow **nunca falla**. Las suites de M91 son `extends SceneTree`, no
GdUnit4, y quedan fuera de ese camino. Anotado en `07-Resultados` §4 H-1.

### Archivos tocados

- `06-Plan-Testings.md` §2 → comandos corregidos con la tabla de evidencia.
- `07-Resultados-Testings.md` §4 → H-1 marcado ✅ RESUELTO.
- **`05-Checklist.md` sin cambios** — H-1 nunca fue un ítem.

### Recomendaciones para el próximo agente

- **H-1 queda cerrado**: desaparece el único «pendiente técnico propio»
  que quedaba en M91. Lo que resta es **hardware del usuario (9), assets de
  audio (10), M53 (12+), M58, M87, AudioTestManager, pruebas de calidad y el
  `[?]` de HRTF (L88)**.
- Si se quiere cobertura de CI real para M91, hay que migrar las suites a
  **GdUnit4** dentro de `tests/` — eso es módulo de CI, no de M91.
- Las 3 suites siguen en verde: **265 checks, 0 fallos**.
## Notas del Agente — Iteración 9 (Lote 9: pruebas de audio + API de Godot 3)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-02 21:35:00
**Estado:** Completado (el módulo queda con 1 `[?]` pendiente)

### Lo que hice

1. **Reescribí `03-Diseno.md` §11 «Pruebas de audio»** — era un esqueleto con
   solo comentarios `# Test estéreo`. Ahora son 7 subsecciones (11.1–11.7):
   `AudioTestManager` con `enum Test`, señales `test_iniciado` /
   `paso_cambiado` / `test_terminado`, los 4 tests (estéreo, espacial 3D,
   balance de canales, 5.1/7.1) y los botones de prueba de settings, todo con
   la API sondeada en el Lote 7.
2. **Reescribí `03-Diseno.md` §19 «Pruebas de calidad»** — era una lista de
   una línea. Ahora 5 subsecciones (19.1–19.5), automatizadas donde el motor
   lo permite: `get_bus_peak_volume_left_db` / `..._right_db` permiten validar
   el balance **sin oído humano**.
3. **Corregí la API de Godot 3 heredada en 3 documentos** (hallazgo abajo).
4. **Marqué 14 ítems `[x]`**: L150, L152, L157, L160, L161, L162, L163, L167,
   L271, L272, L273, L303, L305, L307 → **192 → 206 `[x]` (86%)**.
5. **Añadí notas anti-inflado** a L18, L22, L23 y L151: siguen en `[ ]` y
   ahora explica *por qué*, para que el próximo agente no los marque «por
   tener hijos en `[x]`» (Trampa 119).
6. Borré el sondeo temporal `scripts/audio/_probe_speaker.gd`.

### Hallazgo: tres documentos usaban la API de Godot 3

`03-Diseno` §10, `02-Analisis` §14 y los ítems L145/L146/L264/L265 del
checklist decían `AudioServer.get_device_list()` / `set_device()` /
`get_device()`. **Esos métodos no existen en Godot 4.7.2.**

| Equivocado (Godot 3) | Real (Godot 4.7.2, sondeo T-107) |
|---|---|
| `AudioServer.get_device_list()` | `AudioServer.get_output_device_list()` |
| `AudioServer.set_device(n)` | `AudioServer.set_output_device(n)` |
| `AudioServer.get_device()` | `AudioServer.get_output_device()` |

**El código implementado NO estaba roto**: `output_device_manager.gd` ya usaba
los nombres correctos desde el Lote 1 y hasta lo advertía en su cabecera. Lo
que estaba mal era **solo la documentación**. Los ítems se reescribieron con
el mismo patrón que L227 (el original queda preservado en
`plan-inicial/05-Checklist.md`, que no se toca).

### ⚠️ Error propio durante el lote — lección para no repetir

Al reemplazar §10 escribí:

```python
k = ls.index("```", ls.index("```", i) + 1)
```

`list.index()` compara **igualdad exacta**, no subcadena. La cerca de apertura
del bloque es `` ```gdscript ``, que **no** es igual a `` ``` ``, así que el
primer `index` saltó a la cerca de **cierre** y el segundo saltó a la
siguiente apertura de otra sección: **se comió 41 líneas de más** (el
encabezado `## 11. Pruebas de audio`, `§11.1` y `§11.2`).

**Cómo se detectó:** el propio script imprimió «reemplazo lineas 544-599
(56 lineas)» en vez de ~15, y la verificación estructural posterior acusó
`## 11`, `### 11.1` y `### 11.2` ausentes (864 líneas donde debían ser 905).

**Recuperación:** el texto fuente vivía en mi propio script
`diseno_s11_s19.py`, así que se restauró desde ahí. No se usó `git restore`
— habría borrado también la reescritura de §19, que todavía no estaba
commiteada. Quedó un `__FIRMA__` del literal crudo que el script original
reemplazaba antes de escribir; se corrigió en la misma pasada.

**Lección:** para cortar un bloque markdown entre cercas de código, buscar la
apertura con `.startswith("```")` y después el siguiente elemento que **sea**
`` ``` ``; nunca dos `index("```")` seguidos.

### Estado del módulo

| Métrica | Antes | Después |
|---|---|---|
| `[x]` | 192 | **206** |
| `[ ]` | 46 | **32** |
| `[?]` | 1 | 1 (L88, HRTF) |
| Total | 239 | 239 |
| Avance | 80% | **86%** |

### Lo que NO pude hacer (honestidad obligatoria)

- **L88 `[?]` / L151 `[ ]` (HRTF)** → Godot 4.7.2 no expone HRTF (verificado
  por reflexión). Limitación real del motor, no un descuido.
- **L22 / L23 (ejecutar pruebas con auriculares y altavoces)** → siguen `[ ]`:
  requieren hardware real del usuario. Les puse nota para que no se inflen.
- **L147 (dropdown de dispositivo de salida)** → `[ ]`: lo diseña y monta M53.
- **L18 y L110–L116 (sonidos de interfaz)** → `[ ]`: `03-Diseno` §7 está
  bloqueado porque el proyecto tiene **cero** assets `.wav`/`.ogg`/`.mp3`.
- **No ejecuté las suites en este lote** (no se tocó GDScript): solo
  documentación. Las 3 suites siguen en **265 checks, 0 fallos**.

### Recomendaciones para el próximo agente

- **M91 está en 86% con un solo `[?]`.** Ya no queda trabajo de diseño
  propio pendiente: lo que resta es de **otros módulos** (M53 menú, M58
  accesibilidad, M87 i18n) o es **bloqueante externo** (assets de audio,
  hardware del usuario).
- **Al liberar, M91 debe salir `🟡 Con dudas`, nunca `✅`**: el `[?]` de L88
  lo impide (§21.2 y §21.6). Mientras el lock siga a mi nombre, la fila de
  `CHECKLIST-GLOBAL.md` no se toca.
- Si algún día se necesita HRTF real, las opciones están escritas en
  `03-Diseno` §5.1.1 (plugin binaural, o aceptar el panorama estéreo actual).
