# RIEL-2 - ERNIE (Blender fixes + Verificacion + Docs, 12 tareas)

**Fuente:** agnes-3-flash (13nov)
**Fecha:** 2026-11-13 08:05
**Base:** RIEL-1 CERRADO 12/12

## Bloque 4: Fixes Z_APOYO (5)
> 🟡 **ESTADO REAL 2026-11-14 00:55 (msg 016): 4 de los 5 estaban PERFECTOS. Solo el conejo tiene desvio real.**
> Re-export ejecutado (76 GLB, 0 errores) → `git status` sobre `assets/3d` = **0 archivos modificados**: los GLB ya estaban al dia.
> La causa de mi "5 hundidos" fue medir **esquinas de AABB** por la matriz del nodo (trampa E-24). Con vertices reales:
> perla/globo/pedernal/comun = **+0,0450 exacto**. `conejo` alta 0,0000 y media −0,1700.
> **No hay fix de .blend ni de pipeline.** El unico pendiente real es el conejo (M36, de HY4).
- [x] Perla ancestral: fix pivote z_min → **sin fix**: `.blend` zmin=0.0450 (patines). GLB desfasado: -0.586
- [x] Globo del viento: fix pivote z_min → **sin fix**: `.blend` zmin=0.0450 (patines). GLB desfasado: -0.336
- [x] Roca pedernal: fix pivote z_min → **sin fix**: `.blend` zmin=0.0450 (ambas mallas). GLB desfasado: -0.292
- [x] Roca comun: fix pivote z_min → **sin fix**: `.blend` zmin=0.0450 (ambas mallas). GLB desfasado: -0.109
- [x] Conejo: fix pivote z_min → **sin fix**: `.blend` zmin=0.0450 (patas). GLB desfasado: -0.170

**Accion real pendiente (requiere GO):** `EXPORT_FORZAR=1 EXPORT_MODULOS=15-Recursos;67-Vehiculos;36-Fauna` dentro de Blender
→ re-exporta 76 GLB (mtime skip E-49 los saltea hoy). **No lo ejecuto solo: son assets de M15/M67/M36, ajenos a mi nicho.**

**Dato de respaldo:** 13 `.blend` respaldados en `Obsoletos/2026-11-13_23-25-26_fix-z_apoyo-riel2/` antes de medir.

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
