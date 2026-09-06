# Log 731: M49 iter. 3 — curvas de color por franja + fix script DayNightCycle

**Fecha:** 2026-09-06
**Hora:** 07:54
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 3 del módulo 49 (Iluminación): implementación de las curvas de color por franja del día (amanecer/mediodía/atardecer/noche) como Gradient data-driven, integradas al DayNightCycle. Durante la verificación se descubrió y corrigió el bug raíz que impedía todo el sistema: el nodo DayNightCycle de main_island.tscn no tenía el script adjunto. Verificación visual completa con capturas del juego real en los 4 momentos del día.

## Cambios Realizados
- `data/light/sun_color_ramp.tres` (NUEVO): Gradient de 10 puntos sobre 24h — noche azul (0.1/0.12/0.2) → púrpura alba → naranja amanecer (1/0.62/0.38) → dorado mañana → blanco cálido mediodía (1/0.96/0.88) → dorado tarde → naranja atardecer (1/0.55/0.3) → púrpura crepúsculo → azul noche.
- `data/light/sky_color_ramp.tres` (NUEVO): Gradient del color ambiente (cielo) — azul noche → rosado alba → azul cielo (0.8/0.9/1) → dorado → crepúsculo → azul noche.
- `scripts/world/day_night_cycle.gd`: carga de ambos ramps (fallback al hardcode previo si faltan); sun.light_color y env.environment.ambient_light_color muestreados en hora/24.0 y animados por el tween existente.
- `scenes/main_island.tscn`: **FIX CRÍTICO** — adjuntado script day_night_cycle.gd al nodo DayNightCycle (ext_resource 17_dnc). Sin esto el sistema completo de iluminación por franjas (iteraciones 1-7) nunca se ejecutaba.
- `scripts/world/test_ramps_color_m49.gd` (NUEVO): 10 checks — colores por franja (naranja/blanco cálido/rojizo/azul noche), interpolación continua (9:00 entre amanecer y mediodía), sky por franja.
- Herramienta de verificación: autoload temporal `captura_franjas_m49.gd` (ELIMINADO al finalizar) que saltaba la hora seteando `_hora` + emitiendo `hora_cambio` una vez, y capturaba el viewport a PNG en cada franja.

## Hallazgos (documentados para 07-GUIA-GODOT §8)
1. **Node sin script en la escena:** un nodo `[node name="DayNightCycle" type="Node3D"]` sin `script = ExtResource(...)` carga silencioso — el sistema no corre y no hay error. Al diagnosticar sistemas "que no funcionan", verificar primero que el script esté adjunto.
2. **`avanzar_hasta()` congela el juego en runtime con stdout pipeado:** emite `minuto_cambio` × N (22h = 1320 señales) que provoca spam de NPC React → el buffer del pipe se llena → print() bloquea el hilo del juego → frame congelado con FPS aparente activo. Para pruebas de hora: setear `_hora`/`_minuto` directo + emitir `hora_cambio` una sola vez.
3. **Captura determinista:** `get_viewport().get_texture().get_image().save_png()` desde un autoload es superior a las capturas de pantalla externas (sin carrera de timing, sin overlay del SO).

## Evidencia Visual (capturas/49/)
- `cap_49_..._franja_0600_final.png` — 06:01: terreno dorado/naranja cálido (R=115/G=81/B=35)
- `cap_49_..._franja_1200_final.png` — 12:01: luz clara, cielo azul (brillo 150)
- `cap_49_..._franja_1800_final.png` — 18:01: naranja atardecer (R=121/B=37)
- `cap_49_..._franja_0000_final.png` — 00:01: noche azulada oscura (brillo 5)
- Diagnóstico runtime: sun color/energy/rotación distintos por franja (log godot.log del juego).

## Tests
- `test_ramps_color_m49.gd`: 10 checks, 0 fallos.
- Regresión `test_curvas_luz.gd` (M31): 0 fallos.
- Boot completo de la escena sin SCRIPT ERROR.

## Archivos Modificados/Creados
- `game/isla-ancestral/data/light/sun_color_ramp.tres` (NUEVO)
- `game/isla-ancestral/data/light/sky_color_ramp.tres` (NUEVO)
- `game/isla-ancestral/scripts/world/day_night_cycle.gd` (ramps de color)
- `game/isla-ancestral/scenes/main_island.tscn` (script adjuntado a DayNightCycle)
- `game/isla-ancestral/scripts/world/test_ramps_color_m49.gd` (NUEVO)
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` (13 → 24 [x] + notas)
- `CHECKLIST-GLOBAL.md` (fila 49: 24/117, 🟡 Liberado iter. 8)
