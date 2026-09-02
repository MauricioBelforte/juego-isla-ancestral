# Log 358: Sincronización documentación vs código (M07, M15, M29, M30, M38, M39, M66)

**Fecha:** 2026-08-30
**Hora:** 20:46
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Auditoría de código vs documentación: 22 scripts de código real existían pero no estaban documentados en ningún `04-Codigo.md`. Se corrigieron los 7 módulos no bloqueados (M16/M53/M19 excluidos por tener agentes activos).

## Cambios Realizados

### M07 Arquitectura General (`plan-actual/04-Codigo.md`)
- Se reemplazó la tabla "Archivos de referencia para M1" por tabla "Archivos involucrados" con estado real
- Se agregaron: `game_settings.gd` (M46 config), `terrain_locator.gd` (M167/M168 posicionamiento), `registro.gd` (M05 logging)
- Se marcó `thread_pool.gd` como pendiente

### M15 Recursos (`plan-actual/04-Codigo.md`)
- Se corrigieron paths de `res://_Project/Scripts/Gameplay/Resources/` a `res://scripts/resources/`
- Se agregó `resource_drop_entry.gd` (faltaba documentar)
- Se actualizó estado de todos los scripts a "Implementado"

### M29 Tiempo y Calendario (`plan-actual/04-Codigo.md`)
- Se reemplazó la tabla genérica por tabla detallada con scripts reales
- Se documentaron `time_calendar.gd` (fachada unificada, ISaveProvider) y `festival_data.gd` (datos eventos)
- Se eliminaron referencias a `date_model.gd` y `event_catalog.gd` (no existen en el código real)

### M30 Reloj en Tiempo Real (`plan-actual/04-Codigo.md`)
- Se agregó `reloj_hud.gd` (capa de DISPLAY + POLÍTICA, consumo de GameClock)
- Se eliminaron referencias a archivos de test no existentes

### M38 Economía (`plan-actual/04-Codigo.md`)
- Se agregó `economy_price_catalog.gd` (catálogo central de precios, class_name, cache estático)

### M39 Tiendas (`plan-actual/04-Codigo.md`)
- Se reemplazó la tabla de "Pendiente de implementación" por scripts reales implementados
- Se documentaron `shop_data.gd` (Resource data-driven, inner class StockEntry) y `reputacion_tienda.gd` (niveles 0-5, cozy)
- Se actualizaron paths de `res://tiendas/` a `scripts/shops/`

### M66 Anti-Softlock (`plan-actual/04-Codigo.md`)
- Se reemplazó la tabla de C# futuro por scripts GDScript implementados
- Se documentaron los 8 invariant scripts: `invariant_base.gd`, `irecoverable.gd`, `jugador_invariant.gd`, `npc_invariant.gd`, `mision_invariant.gd`, `objeto_clave_invariant.gd`, `puzzle_invariant.gd`, `vehiculo_invariant.gd`
- Se eliminaron referencias a paths C# (`Assets/_Project/Scripts/Core/*.cs`)

## Archivos Modificados/Creados

- `DOCUMENTACION/07-Arquitectura-General/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/30-Reloj-En-Tiempo-Real/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/39-Tiendas/plan-actual/04-Codigo.md` — editado
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/04-Codigo.md` — editado
- `Logs/296-sincronizacion-doc-vs-codigo-m07-m15-m29-m30-m38-m39-m66_2026-08-30.md` — creado
- `Logs/ULTIMO_NUMERO.txt` — actualizado a 296

## Pendiente (módulos bloqueados)

Cuando los agentes liberen M16, M53 y M19:
- **M16 Crafting**: verificar si `crafting.json` (M93) está documentado
- **M53 UI-UX**: documentar `ui_root.gd` y `theme_service.gd`
- **M19 NPC**: verificar paths de `villager_*.gd` en documentación
