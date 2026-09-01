# Log 263: M93 Balance (iter. 2) — Tablas de contenido + reglas ampliadas

**Fecha:** 2026-08-30
**Hora:** 04:10
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M93 (Balance). Se completaron las tablas de contenido del balance central:
crafting, construction, tools, resources, farming, fishing, mining, travel, seals, quests,
puzzles y unlocks (RF3-RF17). Se amplió el validador con reglas de recetas, durabilidad y
sellos sin grind. Tests headless 0 fallos.

## Cambios Realizados

### Código (Godot) y datos
- `data/balance/crafting.json` — **NUEVO** (RF4): recetas con coste de recursos, AO, tiempo.
- `data/balance/construction.json` — **NUEVO** (RF3): piezas con coste AO + recursos.
- `data/balance/tools.json` — **NUEVO** (RF5): durabilidad y coste de mejora por herramienta.
- `data/balance/resources.json` — **NUEVO** (RF6): abundancia por bioma/estación + respawn.
- `data/balance/farming.json` — **NUEVO** (RF7): ciclo de crecimiento por cultivo.
- `data/balance/fishing.json` — **NUEVO** (RF8): peces por temporada/hora/clima + pity.
- `data/balance/mining.json` — **NUEVO** (RF9): minerales por profundidad.
- `data/balance/travel.json` — **NUEVO** (RF10): rutas y coste/duración.
- `data/balance/seals.json` — **NUEVO** (RF11): sellos con esfuerzo, grind_blocks=0, recompensa.
- `data/balance/quests.json` — **NUEVO** (RF13): misiones con recompensas.
- `data/balance/puzzles.json` — **NUEVO** (RF14): tiempos de resolución con/sin ayuda.
- `data/balance/unlocks.json` — **NUEVO** (RF15): desbloqueos con coste y condición.
- `scripts/balance/balance_service.gd` — Modificado: carga las 12 tablas extra y expone
  getters específicos (get_crafting, get_farming, get_fishing, get_seals, ...) y `coste_receta`.
- `scripts/balance/validate_balance.gd` — Modificado: reglas ampliadas R3 (recetas sin generación),
  R5 (durabilidad > 0), R8b (sellos sin grind).
- `scripts/balance/test_balance.gd` — Modificado: test de tablas de contenido. 0 fallos.

### Documentación
- `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md` — marcados ítems de tablas (A-F).
- `DOCUMENTACION/93-Balance/plan-actual/04-Codigo.md` — notas de iteración 2.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `data/balance/crafting.json` + 11 tablas | Creados |
| `scripts/balance/balance_service.gd` | Modificado |
| `scripts/balance/validate_balance.gd` | Modificado |
| `scripts/balance/test_balance.gd` | Modificado |
| `DOCUMENTACION/93-Balance/plan-actual/05-Checklist.md` | Modificado |
| `DOCUMENTACION/93-Balance/plan-actual/04-Codigo.md` | Modificado |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (262 → 263) |
| `Logs/263-M93-Balance-Tablas-Contenido_2026-08-30_04-10-00.md` | Creado (este log) |

## Validación
- `test_balance.gd` headless: 0 fallos (12 tablas cargadas, coste_receta, getters).
- `validate_balance.gd` headless: 0 fallos (reglas R1, R2, R3, R4, R5, R7, R8, R8b, R12).

## Pendientes honestos
- Integración de consumo en M38 (tiendas con get_price) y M16 (crafting con coste_receta).
- Simulación económica (simulate_economy.gd): escenarios 60/180/365 días (RF20).
- Reporte markdown para playtest (balance_report.gd) (RF22).
- Métricas M105 (BALANCE_DESVIO, PLAYER_ECON).