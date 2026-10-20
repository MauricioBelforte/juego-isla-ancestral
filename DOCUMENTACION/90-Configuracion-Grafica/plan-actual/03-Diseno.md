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


## 15. Cierre de diseño de los ítems abiertos (tanda 2026-10-20, Step-5-WorkBuddy)

Tanda sobre la COLA ACTIVA del director (REPOBLACION V3, ítems 97-174 de este módulo).
Estado medido antes de tocar: **201 [x] / 4 [?] / 44 [ ] = 249** en `05-Checklist.md`
(conteo por prefijo de línea). 34 de los 78 ítems ya estaban cerrados por agnes-3-flash
(tandas t6-t13) y step-5-kilocode; esta sección documenta los 44 que quedaban abiertos.

**Evidencia de código (medida hoy, repo en HEAD):**
- Núcleo: `scripts/settings/graphics_config.gd` (575 líneas, `extends RefCounted`, núcleo puro
  headless). Presets SOMBRAS/TEXTURAS/DISTANCIA/EFECTOS/VEGETACION/AGUA/PARTICULAS, AA_OPCIONES,
  UPSCALING, ESCALAS, VSYNC_OPCIONES, FPS_OPCIONES, MODOS, RESOLUCIONES, RANGOS_SLIDERS,
  SLIDERS_DEFAULT, ACCESIBILIDAD_DEFAULT, VOLUMETRICO, CULLING, LOD, DEBUG_FLAGS.
- Suites VERDES con binario real Godot 4.7.2 console (`--headless --script`):
  `test_graphics_config.gd` = 85 checks / 0 fallos / 6 bloques / EXIT 0 / 0 SCRIPT ERROR;
  `test_graphics_config_post_m90.gd` = 57 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR.
- Shaders en disco: `shaders/agua_olas.gdshader`, `shaders/caustics.gdshader`,
  `shaders/oceano.gdshader`, `shaders/wind_vegetacion.gdshader`.
- Medido AUSENTE en disco: menú de UI de ajustes gráficos (`find` por *graphics*settings* = 0
  archivos), métodos `apply_resolution()`/`apply_vsync()`/`apply_anti_aliasing()` (grep = 0),
  colisión de partículas con world (grep = 0), parallax mapping (grep = 0), normal map de olas
  como textura (el shader calcula la normal procedimentalmente).

### 15.1 Controles del menú (ítems 133-152) — contrato núcleo ↔ UI

La UI la construye M53 sobre este núcleo; cada control mapea a una clave de `GraphicsConfig`
con sus opciones ya validadas en código. Control → clave (`graphics_config.gd`) → opciones →
default del preset medio:

| Control | Tipo | Clave | Opciones (const en código) | Default medio |
|---|---|---|---|---|
| Resolución | dropdown | `resolucion` | RESOLUCIONES: 720p/1080p/1440p/4k/nativa | 1080p |
| Pantalla completa | toggle | `modo` = pantalla_completa | MODOS: ventana/pantalla_completa/borderless | ventana |
| Ventana | toggle | `modo` = ventana | ídem (mismo matiz de `modo`, no son flags independientes) | ventana |
| Borderless | toggle | `modo` = borderless | ídem | ventana |
| VSync | dropdown | `vsync` | VSYNC_OPCIONES [0, 1, 2] (disabled/enabled/adaptive) | 1 |
| FPS cap | dropdown | `fps` | FPS_OPCIONES [30, 60, 120, 0] (0 = ilimitado) | 60 |
| Escala de resolución | slider | `escala` | ESCALAS [0.5, 0.75, 1.0, 1.25, 1.5] | 0.75 |
| Upscaling | dropdown | `upscaling` | UPSCALING: off/fsr_1_0/fsr_2_0/dlss/xess | fsr_2_0 |
| Calidad de sombras | dropdown | `sombras` | CALIDADES: baja/media/alta/ultra | media |
| Calidad de texturas | dropdown | `texturas` | CALIDADES | media |
| Distancia de dibujado | slider | `distancia` | DISTANCIA: 300/600/1200/2500 m | media (600 m) |
| Calidad de efectos | dropdown | `efectos` | CALIDADES (multiplicador 0.25/0.5/0.85/1.0) | media |
| Calidad de vegetación | dropdown | `vegetacion` | CALIDADES (0.2/0.45/0.8/1.0) | media |
| Calidad de agua | dropdown | `agua` | CALIDADES (0.25/0.5/0.85/1.0) | media |
| Calidad de partículas | dropdown | `particulas` | CALIDADES → 100/500/1000/2000 por sistema | media |
| Anti-aliasing | dropdown | `aa` | AA_OPCIONES: off/fxaa/msaa_2x/msaa_4x/taa | fxaa |
| Anisotropic filtering | dropdown | `aniso` | 2/4/8/16 (valores por preset; TEXTURAS.aniso) | 4 |
| Post-processing | toggle | `post` | bool — `post=false` apaga TODO (mapeo_post) | true |
| Bloom | toggle + slider | `bloom`, `bloom_intensidad` | bool + [0.0, 1.0] (SLIDERS_DEFAULT 0.5) | true / 0.5 |
| Motion blur | toggle + slider | `motion_blur`, `motion_blur_intensidad` | bool + [0.0, 1.0] (default 0.5; sample_count [4,16] default 8) | false / 0.5 |
| Depth of field | toggle + slider | `dof`, `dof_intensidad` | bool + [0.0, 1.0] (default 0.5; dof_distancia [0,100] default 10; dof_apertura [0,1] default 0.5) | false / 0.5 |

Notas de aplicación: los sliders se clamplean con `validar_slider()` contra `RANGOS_SLIDERS`;
`preset_actual()` devuelve "personalizado" si los valores no coinciden con ningún preset (regla
de `_igual()`); `to_dict()`/`from_dict()`/`from_json()` serializan para M46/M59 (from_json
devuelve false ante JSON inválido o array, verificado por suite).

### 15.2 Agua, olas y partículas (ítems 101, 102, 103, 105)

- **Normal map para olas (102):** el shader `agua_olas.gdshader` deriva la normal
  procedimentalmente de las olas (`NORMAL = normalize(vec3(-dx, 1.0, -dz))`, L49) y el fresnel
  (~L66). Decisión de diseño: **normales procedimentales, sin textura de normal map** (no
  existe el uniform en disco). El slot alternativo `normal_map` + UV2 en el plano de agua
  queda como mejora futura opcional (requiere asset). M51 ya cubre "Agua animada (shader
  olas+fresnel)".
- **Parallax para profundidad (103):** no hay parallax mapping en disco (grep = 0 en shaders).
  Diseño: uniform opcional `parallax_profundidad` (altura + escala) en el shader de agua, con
  la profundidad aparente acotada para no romper la línea de costa (la costa ya se maneja en
  el shader vía `costa`). Implementación diferida; el contrato queda aquí.
- **Colisión de partículas con world (105):** sin nodos de colisión ni SDF en disco
  (grep = 0). Diseño: `GPUParticles3D` + `GPUParticlesCollisionHeightField3/SDF` atado al
  terreno voxel; el nodo de colisión sólo se instancia con calidad >= alta (presupuesto
  `PARTICULAS`: 100/500/1000/2000 por sistema).
- **Interacción con jugador (101):** `scripts/world/agua_animada.gd` sólo tiene `_ready()`
  (medido: sin lógica de jugador). Diseño: al entrar el Player al volumen de agua → emisor de
  salpicadura en el punto de contacto + onda radial (`ripple`) de vida corta, cantidad
  acotada por la calidad de partículas; en baja, sin emisor (sólo audio si lo hubiera).
  Implementación diferida al módulo de movimiento del Player.

### 15.3 Bloom / motion blur / depth of field (ítems 106, 107, 109, 110, 112, 113, 114, 125)

- **Toggle de bloom (106):** implementado en el núcleo — `mapeo_post()` fija
  `glow = bloom AND post`; `aplicar_env(entorno)` setea `entorno.glow_enabled` (verificado por
  `test_graphics_config_post_m90.gd` sobre un `Environment` real y en null-safe headless).
- **Bloom shader para glow (107):** Godot 4 usa el glow integrado del `Environment` (shader
  propio del motor). Parámetros: `glow_enabled` + `glow_bloom` = `bloom_intensidad`
  [0,1] default 0.5; umbrales `bloom_threshold` [0,1] default 0.7 y `bloom_radius` [0,1]
  default 0.3 para fuentes brillantes (las constantes ya existen en RANGOS_SLIDERS /
  SLIDERS_DEFAULT).
- **Motion blur por velocidad de cámara (109, 110):** intensidad proporcional a la velocidad
  lineal de la cámara (clamp [0,1]); `motion_blur_sample_count` [4,16] default 8. Apagado en
  todos los presets salvo ultra; el toggle de accesibilidad `reducir_motion` lo apaga aunque
  el preset lo tenga activo (`mapeo_accesibilidad()`, medido).
- **DoF (112, 113, 114):** `dof_distancia` [0,100] m (distancia focal), `dof_apertura` [0,1]
  (cuánto blur), `dof_intensidad` [0,1] (fuerza); defaults 10 / 0.5 / 0.5. Sólo el preset
  ultra lo activa; `post=false` lo apaga vía `mapeo_post()`.
- **Reducción de bloom por accesibilidad (125):** `reducir_bloom` en ACCESIBILIDAD_DEFAULT;
  `mapeo_accesibilidad()` = `glow AND NOT reducir_bloom` → opción anti-distracción
  implementada como lógica en el núcleo.

### 15.4 Métodos de aplicación (ítems 157, 158, 160) — contratos

Nombres y semántica (la capa de aplicación real va en M90/M53; el núcleo ya expone los datos):

- `apply_resolution() -> Vector2i`: recibe id de RESOLUCIONES; "nativa" se resuelve con
  `DisplayServer.screen_get_size()`; aplica el modo de MODOS con
  `DisplayServer.window_set_mode()` + `window_set_flag(BORDERLESS)`; tamaño efectivo =
  `resolucion_vec2()` (objeto {x, y} con la escala de render aplicada).
- `apply_vsync() -> int`: `vsync` ∈ VSYNC_OPCIONES [0,1,2] →
  `DisplayServer.window_set_vsync_mode(VSYNC_DISABLED/ENABLED/ADAPTIVE)`; devuelve el modo
  aplicado.
- `apply_anti_aliasing() -> String`: `aa` ∈ AA_OPCIONES → `Viewport.msaa_3d` (off/2x/4x) para
  MSAA; `ProjectSettings "rendering/anti_aliasing/quality/msaa_3d"` para el proyecto; FXAA/TAA
  por ProjectSettings. DLSS/XeSS quedan fuera (requieren plugin del vendor — ítems cerrados
  por agnes con `_set_upscaler_proyecto()` como precedente de flags).
- `apply_fps_cap()` **ya existe** en el núcleo (L408: `Engine.max_fps` con validación contra
  FPS_OPCIONES; 0 = ilimitado) → el ítem 159 quedó cerrado por implementación real.

### 15.5 Detección automática (ítem 153)

Botón "Detección automática" → `detect_hardware()` (núcleo L501: RAM por
`OS.get_static_memory_usage()` en MB → GB, CPU por `OS.get_processor_name()` /
`get_processor_count()`) → `recomendar_preset(gpu, ram_gb, nucleos)` (regla MINI: gana la
clasificación más baja de las tres — verificada por test: GPU ultra + 4 GB RAM → "baja";
GPU débil + 32 GB → "baja") → `aplicar_preset(recomendado)`. El modelo de GPU lo resuelve
M115 (HardwareManager); el núcleo deja el marcador `"gpu": ""` (medido L519) y
`recomendar_preset` clasifica el nombre por palabras clave (rtx 40/50, rtx 30/20, gtx 16...).

### 15.6 Pruebas (ítems 162-170, 171, 172, 174)

Ver `06-Plan-Testings.md` (creado en esta tanda). Resumen: legibilidad 720p/1080p/4K
(capturas a resolución nativa — NO headless), soporte de tildes/ñ/símbolos (barrido del
glosario + capturas), localización 6 idiomas (es/pt/fr/de/it/ru), ajustes de accesibilidad
(`reducir_motion` / `reducir_bloom` / `alto_contraste`), rendimiento (tiempo de carga por
preset). Los tests de **detección automática ya existen y están verdes hoy**:
`test_graphics_config.gd` cubre `clasificar_ram`/`clasificar_cpu`, `recomendar_preset`
(5 casos incluida la regla MINI), `from_json` (válido / inválido / array) — 85 checks / 0
fallos / 6 bloques / EXIT 0 con binario real. Los tests de **aplicación** (post/volumétrico/
upscaling/resolución) cubren 57 checks en `test_graphics_config_post_m90.gd` (EXIT 0; esa
suite no tiene guardia de 3 capas — confianza por lectura de flujo + resumen final, no fue
modificada por mí).
