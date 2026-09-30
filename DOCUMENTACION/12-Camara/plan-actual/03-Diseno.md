**Modelo:** mimo-v2.5
**Plataforma:** OpenCode
**Última actualización:** 2026-09-18 (FASE 2 — arquitectura hybrid)

# 03-Diseno.md — Módulo 12: Cámara

## 0. Arquitectura (decisión 2026-09-18)

### Cámara canónica: `follow_camera.gd` (109+ líneas)

La cámara que **realmente ejecuta** el juego es `scripts/follow_camera.gd`, instanciada en `main_island.tscn:70-73`. Esta fue la decisión de diseño:

- **§15 "no tocar lo que funciona":** follow_camera.gd funciona, player.gd consume sus APIs (`get_camera_forward_xz`, `get_camera_right_xz`).
- **Código muerto:** `camera_rig.gd` (267 líneas) + `camera_spring.gd` + `camera_mode.gd` + `simple_camera.gd` existen pero **nunca se instancian** en la escena principal. Solo `main.gd` (legacy) los usa.
- **Estrategia hybrid:** Features útiles de camera_rig (FOV, shake, fade, modos) fueron **portadas** a follow_camera.gd.

### Archivos del módulo

| Archivo | Estado | Función |
|---|---|---|
| `scripts/follow_camera.gd` | **CANÓNICO** | Cámara principal: orbit, zoom, colisión, shake, fade, modos |
| `scripts/camera/camera_rig.gd` | ⚠️ DEPRECATED | Código muerto — referencia histórica |
| `scripts/camera/camera_spring.gd` | ⚠️ DEPRECATED | Código muerto — spring-arm duplicado |
| `scripts/camera/camera_mode.gd` | ⚠️ DEPRECATED | Código muerto — enum + constants (útil como referencia) |
| `scripts/camera/simple_camera.gd` | ⚠️ DEPRECATED | Código muerto — alternativa no usada |

## 1. Modos de cámara (enum en follow_camera.gd)

```
enum ModoCamara { EXPLORE, BUILD, DIALOG, CUTSCENE, MINIMAP }
```

| Modo | Estado | Comportamiento |
|---|---|---|
| `EXPLORE` | ✅ Activo | Modo base: orbit libre, zoom scroll, colisión terreno |
| `BUILD` | [?] Pendiente M17 | Aérea 45°, distancia 12 m, solo con herramienta equipada |
| `DIALOG` | [?] Pendiente M21 | Encuadre fijo, input bloqueado |
| `CUTSCENE` | [?] Pendiente M22/M26 | Planos fijos con fade |
| `MINIMAP` | [?] Pendiente M10 | Vista supervisor 2D |

**Señales:** `mode_changed(new_mode)`, `shake_finished()`, `transition_finished()`

## 2. Seguimiento y colisión (follow_camera.gd)

```
PIVOT = player.group("player")  →  orbit con mouse
Distancia: min 4.0 m, max 20.0 m (zoom scroll)
Pitch: clamp -10° a 60° (libre por mouse)
Yaw: orbit libre del mouse (sensibilidad desde GameSettings)
Raycast (VoxelTool.raycast) contra VoxelTerrain:
  si colisiona → cámara = hit_dist - 0.5 m (separación mínima)
FOV: 70° fijo (anti-mareo), suave con lerpf
```

- El raycast busca el VoxelTerrain en la escena actual.
- Re-intento de target en `_physics_process` (fix M21 — _ready con await puede correr antes del Player).

## 3. Shake (portado de camera_rig.gd)

```
trigger_shake(amplitude, duration)
  amplitude: 0.0 - 0.15 m (clamp)
  duration: 0.0 - 0.5 s (clamp)
  frecuencia: 8 Hz (shake_frequency)
  decaimiento: lineal (progreso = timer / duration)
  offset: sin(freq * seed) * amp * (1 - progress)
```

- Conectado a `EventBus.ui.shake_requested` si existe.
- Solo eventos narrativos (vórtice, terremoto).
- Sin shake por acciones del jugador (regla dura).

## 4. Fade (portado de camera_rig.gd)

```
fade_screen(color, time)   →  fade out + fade in ( tween )
fade_to_black(time)        →  atajo a fade_screen(fade_color, time)
fade_from_black(time)      →  fade in desde negro
```

- CanvasLayer con layer=100 (siempre encima).
- ColorRect overlay con `mouse_filter = IGNORE`.
- Tween mata el anterior si hay conflicto.

## 5. FOV (nuevo)

```
@export target_fov: float = 70.0
```

- Aplicado en `_ready()` y suavizado en `_process()` con `lerpf(fov, target_fov, 8.0 * delta)`.
- Anti-mareo: FOV fijo en todos los modos.

## 6. Dependencias

| Elemento | Estado | Dueño |
|---|---|---|
| Player pivot (group "player") | ✅ Funciona | M11 |
| GameSettings (sensibilidad, invert Y) | ✅ Funciona | M59 |
| EventBus.ui.shake_requested | [?] Pendiente | M05 |
| VoxelTerrain (colisión) | ✅ Funciona | M10 |
| Modo Build (herramienta equipada) | [?] Pendiente | M17 |
| Modo Dialog (encuadre NPC) | [?] Pendiente | M21 |
| Modo Cutscene (eventos historia) | [?] Pendiente | M22/M26 |
| Minimapa (texturas biomas) | [?] Pendiente | M10 |
| Calibración sensación real | [?] Pendiente | Playtest M1 |

## 7. Consumidores de la cámara

- **player.gd:385-387** — `get_camera_forward_xz()`, `get_camera_right_xz()` para movimiento relativo a cámara.
- **tool_controller.gd** — Referencia al patrón de raycast de follow_camera.
- **villager_manager.gd** — Referencia al patrón de raycast de M13/follow_camera.
