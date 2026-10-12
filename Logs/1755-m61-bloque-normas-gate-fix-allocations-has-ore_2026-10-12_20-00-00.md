# Log 1755: M61 norma transversal data-driven (bloque normas + gate) y fix de allocations en _has_ore

**Fecha:** 2026-10-12
**Hora:** 20:00
**Modelo:** atria (Atria-Dawn-Preview)
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo-v2.6-flash-free, mensaje #36 del canal atria-dawn): deep work en M61-Rendimiento (37/144). Se (1) incorporó la norma transversal de M61 como umbrales data-driven en `budgets.json` (bloque `normas`), (2) se amplió el gate `validate_budget.gd` con `_validar_normas()` —mismo patrón tolerante de la iter. agnes (Log 943)—, y (3) se aplicó un fix real de RF25: `_has_ore` ya no allocaba `FastNoiseLite` por cada bloque subterráneo del camino caliente (hallazgo del Log 945, QA M10). Doce ítems `Definir X` del checklist se cerraron con cita al artefacto + gate: 37 → **49/144** (89 `[ ]`, 6 `[?]`).

## Cambios Realizados

### 1. `data/performance/budgets.json` — nuevo bloque `normas` (version 1 → 2)

Doce umbrales transversales que antes solo existían como prosa del plan-inicial: `vsync` (true), `fps_objetivo` (60), `fps_minimo` (30), `resolucion_base` ("1080p"), `distancia_dibujado_presets_m` ([100,150,220]), `lod_niveles` (3), `lod_transicion_sin_pop_m` (2), `npcs_activos_max` (20), `remesh_bloque_ms_max` (2.0), `carga_fria_s_max` (30), `carga_caliente_s_max` (10), `almacenamiento_hdd_soportado` (false). Cierran ítems de las secciones A, B, C, H, K, L, R, U e Y del checklist con la misma técnica data-driven ya aceptada en el Log 943.

### 2. `scripts/performance/validate_budget.gd` — `_validar_normas()`

Sigue exactamente el patrón de `_validar_limites()` (Log 943): tolerante si el bloque falta (no rompe el gate de ramas anteriores) y, si está, exige bien formado + los valores canónicos de la spec (vsync true, fps 60/30 con mínimo < objetivo, 1080p, 3 presets 100/150/220, LOD 3, NPCs 20, remesh ≤ 2 ms, cargas ≤ 30/10 s, HDD false). Print de evidencia `[M61] normas: 12 umbral(es) transversales validados (fps 60/30, presets [100, 150, 220], LOD 3, NPCs 20)`.

### 3. FIX RF25 — `scripts/world/island_generator.gd`

Hallazgo del Log 945 (mi QA M10): `_has_ore` hacía `FastNoiseLite.new()` en cada llamada, y `get_block_at` la llama por cada bloque subterráneo — una asignación por bloque del camino caliente del generador. Ahora el ruido se preconstruye una sola vez en `_setup_noises()` (nueva miembro `_ore_noise`, seed +3000, TYPE_SIMPLEX_SMOOTH, frequency 0.1 — valores idénticos a los originales, **determinismo inalterado**). Cierra el ítem Y "Definir cero allocations en bucles calientes" con aplicación real, no solo con la declaración de la norma.

### 4. Documentación

- `05-Checklist.md`: nueva sección "Iteración atria", 12 flips `[ ]`→`[x]` con cita al artefacto, Totales corregido (37→49, 101→89), firma actualizada.
- `04-Codigo.md`: nueva iteración documentada con tabla de los 12 umbrales ↔ RF ↔ ítem del checklist, el fix, lo no hecho y recomendaciones; firma actualizada.

## Archivos Modificados/Creados

- `game/isla-ancestral/data/performance/budgets.json`
- `game/isla-ancestral/scripts/performance/validate_budget.gd`
- `game/isla-ancestral/scripts/world/island_generator.gd`
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md`
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md`

## Lo que NO se hizo (honestidad obligatoria)

- **Gate sin ejecutar**: Godot no es ejecutable en este sandbox. Pendiente de CI/headless: `godot --headless --script res://scripts/performance/validate_budget.gd` → esperar 0 fallos + línea `[M61] normas: 12 ...`. Validación estática hecha: JSON parsea (python json), indentación a tabs en el gate (136 líneas tab, 0 con espacios), 212/212 paréntesis balanceados.
- **6 `[?]` intactos**, todos fundados: los dos de mi QA E-12a (JSON `bench_2026-09-01.json` inexistente en cualquier ruta — sigue sin artefacto; capturas del bench en disco pero sin versionar) y los de alineación con M114/M91 — **verificado contra disco**: `DOCUMENTACION/114-Playtest` es protocolos de playtest (no hardware objetivo) y `DOCUMENTACION/91-Configuracion-De-Audio` es audio (no presets gráficos), así que las referencias del plan-inicial son incorrectas; queda documentado para que el dueño redirija la alineación. El de metodología de profiler requiere escritura adicional; el de cableado CI es de M118.
- **bench_scene_a / mediciones reales / gate CI en M116**: sin Godot, sin visión (V2) y fuera de alcance de esta iteración.
- No se tocaron CHECKLIST-GLOBAL ni se aplicaron sellos §21.8 (reglas del director). No se committeó.

## Notas para el director

- El conteo verificado con regex estricto tras los flips: **49 [x] / 89 [ ] / 6 [?] = 144**, coincidente con la línea Totales actualizada (sin drift).
- Los 12 flips son del tipo "Definir X" (norma), cerrados con artefacto data-driven + gate — el mismo criterio de la iter. agnes (Log 943) que el director ya aceptó. Ningún flip es de tipo "Validar X [C]" (esos requieren runtime y quedan `[ ]`).
- El fix de `_has_ore` toca `island_generator.gd` (M10/M08) pero preserva el determinismo bit a bit (mismo seed, tipo y frecuencia del ruido) — el test `test_generacion_m10_atria.gd` sigue siendo válido.
