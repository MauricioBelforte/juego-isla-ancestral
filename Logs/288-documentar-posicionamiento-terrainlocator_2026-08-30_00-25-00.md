# Log 288: Documentar el posicionamiento con TerrainLocator para todos los agentes

**Fecha:** 2026-08-30
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se documentó la estrategia de posicionamiento de objetos sobre el terreno (TerrainLocator)
en módulos y guías, para que cualquier agente sepa cómo posicionar sin que los NPCs floten.

## Cambios
- AGENTS.md §26: añadida la regla de oro del posicionamiento con TerrainLocator (no crear
  IslandGenerator propio con radio hardcodeado).
- DOCUMENTACION/168-Plantilla-De-Isla: 03-Diseno y 04-Codigo actualizados con el método
  OBLIGATORIO TerrainLocator (para que las islas nuevas lo usen desde el inicio).
- DOCUMENTACION/167-Isla-Raiz: ya documentado el TerrainLocator (04-Codigo, 03-Diseno, mapa).
- DOCUMENTACION/07-GUIA-GODOT.md: §10.16 (TerrainLocator) ya anexada en log 284.

## Uso para agentes
- Para posicionar cualquier objeto/NPC/casita: usar "/root/TerrainLocator".get_height(x,z)+1
  o locator.posicionar_sobre_terreno(nodo, x, z).
- NUNCA crear IslandGenerator propio con radio hardcodeado (causa de flotamiento).
- Ver guía 07 §10.16 y módulo 167 (ejemplo resuelto).

## Archivos
- AGENTS.md, DOCUMENTACION/168-Plantilla-De-Isla (03-Diseno, 04-Codigo + plan-inicial)
- Logs/243-documentar-posicionamiento-terrainlocator_2026-08-30_00-25-00.md
