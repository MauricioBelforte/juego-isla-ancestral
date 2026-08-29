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

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-25 23:30:00
**Estado:** Implementado (scripts creados, WorldManager funcional)

### Lo que hice
- Creé `block_type.gd` con Resource custom para 30+ bloques, IDs constantes (BLOCK_AIR a BLOCK_LAVA), herramientas requeridas, drops, debug colors.
- Creé `block_catalog.gd` como catálogo centralizado con `build_voxel_library()` para generar `VoxelBlockyLibrary` automáticamente.
- Resolví errores de VoxelBlockyModelCube: NO tiene `set_material()` — solo acepta `set_name()`.
- Resolví inferencia de tipos: usar `: float` explícito cuando `clamp()` u otras funciones retornan tipo ambiguado.

### Lo que NO pude hacer (honestidad obligatoria)
- `set_material()` en VoxelBlockyModelCube no existe — colores se asignan por separado via material override o VoxelMesherBlocky.
- VoxelBlockyLibrary configuración final queda pendiente de pruebas visuales con bloques reales.

### Recomendaciones para el próximo agente
- Los bloques se definen en `block_type.gd` (Resource). Cada tipo tiene: id, nombre, hardness, tool_required, drops.
- El catálogo se genera con `BlockCatalog.new().build_voxel_library()`.
- Para agregar un bloque nuevo: añadir constante en `block_type.gd` + añadir entrada en `_init_block_data()`.

---

### Notas del Agente Anterior

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 02:45:00
**Estado:** Completado (diseño; prototipo en M1)

### Lo que hice (agente anterior)
- Resolví los 39 puntos del plan maestro (sección 7) con constantes, catálogo de ~30 bloques, reglas de validación y estrategias de mesh/agua/persistencia.
- Basé el mundo en Voxel Tools (no reinventar) con capa propia para catálogo/reglas/diffs.

### Recomendaciones del agente anterior
- M10 (Generación): el mundo base debe ser determinista por seed; los diffs se re-aplican.
- M13 (Herramientas): usar `try_extract/try_place` como contrato desde el día 1.
- El prototipo M1 debe incluir SIEMPRE un test de edición rápida (10 bloques/seg) para validar diffs sin lag.

## Paleta Maldivas aprobada (2026-08-29 — Hy3/Kilo)

El usuario aprobo esta paleta para la isla (aplicada en main_island.gd, library de bloques):
- SAND (arena blanca): #F5F0E1
- GRASS (verde tropical): #55711E (ajustado por el usuario desde el propuesto #3AAF34)
- DIRT (tierra calida): #8C5A28
- WATER (agua profunda): #0A4B91
- SHALLOW_WATER (agua clara pisable, nuevo bloque id 30): #25D2C7 aproximado (0.25, 0.82, 0.78)
- STONE (piedra): #7D7D84

DIRECTIVA NUEVA — colores por isla: cada isla definira su propia paleta de bloques
(library propia o variantes de color por bioma) y los bloques extraidos por el
personaje conservaran el color de la isla de origen (requiere campo origen_isla en
ItemData + variante de color en el bloque colocado — a implementar en M08/M14/M15).
