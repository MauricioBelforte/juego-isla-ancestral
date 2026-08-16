**Modelo:** Devin
**Plataforma:** Antigravity

# 04-Codigo.md — Módulo 90: Configuración Gráfica

## 1. Carácter del Componente

Módulo de **configuración gráfica** que define menú de settings gráficos, presets, detección automática de hardware y aplicación de configuración en tiempo real. Implementable inmediatamente (depende de M50 para modelos 3D, M61 para rendimiento, M88 para fuentes, M58 para accesibilidad). Es un módulo de UI y settings.

**06-Plan-Testings.md:** APLICA (sistema de UI con múltiples opciones gráficas, requiere testing de presets, ajustes individuales, aplicación en tiempo real, guardado y carga de configuración, detección automática de hardware).

## 2. Archivos involucrados (implementación)

```
res://ui/settings/
├── graphics_settings_menu.gd                → Menú de configuración gráfica
├── font_settings_menu.gd                  → Menú de configuración de fuentes (M88)
└── accessibility_settings_menu.gd          → Menú de configuración de accesibilidad (M58)

res://settings/
├── graphics_settings.gd                     → Configuración gráfica (Resource)
├── graphics_presets.gd                      → Presets gráficos
├── hardware_detector.gd                      → Detección de hardware
├── graphics_applier.gd                       → Aplicación de configuración en tiempo real
├── graphics_settings_loader.gd                → Carga de configuración al inicio
└── graphics_settings_saver.gd                 → Guardado de configuración al cerrar

user://settings/
└── graphics_settings.json                     → Configuración guardada

06-Plan-Testings.md                           → Plan de testings (APLICA)
07-Resultados-Testings.md                      → Resultados de testings (APLICA)
```

## 3. Contratos de integración

### Salida (hacia otros módulos)
- **M50 (Modelos 3D):** Calidad de texturas, LODs afectados por calidad gráfica
- **M61 (Rendimiento):** FPS counter, profiling, monitoreo de GPU/RAM en debug
- **M88 (Fuentes Tipográficas):** Tamaño de fuente, alto contraste en settings
- **M58 (Accesibilidad):** Tamaño de fuente, alto contraste, reducción de motion blur/bloom

### Entrada (desde otros módulos)
- **M50 (Modelos 3D):** Modelos 3D optimizados para diferentes calidades gráficas
- **M61 (Rendimiento):** Recomendaciones de settings según performance
- **M88 (Fuentes Tipográficas):** FontSettings para ajustes de fuentes
- **M58 (Accesibilidad):** AccessibilitySettings para ajustes de accesibilidad

### Configuración
- `res://settings/graphics_settings.gd` define configuración gráfica actual
- `res://settings/graphics_presets.gd` define presets gráficos
- `user://settings/graphics_settings.json` guarda configuración

## 4. Implementación de graphics_settings_menu.gd (esqueleto)

```gdscript
# res://ui/settings/graphics_settings_menu.gd
class_name GraphicsSettingsMenu
extends Control

@onready var resolution_dropdown = $ResolutionDropdown
@onready var fullscreen_toggle = $FullscreenToggle
@onready var windowed_toggle = $WindowedToggle
@onready var borderless_toggle = $BorderlessToggle
@onready var vsync_dropdown = $VSyncDropdown
@onready var fps_cap_dropdown = $FPSCapDropdown
@onready var resolution_scale_slider = $ResolutionScaleSlider
@onready var upscaling_dropdown = $UpscalingDropdown
@onready var shadows_quality_dropdown = $ShadowsQualityDropdown
@onready var textures_quality_dropdown = $TexturesQualityDropdown
@onready var draw_distance_slider = $DrawDistanceSlider
@onready var effects_quality_dropdown = $EffectsQualityDropdown
@onready var vegetation_quality_dropdown = $VegetationQualityDropdown
@onready var water_quality_dropdown = $WaterQualityDropdown
@onready var particles_quality_dropdown = $ParticlesQualityDropdown
@onready var anti_aliasing_dropdown = $AntiAliasingDropdown
@onready var anisotropic_filtering_dropdown = $AnisotropicFilteringDropdown
@onready var post_processing_toggle = $PostProcessingToggle
@onready var bloom_toggle = $BloomToggle
@onready var bloom_intensity_slider = $BloomIntensitySlider
@onready var motion_blur_toggle = $MotionBlurToggle
@onready var motion_blur_intensity_slider = $MotionBlurIntensitySlider
@onready var depth_of_field_toggle = $DepthOfFieldToggle
@onready var depth_of_field_intensity_slider = $DepthOfFieldIntensitySlider
@onready var low_preset_button = $LowPresetButton
@onready var medium_preset_button = $MediumPresetButton
@onready var high_preset_button = $HighPresetButton
@onready var ultra_preset_button = $UltraPresetButton
@onready var custom_preset_label = $CustomPresetLabel
@onready var auto_detect_button = $AutoDetectButton

func _ready():
    load_current_settings()
    populate_dropdowns()

func load_current_settings():
    resolution_dropdown.selected = get_resolution_index(GraphicsSettings.resolution)
    fullscreen_toggle.button_pressed = GraphicsSettings.fullscreen
    borderless_toggle.button_pressed = GraphicsSettings.borderless
    vsync_dropdown.selected = GraphicsSettings.vsync
    fps_cap_dropdown.selected = get_fps_cap_index(GraphicsSettings.fps_cap)
    resolution_scale_slider.value = GraphicsSettings.resolution_scale
    upscaling_dropdown.selected = get_upscaling_index(GraphicsSettings.upscaling)
    shadows_quality_dropdown.selected = get_quality_index(GraphicsSettings.shadows_quality)
    textures_quality_dropdown.selected = get_quality_index(GraphicsSettings.textures_quality)
    draw_distance_slider.value = GraphicsSettings.draw_distance
    effects_quality_dropdown.selected = get_quality_index(GraphicsSettings.effects_quality)
    vegetation_quality_dropdown.selected = get_quality_index(GraphicsSettings.vegetation_quality)
    water_quality_dropdown.selected = get_quality_index(GraphicsSettings.water_quality)
    particles_quality_dropdown.selected = get_quality_index(GraphicsSettings.particles_quality)
    anti_aliasing_dropdown.selected = get_anti_aliasing_index(GraphicsSettings.anti_aliasing)
    anisotropic_filtering_dropdown.selected = get_anisotropic_index(GraphicsSettings.anisotropic_filtering)
    post_processing_toggle.button_pressed = GraphicsSettings.post_processing
    bloom_toggle.button_pressed = GraphicsSettings.bloom
    bloom_intensity_slider.value = GraphicsSettings.bloom_intensity
    motion_blur_toggle.button_pressed = GraphicsSettings.motion_blur
    motion_blur_intensity_slider.value = GraphicsSettings.motion_blur_intensity
    depth_of_field_toggle.button_pressed = GraphicsSettings.depth_of_field
    depth_of_field_intensity_slider.value = GraphicsSettings.depth_of_field_intensity
    custom_preset_label.text = GraphicsSettings.preset.capitalize()

func populate_dropdowns():
    resolution_dropdown.add_item("720p (1280x720)")
    resolution_dropdown.add_item("1080p (1920x1080)")
    resolution_dropdown.add_item("1440p (2560x1440)")
    resolution_dropdown.add_item("4K (3840x2160)")
    resolution_dropdown.add_item("Nativa")
    
    vsync_dropdown.add_item("Off (0)")
    vsync_dropdown.add_item("On (1)")
    vsync_dropdown.add_item("Adaptive (2)")
    
    fps_cap_dropdown.add_item("30 FPS")
    fps_cap_dropdown.add_item("60 FPS")
    fps_cap_dropdown.add_item("120 FPS")
    fps_cap_dropdown.add_item("Ilimitado")
    
    upscaling_dropdown.add_item("Off")
    upscaling_dropdown.add_item("FSR 1.0")
    upscaling_dropdown.add_item("FSR 2.0")
    upscaling_dropdown.add_item("DLSS")
    upscaling_dropdown.add_item("XeSS")
    
    # ... más dropdowns para calidad de sombras, texturas, efectos, vegetación, agua, partículas, anti-aliasing, anisotropic filtering

func _on_resolution_dropdown_item_selected(index: int):
    match index:
        0: GraphicsSettings.resolution = Vector2i(1280, 720)
        1: GraphicsSettings.resolution = Vector2i(1920, 1080)
        2: GraphicsSettings.resolution = Vector2i(2560, 1440)
        3: GraphicsSettings.resolution = Vector2i(3840, 2160)
        4: GraphicsSettings.resolution = DisplayServer.screen_get_size()
    GraphicsApplier.apply_resolution(GraphicsSettings.resolution)
    GraphicsSettings.preset = "personalizado"
    custom_preset_label.text = "Personalizado"

func _on_fullscreen_toggle_toggled(pressed: bool):
    GraphicsSettings.fullscreen = pressed
    GraphicsApplier.apply_fullscreen(pressed)
    GraphicsSettings.preset = "personalizado"
    custom_preset_label.text = "Personalizado"

func _on_low_preset_button_pressed():
    GraphicsPresets.apply_preset("bajo")
    load_current_settings()

func _on_medium_preset_button_pressed():
    GraphicsPresets.apply_preset("medio")
    load_current_settings()

func _on_high_preset_button_pressed():
    GraphicsPresets.apply_preset("alto")
    load_current_settings()

func _on_ultra_preset_button_pressed():
    GraphicsPresets.apply_preset("ultra")
    load_current_settings()

func _on_auto_detect_button_pressed():
    var hardware = HardwareDetector.detect_hardware()
    var recommended_preset = HardwareDetector.recommend_preset(hardware)
    GraphicsPresets.apply_preset(recommended_preset)
    load_current_settings()
```

## 5. Implementación de graphics_settings.gd (esqueleto)

```gdscript
# res://settings/graphics_settings.gd
class_name GraphicsSettings
extends Resource

var resolution: Vector2i = Vector2i(1920, 1080)
var fullscreen: bool = false
var borderless: bool = false
var vsync: int = 1
var fps_cap: int = 60
var resolution_scale: float = 1.0
var upscaling: String = "off"
var shadows_quality: String = "media"
var textures_quality: String = "media"
var draw_distance: int = 100
var effects_quality: String = "media"
var vegetation_quality: String = "media"
var water_quality: String = "media"
var particles_quality: String = "media"
var anti_aliasing: String = "FXAA"
var anisotropic_filtering: int = 4
var post_processing: bool = true
var bloom: bool = true
var bloom_intensity: float = 0.5
var motion_blur: bool = false
var motion_blur_intensity: float = 0.5
var depth_of_field: bool = false
var depth_of_field_intensity: float = 0.5
var preset: String = "medio"

func apply_settings():
    get_tree().root.set_mode_flags(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync == 1 else DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = fps_cap if fps_cap > 0 else 0
    # ... más configuraciones
```

## 6. Implementación de graphics_presets.gd (esqueleto)

```gdscript
# res://settings/graphics_presets.gd
class_name GraphicsPresets
extends Resource

const PRESETS = {
    "bajo": {
        "resolution": Vector2i(1280, 720),
        "vsync": 0,
        "fps_cap": 30,
        "resolution_scale": 0.5,
        "shadows_quality": "baja",
        "textures_quality": "baja",
        "draw_distance": 50,
        "effects_quality": "baja",
        "vegetation_quality": "baja",
        "water_quality": "baja",
        "particles_quality": "baja",
        "anti_aliasing": "off",
        "anisotropic_filtering": 2,
        "post_processing": false,
        "bloom": false,
        "motion_blur": false,
        "depth_of_field": false
    },
    "medio": {
        "resolution": Vector2i(1920, 1080),
        "vsync": 1,
        "fps_cap": 60,
        "resolution_scale": 0.75,
        "shadows_quality": "media",
        "textures_quality": "media",
        "draw_distance": 100,
        "effects_quality": "media",
        "vegetation_quality": "media",
        "water_quality": "media",
        "particles_quality": "media",
        "anti_aliasing": "FXAA",
        "anisotropic_filtering": 4,
        "post_processing": true,
        "bloom": true,
        "motion_blur": false,
        "depth_of_field": false
    },
    "alto": {
        "resolution": Vector2i(2560, 1440),
        "vsync": 2,
        "fps_cap": 120,
        "resolution_scale": 1.0,
        "shadows_quality": "alta",
        "textures_quality": "alta",
        "draw_distance": 150,
        "effects_quality": "alta",
        "vegetation_quality": "alta",
        "water_quality": "alta",
        "particles_quality": "alta",
        "anti_aliasing": "MSAA 2x",
        "anisotropic_filtering": 8,
        "post_processing": true,
        "bloom": true,
        "motion_blur": true,
        "depth_of_field": true
    },
    "ultra": {
        "resolution": Vector2i(3840, 2160),
        "vsync": 2,
        "fps_cap": 0,
        "resolution_scale": 1.0,
        "shadows_quality": "ultra",
        "textures_quality": "ultra",
        "draw_distance": 200,
        "effects_quality": "ultra",
        "vegetation_quality": "ultra",
        "water_quality": "ultra",
        "particles_quality": "ultra",
        "anti_aliasing": "TAA",
        "anisotropic_filtering": 16,
        "post_processing": true,
        "bloom": true,
        "motion_blur": true,
        "depth_of_field": true
    }
}

static func apply_preset(preset_name: String):
    var preset = PRESETS[preset_name]
    GraphicsSettings.resolution = preset["resolution"]
    GraphicsSettings.vsync = preset["vsync"]
    GraphicsSettings.fps_cap = preset["fps_cap"]
    GraphicsSettings.resolution_scale = preset["resolution_scale"]
    GraphicsSettings.shadows_quality = preset["shadows_quality"]
    GraphicsSettings.textures_quality = preset["textures_quality"]
    GraphicsSettings.draw_distance = preset["draw_distance"]
    GraphicsSettings.effects_quality = preset["effects_quality"]
    GraphicsSettings.vegetation_quality = preset["vegetation_quality"]
    GraphicsSettings.water_quality = preset["water_quality"]
    GraphicsSettings.particles_quality = preset["particles_quality"]
    GraphicsSettings.anti_aliasing = preset["anti_aliasing"]
    GraphicsSettings.anisotropic_filtering = preset["anisotropic_filtering"]
    GraphicsSettings.post_processing = preset["post_processing"]
    GraphicsSettings.bloom = preset["bloom"]
    GraphicsSettings.motion_blur = preset["motion_blur"]
    GraphicsSettings.depth_of_field = preset["depth_of_field"]
    GraphicsSettings.preset = preset_name
    GraphicsSettings.apply_settings()
```

## 7. Implementación de hardware_detector.gd (esqueleto)

```gdscript
# res://settings/hardware_detector.gd
class_name HardwareDetector
extends RefCounted

static func detect_hardware() -> Dictionary:
    var gpu = RenderingServer.get_video_adapter_name()
    var ram = OS.get_static_memory_usage() / 1024 / 1024 / 1024  # GB
    var cpu = OS.get_processor_name()
    
    return {
        "gpu": gpu,
        "ram": ram,
        "cpu": cpu
    }

static func recommend_preset(hardware: Dictionary) -> String:
    var gpu = hardware["gpu"]
    var ram = hardware["ram"]
    var cpu = hardware["cpu"]
    
    # Lógica simple de recomendación
    if "integrated" in gpu.to_lower() or ram < 8:
        return "bajo"
    elif "gtx" in gpu.to_lower() or "rtx" in gpu.to_lower() or ram >= 16:
        return "alto"
    elif "rx" in gpu.to_lower() or ram >= 12:
        return "medio"
    else:
        return "medio"
```

## 8. Implementación de graphics_applier.gd (esqueleto)

```gdscript
# res://settings/graphics_applier.gd
class_name GraphicsApplier
extends RefCounted

static func apply_resolution(resolution: Vector2i):
    get_tree().root.set_mode_flags(DisplayServer.WINDOW_MODE_FULLSCREEN if resolution.y >= 1080 else DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_size(resolution.x, resolution.y)

static func apply_vsync(vsync: int):
    match vsync:
        0: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
        1: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
        2: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)

static func apply_fps_cap(fps_cap: int):
    Engine.max_fps = fps_cap if fps_cap > 0 else 0

static func apply_shadows_quality(quality: String):
    # Configurar calidad de sombras en Godot
    # DirectionalLight.shadow_filter = SHADOW_FILTER_*
    pass

static func apply_textures_quality(quality: String):
    # Configurar calidad de texturas en Godot
    # Texture2D.filter = TEXTURE_FILTER_*
    pass

static func apply_anti_aliasing(anti_aliasing: String):
    # Configurar anti-aliasing en Godot
    # RenderingServer.use_taa = true/false
    pass
```

## 9. Implementación de graphics_settings_loader.gd (esqueleto)

```gdscript
# res://settings/graphics_settings_loader.gd
class_name GraphicsSettingsLoader
extends Node

func _ready():
    load_settings()

func load_settings():
    var file = FileAccess.open("user://settings/graphics_settings.json", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json.error == OK:
            var settings = json.result
            GraphicsSettings.resolution = Vector2i(settings["resolution"]["x"], settings["resolution"]["y"])
            GraphicsSettings.fullscreen = settings["fullscreen"]
            GraphicsSettings.borderless = settings["borderless"]
            GraphicsSettings.vsync = settings["vsync"]
            GraphicsSettings.fps_cap = settings["fps_cap"]
            GraphicsSettings.resolution_scale = settings["resolution_scale"]
            GraphicsSettings.upscaling = settings["upscaling"]
            GraphicsSettings.shadows_quality = settings["shadows_quality"]
            GraphicsSettings.textures_quality = settings["textures_quality"]
            GraphicsSettings.draw_distance = settings["draw_distance"]
            GraphicsSettings.effects_quality = settings["effects_quality"]
            GraphicsSettings.vegetation_quality = settings["vegetation_quality"]
            GraphicsSettings.water_quality = settings["water_quality"]
            GraphicsSettings.particles_quality = settings["particles_quality"]
            GraphicsSettings.anti_aliasing = settings["anti_aliasing"]
            GraphicsSettings.anisotropic_filtering = settings["anisotropic_filtering"]
            GraphicsSettings.post_processing = settings["post_processing"]
            GraphicsSettings.bloom = settings["bloom"]
            GraphicsSettings.bloom_intensity = settings["bloom_intensity"]
            GraphicsSettings.motion_blur = settings["motion_blur"]
            GraphicsSettings.motion_blur_intensity = settings["motion_blur_intensity"]
            GraphicsSettings.depth_of_field = settings["depth_of_field"]
            GraphicsSettings.depth_of_field_intensity = settings["depth_of_field_intensity"]
            GraphicsSettings.preset = settings["preset"]
            GraphicsSettings.apply_settings()
        file.close()
    else:
        # Configuración por defecto
        GraphicsPresets.apply_preset("medio")
```

## 10. Implementación de graphics_settings_saver.gd (esqueleto)

```gdscript
# res://settings/graphics_settings_saver.gd
class_name GraphicsSettingsSaver
extends Node

func save_settings():
    var settings = {
        "resolution": {"x": GraphicsSettings.resolution.x, "y": GraphicsSettings.resolution.y},
        "fullscreen": GraphicsSettings.fullscreen,
        "borderless": GraphicsSettings.borderless,
        "vsync": GraphicsSettings.vsync,
        "fps_cap": GraphicsSettings.fps_cap,
        "resolution_scale": GraphicsSettings.resolution_scale,
        "upscaling": GraphicsSettings.upscaling,
        "shadows_quality": GraphicsSettings.shadows_quality,
        "textures_quality": GraphicsSettings.textures_quality,
        "draw_distance": GraphicsSettings.draw_distance,
        "effects_quality": GraphicsSettings.effects_quality,
        "vegetation_quality": GraphicsSettings.vegetation_quality,
        "water_quality": GraphicsSettings.water_quality,
        "particles_quality": GraphicsSettings.particles_quality,
        "anti_aliasing": GraphicsSettings.anti_aliasing,
        "anisotropic_filtering": GraphicsSettings.anisotropic_filtering,
        "post_processing": GraphicsSettings.post_processing,
        "bloom": GraphicsSettings.bloom,
        "bloom_intensity": GraphicsSettings.bloom_intensity,
        "motion_blur": GraphicsSettings.motion_blur,
        "motion_blur_intensity": GraphicsSettings.motion_blur_intensity,
        "depth_of_field": GraphicsSettings.depth_of_field,
        "depth_of_field_intensity": GraphicsSettings.depth_of_field_intensity,
        "preset": GraphicsSettings.preset
    }
    
    var file = FileAccess.open("user://settings/graphics_settings.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(settings))
    file.close()
```

## 11. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Crear res://ui/settings/graphics_settings_menu.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/graphics_settings.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/graphics_presets.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/hardware_detector.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/graphics_applier.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/graphics_settings_loader.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Crear res://settings/graphics_settings_saver.gd | **IMPLEMENTACIÓN INMEDIATA** |
| Integrar con M50 (Modelos 3D) para calidad de texturas y LODs | **M50 (Modelos 3D)** |
| Integrar con M61 (Rendimiento) para FPS counter y profiling | **M61 (Rendimiento)** |
| Integrar con M88 (Fuentes Tipográficas) para ajustes de fuentes | **M88 (Fuentes Tipográficas)** |
| Integrar con M58 (Accesibilidad) para ajustes de accesibilidad | **M58 (Accesibilidad)** |
| Crear 06-Plan-Testings.md | **IMPLEMENTACIÓN INMEDIATA** |
| Ejecutar 07-Resultados-Testings.md | **M58 (Accesibilidad) / M61 (Rendimiento)** |

## 12. Notas del Agente

**Modelo:** Devin
**Plataforma:** Antigravity
**Fecha:** 2026-08-17 00:30:00
**Estado:** Completado (especificación; implementación inmediata posible)

### Lo que hice
- Resolví los 23 puntos de la sección 89 del plan maestro.
- Definí resoluciones (720p, 1080p, 1440p, 4K, nativa).
- Definí modos de pantalla (pantalla completa, ventana, borderless).
- Definí VSync options (0 off, 1 on, 2 adaptive).
- Definí cap de FPS (30, 60, 120, ilimitado).
- Definí calidad de sombras (baja, media, alta, ultra con cascada y PCSS).
- Definí calidad de texturas (baja 0.5x, media 1x, alta 2x, ultra 4x).
- Definí distancia de dibujado (cercana 50, media 100, lejana 200).
- Definí calidad de efectos (baja, media, alta, ultra).
- Definí calidad de vegetación (baja sin animación, media animación básica, alta animación completa, ultra animación + wind).
- Definí calidad de agua (baja sin reflexiones, media reflexiones básicas, alta reflexiones completas, ultra reflexiones + caustics).
- Definí calidad de partículas (baja 100, media 500, alta 1000, ultra 2000).
- Definí anti-aliasing (off, FXAA, MSAA 2x, MSAA 4x, TAA).
- Definí anisotropic filtering (off, 2x, 4x, 8x, 16x).
- Definí post-processing (toggle, bloom, motion blur, depth of field).
- Definí upscaling (FSR 1.0, FSR 2.0, DLSS, XeSS) según GPU.
- Definí escala de resolución (50%, 75%, 100%, 125%, 150%).
- Definí presets gráficos (bajo, medio, alto, ultra, personalizado).
- Definí detección automática de hardware (GPU, RAM, CPU) y recomendación de preset.
- Diseñé menú de configuración gráfica con todos los controles.
- Diseñé GraphicsSettings (Resource) para configuración actual.
- Diseñé GraphicsPresets con 4 presets (bajo, medio, alto, ultra).
- Diseñé HardwareDetector para detección de hardware y recomendación de preset.
- Diseñé GraphicsApplier para aplicación de configuración en tiempo real.
- Diseñé GraphicsSettingsLoader para carga de configuración al inicio.
- Diseñé GraphicsSettingsSaver para guardado de configuración al cerrar.
- Diseñé integración con M58 (Accesibilidad) para ajustes de fuentes y reducción de effects.
- Diseñé integración con M61 (Rendimiento) para FPS counter y profiling en debug.
- Diseñé integración con M88 (Fuentes Tipográficas) para ajustes de fuentes.

### Lo que NO pude hacer (honestidad obligatoria)
- Crear los archivos físicos de Godot (escenas, scripts) — requiere implementación real.
- Implementar aplicación de configuración de sombras, texturas, efectos en Godot Engine — requiere integración con RenderingServer.
- Implementar upscaling (FSR/DLSS/XeSS) — requiere integración con GPU vendors.
- Ejecutar tests de presets y ajustes individuales — requiere código real para testear.

### Recomendaciones para el primer agente (implementador)
- Implementar GraphicsSettingsMenu en Godot Editor con todos los controles (dropdowns, toggles, sliders).
- Implementar GraphicsSettings como Resource en Godot.
- Implementar GraphicsPresets con 4 presets (bajo, medio, alto, ultra).
- Implementar HardwareDetector con detección de GPU, RAM, CPU.
- Implementar GraphicsApplier con métodos para aplicar cada configuración (resolución, VSync, FPS, sombras, texturas, etc.).
- Implementar GraphicsSettingsLoader para cargar configuración al inicio.
- Implementar GraphicsSettingsSaver para guardar configuración al cerrar.
- Integrar con M50 (Modelos 3D) para calidad de texturas y LODs.
- Integrar con M61 (Rendimiento) para FPS counter y profiling en debug (M110).
- Integrar con M88 (Fuentes Tipográficas) para ajustes de fuentes.
- Integrar con M58 (Accesibilidad) para ajustes de accesibilidad.
- Probar presets en diferentes hardware (bajo, medio, alto, ultra).
- Probar aplicación en tiempo real de ajustes individuales.
- Probar guardado y carga de configuración.
- Probar detección automática de hardware y recomendación de preset.
