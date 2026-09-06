# Log 725: M160 iter. 5 — catálogo JSON de ubicaciones + grafo de conexiones

**Fecha:** 2026-09-06
**Hora:** 03:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iteración 5 del módulo 160 (Diseño de Ubicaciones del Mundo): se completaron las 39 ubicaciones que faltaban del checklist mediante un catálogo data-driven JSON, se conectó todo el grafo de ubicaciones (bidireccional, validado) y se definieron requisitos de acceso por tier de herramienta M158 y objetos de recolección con regeneración del catálogo M159. Test headless: 19 checks 0 fallos + regresión del schema 5/5.

## Cambios Realizados
- `data/ubicaciones/ubicaciones_loc.json` (NUEVO): 39 ubicaciones LOC-* — RIZ: BOS-001/002/003, PLA-001, PLA-002, CUE-001, RUI-001, PUER-001, TAL-001; COR: PUB-001, TIE-001 (Ferretería), TIE-002 (Pescadería), TAL-001 (Herrería), CASA-001, PUER-001, SEL-002 (Cataratas), PLA-001, PLA-002 (Arrecife), CUE-001, MON-001 (Monte Vigía); CEN: PUB-001, TIE-001, TAL-001, CASA-001, PUER-001, MON-002 (Mina Abandonada), BOS-001, CUE-001, CUE-002 (Cueva Profunda), RUI-001; AUR: PUB-001, TIE-001, TAL-001, CASA-001, SEL-001, TEM-002 (Templo del Sol), TEM-003 (Templo de la Luna), CUE-001 (Cueva de las Estrellas), RUI-001 (Ruinas del Archivo).
- Conexiones bidireccionales completas: el pueblo conecta con naturaleza/tiendas/puerto por isla; circuito de templos de Aurora (selva→cueva→sol→luna→archivo); 0 conexiones a ubicaciones faltantes.
- Requisitos por tier: CEN exige pico T2 (mina/cueva profunda/rui), AUR T3 (selva/templos), COR T1 (arrecife/cueva).
- Objetos con `regeneracion_seg` (120-1800s) y `herramienta`+`tier_minimo` por objeto; todos los IDs validados contra el catálogo M159 (data/items/).
- `world_locations.gd`: `cargar_catalogo_json()` (los .tres tienen prioridad, el JSON completa), `_reflejar_conexiones()` (grafo bidireccional en memoria sin tocar los .tres), `get_conexiones()`, `get_recolectables()`.
- `test_ubicaciones_iter5.gd` (NUEVO): 19 checks — carga 48 ubicaciones (9 .tres + 39 JSON), conteos por isla, conexiones bidireccionales, requisitos, regeneración, validación M159 via ItemDatabase.
- Checklist del módulo: 73/134 → 149/156.

## Archivos Modificados/Creados
- `game/isla-ancestral/data/ubicaciones/ubicaciones_loc.json` (NUEVO, 39 ubicaciones)
- `game/isla-ancestral/scripts/data/world_locations.gd` (carga JSON + reflejo + 2 APIs)
- `game/isla-ancestral/scripts/data/test_ubicaciones_iter5.gd` (NUEVO)
- `DOCUMENTACION/160-Diseno-De-Ubicaciones-Del-Mundo/plan-actual/05-Checklist.md` (149/156 + Notas del Agente)
- `CHECKLIST-GLOBAL.md` (fila 160: 149/156, 🟡 Liberado iter. 5)

## Evidencia
- Test: `=== Resumen M160 iter. 5: 19 checks, 0 fallos ===` y `[M160] catálogo JSON: 39 cargadas, 0 omitidas (.tres), 0 errores`.
- Regresión: `=== Resumen M160: 5 checks, 0 fallos ===` (test del schema ubic_* intacto).
- Boot completo del juego sin SCRIPT ERROR tras los cambios.
