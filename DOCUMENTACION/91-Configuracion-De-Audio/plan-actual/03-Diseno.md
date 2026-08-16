**Modelo:** Devin
**Plataforma:** Antigravity

# 03-Diseno.md — Módulo 91: Configuración de Audio

## 1. Arquitectura del módulo

```
Configuración de Audio (menú de settings de audio)
├── Volúmenes
│   ├── Volumen maestro (slider 0-100%)
│   ├── Música (slider 0-100%)
│   ├── Efectos (slider 0-100%)
│   ├── Ambiente (slider 0-100%)
│   ├── Voces (slider 0-100%)
│   ├── UI (slider 0-100%)
│   └── Cinemáticas (slider 0-100%)
├── Audio 3D
│   ├── Toggle de audio 3D
│   ├── Espacialización (HRTF)
│   └── Oclusión
├── Subtítulos
│   ├── Toggle de subtítulos
│   ├── Tamaño (slider 0.5x a 2x)
│   ├── Opacidad (slider 0.2 a 1.0)
│   ├── Fondo (toggle + color)
│   └── Color de texto (selector)
├── Sonidos de interfaz
│   ├── Toggle de sonidos de interfaz
│   ├── Hover
│   ├── Click
│   ├── Notificaciones
│   └── Errores
├── Rango dinámico
│   ├── Quiet (compresión alta)
│   ├── Medio (compresión media)
│   └── Dinámico (sin compresión)
├── Compresión
│   ├── Toggle de compresión
│   ├── Threshold
│   └── Ratio
└── Dispositivo de salida
    ├── Predeterminado
    ├── Auriculares
    ├── Altavoces
    ├── HDMI
    └── Bluetooth
```

## 2. Menú de configuración de audio

**Archivo: res://ui/settings/audio_settings_menu.gd**

**Estructura:**
```gdscript
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
```

## 3. Configuración de settings

**Archivo: res://settings/audio_settings.gd**

**Estructura:**
```gdscript
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
    # Aplicar configuración a AudioServer
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), linear2db(ambient_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear2db(voice_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("UI"), linear2db(ui_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Cinematic"), linear2db(cinematic_volume))
    # ... más configuraciones
```

## 4. Buses de audio

**Buses de audio en AudioServer:**
```
Master (bus índice 0)
├── Music (bus índice 1)
├── SFX (bus índice 2)
├── Ambient (bus índice 3)
├── Voice (bus índice 4)
├── UI (bus índice 5)
└── Cinematic (bus índice 6)
```

**Implementación:**
```gdscript
# res://audio/audio_bus_setup.gd
class_name AudioBusSetup
extends Node

func _ready():
    setup_audio_buses()

func setup_audio_buses():
    # Crear buses de audio
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

## 5. Audio 3D

**Audio 3D:**
```gdscript
# res://audio/audio_3d_setup.gd
class_name Audio3DSetup
extends Node

func setup_audio_3d():
    var sfx_bus = AudioServer.get_bus_index("SFX")
    
    # Agregar efecto de espacialización
    var spatial_effect = AudioEffectEQ.new()
    AudioServer.add_bus_effect(sfx_bus, spatial_effect, 0)
    
    # Agregar efecto de oclusión
    var occlusion_effect = AudioEffectLowPassFilter.new()
    AudioServer.add_bus_effect(sfx_bus, occlusion_effect, 1)
```

## 6. Subtítulos

**SubtitleManager:**
```gdscript
# res://ui/subtitles/subtitle_manager.gd
class_name SubtitleManager
extends Node

@onready var subtitle_label = $SubtitleLabel

func show_subtitle(text: String, duration: float):
    if AudioSettings.subtitles:
        subtitle_label.text = text
        subtitle_label.modulate.a = AudioSettings.subtitle_opacity
        subtitle_label.add_theme_font_size_override("font_size", int(16 * AudioSettings.subtitle_size))
        subtitle_label.visible = true
        await get_tree().create_timer(duration).timeout
        subtitle_label.visible = false

func hide_subtitle():
    subtitle_label.visible = false
```

## 7. Sonidos de interfaz

**UISoundManager:**
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

## 8. Rango dinámico

**DynamicRangeManager:**
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

## 9. Compresión

**CompressionManager:**
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

## 10. Dispositivo de salida

**OutputDeviceManager:**
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

## 11. Pruebas de audio

**AudioTestManager:**
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

## 12. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaño de subtítulos (slider 0.5x a 2x)
- Alto contraste (toggle)
- Reducción de audio complejo (opción para simplificar audio)
- Audio descriptivo (opción para descripción visual en audio)

**Implementación:**
- Ajustes de accesibilidad en menú de configuración de audio
- Ajustes guardados en settings (M91)
- Ajustes aplicados en tiempo real

## 13. Integración con M87 (Internacionalización)

**Internacionalización:**
- Subtítulos en diferentes idiomas (español, portugués, francés, alemán, italiano, ruso)
- Audio de voces en diferentes idiomas (si disponible)
- Localización de nombres de dispositivos de salida

**Implementación:**
- SubtitleManager con soporte multiidioma
- AudioPlayer con soporte multiidioma
- LocalizationManager para traducción

## 14. Integración con M61 (Rendimiento)

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

## 15. Diagrama de flujo

```
[Usuario abre settings]
    ↓
[Menú de configuración de audio]
    ↓
[Usuario ajusta volúmenes y opciones]
    ↓
[AudioSettings se actualiza]
    ↓
[AudioBusSetup aplica configuración a AudioServer]
    ↓
[Configuración guardada en settings (M91)]
    ↓
[Usuario cierra settings]
    ↓
[Configuración aplicada al audio del juego]
```

## 16. Guardado de configuración

**Archivo: user://settings/audio_settings.json**

**Formato:**
```json
{
    "master_volume": 0.8,
    "music_volume": 0.7,
    "sfx_volume": 0.8,
    "ambient_volume": 0.6,
    "voice_volume": 0.9,
    "ui_volume": 0.5,
    "cinematic_volume": 0.8,
    "audio_3d": true,
    "subtitles": true,
    "subtitle_size": 1.0,
    "subtitle_opacity": 0.8,
    "subtitle_background": true,
    "subtitle_color": {"r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0},
    "ui_sounds": true,
    "dynamic_range": "medio",
    "compression": true,
    "output_device": "predeterminado"
}
```

## 17. Carga de configuración al inicio

**Archivo: res://settings/audio_settings_loader.gd**

**Estructura:**
```gdscript
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

## 18. Guardado de configuración al cerrar

**Archivo: res://settings/audio_settings_saver.gd**

**Estructura:**
```gdscript
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

## 19. Pruebas de calidad

**Pruebas manuales:**
- Probar ajustes de volúmenes en diferentes escenarios
- Probar audio 3D con auriculares y altavoces
- Probar subtítulos en diferentes idiomas
- Probar rango dinámico (quiet, medio, dinámico)
- Probar compresión de audio
- Probar cambio de dispositivo de salida
- Probar sonidos de interfaz

**Pruebas automáticas:**
- Tests de carga de configuración
- Tests de aplicación de configuración
- Tests de cambio de dispositivo de salida
