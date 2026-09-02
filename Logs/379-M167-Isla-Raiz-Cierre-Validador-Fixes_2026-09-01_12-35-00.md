# Log 379: M167 Isla Raíz — Cierre iter 1: validador del terreno + 3 fixes (batimetría/spawn/snap) + verificación visual V4

**Fecha:** 2026-09-01
**Hora:** 12:35
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 1 de cierre del módulo M167 (Isla Raíz, fuente de verdad del terreno): 21 ítems pendientes (H validador, K mantenimiento, L verificación visual, M plantilla) implementados/verificados. Se creó un validador headless del terreno (28 checks), una escena de inspección de costa para QA visual, y se corrigieron 3 defectos reales del posicionamiento/perfil: el agua clara turquesa (SHALLOW_WATER) nunca se generaba, el spawn enterraba al jugador en el arranque y el snap de Catalina flotaba.

## Cambios Realizados

### Código nuevo (módulo)
- `game/isla-ancestral/scripts/terreno/validador_isla_raiz.gd` — validador del terreno (28 checks): config estática real de main_island.gd (world_seed 42, island_radius 256, max_height 40, spawn (256,16,256), TerrainLocator autoload/en uso, sin IslandGenerator propio en villager*), perfil dinámico radial (centro h≥12 y ≤40 = 14 real con semilla 42; plato 3-4; banda clara fondo 2; profunda 0), batimetría (SHALLOW_WATER id 30 en y=3 de la banda, SAND 5 en plato, WATER 17 en profunda), determinismo (2 generadores seed 42, 10 puntos), sin muros verticales (salto máx ≤6, medido 2). Ejecución: `godot --headless --path game/isla-ancestral --script res://scripts/terreno/validador_isla_raiz.gd` → **28/28 OK, exit 0**.
- `game/isla-ancestral/scripts/terreno/captura_playa.gd` + `game/isla-ancestral/scenes/captura_playa.tscn` — escena de inspección de la costa (misma librería/colores Maldivas, viewer en la playa mirando al mar) para QA visual L.3-L.5.

### Fixes de dominio (terreno/posicionamiento)
1. **island_generator.gd** (batimetría): `y <= water_level` → `y <= water_level + 1` en get_block_at. Antes la banda 0.94-0.98 generaba AIR en la capa superficial (el agua clara turquesa NUNCA se renderizaba; el diseño pedía la capa SHALLOW_WATER en y=height+1 para caminar sumergido hasta la cintura). Confirmado runtime: block=30 (SHALLOW_WATER) en (503,3,256) y block=17 (WATER) en (530,1,256).
2. **main_island.gd** (spawn): `_ajustar_spawn_superficie` verificaba `altura_spawn < 0`? NO — si el TerrainLocator aún no tiene el VoxelTerrain (h=-1), el jugador quedaba en Y=2 bajo la montaña (h=14). Fix: conservar (256,16,256) y reintentar con timer 0.5 s (hasta 6). Runtime verificado: "Spawn sobre superficie calculada Y=17".
3. **villager.gd** (snap): fallback dejaba Y=30 (flotando ~15 bloques). Fix: reintento del snap (timer 0.5 s hasta 6) hasta que el locator esté disponible. Runtime verificado: "CatalinaOso snap al terreno en Y=24.0 (height=23)".

### Verificación (V4 godot-mcp + capturas V1)
- Runtime: FPS 60, 0 errores nuevos (2 errores preexistentes de M161 `npc_visual_database.gd:18` documentados como hallazgo ajeno).
- Capturas: `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-09-01_12-28-00_overview.png` (ladera: jugador sobre terreno, Catalina en superficie, HUD, calendario) y `cap_167_2026-09-01_12-32-00_costa.png` (plato arena + agua turquesa clara + azul profundo).

### Documentación
- 03-Diseno.md §6: fixes + valor real del pico (14) + herramientas + hallazgo ajeno.
- 05-Checklist.md: H/K/L/M marcados (102/104 [x]; 2 [?] honestos).
- 04-Codigo.md: implementación, evidencia y Notas del Agente.

### Coordinación
- CHECKLIST-GLOBAL (fila 167 → 🟡 102/104), guía 08 (fila M167), ESTADO-PARALELO (fila), Logs/ULTIMO_NUMERO.txt (→365).

## Archivos Modificados/Creados

- Creados: `game/isla-ancestral/scripts/terreno/validador_isla_raiz.gd`, `game/isla-ancestral/scripts/terreno/captura_playa.gd`, `game/isla-ancestral/scenes/captura_playa.tscn`, capturas (2 PNG, no versionados)
- Modificados: `game/isla-ancestral/scripts/world/island_generator.gd` (batimetría), `game/isla-ancestral/scripts/main_island.gd` (spawn reintento), `game/isla-ancestral/scripts/npc/villager.gd` (snap reintento)
- Documentación: `DOCUMENTACION/167-Isla-Raiz/plan-actual/{03-Diseno,04-Codigo,05-Checklist}.md`
- Coordinación: `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `Logs/ULTIMO_NUMERO.txt`

## Verificación

- Validador: 28/28 OK exit 0 (2 corridas: antes con 3 fallos → eran hallazgos reales; después de fixes 0 fallos).
- Runtime V4: spawn Y=17 ✓, Catalina snap Y=24 (h=23) ✓, SHALLOW_WATER block=30 ✓, WATER block=17 ✓, FPS 60 ✓.
- Visual (capturas leídas con visión del modelo): ladera correcta + costa Maldivas (arena/turquesa/azul) ✓.
- 2 [?] honestos: L.9 (diálogo con F — revalidar en build M137; verificado 2026-08-28 y hook intacto) y M-crear isla futura (no aplica aún; M168 es la plantilla).

