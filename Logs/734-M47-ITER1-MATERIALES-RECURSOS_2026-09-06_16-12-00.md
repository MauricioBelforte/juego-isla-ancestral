# Log 734: M47 iter. 1 — materiales/formas distintivas por tipo de recurso

**Fecha:** 2026-09-06
**Hora:** 16:12
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 1 del módulo 47 (Texturas y Materiales): los recursos M15 dejaron de ser cajas naranjas indistinguibles — ahora cada tipo tiene color Y forma lowpoly distintiva, data-driven. Durante la verificación se descubrió y corrigió un bug de orden (configurar antes de add_child → get_tree() null).

## Cambios Realizados
- `data/arte3d/materiales_recursos.json` (NUEVO): 24 tipos con color RGB + forma (roca_mineral/tronco/mata/esfera_baya/cristal/roca) + emisión opcional. Match por substring sobre def_id (veta_cobre, mineral_cobre, madera_roble, baya_roja, fragmento_ancestral, clay, mud, sand, moss, ice...).
- `scripts/arte3d/materiales_recursos.gd` (NUEVO, autoload MaterialesRecursos): carga la tabla, cachea materiales, construye visuales lowpoly — roca_mineral (prisma + 3 pepitas esféricas), tronco (cilindro hexagonal con anillos), mata (3 cajas cruzadas), esfera_baya (esfera + tallito), cristal (prismas facetados inclinados con emisión), roca (2 prismas superpuestos).
- `scripts/resources/resource_node.gd`: _crear_presentacion() usa el visual M47 cuando el autoload existe (3 copias con escalas/rotaciones de estado INTACTO/DANIADO/AGOTADO); fallback legacy a cajas por categoría.
- `scripts/resources/resource_spawner.gd`: **FIX de orden** — `configurar()` necesita el árbol (get_tree() para buscar M47): ahora es add_child → configurar (antes configurar → add_child, lo que dejaba todos los recursos con el visual legacy por error "data.tree is null" silencioso en consola).
- `scripts/arte3d/test_materiales_m47.gd` (NUEVO): 17 checks — colores distintivos (cobre naranja R>G>B, hierro gris, oro amarillo), formas por tipo, default a roca, visuales construidos, emisión del ancestral, integración ResourceNode con el orden corregido.

## Evidencia Visual (capturas/47/)
- `cap_47_..._recursos_vetas.png` — veta cobre NARANJA con pepitas, veta oro AMARILLA, veta hierro GRIS (antes: todas naranja uniforme).
- `cap_47_..._recursos_naturaleza.png` — madera marrón, fibra clara, bayas rojas — cada tipo distinguible a simple vista.
- ANTES (manchas naranjas sin forma): `tools/mcp/godot-mcp/capturas/50/cap_50_2026-09-06_07-57-03_panoramica_inicial_escala.png`.

## Tests
- test_materiales_m47.gd: 17 checks, 0 fallos.
- Boot completo sin errores "data.tree is null" (12 nodos M15 spawnean con visual M47).

## Archivos Modificados/Creados
- `game/isla-ancestral/data/arte3d/materiales_recursos.json` (NUEVO)
- `game/isla-ancestral/scripts/arte3d/materiales_recursos.gd` (NUEVO, autoload)
- `game/isla-ancestral/scripts/resources/resource_node.gd` (visual M47 + tipos Node3D)
- `game/isla-ancestral/scripts/resources/resource_spawner.gd` (FIX orden add_child→configurar)
- `game/isla-ancestral/scripts/arte3d/test_materiales_m47.gd` (NUEVO)
- `game/isla-ancestral/project.godot` (autoload MaterialesRecursos)
- `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/05-Checklist.md` + CHECKLIST-GLOBAL.md (fila 47)
