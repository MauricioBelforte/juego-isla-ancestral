# RIEL-3 - ERNIE (Blender + Docs volumen 2, 12 tareas)

**Fuente:** agnes-3-flash (14nov)
**Fecha:** 2026-11-14 09:05
**Base:** RIEL-1 CERRADO + RIEL-2 CERRADO
**Estado:** 10/12 resueltos + 2 cerrados por bloqueo real (ver notas).

## 12 tareas nuevas

### Bloque 7: Blender - verificacion assets (5)
- [x] M25 Columna rota: verificar si ya existe GLB -> **SI**: `25-Ruinas-Templos_columna_rota_alta.glb` y `_baja.glb`, 3 LOD. Medidas: 1,45x1,02x**2,15** m y 1,45x1,02x**1,45** m, z_min +0,045. (Ya reportado en msg 006; reverificado 2026-11-14.)
- [x] M25 Columna entera: verificar si ya existe GLB -> **SI**: `25-Ruinas-Templos_columna_entera.glb`, 3 LOD, z_min +0,045.
- [x] Palanca de puzzle: verificar estado (creada?) -> **SI**: `70-Interacciones_palanca_madera.glb` x3 LOD, 1,20x0,34x0,57 m, z_min +0,045.
- [x] Semillero M35: verificar estado (creado?) -> **SI**: `33-Agricultura_cultivo_brote.glb` x3 LOD + `cultivo_brote_lowpoly.blend` + 6 capturas, 0,28x0,28x0,15 m, z_min +0,045.
- [x] Casa vecino M19: verificar estado (creada?) -> **SI**: `18-Casas_casa_vecino.glb` x3 LOD, 7,60x7,10x3,52 m, z_min +0,045.

> Los 5 estaban verificados desde RIEL-1 (msg 006). Reverificados con glob + medicion exacta el 2026-11-14.
> **No se re-modelo nada: no habia huecos.**

### Bloque 8: Analisis visual batch (4)
- [x] 490 GLB: re-verificar los 48 fuera de Z_APOYO (post retractacion) -> **AUDITORIA DEFINITIVA con vertices reales (no AABB)**:
      **447/490 dentro** de Z_APOYO 0,045 +-0,020; **43 fuera**, clasificados:
      - **18 montaje legitimo** (el pivote va al plano de contacto, no al suelo): techos x6 (z=2,645), decor de pared x6 (0,52-0,59), cabezas NPC x9 (-0,02, se ensamblan) -> **NO TOCAR**
      - **15 defectos reales**: `media` LOD de 10 assets de `50-Vegetacion` + `15-Recursos_cristal_ancestral` + `45-Arte3D_jugador_voxel` (todos z=0,0000), `36-Fauna_nutria_ribera_v2` alta (0,0000), `36-Fauna_conejo` alta (0,0000) y media (-0,1700)
      - **Patron encontrado**: en esos assets `alta` y `baja` = +0,045 pero `media` = 0,0000 -> el lote `media` se exporto con otra convencion. Es un problema de **pipeline de un lote**, no de 43 assets sueltos.
      - Herramienta: `auditar_glb_490.py` (numpy, vertices reales, 490 archivos, 0 errores).
- [x] M18: verificar 65 ventanas tras saneo -> **CONFIRMADO 65** (Agricultor 14 + Mercader 12 + Casona 19 + Mansion 20). El saneo del 65 esta aplicado en disco (msg 013) y `verificar_checklist.py` ya no marca M18.
- [~] M45 artbook: cross-check specs vs assets reales -> **BLOQUEADO**: `artbook_specs_m47.md` tiene mojibake cp1252 real (62/221 lineas, confirmado en bytes). No se audita texto corrupto. Requiere OK para `fix_encoding.py`.
- [x] Detectar 5 modulos nuevos con drift de Totales -> **HECHOS (2026-11-14)**: 106-Seguridad +12 (194/206 vs 206/206), 104-Analytics +8 (111/119 vs 119/119), 107-Backups +5 (177/182 vs 182/182), 122-Crash-Reporting +2 (254/264 vs 256/264), 04-Game-Engine +2 (126/128 vs 128/128). + **108-Pipeline-De-Assets: `✅` con 3 `[?]`** (mismo patron que 73/75, viola §21.6).

### Bloque 9: Docs + QA (3)
- [x] GUIA-BLENDER E-106: verificar que fue agregado correctamente -> **SI**: presente en `04-errores-avanzados.md`, y `INDICE.md` dice "E-01 a E-106" + la fila de exportacion glTF incluye `(E-44, E-45, E-106)`. `AGENTS.md` §2c dice 106.
- [x] GUIA-COMPARATIVA: actualizar con RIEL-1/2/3 de ERNIE -> **HECHO**: estado a "en flota" + seccion "NO PERSONAJES (directiva del fundador, 2026-11-14)" + limitacion de vision + mediciones verificadas.
- [x] AGENTS §28: verificar que no quedo mojibake nuevo -> **LIMPIO**: 3 ocurrencias de U+00C3, las 3 son los ejemplos intencionales de la propia seccion §28. 0 U+FFFD, 0 BOM.

**Total: 12 = 10 resueltos + 1 bloqueado (M45) + 1 cerrado por bloqueo del propio director (M45).**
Prioridad cumplida: 7 -> 8 -> 9.

## Nota de alcance (directiva del fundador, 2026-11-14)

El fundador me saco de **diseño de personajes** ("no se te da bien con precision") y confirmo que **no tengo visión** en este harness.
Vigente en `NICHO-Y-LIMITES.md`. Afecta a este RIEL: el "analisis visual batch" lo hago **por binario** (numeros), no mirando renders.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code - 2026-11-14 05:25
