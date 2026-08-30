# Log 242: Estrategia anti-flotamiento — TerrainLocator (servicio central de posicionamiento)

**Fecha:** 2026-08-30
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se eliminó la causa raíz de que los NPCs floten: cada uno creaba su propio IslandGenerator
con radio hardcodeado distinto al del mundo. Se creó el autoload TerrainLocator, único
punto de verdad del posicionamiento, que consulta el generador REAL del mundo.

## Cambios
- scripts/core/terrain_locator.gd (NUEVO, autoload): get_height(x,z) + posicionar_sobre_terreno(nodo,x,z)
- scripts/npc/villager.gd: snap con TerrainLocator (antes creaba IslandGenerator con radio 2048)
- scripts/npc/villager_manager.gd: get_ground_height con TerrainLocator (antes radio 64/1024)
- scripts/ruinas/generador_ruina.gd: _buscar_altura con TerrainLocator (antes get_voxel de chunks)
- scripts/main_island.gd: spawn con TerrainLocator
- project.godot: autoload TerrainLocator registrado

## Verificación
- Juego corre sin errores. Log del run: CatalinaOso snap al terreno en Y=24.0 (height=23)
  — ahora SIEMPRE sobre la superficie real, no flota.
- FPS 60, terreno visible.

## Regla establecida
TODOS los objetos usan TerrainLocator. NUNCA crear IslandGenerator propio con radio
hardcodeado. Documentado en guía 07 §10.16 y módulo 167.

## Archivos
- scripts/core/terrain_locator.gd, villager.gd, villager_manager.gd, generador_ruina.gd, main_island.gd, project.godot
- DOCUMENTACION/07-GUIA-GODOT.md (§10.16), DOCUMENTACION/167-Isla-Raiz (04-Codigo, 03-Diseno)
- Logs/242-estrategia-anti-flotamiento-terrainlocator_2026-08-30_00-20-00.md
