# Módulo 115: Hardware — Código

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:27:00

## Archivos a Crear

### 1. `scripts/hardware/hardware_detector.gd` — Detección de hardware

```gdscript
class_name HardwareDetector
extends Node

## Detecta hardware del sistema y retorna perfil completo.

func detect() -> HardwareProfile:
    var profile = HardwareProfile.new()
    profile.cpu_cores = OS.get_processor_count()
    profile.cpu_name = OS.get_processor_name()
    profile.cpu_freq_ghz = _estimate_cpu_freq()
    
    var rendering_info = RenderingServer.get_rendering_info()
    profile.gpu_name = rendering_info.get("device_name", "Unknown GPU")
    profile.gpu_vram_mb = rendering_info.get("video_memory_mb", 0)
    
    var memory_info = OS.get_memory_info()
    profile.ram_mb = memory_info.get("total", 0) / 1024
    
    profile.os_name = OS.get_name()
    profile.os_version = OS.get_version()
    profile.detected_at = Time.get_datetime_string_from_system()
    
    return profile

func _estimate_cpu_freq() -> float:
    # Estimación basada en cores (no hay API directa en Godot)
    var cores = OS.get_processor_count()
    if cores >= 16:
        return 4.0
    elif cores >= 8:
        return 3.5
    elif cores >= 6:
        return 3.0
    elif cores >= 4:
        return 2.8
    else:
        return 2.5

func get_input_devices() -> Array[String]:
    var devices: Array[String] = []
    var joy_devices = Input.get_connected_joypads()
    for device_id in joy_devices:
        devices.append(Input.get_joy_name(device_id))
    return devices
```

### 2. `scripts/hardware/quality_preset_selector.gd` — Selector de presets

```gdscript
class_name QualityPresetSelector
extends Node

## Selecciona el mejor preset de calidad basado en el perfil de hardware.

func select_preset(profile: HardwareProfile) -> QualityPreset:
    var score = _calculate_score(profile)
    
    if score >= 80:
        return QualityPreset.ULTRA
    elif score >= 60:
        return QualityPreset.HIGH
    elif score >= 40:
        return QualityPreset.MEDIUM
    elif score >= 20:
        return QualityPreset.LOW
    else:
        return QualityPreset.VERY_LOW

func _calculate_score(profile: HardwareProfile) -> int:
    var score = 0
    
    # VRAM score (0-40 points)
    if profile.gpu_vram_mb >= 8000:
        score += 40
    elif profile.gpu_vram_mb >= 6000:
        score += 35
    elif profile.gpu_vram_mb >= 4000:
        score += 25
    elif profile.gpu_vram_mb >= 2000:
        score += 15
    elif profile.gpu_vram_mb >= 1000:
        score += 5
    
    # RAM score (0-30 points)
    if profile.ram_mb >= 16000:
        score += 30
    elif profile.ram_mb >= 8000:
        score += 20
    elif profile.ram_mb >= 6000:
        score += 15
    elif profile.ram_mb >= 4000:
        score += 10
    else:
        score += 5
    
    # CPU score (0-30 points)
    if profile.cpu_cores >= 12:
        score += 30
    elif profile.cpu_cores >= 8:
        score += 25
    elif profile.cpu_cores >= 6:
        score += 20
    elif profile.cpu_cores >= 4:
        score += 15
    else:
        score += 5
    
    return score
```

### 3. `scripts/hardware/quality_applier.gd` — Aplicador de calidad

```gdscript
class_name QualityApplier
extends Node

## Aplica ajustes de calidad al motor de renderizado.

func apply_preset(preset: QualityPreset) -> void:
    var settings = _get_settings_for_preset(preset)
    _apply_settings(settings)

func _apply_settings(settings: QualitySettings) -> void:
    # Render scale
    get_viewport().scaling_3d_scale = settings.render_scale
    
    # V-Sync
    if settings.vsync:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    
    # Max FPS
    Engine.max_fps = settings.max_fps

func _get_settings_for_preset(preset: QualityPreset) -> QualitySettings:
    var settings = QualitySettings.new()
    settings.preset = preset
    
    match preset:
        QualityPreset.ULTRA:
            settings.render_scale = 1.0
            settings.shadow_quality = 3
            settings.ssao = true
            settings.ssr = true
            settings.lod_bias = 2.0
            settings.max_fps = 120
            settings.vsync = false
            settings.texture_quality = 2
            settings.antialiasing = 4
            settings.volumetric_fog = true
            settings.grass_distance = 1.0
        QualityPreset.HIGH:
            settings.render_scale = 1.0
            settings.shadow_quality = 3
            settings.ssao = true
            settings.ssr = true
            settings.lod_bias = 1.5
            settings.max_fps = 60
            settings.vsync = true
            settings.texture_quality = 2
            settings.antialiasing = 2
            settings.volumetric_fog = true
            settings.grass_distance = 0.75
        QualityPreset.MEDIUM:
            settings.render_scale = 0.85
            settings.shadow_quality = 2
            settings.ssao = true
            settings.ssr = false
            settings.lod_bias = 1.0
            settings.max_fps = 60
            settings.vsync = true
            settings.texture_quality = 1
            settings.antialiasing = 1
            settings.volumetric_fog = false
            settings.grass_distance = 0.5
        QualityPreset.LOW:
            settings.render_scale = 0.7
            settings.shadow_quality = 1
            settings.ssao = false
            settings.ssr = false
            settings.lod_bias = 0.7
            settings.max_fps = 30
            settings.vsync = true
            settings.texture_quality = 0
            settings.antialiasing = 0
            settings.volumetric_fog = false
            settings.grass_distance = 0.25
        QualityPreset.VERY_LOW:
            settings.render_scale = 0.5
            settings.shadow_quality = 0
            settings.ssao = false
            settings.ssr = false
            settings.lod_bias = 0.5
            settings.max_fps = 30
            settings.vsync = true
            settings.texture_quality = 0
            settings.antialiasing = 0
            settings.volumetric_fog = false
            settings.grass_distance = 0.0
    
    return settings
```

### 4. `scripts/hardware/hardware_manager.gd` — Gestor principal

```gdscript
class_name HardwareManager
extends Node

## Gestor principal de hardware. Orquesta detección, selección y aplicación.

var current_profile: HardwareProfile
var current_preset: QualityPreset

func _ready() -> void:
    _initialize_hardware()

func _initialize_hardware() -> void:
    var detector = HardwareDetector.new()
    current_profile = detector.detect()
    
    # Intentar cargar perfil guardado
    var saved_profile = _load_saved_profile()
    if saved_profile:
        current_profile = saved_profile
    
    # Seleccionar preset
    var selector = QualityPresetSelector.new()
    current_preset = selector.select_preset(current_profile)
    
    # Aplicar
    var applier = QualityApplier.new()
    applier.apply_preset(current_preset)
    
    # Guardar
    _save_profile()

func _load_saved_profile() -> HardwareProfile:
    if FileAccess.file_exists("user://hardware_profile.tres"):
        return load("user://hardware_profile.tres") as HardwareProfile
    return null

func _save_profile() -> void:
    ResourceSaver.save(current_profile, "user://hardware_profile.tres")

func get_current_preset() -> QualityPreset:
    return current_preset

func set_preset(preset: QualityPreset) -> void:
    current_preset = preset
    var applier = QualityApplier.new()
    applier.apply_preset(preset)
    _save_profile()
```

## Archivos a Modificar

### 5. `project.godot` — Agregar autoload

**Cómo modificar:** Agregar:
```
[autoload]
HardwareManager="*res://scripts/hardware/hardware_manager.gd"
```

## Integración con Sistemas Existentes

| Sistema | Cómo se conecta |
|---------|-----------------|
| Configuración Gráfica (M90) | Lee/aplica presets de calidad |
| Rendimiento (M61) | Monitorea FPS, ajusta calidad |
| Interfaz de Control (M57) | Detecta gamepads, mapea botones |
| Build Pipeline (M117) | Incluye perfiles en build |
