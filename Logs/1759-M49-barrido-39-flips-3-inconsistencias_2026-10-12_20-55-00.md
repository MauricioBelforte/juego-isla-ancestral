# Log 1759: M49-Iluminación barrido con 39 flips y 3 inconsistencias detectadas

**Fecha:** 2026-10-12
**Hora:** 20:55
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Barrido del checklist de M49-Iluminación (encargo del director, msg 320). 39 ítems `[?]` -> `[x]` con evidencia en disco y runtime; conteo final 105/0/38 = 143 sin drift. Runtime 5 suites Godot 4.7.2 headless: 70 checks útiles, 0 fallos. Se detectaron 3 inconsistencias materiales (lighting_budget.json inexistente, view_distance/LOD, distancias de sombra por preset).

## Cambios Realizados
### Flips aplicados (39), por categoría
**(a) Pool de luces — 5 ítems** (ahora implementados en `scripts/world/light_pool.gd`, commit `dc8218f` de Step 5): luz desde el pool no por instancia (G57); pool con MAX_DINAMICAS/MAX_CONT_SOMBRA (N104); descartar luz por instancia de props (N105); desactivación offscreen/descarte 30 m (N106); descartar luz por instancia (T148).
**(b) Decisiones de diseño documentadas — 4:** lightmaps SÍ para interiores (D34); SDFGI/VoxelGI OFF por defecto (D35); descartar SDFGI global (T145); descartar lightmap del mundo abierto (T146).
**(c) Riesgos mitigados — 3:** overdraw en pueblo (U154); acne voxel con bias fino (U155); cuevas ilegibles con piso 0.15 (U158).
**(d) Verificaciones del validador — 2:** límites de luces por escena (Q123); flicker por accesibilidad (Q126).
**(e) Flujos documentados — 3:** transición de franja (W178); entrada a cueva (W179); validación de escena (W180).
**(f) Criterios de aceptación verificados — 5:** 5 franjas distinguibles (X185); cuevas legibles sin luces por instancia (X186); luces dinámicas ≤ tope (X187); flicker determinista (X188); sin sombras negras ni acne (X191).
**(g) Artefactos data/light/ — 8:** sun_color_ramp.tres, sky_color_ramp.tres, day_night_cycle.gd con carga de ramps, FIX CRÍTICO del script adjunto, test_ramps_color_m49.gd, verificación visual de 4 momentos (capturas/49/), hallazgo documentado de avanzar_hasta().
**(h) Iteraciones 4-6 — 8:** skyline_montanas.gd (archivado en Obsoletos/), verificación visual skyline (captura existe), escanear_montanas_m09.gd, montaña real 420 m (captura), terreno_horizonte.gd (impostor), impostor desde spawn (captura).

### No flippeados (38 `[?]`): dependencias externas legítimas
M09 (cielo procedural por bioma, niebla de jungla), M18/M39 (interiores baked, luz de tiendas), M47 (cristales, bajorrelieves), M52 (hogueras), M11 (esporas), M62/M61 (memoria lightmap, budget), M90 (presets de calidad, hardware medio), M118 (bake en CI), M24/M25 (rayo cenital), easing de 3 s entre franjas (el tween real es de 1 s).

### Inconsistencias materiales detectadas (3)
1. **`lighting_budget.json` no existe** (L127, L156 lo citan como registro de memoria/CI) — 0 hits en disco.
2. **L245 declara view_distance 512→2048 + lod_split_count 6**, pero `main_island.gd:138/147` tiene `view_distance = 1024.0` y `lod_split_count = 5` — el ítem describe valores que no están en código.
3. **L96/L159 declaran distancias de sombra por preset (45 m / 25 m bajo)**, pero la implementación es `directional_shadow_max_distance = 120` sin presets por calidad — M90 no proporcionó los presets.

Estas 3 requieren decisión del director (corregir el ítem o implementar el valor).

### Runtime (Godot 4.7.2 headless, 5 suites)
- `test_light_pool_m49.gd`: 44 checks, 0 fallos, PASS
- `validate_lighting_m49.gd`: 0 fallos, 0 advertencias
- `test_ramps_color_m49.gd`: 10 checks, 0 fallos
- `test_curvas_luz.gd`: 0 fallos
- `test_ciclo_dia_noche.gd`: 16 checks, 0 fallos (SKIP esperado: WorldEnvironment ausente sin escena)

## Archivos Modificados/Creados
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` (39 flips + Totales 66/0/77 -> 105/0/38 + nota de agente)

## Notas
- CHECKLIST-GLOBAL declaraba 103/249 para M49; el checklist real del módulo es 143 ítems. Drift reportado al director en el informe 321 para que decida la actualización (yo no edito CHECKLIST-GLOBAL).
- El barrido se basó en la implementación de `light_pool.gd` de Step 5 (commit dc8218f) que cambió el estado de varios `[?]` dejados a propósito por Step 5 e hy3.
