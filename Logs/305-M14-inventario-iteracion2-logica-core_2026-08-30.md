# Log 305: M14 Inventario — Iteración 2 (lógica core)

**Fecha:** 2026-08-30
**Hora:** 22:30
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Iteración 2 de M14 Inventario. Se implementaron 13 ítems pendientes de lógica pura (sin UI/visión): validación de datos, consumo para crafting, regalos NPC, herramientas M13, descarte protegido, donación a museo y validación global.

## Cambios Realizados

### inventario_contenedor.gd
- **[64/164] Validación en `deserializar()`:** rechaza items con ID desconocido (log DOM-14) o cantidad ≤ 0
- **[140] `validate_quantities()`:** corrige slots con cantidad > stack_max o < 0

### inventario_service.gd
- **[78/133] `consume_for_crafting(recipe, include_house)`:** consumo todo-o-nada desde bolsillo, luego casa si include_house
- **[127] `give_gift(item_id, cantidad)`:** entrega directa al bolsillo con fallback casa → correo
- **[128] Redirección a correo:** si bolsillo y casa llenos, va a CORREO (bandeja)
- **[129] `equip_tool(container, slot)`:** equipa herramienta (categoría HERRAMIENTAS), marca instancia equipped
- **[129] `use_toolDurability(container, slot, amount)`:** reduce durabilidad, remueve si llega a 0
- **[130] `discard_item(container, slot, confirmado)`:** descarte con doble confirmación, protege items misión (prefijo `mission_`)
- **[138] `donate_item(item_id, cantidad)`:** donación a museo (consume de bolsillo)
- **[130] `is_mission_item(item_id)`:** verifica prefijo `mission_`
- **[140] `validate_all_containers()`:** valida todos los contenedores, corrige cantidades ilegales
- **[161/162] Descarte:** doble verificación + señal `item_removed` para world drop

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/inventario/inventario_contenedor.gd` — editado (deserializar + validate_quantities)
- `game/isla-ancestral/scripts/inventario/inventario_service.gd` — editado (+10 métodos nuevos)
- `DOCUMENTACION/14-Inventario/plan-actual/05-Checklist.md` — 13 ítems marcados [x]
- `CHECKLIST-GLOBAL.md` — M14 actualizado 81/140
