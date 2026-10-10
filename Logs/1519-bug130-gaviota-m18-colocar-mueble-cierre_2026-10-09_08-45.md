# Log 1519: BUG-130 gaviota + M18 iter 5 parcial (colocar_mueble)

**Fecha:** 2026-10-09
**Hora:** 08:45
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
BUG-130 cerrado (null-guard gaviota_npc.gd:111) + M18 iter 5 parcial (`colocar_mueble()` + SLOTS_POR_ETAPA). Cierre de jornada.

## BUG-130
- `gaviota_npc.gd:111`: `load(glb).instantiate()` → `res_glb = load(glb); if res_glb == null: return; res_glb.instantiate()`
- Mismo patrón que BUG-121 (tortuga/cangrejo/jabalí)
- --check-only: 0 errores

## M18 iter 5 (parcial — cierre de jornada)
- `colocar_mueble(casa_id, mueble)`: verifica capacidad (SLOTS_POR_ETAPA: 2/4/6/8/12) + superficie/pared
- `SLOTS_POR_ETAPA` const agregada
- Test M18 sigue 37/0

## Archivos modificados
- `game/isla-ancestral/scripts/fauna/gaviota_npc.gd` (BUG-130, 4 líneas)
- `game/isla-ancestral/scripts/houses/house_manager.gd` (colocar_mueble + SLOTS_POR_ETAPA)

## --check-only
- gaviota_npc.gd: 0 errores ✓
- house_manager.gd: 0 errores ✓

## Conteo M18
11 [x] / 0 [?] / 115 [ ] = 126 (sin nuevos flips en esta iter parcial)

## Pendiente para próximo agente/sesión
- M18 Priority 2: catálogo de muebles (6-8 FurnitureData .tres)
- M18 Priority 3: CasasPanel UI
- M18 test integración M60 (arranque real + tiene_fuente()==true)
- M107: 12 [ ] user-dependent
- M110: 90 [?] restantes
