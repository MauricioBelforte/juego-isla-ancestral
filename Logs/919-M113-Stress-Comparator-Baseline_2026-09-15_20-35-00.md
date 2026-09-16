# Log 919: M113 Pruebas de Stress — iter. agnes (StressComparator + baseline ±5%)

**Fecha:** 2026-09-15
**Hora:** 20:35
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Primera sesión de **agnes-3-flash** en el proyecto (Sapiens AI). Creé mi carpeta
`TAREAS-POR-MODELO/agnes-3-flash/` (BACKLOG curado por encaje: M113 + M115, ~162 subítems) y trabajé
mi mejor encaje: **M113 Pruebas de Stress** (tooling + gates de CI + data-driven + V0). Entregué el gap
que el diseño marcó `[x]` pero el runner **no implementaba**: `StressComparator` + baseline versionado
`perf_base.json` + comparación ±5% + gate de regresión + test headless.

## Cambios Realizados

- **NUEVO `scripts/stress/stress_comparator.gd`** — `StressComparator` (RefCounted, sin `class_name`, vía
  `preload` §9.52): `derivar_baseline()`, `comparar(escenarios, baseline, umbral=0.05)`, `cargar()`,
  `guardar()`, `ruta_baseline()`. Lógica pura + headless-safe (no aborta si el baseline falta/está inválido).
- **MOD `scripts/stress/stress_runner.gd`** — cablea el comparador: `--update-baseline` siembra/actualiza
  `perf_base.json` y sale; corrida normal compara contra el baseline y si hay **regresión** el exit code
  pasa a 1; sin baseline → "primera corrida", gate inactivo (exit 0).
- **NUEVO `scripts/stress/test_stress_m113_comparador.gd`** — 19 checks, 3 bloques con guardián
  anti-falso-verde (`_fin()`): derivar_baseline, comparar (sin base / delta 0 / 4% ok / 6% regresión /
  p95 base 0 / umbral configurable), round-trip guardar/cargar en `user://`.
- **Docs:** `04-Codigo.md` §5 "Iteración agnes"; `05-Checklist.md` (sobre-cierre del `Totales` corregido +
  `[?]` Iter.3 cerrado + "Notas del Agente"); `CHECKLIST-GLOBAL` fila 113; `ESTADO-PARALELO`; mi
  checklist personal `TAREAS-POR-MODELO/agnes-3-flash/113-...`.

## Evidencia de verificación (godot 4.7.2 headless, binario del MCP)

- `test_stress_m113_comparador.gd` → **19 checks, 0 fallos**, `SCRIPT ERROR: 0`, 3 guardianes OK.
- `test_stress_m113.gd` (regresión del framework) → **19 checks, 0 fallos** (iter. 2 intacta).
- `stress_runner.gd` sin baseline → "sin baseline (primera corrida)", **exit 0**.
- `--update-baseline` → siembra `perf_base.json` (4 escenarios).
- Corrida con baseline **excedido** → "REGRESIÓN (n métricas > umbral 5%)", **exit 1** (el gate dispara).

## Hallazgo honesto (documentado, decisión de no versionar)

Al sembrar `perf_base.json` desde una corrida **headless en dev** y volver a correr, el gate marcó
**5 regresiones falsas** (p95 de timing —ops/s, add_ms— oscila >5% entre corridas en hardware variable).
El diseño §1 exige "corre en hardware fijo (label CI)". Por eso **eliminé la siembra de dev del repo**:
un baseline ruidoso dejaría el gate en rojo para quien corra el runner en laptop. **Mi aporte es el
mecanismo** (comparador + gate + `--update-baseline` + test); **el valor del baseline lo genera M61/CI
sobre hardware fijo** (dueño M61 🟡). No inflé el estado del módulo.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/stress/stress_comparator.gd` (nuevo)
- `game/isla-ancestral/scripts/stress/stress_runner.gd` (mod)
- `game/isla-ancestral/scripts/stress/test_stress_m113_comparador.gd` (nuevo)
- `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/04-Codigo.md` (mod)
- `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md` (mod)
- `CHECKLIST-GLOBAL.md` fila 113 (mod)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada agregada)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/` (BACKLOG-MASTER + 113 + 115, nuevo)
- `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md` (registro de modelo)

## Estado de M113
🟡 **Liberado (iter. agnes).** 102/132 `[x]`. Los 30 `[ ]` "definir métrica/prueba" + gate M141/M142 +
feed M96 siguen con dueño (M61/M141/M142/M96). QA cruzado §21.8 pendiente (verificador ≠ autor).
