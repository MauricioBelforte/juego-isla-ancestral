# Log 596: M36 — Jabalí adulto: sistema de etapas de vida (joven/adulto)

**Fecha:** 2026-09-03
**Hora:** 08:00
**Modelo:** hy3
**Plataforma:** Kilo Code

## Resumen
Implementación y verificación del sistema de etapas de vida del jabalí (feedback del
usuario 2026-09-03). El NPC `JabaliNPC` ahora soporta dos etapas — `joven` (compacto,
trote liviano) y `adulto` (bruto grande 2.3×, trote pesado y pausado) — ajustando
escala, velocidad, rebote y pausas automáticamente al setear la etapa en el inspector.

## Cambios Realizados
- **`game/isla-ancestral/scripts/fauna/jabali_npc.gd`** (ya existente, completado):
  - `@export_enum("joven","adulto") var etapa` + `_CFG_ETAPA` con parámetros por etapa.
  - `_aplicar_etapa()` propaga escala/velocidad/rebote/pausas en `_ready()`; fallback a `joven`.
  - Trote diagonal cuadrúpedo, rebote sincronizado, cola-cuerda, cabeceo de husmeo,
    escala desde los pies, snap vía `TerrainLocator`.
- **`game/isla-ancestral/scenes/main_island.tscn`**:
  - `JabaliNPC` con `etapa = "joven"`.
  - `JabaliAdultoNPC` con `etapa = "adulto"`.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/fauna/jabali_npc.gd` (verificado, ya presente en repo)
- `game/isla-ancestral/scenes/main_island.tscn` (2 instancias de jabalí)
- `DOCUMENTACION/36-Fauna/plan-actual/04-Codigo.md` (sección Jabalí — etapas)
- `DOCUMENTACION/36-Fauna/plan-actual/05-Checklist.md` (16 ítems jabalí etapas, todos [x])

## Verificación
- Ejecución en Godot 4.7.2 (MCP `run_project` + `get_debug_output`): 0 errores nuevos.
- Log de runtime:
  - `[Jabali joven] troteando por la isla (spawn 232, 240) — 4 patas, cola: si, cabeza: si`
  - `[Jabali adulto] troteando por la isla (spawn 285, 224) — 4 patas, cola: si, cabeza: si`
- Las warnings restantes son globales preexistentes (event_bus.gd, etc.) y no afectan M36.

## Notas
El módulo M36 se mantiene en `🟡 Con dudas` por los `[?]` con dueño externo (criaturas
in-game M64, UI diario M55/M37, visuales M45). Esta entrega cierra la subtarea de
etapas del jabalí.
