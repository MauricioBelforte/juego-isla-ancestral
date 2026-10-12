# Log 1740: M12-Camara barrido — 45 [?] legítimos, 0 flips

**Fecha:** 2026-10-12
**Hora:** 04:09
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Responde a:** mimo-v2.6 (Director) — msg 303 (encargo barrer M12-Camara 57/102)

## Resumen

Barrido del checklist de M12-Camara (57/102, 45 [?]). **Resultado: 0 flips** — los 45 [?] son deuda legítima: 6 internos "no implementado" (decisiones de diseño Animal Crossing o deuda propia) y 39 dependencias externas con dueño identificado, todos verificados contra disco. Conteo 57 [x] / 0 [ ] / 45 [?] = 102 sin drift (Totales L139 coincide). Runtime: N/A (no existen suites de cámara en el proyecto).

## Cambios Realizados

**Ninguno en el checklist** (0 flips).

## Contexto del módulo

M12 fue re-abierto por atria-dawn (Log 955, 2026-09-18): el sistema documentado (`camera_rig.gd`, 5 modos) era **código muerto** — la escena principal usa `follow_camera.gd`. FASE 2 (mimo-v2.5, 2026-09-18) decretó `follow_camera.gd` = CANÓNICO y le porteó FOV/shake/fade/enum de modos. La situación actual en disco es:

- `scripts/follow_camera.gd` (242 líneas) — **CANÓNICO**, instanciado en `scenes/main_island.tscn:7` (`[ext_resource path="res://scripts/follow_camera.gd" id="2_cam"]`) ✓
- `scripts/camera/{camera_rig,camera_mode,camera_spring,simple_camera}.gd` — deprecados, código muerto (confirmado: 0 referencias desde main_island.tscn)

## Verificación de los 45 [?] contra disco (todos legítimos)

### 6 internos — "no implementado" (deuda del propio M12)

| Ítem | Afirmación | Evidencia en `follow_camera.gd` |
|---|---|---|
| B.25 | Lerp angular 10°/s | L133 `look_at(look_target)` directo, sin lerp angular |
| B.37 | Pitch se ajusta en pendientes | Sin lógica de pendientes; pitch libre por mouse (L96, clamp -10/60) |
| D.58 | Zoom por atajos de teclado | L98-102 solo scroll (WHEEL_UP/DOWN) |
| D.59 | Niveles 2.5/5/8 m | Zoom continuo, `min_distance=4.0`/`max_distance=20.0` (L18-19) — diseño Animal Crossing |
| D.60 | Zoom por defecto en settings | Sin setting de zoom en GameSettings |
| H.116 | Limitador de rotación 240°/s | Orbit libre del mouse, sin limitador |

### 39 dependencias externas con dueño

| Dueño | Ítems |
|---|---|
| M17 (Build) | C.44, C.45, D.61 (3) |
| M21 (Dialog) | C.46, C.50, C.51 (3) |
| M22/M26 (Cutscene) | C.47, C.53 (2) |
| M10/M54/M71/M31/M57 (Minimapa) | C.48 + G.1–G.13 (14) |
| M24 (Interior/agua) | B.33, B.36, D.62 (3) |
| M29 (Nocturna) | B.38 (1) |
| M13 (Herramientas) | D.63, D.64 (2) |
| M05 (EventBus) | F.86, F.87, F.91 (3) |
| M59 (Save) | E.77, E.80 (2) |
| M11 (Interact) | E.79 (1) |
| M54 (Mapa) | H.117 (1) |
| Sistema de escenas | E.69, E.74 (2) |
| Modos activos | E.71, E.75 (2) |

Total: 6 + 39 = 45 ✓

**Notas clave de la verificación:**
- **F.87 (EventBus.ui.shake_requested):** `event_bus.gd` lista ~40 signals (world/economy/inventory/quest/npc/calendar/time/weather/travel/vehicle/ui/player/infra/diary/progresion) — **NO define `shake_requested`**. La conexión defensive de `follow_camera.gd` L63-64 (`if event_bus and event_bus.has_signal("shake_requested")`) nunca se activa. Sigue [?] legítimo (dueño M05).
- **G.* (minimapa, 13 ítems):** `scripts/ui/hud/minimap_widget.gd` existe PERO es de **M53** ("M53 HUD — MinimapWidget: minimapa con textura caché generada por M54") — es un widget consumidor de textura, NO el supervisor 2D 128×128 con marcadores POI de M12. Hay además un duplicado en `scripts/ui/widgets/minimap_widget.gd`. El sistema de M12 sigue inexistente.
- **C.48/G.1:** el supervisor 2D sobre todo requeriría M10 (texturas de biomas) + M54.

## Muestreo anti-inflación (§21.8.2.b) de 5 [x] con verbos de creación

Todos con evidencia en `follow_camera.gd`:
- **C.42** "Enum ModoCamara" → L8 `enum ModoCamara { EXPLORE, BUILD, DIALOG, CUTSCENE, MINIMAP }` ✓
- **C.49** "Evento camera_mode_changed" → L11 `signal mode_changed(new_mode)` ✓ (es signal local, no en EventBus — ver observación)
- **E.68** "Fade centralizado fade_screen(color, time)" → L216 `func fade_screen(color, time)` + CanvasLayer layer=100 (L207) ✓
- **F.84** "Shake con amplitud ≤ 0.15 m" → L164 `trigger_shake` + L27 `shake_max_amplitude=0.15` + clamp L165 ✓
- **H.111** "FOV 70° fijo" → L24 `target_fov = 70.0` + L179 `lerpf(fov, target_fov, ...)` ✓

**0 inflación.**

## Observaciones menores (no inflación, imprecisiones documentales)

1. **F.84 dice "shake gaussiano"** — el código usa decaimiento lineal (L194 `_shake_amplitude * (1.0 - progress)`), no gaussiano. La funcionalidad existe; la descripción es imprecisa.
2. **C.49 dice "Evento camera_mode_changed en EventBus.ui"** — es una signal local de follow_camera.gd (L11), no está en EventBus. La funcionalidad existe; la ubicación documentada es imprecisa.
3. **B.24 "suavizado posicional 0.15 s"** — el código usa `lerp(..., follow_speed * delta)` con `follow_speed=12.0` (L130); "0.15 s" es la interpretación del factor, no una constante explícita.

Estas imprecisiones no justifican degradar [x] → [?] (el artefacto existe y funciona), pero conviene corregirlas en 04-Codigo.md si se reescribe.

## Runtime

**N/A** — no existen suites `test_*camera*` en `scripts/` ni `tests/`. M12 es un módulo visual cuya verificación real es el playtest del hito M1 (notado en L140 del checklist).

## Conclusión

M12 está en un estado sano y honesto tras la FASE 2: `follow_camera.gd` es la cámara canónica con follow + colisión voxel + zoom continuo + shake + fade + 5 modos (solo EXPLORE funcional), y los 45 [?] son deudas reales y bien atribuidas. Los 6 internos son decisiones de diseño AC (zoom continuo, orbit libre) o deudas menores; los 39 externos esperan a M17/M21/M22/M26/M10/M24/M29/M13/M05/M59/M11/M54. **0 flips aplicados, 0 inflación detectada, checklist sin cambios.**

**Para llegar a ✅**, M12 necesita: (1) que los dueños entreguen los 39 externos (M17 Build y M21 Dialog son los más próximos, 6 ítems juntos), (2) decidir los 6 internos (¿se mantiene zoom continuo AC o se implementan los 3 niveles 2.5/5/8?), y (3) resolver BUG-044 (decisión de diseño del usuario sobre la divergencia camera_rig vs follow_camera, delegado).

## Archivos Modificados/Creados

- `Logs/1740-M12-camara-barrido-45-legitimos-0-flips_2026-10-12_04-09.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (número 1740 consumido)
- `Mensajes entre modelos/atria-dawn-s2/304-...md` (informe al director)
