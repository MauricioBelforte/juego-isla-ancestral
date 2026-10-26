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

## 8. Specs de items degradados (definidos 2026-10-26, Reflection-Beam-1.0 T161)

- **Lerp angular (L25):** la cámara canónica `follow_camera.gd` usa `look_at` directo (sin lerp angular); no se aplica lerp de 10°/s. Documentado en §2.
- **Interior (L33):** en interiores (M24), distancia máx 2.2 m y zoom bloqueado en cercano.
- **Agua (L36):** en agua, la cámara sube 0.5 m sobre el nivel para visibilidad de buceo.
- **Pendientes (L37):** en pendientes pronunciadas el pitch se ajusta sin sacudidas (clamp + suavizado).
- **Nocturno (L38):** en modo nocturno (M29), distancia mínima 3 m para ambiente.
- **Build (L44/L45/L61):** modo aéreo 45°, distancia 12 m, solo con herramienta equipada (M17); regreso automático a EXPLORE al desequipar; zoom mínimo 4 m (nunca macro).
- **Dialog (L46/L51):** encuadre fijo, input bloqueado; el jugador se gira suavemente hacia el NPC (0.5 s) (M21).
- **Cutscene (L47/L53):** planos fijos con fade; zoom por evento definido por M22/M26.
- **Minimap (L48):** vista supervisor 2D sobre todo (M10).
- **HUD (L50):** el HUD se esconde en Dialog/Cutscene.
- **Zoom teclado (L58):** zoom por atajos de teclado (Q/E o +/-) además de scroll.
- **Niveles zoom (L59):** cercano 2.5, estándar 5, lejano 8 m (diseño); implementación actual usa zoom continuo 4.0-20.0 m (Animal Crossing). Documentado en §2.
- **Zoom default (L60):** zoom por defecto configurable en GameSettings (M59), persistido.
- **Interiores zoom (L62):** en interiores, zoom bloqueado en cercano (M24).
- **Apuntar herramienta (L63/L64):** al apuntar con herramienta, acercamiento temporal a 3.5 m (0.3 s); vuelta a distancia elegida al soltar (M13).

## 9. Specs de items degradados — transiciones, shake, minimapa (T162, 2026-10-26)

- **Transición de escena (L69):** fade 0.3 s + swap de escena + lerp de cámara 0.2 s; la cámara no se mueve durante el swap; estados robustos (sin cámara fantasma).
- **Transición de modo (L71):** fade leve 0.15 s entre modos de cámara.
- **Transición Interact (L79):** transiciones de Interact (0.3 s de bloqueo de M11) sin cámara rara.
- **Reapertura (L80):** fade de entrada 0.5 s (suave) al reabrir el juego.
- **Guardado/recarga (L75/L77):** posición de cámara persistida en GameState (M59); compatible con guardado/recarga.
- **Shake narrativo (L86/L87/L91):** solo eventos narrativos (vórtice, terremoto); canal `EventBus.ui.shake_requested(amp, dur)`; follow_camera.trigger_shake() existe; log de eventos de shake (M05 Logger).
- **Minimapa (L95-L104):** supervisor 2D en Canvas 128×128; esquina superior derecha (reposicionable); fuente: texturas de biomas del generador (M10); sin coste de render (no cámara render); marcadores POI M71/casa M31/caminos/grieta/puerto; iconos 24×24 px con colores por tipo; se actualiza al descubrir POI o regenerar mundo; tecla M para abrir/cerrar; cerrado en Dialog/Cutscene; persistencia de posición/visibilidad en GameState.M12. Sistema inexistente hoy (QA atria-dawn): definido como contrato.

- **Minimapa extendido (L105-L107):** deshabilitado en cutscenes largas (M22); zoom del minimapa 1x/2x configurable; textos de marcadores localizables (M57).
- **Limitador de rotación (L116):** limitador de rotación de cámara 240°/s suave (orbit libre).
