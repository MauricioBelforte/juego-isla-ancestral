**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo:** 113-Pruebas-De-Stress (113)

# Checklist personal tareas — 113-Pruebas-De-Stress

> Fuente: ~30 `[ ]` + 1 `[?]` del `05-Checklist.md` del módulo.
> **Iter. agnes (Log 919, 2026-09-15):** cerré el gap real y headless-verificable — `StressComparator` +
> baseline `perf_base.json` (±5%) + gate de regresión + test. M113 **🟡 Liberado (102/132)**.
> Las métricas que piden baseline real de rendimiento (M61) y el gate pre-Beta (M141/M142) quedan `[?]`.

## Tareas

### Núcleo — COMPLETADO en iter. agnes (Log 919)
- [x] T-001 `StressComparator` (script reutilizable): `derivar_baseline` + `comparar` (p95 ±5% configurable) + `cargar`/`guardar` [M] — `scripts/stress/stress_comparator.gd`
- [x] T-002 Cableado en `stress_runner.gd`: marcador `regresion` + exit 1 + modo `--update-baseline` [M]
- [x] T-003 Test headless `test_stress_m113_comparador.gd` → **19 checks, 0 fallos**, 3 guardianes anti-falso-verde [M]
- [x] T-004 Reconciliar sobre-cierre del `Totales` (decía 127/127 "0 pendientes"; real 101/30/1) [S]
- [x] T-005 Cerrar `[?]` Iter.3 "umbral por escenario" = mi comparador [M]
- [x] T-006 Documentar `04-Codigo.md` §5 + firmado agnes-3-flash/Kilo Code [S]
- [x] T-007 Log 919 + actualizar 05-Checklist/CHECKLIST-GLOBAL + desbloquear [S]
- [x] T-008' **Decisión:** NO versionar baseline sembrado en dev (5 regresiones falsas; p95 de timing oscila >5% en HW variable). El **valor** del baseline → M61/CI sobre HW fijo.

### Cierre honesto — `[?]` con dueño (no inflar)
- [?] T-008 "Definir métrica" que piden baseline real de rendimiento (física<5ms, culling/memoria, streaming<30s, memoria<4GB, UI<16ms) — **dueño M61** (🟡)
- [?] T-009 "feed de límites desde M96" — **dueño M96**
- [?] T-010 "gate pre-Beta/pre-RC" — hice el **hook del lado de stress** (comparador + `--update-baseline` + exit 1); el **cableado a M141/M142 es ajeno — dueño M141/M142**

## Verificación
- `godot --headless --script res://scripts/stress/test_stress_m113_comparador.gd` → 19/0, `SCRIPT ERROR: 0`
- `godot --headless --script res://scripts/stress/test_stress_m113.gd` → 19/0 (regresión)
- `godot --headless --script res://scripts/stress/stress_runner.gd` → sin baseline exit 0; con baseline excedido exit 1
