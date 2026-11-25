# BACKLOG-MASTER — ERNIE-5.5-Flash-Preview

**Modelo:** ERNIE-5.5-Flash-Preview (Baidu)
**Plataforma:** Kilo Code
**Nicho:** 3D Blender + analisis visual + documentacion
**Estado:** ACTIVO en flota (13nov) — ya NO supervisado por Nemotron

## REGLAS OBLIGATORIAS (directiva del fundador 2026-11-25)

1. **RESPONDER SIEMPRE AL DIRECTOR (agnes-3-flash).** Cada vez que el director deja un mensaje
   en mi canal (`Mensajes entre modelos/ERNIE-5.5-Flash-Preview/`), es **obligatorio** leerlo y
   responder creando MI propio archivo (numeración último+1 del pool, plantilla del helper
   `scripts/reservar_mensaje.py`). Nunca dejar un mensaje del director sin respuesta.
2. **SIN TAREAS → PEDIR MÁS.** Si el mensaje del director **no trae tareas** y no tengo nada
   pendiente en mis backlogs, le **pido que me asigne más tareas** (ofrezco opciones de mi nicho:
   3D/Blender headless, auditoría GLB, código GDScript, docs, tests). **No** me quedo en silencio
   ni escribo mensajes de relleno tipo "sigo esperando".
3. **Nicho:** objetos 3D + auditoría de assets por binario + documentación + código. **NO**
   personajes, **NO** QA visual (no tengo visión en este harness).

## Estructura de archivos

| Archivo | Contenido | Estado |
|---------|-----------|--------|
| RIEL-1-Blender-Docs.md | 12 tareas (Blender + docs + M18/M45) | CERRADO 12/12 |
| RIEL-2-Blender-Fixes-Docs.md | 12 tareas (nuevas) | **CERRADO 12/12** (5 anuladas + 7 hechas) |
| 01-Backlog-M169-Doc-Code-Verify.md | 12 tareas (M169 doc/code/verify) | **CERRADO 12/12** (2026-11-25) |
| 02-Backlog-M169-Doc-Verify-Code.md | 12 tareas (M169 doc/verify/code) | **CERRADO 10/12** (2 `[?]` por Blender/visión) |
| 03-Backlog-M169-Codigo-Tests-Docs.md | 8 tareas | PENDIENTE |

## RIEL-2 (proximas 12 tareas)

### Bloque 4: Blender - fixes Z_APOYO (5) — ⛔ **ANULADO (msg 017)**
> No habia trabajo: los 5 GLB estan en **+0,0450 exacto**. El "hundido" era mi metodo
> (esquinas de AABB por la matriz del nodo = trampa E-24). Re-export hecho → `git status` = 0 cambios.
- [x] Perla ancestral — ANULADA (GLB correcto)
- [x] Globo del viento — ANULADA (GLB correcto)
- [x] Roca pedernal — ANULADA (GLB correcto)
- [x] Roca comun — ANULADA (GLB correcto)
- [x] Conejo — ANULADA como fix; queda observacion M36 (alta 0,0000 / media −0,1700, `.blend` v12 = +0,0450)

### Bloque 5: Verificacion assets (4) — ✅ 4/4
- [x] M18: saneo CHECKLIST ventanas — aplicado (msg 013): 65 verificado en disco, 4 QA AABB a `[?]`, drift de 11 corregido, `verificar_checklist.py` ya no marca M18
- [x] M25: Columna rota — `columna_rota_alta` (1,45×1,02×2,15 m) y `_baja` (×1,45 m), 3 LOD, z_min +0,045
- [x] M35: Semillero — `33-Agricultura_cultivo_brote` ×3 LOD + `.blend` + 6 capturas, z_min +0,045
- [x] M19: Casa vecino — `18-Casas_casa_vecino` ×3 LOD, 7,60×7,10×3,52 m, z_min +0,045

### Bloque 6: Docs + QA (3) — ✅ 3/3
- [x] AGENTS §18/22/24 + sueltos → Godot (183 lineas); mojibake = solo las 3 lineas de ejemplos de §28 (msg 008)
- [x] GUIA-COMPARATIVA — ERNIE "en flota" + limitacion de vision + mediciones (msg 008)
- [x] 5 modulos de drift — 74-Eventos +58, 71-Progresion +44, 27-Islas +37, 63-Cargas −26, 25-Ruinas −16; + 73-Coleccionables y 75-Postgame con `[]` sin DoD (msg 003)

**Total: 12 = 5 anuladas (Bloque 4) + 7 hechas (Bloques 5 y 6).**

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code - 2026-11-13 08:05

| 04-Backlog-M169-Extra.md | 6 | PENDIENTE |
