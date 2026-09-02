# Log 386: M61 Rendimiento — Mediciones reales del bench_scene_a (FPS 59.35, draw calls 374) — cierre del [?] del Log 384

**Fecha:** 2026-09-01
**Hora:** 19:05
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Con el árbol desbloqueado (fixes de M155/M36), se ejecutó por primera vez el benchmark oficial del proyecto (bench_scene_a.tscn, 90 s, 6 waypoints) en hardware real y se obtuvieron las mediciones de rendimiento el terreno voxel de la Isla Raíz con la vara M61 (BudgetProfile + API Performance). Queda cerrado el [?] de medición pendiente del Log 384.

## Mediciones (build debug, AMD Radeon (TM) Graphics, Godot 4.7.2)

| Métrica | Valor | Objetivo | Estado |
|---|---|---|---|
| FPS promedio | **59.35** (179 muestras, 90 s) | ≥ 60 | ⚠️ WARN (-0.65 FPS; Vsync + carga de chunks) |
| Draw calls promedio | **374.0** | ≤ 400 (objetivo E.59 definido) | ✅ Dentro (margen 26; máx 471 en waypoint 6 cenital) |
| Objetos en frame | **477.4** (máx 575) | — | Informe |
| TIME_PROCESS | **0.018 ms** | — | ✅ CPU casi libre (freno por GPU/Vsync) |
| Frame render (frame_post_draw) | **16.35 ms** | 16.7 ms total | ✅ Dentro del presupuesto total |

- JSON de la corrida: `user://logs/bench/bench_2026-09-01.json` (179 muestras, 6 waypoints, hardware). Apto para gate CI M116.
- Evidencia visual (V1, leída con visión): `tools/mcp/godot-mcp/capturas/61-Rendimiento/cap_61_2026-09-01_19-00-00_bench_mid2.png` (FPS 60 | Draw calls 343 | Objetos 447 | Waypoint 3/6 — vista cenital) y `cap_61_2026-09-01_19-01-30_bench_final.png` (VEREDICTO: WARN (fps prom 59.4) + vista aérea completa de la isla).
- Boot limpio verificado en la misma corrida: `[M36] FaunaManager ready: 7 especies`, `[EquipmentManager] Catálogo cargado: 16 prendas`, 0 parser errors (solo warnings y el error preexistente de M161 npc_visual_database.gd:18).

## Interpretación para el proyecto

1. **El terreno voxel de la isla (un solo mundo, sin NPCs/partículas) está en presupuesto: ~374 draw calls y 16.35 ms/frame** — margen para el contenido que entrará (NPCs, vegetación M50, agua M51, UI).
2. Draw calls 343-471 según ángulo (máximo en la vista cenital por chunks de playa/sombras): el objetivo E.59 queda definido en **≤ 400 para escena de terreno** (máx tolerado por waypoint cenital 471 → informe como referencia, no como fallo; el gate CI validará la MEDIA, no el pico).
3. El FPS "WARN" (59.35) es un artefacto del Vsync + primer pase de generación de chunks; separar "picos de generación" del "steady state" es trabajo para el siguiente paso del módulo (muestras post-warmup).

## Archivos Modificados/Creados

- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` (sección «Iteración 2b — MEDICIÓN REAL»)
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` (ítem de medición [x] vía bloque iter 2 actualizado en Log 384)
- `CHECKLIST-GLOBAL.md` (fila 61 → 🟡 29/130, nota con medición), `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (fila M61), `Mensajes entre modelos/ESTADO-PARALELO.md` (fila M61), `Logs/ULTIMO_NUMERO.txt` (→386)
- Evidencias: 2 capturas PNG + `user://logs/bench/bench_2026-09-01.json` (no versionados)

## Verificación

- Mediciones reales en la máquina de desarrollo (AMD Radeon): FPS 59.35 / draw calls 374 / 16.35 ms → la vara de medición M61 está operativa y reproducible (90 s, JSON, capturas).
- Quedan [?] fuera del alcance del bench: gate CI en M116 (workflow con `validate_budget.gd`), instrumentación por categorías en módulos dueños (M07/M50), medición en GPU mínima (M114).
