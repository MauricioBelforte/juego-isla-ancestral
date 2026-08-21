# Módulo 115: Hardware — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:27:00

## 1. Flujo de Detección de Hardware

```
[Juego Inicia]
       │
       ▼
[HardwareDetector]
       │
       ├──► Detectar CPU (cores, freq)
       ├──► Detectar GPU (nombre, VRAM)
       ├──► Detectar RAM total
       ├──► Detectar OS
       └──► Detectar Input Devices
              │
              ▼
       [HardwareProfile]
              │
              ▼
       [QualityPresetSelector]
              │
              ├── Profile劣劣 ──► Very Low
              ├── Profile Low ──► Low
              ├── Profile Medium ──► Medium
              ├── Profile High ──► High
              └── Profile Ultra ──► Ultra
                     │
                     ▼
              [ApplyQualitySettings]
                     │
                     ▼
              [SaveProfile to disk]
```

## 2. Recursos de Datos

### HardwareProfile (Resource)

```gdscript
class_name HardwareProfile
extends Resource

@export var cpu_cores: int
@export var cpu_freq_ghz: float
@export var gpu_name: String
@export var gpu_vram_mb: int
@export var ram_mb: int
@export var os_name: String
@export var os_version: String
@export var quality_preset: QualityPreset
@export var detected_at: String
```

### QualityPreset (Enum)

```gdscript
enum QualityPreset {
    VERY_LOW,
    LOW,
    MEDIUM,
    HIGH,
    ULTRA
}
```

### QualitySettings (Resource)

```gdscript
class_name QualitySettings
extends Resource

@export var preset: QualityPreset
@export var render_scale: float          # 0.5 - 1.0
@export var shadow_quality: int          # 0=Off, 1=Low, 2=Medium, 3=High
@export var ssao: bool
@export var ssr: bool
@export var lod_bias: float             # 0.5 - 2.0
@export var max_fps: int                # 30, 60, 120, unlimited
@export var vsync: bool
@export var texture_quality: int        # 0=Half, 1=Full, 2=Double
@export var antialiasing: int           # 0=None, 1=FXAA, 2=MSAA2, 4=MSAA4
@export var volumetric_fog: bool
@export var grass_distance: float       # 0.0 - 1.0
```

## 3. Nodos Principales

### HardwareDetector (Node)

```gdscript
class_name HardwareDetector
extends Node

## Detecta hardware del sistema y retorna perfil.

func detect() -> HardwareProfile:
    var profile = HardwareProfile.new()
    profile.cpu_cores = OS.get_processor_count()
    profile.cpu_freq_ghz = _get_cpu_freq()
    profile.gpu_name = RenderingServer.get_rendering_info().get("device_name", "Unknown")
    profile.gpu_vram_mb = _get_vram()
    profile.ram_mb = _get_ram()
    profile.os_name = OS.get_name()
    profile.os_version = OS.get_version()
    profile.detected_at = Time.get_datetime_string_from_system()
    return profile

func _get_cpu_freq() -> float:
    # Implementación específica por OS
    return 0.0

func _get_vram() -> int:
    var info = RenderingServer.get_rendering_info()
    return info.get("video_memory_mb", 0)

func _get_ram() -> int:
    var info = OS.get_memory_info()
    return info.get("total", 0) / 1024  # Convert to MB
```

### QualityPresetSelector (Node)

```gdscript
class_name QualityPresetSelector
extends Node

## Selecciona el mejor preset de calidad basado en el perfil de hardware.

func select_preset(profile: HardwareProfile) -> QualityPreset:
    # Reglas de selección basadas en VRAM y RAM
    if profile.gpu_vram_mb >= 6000 and profile.ram_mb >= 16000:
        return QualityPreset.ULTRA
    elif profile.gpu_vram_mb >= 4000 and profile.ram_mb >= 8000:
        return QualityPreset.HIGH
    elif profile.gpu_vram_mb >= 2000 and profile.ram_mb >= 6000:
        return QualityPreset.MEDIUM
    elif profile.gpu_vram_mb >= 1000 and profile.ram_mb >= 4000:
        return QualityPreset.LOW
    else:
        return QualityPreset.VERY_LOW
```

### QualityApplier (Node)

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
    
    # Shadows
    ProjectSettings.set_setting(
        "rendering/lights_and_shadows/directional_shadow/size",
        _shadow_size_from_quality(settings.shadow_quality)
    )
    
    # SSAO
    ProjectSettings.set_setting(
        "rendering/environment/ssao/ssao_enabled",
        settings.ssao
    )
    
    # SSR
    ProjectSettings.set_setting(
        "rendering/environment/ssr/ssr_enabled",
        settings.ssr
    )
    
    # V-Sync
    if settings.vsync:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
    
    # Max FPS
    Engine.max_fps = settings.max_fps

func _get_settings_for_preset(preset: QualityPreset) -> QualitySettings:
    match preset:
        QualityPreset.ULTRA:
            return _ultra_settings()
        QualityPreset.HIGH:
            return _high_settings()
        QualityPreset.MEDIUM:
            return _medium_settings()
        QualityPreset.LOW:
            return _low_settings()
        QualityPreset.VERY_LOW:
            return _very_low_settings()
```

## 4. Integración con Sistemas Existentes

### Con M90 (Configuración Gráfica)

```
[M90 Settings UI] ──► [HardwareDetector.detect()]
                            │
                            ▼
                       [QualityPresetSelector]
                            │
                            ▼
                       [QualityApplier.apply_preset()]
                            │
                            ▼
                       [Guardar en Settings Profile]
```

### Con M61 (Rendimiento)

```
[M61 Performance Monitor] ──► [Auto-adjust quality if needed]
                                    │
                                    ▼
                               [QualityApplier.apply_preset()]
```

### Con M57 (Interfaz de Control)

```
[M57 Input Manager] ──► [Detect gamepad type]
                              │
                              ▼
                         [Map buttons accordingly]
```

## 5. Archivos de Configuración

### Perfiles de Hardware Guardados

```
user://hardware_profile.tres     ← Perfil detectado
user://quality_settings.tres     ← Configuración de calidad
user://input_mapping.tres        ← Mapeo de dispositivos
```

## 6. Perfiles de Rendimiento

| Preset | Render Scale | Shadows | SSAO | SSR | LOD | FPS Target |
|--------|-------------|---------|------|-----|-----|------------|
| Very Low | 0.5 | Off | Off | Off | 0.5 | 30 |
| Low | 0.7 | Low | Off | Off | 0.7 | 30 |
| Medium | 0.85 | Medium | On | Off | 1.0 | 60 |
| High | 1.0 | High | On | On | 1.5 | 60 |
| Ultra | 1.0 | Ultra | On | On | 2.0 | 120 |
