**Modelo:** SWE-1.6
**Plataforma:** Devin

# 03-Diseno.md — Módulo 90: Configuración Gráfica

## 1. Arquitectura del módulo

```
Configuración Gráfica (menú de settings gráficos)
├── Pantalla
│   ├── Resolución (dropdown)
│   ├── Pantalla completa (toggle)
│   ├── Ventana (toggle)
│   └── Borderless (toggle)
├── Performance
│   ├── VSync (dropdown: 0, 1, 2)
│   ├── FPS Cap (dropdown: 30, 60, 120, ilimitado)
│   ├── Escala de resolución (slider: 50%, 75%, 100%, 125%, 150%)
│   └── Upscaling (dropdown: off, FSR 1.0, FSR 2.0, DLSS, XeSS)
├── Calidad
│   ├── Sombras (dropdown: baja, media, alta, ultra)
│   ├── Texturas (dropdown: baja, media, alta, ultra)
│   ├── Distancia de dibujado (slider: cercana, media, lejana)
│   ├── Efectos (dropdown: baja, media, alta, ultra)
│   ├── Vegetación (dropdown: baja, media, alta, ultra)
│   ├── Agua (dropdown: baja, media, alta, ultra)
│   └── Partículas (dropdown: baja, media, alta, ultra)
├── Anti-aliasing
│   ├── Anti-aliasing (dropdown: off, FXAA, MSAA 2x, MSAA 4x, TAA)
│   └── Anisotropic filtering (dropdown: off, 2x, 4x, 8x, 16x)
├── Post-processing
│   ├── Post-processing (toggle)
│   ├── Bloom (toggle + slider de intensidad)
│   ├── Motion blur (toggle + slider de intensidad)
│   └── Depth of field (toggle + slider de intensidad)
├── Presets
│   ├── Bajo (botón)
│   ├── Medio (botón)
│   ├── Alto (botón)
│   ├── Ultra (botón)
│   └── Personalizado (etiqueta de preset actual)
└── Detección automática
    ├── Detección de hardware (GPU, RAM, CPU)
    └── Recomendación de preset
```

## 2. Menú de configuración gráfica

**Archivo: res://ui/settings/graphics_settings_menu.gd**

**Estructura:**
```gdscript
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
```

## 3. Configuración de settings

**Archivo: res://settings/graphics_settings.gd**

**Estructura:**
```gdscript
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
    # Aplicar configuración a Godot Engine
    get_tree().root.set_mode_flags(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync == 1 else DisplayServer.VSYNC_DISABLED)
    Engine.max_fps = fps_cap if fps_cap > 0 else 0
    # ... más configuraciones
```

## 4. Presets gráficos

**Presets:**
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

## 5. Detección automática de hardware

**Archivo: res://settings/hardware_detector.gd**

**Estructura:**
```gdscript
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

## 6. Aplicación de configuración en tiempo real

**Archivo: res://settings/graphics_applier.gd**

**Estructura:**
```gdscript
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

## 7. Integración con M58 (Accesibilidad)

**Accesibilidad:**
- Tamaño de fuente (slider 0.5x a 2x) - integración con M88 FontSettings
- Alto contraste (toggle) - integración con M88 FontSettings
- Reducción de motion blur (opción para reducir mareo)
- Reducción de bloom (opción para reducir distracción visual)

**Implementación:**
- Ajustes de accesibilidad en menú de configuración gráfica
- Ajustes guardados en settings (M90)
- Ajustes aplicados en tiempo real

## 8. Integración con M61 (Rendimiento)

**Rendimiento:**
- FPS counter (opcional, en debug)
- Profiling de GPU (opcional, en debug)
- Monitoreo de uso de GPU y RAM (opcional, en debug)

**Implementación:**
- FPS counter visible en debug (M110 Debug Menu)
- Profiling visible en debug (M110 Debug Menu)
- Monitoreo de uso de GPU y RAM visible en debug (M110 Debug Menu)

## 9. Integración con M88 (Fuentes Tipográficas)

**Fuentes:**
- Tamaño de fuente (slider 0.5x a 2x)
- Alto contraste (toggle)

**Implementación:**
- Ajustes de fuentes en menú de configuración gráfica
- Ajustes guardados en settings (M90)
- Ajustes aplicados en tiempo real

## 10. Diagrama de flujo

```
[Usuario abre settings]
    ↓
[Menú de configuración gráfica]
    ↓
[Usuario selecciona preset o ajusta opciones individuales]
    ↓
[GraphicsSettings se actualiza]
    ↓
[GraphicsApplier aplica configuración en tiempo real]
    ↓
[Configuración guardada en settings (M90)]
    ↓
[Usuario cierra settings]
    ↓
[Configuración aplicada al juego]
```

## 11. Guardado de configuración

**Archivo: user://settings/graphics_settings.json**

**Formato:**
```json
{
    "resolution": {"x": 1920, "y": 1080},
    "fullscreen": false,
    "borderless": false,
    "vsync": 1,
    "fps_cap": 60,
    "resolution_scale": 1.0,
    "upscaling": "off",
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
    "bloom_intensity": 0.5,
    "motion_blur": false,
    "motion_blur_intensity": 0.5,
    "depth_of_field": false,
    "depth_of_field_intensity": 0.5,
    "preset": "medio"
}
```

## 12. Carga de configuración al inicio

**Archivo: res://settings/graphics_settings_loader.gd**

**Estructura:**
```gdscript
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

## 13. Guardado de configuración al cerrar

**Archivo: res://settings/graphics_settings_saver.gd**

**Estructura:**
```gdscript
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

## 14. Pruebas de calidad

**Pruebas manuales:**
- Probar presets gráficos en diferentes hardware
- Probar ajustes individuales
- Probar aplicación en tiempo real
- Probar guardado y carga de configuración
- Probar detección automática de hardware

**Pruebas automáticas:**
- Tests de carga de configuración
- Tests de aplicación de configuración
- Tests de detección de hardware
