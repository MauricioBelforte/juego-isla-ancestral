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

> ⚠️ **QA atria-dawn (Log 976, 2026-09-17): la lista de arriba era la arquitectura
> PREVISTA. Estado real al 2026-09-17:**
> - `voxel_world.gd` — **NO EXISTE**. No hay fachada VoxelWorld ni registro en
>   ServiceRegistry. La edición de bloques la implementan otros módulos:
>   `scripts/tools/tool_controller.gd` (`try_extract() -> Dictionary`,
>   `try_place(block_id, metadata) -> bool`) y `interaction_manager.gd`.
> - `block_catalog.gd` — existe (140 l.) pero **está muerto en runtime**: ni
>   `BlockCatalog.new()` ni `get_library()` tienen llamadores. La library real la
>   construye `main_island.gd:96-139` inline. Su método útil es `get_block()`.
> - `block_validation.gd`, `world_events.gd`, `diff_store.gd` — **NO EXISTEN**.
> - `block_type.gd` — **live y central**: constantes de ids + `create_default()`
>   consumidas por island_generator, main_island, M15 recursos, etc.
> - `generators/` — se implementó como `world_generator.gd` (VoxelGeneratorScript,
>   M10) en la raíz de scripts/world/, no en subcarpeta.

**Voxel Tools** (GDExtension): VoxelTerrain + VoxelMesherTransvoxel + VoxelStream (diff), colisiones por mapa de bloques.

## 3. Contrato a otros módulos (resumen)

- `world.try_extract(pos: Vector3i, tool: ToolType) -> Result` (M13)
- `world.try_place(pos: Vector3i, type: BlockId) -> Result` (M17/M13)
- `world.get_block(pos) -> BlockData`, `world.set_block_puzzle(pos, state)` (M24)
- Eventos: `block_placed/removed/modified` (payload tipado) — consumidos por NPC reactividad (M19/M64), quests (M22), economía (M38), sonido (M43).

> ⚠️ **QA atria-dawn (Log 976): los contratos de arriba son los DISEÑADOS. La
> implementación real difiere — usar las firmas reales:**
> - No existe el objeto `world`. La edición se hace contra el controlador de
>   herramientas: `tool_controller.try_extract() -> Dictionary` (sin args de
>   posición — opera sobre el objetivo mirado) y
>   `tool_controller.try_place(block_id: int, metadata: Dictionary = {}) -> bool`.
>   Existe también un `recurso_mock.gd` con firmas parecidas (mock de test).
> - `set_block_puzzle` **no existe**; la lógica de bloques-puzzle con estado la
>   implementa M24/M26 por su cuenta (entidad vinculada, ver riesgo H.4).
> - `world.get_block(pos)` no existe; el acceso a bloques del terreno es vía
>   `VoxelTerrain.get_voxel_tool()` + `get_voxel()` (ej. `main_island.gd:349-358`)
>   y `BlockCatalog.get_block(id)` para metadatos del BlockType.
> - Los eventos `block_placed/removed` **sí** están cableados por el EventBus
>   (servicio `event_bus` del Bootstrap): el log de boot registra
>   `[M92] Triggers EventBus conectados: ["inventory.item_added",
>   "world.block_placed", "npc.gift_given"]`.

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

## 6. QA Cruzado — Notas del Agente (atria-dawn)

**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-17 05:35
**Estado:** QA realizado — módulo **mantiene ✅** (0 flips; 105/105 [x] se sostienen)

### Veredicto diferenciado
A diferencia de M09 y M10 (revertidos a 🟡 en los Logs 944/945), el checklist de M08 es **honesto en su alcance**: prácticamente todos los ítems usan verbos de diseño ("Diseñar/Documentar/Definir") y la nota de cierre deja claro que "la validación física (greedy por tipo, radio de carga, medición de remesh) es responsabilidad del hito M1 y de M61; el diseño queda cerrado aquí". Además M08 **sí tiene código vivo**: `block_type.gd` (constantes de ids 0–30 + `create_default()`) es central para island_generator, la library de main_island, M15 recursos, etc. No hay sobre-cierre que revertir.

### Lo que SÍ está mal (defectos de documentación — corregidos en este QA)
1. **§2 listaba 5 archivos de los que 4 NO existen**: `voxel_world.gd`, `block_validation.gd`, `world_events.gd`, `diff_store.gd`. Mismo patrón de "paths fantasma" que M09. La fachada VoxelWorld y su registro en ServiceRegistry **nunca se materializaron**; la edición de bloques la implementan `scripts/tools/tool_controller.gd` + `interaction_manager.gd`. Marcado in-situ arriba.
2. **§3 firmas de contrato incorrectas vs implementación**: `world.try_extract(pos, tool)` y `world.try_place(pos, type)` no existen (no hay objeto `world`); las reales son `tool_controller.try_extract() -> Dictionary` y `try_place(block_id, metadata) -> bool`. `set_block_puzzle` no existe. Corregido in-situ arriba con las firmas reales.
3. **Claims de MiMo stale**: "BLOCK_AIR a BLOCK_LAVA" — **LAVA no existe** (las constantes llegan hasta MUD=29 + SHALLOW_WATER=30); "BlockCatalog.new().build_voxel_library()" — el método real es `_build_library()` (privado, se llama desde `_init`) y `BlockCatalog` es **código muerto** en runtime (ver M10 QA, Log 945).
4. **Fila de CHECKLIST-GLOBAL**: "librería 21 bloques" — la library real de `main_island.gd:96-139` tiene **31 modelos** (ids 0–30).

### Lo que está bien (verificado)
- `block_type.gd`: 30 constantes (AIR=0 … MUD=29 + SHALLOW_WATER=30), categorías (SOLID/TRANSPARENT/LIQUID/EMISSIVE), tool_required, drops, debug colors — **live y consistente** con la library de main_island y con el generador de M10.
- Paleta Maldivas aprobada por el usuario (Hy3, 2026-08-29) aplicada en main_island.gd — confirmada en código (SAND #F5F0E1, GRASS #55711E, SHALLOW_WATER (0.25,0.82,0.78), etc.).
- `VoxelBoxMover` del jugador **live** (boot headless: "Player VoxelBoxMover listo, terrain encontrado").
- Boot headless limpio; los 105 ítems de diseño son trazables a 03-Diseno.md.
- Directiva "colores por isla" (2026-08-29) documentada correctamente como pendiente de M08/M14/M15.

### No verificado en esta iter (headless)
- "Edición E/Q" del GDD (interacción de colocar/extraer en runtime): requiere input/jugador activo; no replicable headless. Las funciones subyacentes (`try_place`/`try_extract` en tool_controller) existen y están tipadas.

### Recomendaciones para el próximo agente
1. Si se materializa la fachada VoxelWorld (voxel_world.gd), alinearla con las firmas reales actuales o migrar tool_controller a ella — hoy hay dos "contratos" (el doc de diseño y el código real) que no coinciden.
2. Decidir el destino de `BlockCatalog` muerto (borrarlo o cablearlo de verdad — ver Log 945).
3. El flag `has_gravity` de arena/grava está definido en BlockType pero **no hay código que lo consuma** (gravedad de bloques sueltos) — queda como diseño pendiente de M1.
4. `world.block_placed` está en EventBus; verificar que M19/M22/M38/M43 realmente consuman `block_removed`/`block_modified` también (no se vio en el boot).
