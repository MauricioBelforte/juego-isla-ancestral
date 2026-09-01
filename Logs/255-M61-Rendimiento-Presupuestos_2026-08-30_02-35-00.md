# Log 255: M61 Rendimiento — BudgetProfile + budgets.json + ValidateBudget

**Fecha:** 2026-08-30
**Hora:** 02:35
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 1 del M61 (Rendimiento, V0). Se implementó la norma de presupuestos de frame
de Aurora: instrumentación por categorías (BudgetProfile), tabla oficial de presupuestos
(budgets.json, 16,7 ms @ 60 FPS, tolerancia 10 %) y validador (validate_budget.gd) que
compara mediciones contra la tabla. Ambos tests headless: 0 fallos.

## Cambios Realizados

### Código (Godot)
- `game/isla-ancestral/scripts/performance/budget_profile.gd` — **NUEVO** instrumentación:
  - `begin_section(categoria)` / `end_section(categoria)` con Time.get_ticks_usec().
  - Acumulado en ms por categoría, contador de llamadas, promedio.
  - `get_resumen()` para diagnose y CI; `reset_profile_run()` para bench scene.
  - `set_activo(false)` → overhead cero en release (no ejecuta secciones).
- `game/isla-ancestral/data/performance/budgets.json` — **NUEVO** tabla oficial:
  presupuesto_total_ms=16.7, tolerancia_ci=0.10, hardware min/recomendado (M114),
  7 categorías (gameplay 2.5, mundo_voxel 4.0, ia_npc 2.0, particulas 1.0, culling 0.5,
  render 5.0, ui 1.5).
- `game/isla-ancestral/scripts/performance/validate_budget.gd` — **NUEVO** validador:
  tabla completa (RF28), categorías > 0, suma dentro del total con margen, hardware
  declarado, y `_validar_medicion()` que compara una medición contra presupuestos
  individuales + total (tolerancia 10 %). Exit code 0/1 para gate CI (M116).
- `game/isla-ancestral/scripts/performance/test_budget_profile.gd` — **NUEVO** test:
  secciones acumulan ~5 ms, categoría no medida = 0, resumen, ventana, promedio,
  inactivo no acumula. 0 fallos.

### Documentación
- `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` — relevado contra lo implementado.
- `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` — sección de implementación real.
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`,
  `Mensajes entre modelos/ESTADO-PARALELO.md` — registros actualizados.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/performance/budget_profile.gd` | Creado |
| `scripts/performance/validate_budget.gd` | Creado |
| `scripts/performance/test_budget_profile.gd` | Creado |
| `data/performance/budgets.json` | Creado |
| `DOCUMENTACION/61-Rendimiento/plan-actual/05-Checklist.md` | Modificado |
| `DOCUMENTACION/61-Rendimiento/plan-actual/04-Codigo.md` | Modificado |
| `CHECKLIST-GLOBAL.md` | Modificado |
| `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` | Modificado |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (254 → 255) |
| `Logs/255-M61-Rendimiento-Presupuestos_2026-08-30_02-35-00.md` | Creado (este log) |

## Validación
- `validate_budget.gd` headless: 0 fallos (valida tabla + medición OK + detección excedida).
- `test_budget_profile.gd` headless: 0 fallos.

## Pendientes honestos
- `bench_scene_a.tscn` (escena oficial de benchmark 60 s): requiere visión/escena 3D
  (M08/M50/M19/M51/M49) — V2, pendiente para agente con visión.
- Gate CI real en M116 (aquí queda el validador listo).
- Integración de categorías en los módulos (cada módulo declara su presupuesto al usar
  BudgetProfile).
- Medición de draw calls/GPU (RenderingServer) y tiempos de carga M115.