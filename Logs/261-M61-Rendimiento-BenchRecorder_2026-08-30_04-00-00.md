# Log 261: M61 Rendimiento (iter. 2) — BenchRecorder (runner de benchmark)

**Fecha:** 2026-08-30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M61 (Rendimiento, V0). Se implementó BenchRecorder: runner headless de
benchmark que perfila el frame budget por categoría con BudgetProfile y guarda el JSON de
resultado en `user://logs/bench/`. Es la vara de medición reproducible (RF27) para el gate CI
(M116/M118); el validador real de reglas sigue siendo validate_budget.gd.

## Cambios Realizados

### Código (Godot)
- `scripts/performance/bench_recorder.gd` — **NUEVO**: runner de benchmark:
  - `_run_bench()` perfila las 7 categorías de budgets.json (gameplay, mundo_voxel, ia_npc,
    particulas, culling, render, ui) con `BudgetProfile.begin/end_section`.
  - Delay proporcional al presupuesto de cada categoría (carga sintética de referencia).
  - `_guardar_json()` escribe `user://logs/bench/bench_<timestamp>.json` con el resumen.
  - Runner info-only (no bloquea por el floor ~1.5ms de OS.delay_msec en presupuestos < 2ms;
    el gate CI real valida con validate_budget.gd usando mediciones del juego).
  - Exit code 0 (perfilado exitoso).

### Documentación
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` — marcados ítems de medición/bench.
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` — notas de iteración 2.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/performance/bench_recorder.gd` | Creado |
| `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` | Modificado |
| `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (260 → 261) |
| `Logs/261-M61-Rendimiento-BenchRecorder_2026-08-30_04-00-00.md` | Creado (este log) |

## Validación
- `bench_recorder.gd` headless: 0 fallos. Perfila 7 categorías (total sintético ~14 ms) y
  guarda JSON en user://logs/bench/.
- `validate_budget.gd` headless: 0 fallos (regresión).

## Pendientes honestos
- `bench_scene_a.tscn` (escena 3D con terreno voxel real): requiere réplica del setup de
  terreno de main_island, que se deja para cuando M08/vegetación/NPC estén consolidados.
- Gate CI real en M116: el validador queda listo; el workflow es de M116.
- Medición de draw calls/GPU (RenderingServer) y veces de carga (M115).
