**Modelo:** mimo-v2.5
**Plataforma:** OpenCode
**Última actualización:** 2026-09-18 (FASE 2 — hybrid integration)

# 04-Codigo.md — Módulo 12: Cámara

## 1. Carácter del Componente

Cámara 3ª persona con orbit, zoom, colisión terreno, shake, fade y modos. La cámara canónica es `follow_camera.gd`, instanciada en `main_island.tscn`.

## 2. Archivos involucrados

### Activo (canónico)
```
scripts/follow_camera.gd          → Cámara principal (orbit, zoom, colisión, shake, fade, modos)
```

### Deprecated (código muerto — referencia histórica)
```
scripts/camera/camera_rig.gd      → 267 líneas, nunca instanciado en main_island.tscn
scripts/camera/camera_spring.gd   → Spring-arm duplicado, solo usado por camera_rig
scripts/camera/camera_mode.gd     → Enum + constants, solo usado por camera_rig
scripts/camera/simple_camera.gd   → Alternativa no usada
```

### No existe (pendiente de implementar)
```
scripts/camera/camera_fade.gd     → Integrado en follow_camera.gd (fade_screen, fade_to_black)
scripts/camera/camera_shake.gd    → Integrado en follow_camera.gd (trigger_shake)
scripts/camera/minimap_view.gd    → Pendiente M10
data/camera/camera_settings.tres  → Config vive en autoload GameSettings (M59)
```

## 3. API pública de follow_camera.gd

### Propiedades (@export)
```gdscript
follow_speed: float = 12.0       # Suavizado posicional
zoom_speed: float = 2.0          # Velocidad de zoom por scroll
min_distance: float = 4.0        # Zoom mínimo
max_distance: float = 20.0       # Zoom máximo
min_pitch: float = -10.0         # Pitch mínimo (grados)
max_pitch: float = 60.0          # Pitch máximo (grados)
target_fov: float = 70.0         # FOV anti-mareo
shake_max_amplitude: float = 0.15
shake_max_duration: float = 0.5
shake_frequency: float = 8.0
fade_color: Color = Color.BLACK
fade_default_time: float = 0.3
```

### Métodos
```gdscript
# Movimiento (consumido por player.gd:385-387)
get_camera_forward_xz() -> Vector3
get_camera_right_xz() -> Vector3

# Modos de cámara
set_mode(new_mode: ModoCamara) -> void
get_mode() -> ModoCamara

# Shake (§F)
trigger_shake(amplitude: float, duration: float) -> void

# Fade (§E)
fade_screen(color: Color, time: float) -> void
fade_to_black(time: float = -1.0) -> void
fade_from_black(time: float = -1.0) -> void
```

### Señales
```gdscript
mode_changed(new_mode: ModoCamara)
shake_finished()
transition_finished()
```

### Enum
```gdscript
enum ModoCamara { EXPLORE, BUILD, DIALOG, CUTSCENE, MINIMAP }
```

## 4. Contratos de integración

- **Entrada:** `EventBus.ui.shake_requested(amplitude, duration)` → conectado en _ready si existe.
- **Salida:** `mode_changed`, `shake_finished`, `transition_finished`.
- **Consume:** Player pivot (group "player"), GameSettings (sensibilidad, invert Y), VoxelTerrain (colisión).
- **Publica:** `camera_mode_changed(mode)` para HUD (esconder en Dialog/Cutscene).

## 5. Pendientes del módulo (con dueño)

| Pendiente | Dueño | Estado |
|---|---|---|
| Modo Build (aérea 45°, 12 m) | M17 | [?] — requiere herramienta equipada |
| Modo Dialog (encuadre fijo) | M21 | [?] — requiere sistema de diálogos |
| Modo Cutscene (planos fijos) | M22/M26 | [?] — requiere eventos de historia |
| Minimapa (texturas biomas) | M10 | [?] — requiere generador de mundo |
| Calibración sensación real | Playtest M1 | [?] — requiere juego jugable |
| EventBus.ui.shake_requested | M05 | [?] — requiere event bus |
| Modo Build → Explore al desequipar | M17 | [?] — requiere sistema de herramientas |

## 6. Notas del Agente

**Modelo:** mimo-v2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18 22:40:00
**Estado:** FASE 2 completada — hybrid integration

### Lo que hice
- Decisión arquitectónica: follow_camera.gd = canónico (§15 "no tocar lo que funciona").
- camera_rig.gd = deprecated con comment (nunca se instanció en main_island.tscn).
- Porté features de camera_rig → follow_camera: FOV (70°), shake (gaussiano 8Hz), fade (CanvasLayer), modos (enum).
- Deprecated camera_spring.gd, simple_camera.gd con comments.
- Rewritten 03-Diseno.md y 04-Codigo.md con arquitectura real.

### Lo que NO pude hacer (honestidad obligatoria)
- Tests headless: binario Godot inaccesible desde shell (host sin permisos GUI).
- Verificación visual: host sin GUI para captura de pantalla.
- Implementar modos Build/Dialog/Cutscene/Minimap: dependen de M17/M21/M22/M26/M10.
- Conectar EventBus.ui.shake_requested: M05 no existe aún.

### Recomendaciones para el próximo agente
- follow_camera.gd es la cámara CANÓNICA. No tocar camera_rig.gd (deprecated).
- Los modos se activan con `set_mode()` — solo EXPLORE funciona hoy.
- El fade CanvasLayer tiene layer=100 (siempre encima de todo).
- El shake usa seeds fijas para el offset (sin RandomNumberGenerator — determinista).
