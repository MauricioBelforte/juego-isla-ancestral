# 510 — Barrido anti-drift M35-Mineria: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 00:41

## M35 — 04-Codigo.md vs. scripts/mineria/

**Rutas de diseño (res://_Project/, propuestas — L7 "Se ajustarán a la estructura final"):**
- `Gameplay/Mining/MiningManager.gd`, `MiningTool.gd`, `OreDefinition.gd`, `OreVein.gd` — MISS.
- L7 declara explícitamente que estas rutas son **propuestas** adaptadas de Unity (`res://_Project/`) y "se ajustarán a la estructura final del proyecto Godot".

**Implementación real (scripts/mineria/ — tabla L336-339):**
| Ruta | Disco |
|------|-------|
| mineria/mining_manager.gd | OK (9011 B→13619, autoload) |
| mineria/mining_vein_catalog.gd | OK |
| mineria/test_mineria.gd | OK |
| data/mining/ores.json | OK (no .tres) |

## Veredicto

**DRIFT 0.** El doc es honesto: las rutas PascalCase de `res://_Project/` son propuestas de diseño (sección "Rutas propuestas"), y la implementación real vive en `scripts/mineria/` + `data/mining/ores.json` — todo en disco. Ningún `[x]` afirma que los archivos `Gameplay/Mining/*.gd` existan.
