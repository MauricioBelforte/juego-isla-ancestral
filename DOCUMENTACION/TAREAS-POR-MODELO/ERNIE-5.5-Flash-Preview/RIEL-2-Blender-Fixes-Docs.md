# RIEL-2 - ERNIE (Blender fixes + Verificacion + Docs, 12 tareas)

**Fuente:** agnes-3-flash (13nov)
**Fecha:** 2026-11-13 08:05
**Base:** RIEL-1 CERRADO 12/12

## Bloque 4: Fixes Z_APOYO (5) — ⛔ **ANULADO por agnes-3-flash (msg 017)**
> **No hay trabajo en este bloque.** Los 5 GLB estaban correctos desde el principio (+0,0450 exacto).
> El "hundido" era mi metodo: transformar **esquinas de AABB** por la matriz del nodo (trampa E-24, documentada en `corregir_asset.py` L71-75).
> Re-export ejecutado (76 GLB, 0 errores) → `git status` sobre `assets/3d` = **0 archivos modificados**: no-op.
> **Unico real: `36-Fauna_conejo.glb`** — alta 0,0000 / media −0,1700 (el `.blend` v12 = +0,0450). agnes lo acepta como pieza plana (017). Es M36 (HY4), no lo toco.
- [x] Perla ancestral — **ANULADA**: GLB +0,0450 correcto
- [x] Globo del viento — **ANULADA**: GLB +0,0450 correcto
- [x] Roca pedernal — **ANULADA**: GLB +0,0450 correcto
- [x] Roca comun — **ANULADA**: GLB +0,0450 correcto
- [x] Conejo — **ANULADA como fix**: queda como observacion M36 (alta 0,0000, media −0,1700)

**Respaldo:** 13 `.blend` en `Obsoletos/2026-11-13_23-25-26_fix-z_apoyo-riel2/` (nombres unicos, sin colision).
⚠️ Mi respaldo de GLB (`Obsoletos/2026-11-13_23-29-15_glb-antes-reexport/`) **es inservible**: copie alta/media/baja a carpeta plana y los nombres se pisan (quedaron 27 de 78). Declarado en msg 016 §3.

## Bloque 5: Verificacion (4)
- [x] M18 saneo ventanas (65) — **HECHO 2026-11-13 20:15** (msg 013): el saneo no estaba aplicado (acuse sin guardar); lo aplique yo. 65 verificado en disco, 4 QA AABB a `[?]`, drift de 11 corregido, CHECKLIST sincronizado (verificar_checklist.py ya no marca M18).
- [x] M25 Columnas estado — **HECHO 2026-11-13** (RIEL-1, msg 006): `columna_rota_alta` (1,45×1,02×**2,15** m) y `columna_rota_baja` (×**1,45** m) existen en 3 LOD, z_min=+0,045.
- [x] M35 Semillero — **HECHO 2026-11-13** (RIEL-1, msg 006): `33-Agricultura_cultivo_brote` ×3 LOD + `.blend` + 6 capturas, 0,28×0,28×0,15 m, z_min=+0,045.
- [x] M19 Casa vecino — **HECHO 2026-11-13** (RIEL-1, msg 006): `18-Casas_casa_vecino` ×3 LOD, 7,60×7,10×3,52 m, z_min=+0,045.

## Bloque 6: Docs (3)
- [x] AGENTS §24 mojibake check — **HECHO 2026-11-13 19:58** (msg 008): AGENTS saneado a Godot (183 lineas). Mojibake en AGENTS: **solo 3 lineas, las de ejemplos de §28** (preexistentes, intencionales). 0 tabs sueltos, 0 mojibake accidental.
- [x] GUIA-COMPARATIVA + ERNIE — **HECHO 2026-11-13 19:58** (msg 008): ERNIE "en prueba" → "en flota", con limitacion de vision y mediciones verificadas.
- [x] 5 modulos drift Totales — **HECHO 2026-11-13 18:56** (msg 003 §4): 74-Eventos +58, 71-Progresion +44, 27-Islas +37, 63-Cargas -26, 25-Ruinas -16; + 73-Coleccionables y 75-Postgame con `✅` sin DoD.

**Total: 12. Prioridad: 4 -> 5 -> 6.**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code - 2026-11-13 08:05
