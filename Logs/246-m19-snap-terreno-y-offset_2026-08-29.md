# Log 246: M19 — Snap al terreno y offset de NPC

**Fecha:** 2026-08-29
**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode

## Resumen
Se corrigió el posicionamiento del NPC CatalinaOso sobre el terreno vóxel: snap al terreno con IslandGenerator.get_height() y offset +1.0.

## Cambios Realizados

### 1. NPC movido dentro de la isla
- Posición anterior: (5, 8, 5) — fuera de la isla (centro 64,64, radio 64)
- Posición nueva: (30, 10, 64) — dentro de la isla

### 2. Snap al terreno: IslandGenerator.get_height() en vez de VoxelTool.raycast()
- **Problema:** VoxelTool.raycast() fallaba al inicio porque los chunks del terreno no estaban generados (generación asíncrona)
- **Solución:** usar IslandGenerator.get_height() directamente — es determinista, no necesita chunks
- Archivos modificados: `villager.gd`, `villager_manager.gd`

### 3. Offset +1.0 para pies sobre bloque
- get_height() retorna Y del bloque sólido más alto (ej: 8)
- Bloque en Y=8 ocupa Y=8 a Y=9
- Cápsula del NPC tiene centro en local Y=0.5 (altura 1.0), pies en local Y=0
- Con +0.5: pies en Y=8.5 → mitad dentro del bloque
- Con +1.0: pies en Y=9.0 → exactamente sobre la superficie (CORRECTO)

### 4. Documentación de errores
- §9.44: VoxelTool.raycast() no funciona al inicio (chunks no cargados)
- §9.45: Offset de NPC sobre bloques: +1.0 sobre get_height()

### 5. M19 Checklist actualizado
- 4 ítems marcados en sección F (Interacción con tecla F)

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/npc/villager.gd` — snap con IslandGenerator + offset +1.0
- `game/isla-ancestral/scripts/npc/villager_manager.gd` — get_ground_height con IslandGenerator
- `game/isla-ancestral/scenes/main_island.tscn` — NPC en posición (30, 10, 64)
- `DOCUMENTACION/07-GUIA-GODOT.md` — §9.44 y §9.45 agregados
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/04-Codigo.md` — Notas del Agente actualizadas
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md` — 4 ítems marcados
