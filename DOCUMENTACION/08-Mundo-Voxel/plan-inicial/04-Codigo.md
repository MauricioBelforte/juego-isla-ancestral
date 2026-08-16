**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 08: Mundo Voxel

## 1. Carácter del Componente

Módulo **técnico de diseño** del mundo voxel (complejidad 5, riesgo #1). Definición de configuraciones y contratos; la implementación (world.gd, chunk integration) es parte del hito M1/prototipo. Los 06/07 de testing se activarán con el prototipo (remesh, AO, edición).

## 2. Arquitectura de implementación (Godot + Voxel Tools)

```
scripts/world/
├── voxel_world.gd          ← fachada de VoxelWorld (registro en ServiceRegistry)
├── block_catalog.gd        ← catálogo de BlockType (Resources)
├── block_validation.gd     ← reglas de colocación/protección
├── world_events.gd         ← señales world: (chunk_modified, block_placed…)
├── diff_store.gd           ← diffs por chunk (partición world de GameState)
└── generators/             ← (M10)
```

**Voxel Tools** (GDExtension): VoxelTerrain + VoxelMesherTransvoxel + VoxelStream (diff), colisiones por mapa de bloques.

## 3. Contrato a otros módulos (resumen)

- `world.try_extract(pos: Vector3i, tool: ToolType) -> Result` (M13)
- `world.try_place(pos: Vector3i, type: BlockId) -> Result` (M17/M13)
- `world.get_block(pos) -> BlockData`, `world.set_block_puzzle(pos, state)` (M24)
- Eventos: `block_placed/removed/modified` (payload tipado) — consumidos por NPC reactividad (M19/M64), quests (M22), economía (M38), sonido (M43).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Validar en M1: greedy meshing ON/OFF por tipo (medición) | Hito M1 |
| Calibrar radio de carga/descarga óptimo (fps) | M61 |
| Formato binario de diffs (compresión) | M59 |
| Bloque de agua con nivel: script de soporte propio | M51 + M1 |
| Definir texturas/skins por bioma del catálogo | M45/M47 |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 02:45:00
**Estado:** Completado (diseño; prototipo en M1)

### Lo que hice
- Resolví los 39 puntos del plan maestro (sección 7) con constantes, catálogo de ~30 bloques, reglas de validación y estrategias de mesh/agua/persistencia.
- Basé el mundo en Voxel Tools (no reinventar) con capa propia para catálogo/reglas/diffs.

### Lo que NO pude hacer (honestidad obligatoria)
- Medir rendimiento real (greedy vs no, radio óptimo) → requiere el prototipo.
- Implementar el agua con nivel → requiere motor corriendo; detalles en M51.
- Confirmar el catálogo final de bloques → depende de arte (M45) y diseño de puzzles (M24).
- No elegí 32³ vs 16³ de chunk definitivo (depende de la medición del prototipo; base 16³).

### Recomendaciones para el próximo agente
- M10 (Generación): el mundo base debe ser determinista por seed; los diffs se re-aplican (referencia aquí §6).
- M13 (Herramientas): usar `try_extract/try_place` como contrato desde el día 1.
- El prototipo M1 debe incluir SIEMPRE un test de edición rápida (10 bloques/seg) para validar diffs sin lag.