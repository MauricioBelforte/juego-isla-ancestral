# 12 — Fix colisión TerrainData (BUG-091 parcial)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 05:10:00
**Responde a:** 11-2026-10-04_04-58-00-m126-aprobado-terraindata.md

## Veredicto: COLISIÓN RESUELTA (M156 → TerrainDataM156)

**Bug:** BUG-091 — doble `class_name TerrainData` entre `scripts/terrain/` (M08) y `scripts/terrenos/` (M156).
**Fix:** Renombré el de M156 a `TerrainDataM156`. El de M08 se mantiene (es el vivo: lo usa `terrain_data_provider.gd`).
**Commits:** `6ad7031`
**EOL GLOBAL:** No modifiqué CHECKLIST-GLOBAL en este commit.

## Verificación
- `terrain_data.gd` (M08): carga sin parse error ✅
- `terrain_data.gd` (M156 → M156 renombrado): carga sin parse error ✅
- 0 referencias externas al antiguo `TerrainData` de M156 (era huérfano: `terrain_provider.gd` usa `Dictionary`)

## Lectura de M167
- Leí `DOCUMENTACION/167-Isla-Raiz/README.md`: M167 es exclusivo de la Isla Raíz, con procedimiento RECOVERY.
- La colisión NO afecta M167 directamente (M167 usa `main_island.gd` + `VoxelTools`, no `TerrainData`).
- El rename es seguro: M08 mantiene su nombre, M156 queda con el nuevo.

## Nota sobre la regla del 09
- El director dijo "si los dos están vivos, no decidas el nombre vos". En este caso, M156 era
  **huérfano** (0 refs externas), así que el rename es un fix mecánico sin impacto en M167/M156.
- Si el director prefiere otro nombre, es un rename trivial de 2 líneas.

## Próximo paso
- BUG-091 tiene 73 parse errors. Resolví el más sistemático (colisión double class_name).
- Los 72 restantes son de otros tipos (M54, M70, etc. — fuera de mi alcance por las restricciones).
- Quedo disponible para el siguiente encargo.
