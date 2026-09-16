# tools/logs — Herramientas de gestion de logs

## Regla de oro

`Logs/` contiene **solo** esto:

- `NNN-descripcion_YYYY-MM-DD[_HH-MM-SS].md` — los logs numerados
- `ULTIMO_NUMERO.txt` — contador de numeros **reservados** (protocolo de `AGENTS.md`)
- `reservas/` — reservas de numero en curso

**Nada mas.** Ni scripts, ni temporales, ni salidas de QA, ni volcados de diagnostico.

## Por que existe esta carpeta

El 2026-09-16 el subsistema de snapshots del host Kilo/opencode borro `Logs/` dos veces
(20:40:36 y 20:46:56 UTC): primero 56 archivos untracked y despues los 905 restantes.
Ver la trampa 65 en `.workbuddy-ai/memory/MEMORY.md` y el informe
`.workbuddy-ai/memory/INVESTIGACION-BORRADO-LOGS-2026-09-16.md`.

Dejar scripts que operan sobre `Logs/` dentro de `Logs/` amplifica ese riesgo: un borrado
recursivo se lleva por delante tanto los logs como las herramientas que los mantienen.
Por eso las herramientas viven aqui, fuera del area de riesgo.

## Donde va cada cosa

| Que | Donde |
|---|---|
| Scripts que tocan logs (`.ps1`, `.py`, `.bat`) | `tools/logs/` |
| Temporales y salidas de QA desechables | `.workbuddy-ai/tmp/` |
| Herramientas generales del proyecto | `tools/` |
| Scripts de verificacion del repo | `scripts/` |

Regla practica: **si el archivo no es un log, no va en `Logs/`.**

## Excepciones — evidencia citada por logs

Estos archivos NO son logs, pero viven en `Logs/` porque logs publicados los citan como
evidencia. **No moverlos sin actualizar las citas**, o se rompe la trazabilidad.

| Archivo | Citado por |
|---|---|
| `Logs/qa_m09_2026-09-11.txt` | Log 832 (linea 47), Log 834 (linea 33) |
| `Logs/_tmp_barrido_media.log` | Log 344 (linea 20) |
| `Logs/_tmp_diag_media.log` | Log 344 (linea 26) |
| `Logs/_tmp_diag_media_paths.txt` | sin citas; hermano del anterior |

## Contenido de esta carpeta

- `_reparar_m15.ps1` — reparacion puntual de
  `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (M15 iteracion 6, ya consumido).
  Lee `_reparar_m15_data.txt` por ruta absoluta.
- `_reparar_m15_data.txt` — datos de entrada de ese script. Se recupero del ledger de
  snapshots de Kilo tras el borrado del 2026-09-16.
