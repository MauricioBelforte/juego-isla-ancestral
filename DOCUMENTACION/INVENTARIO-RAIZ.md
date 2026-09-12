# Inventario de archivos sueltos en la raíz

Generado por `scripts/inventariar_raiz.py` — Log 853, 2026-09-12 14:33.

Criterio de las columnas:

- **Tracked**: si el archivo está versionado en git.
- **Menciones**: cuántas veces aparece el nombre en archivos `.md` del repo (0 = nadie lo documenta).
- **Tipo**: `temporal` (desechable por nombre), `utilidad` (script posiblemente reutilizable), `recurso`, `otro`.
- **Codif**: encoding detectado para leer la primera línea.
- **Primera línea**: indicio de propósito.

| Archivo | Bytes | Fecha | Tracked | Menciones | Tipo | Codif | Primera línea |
|---|---:|---|---|---:|---|---|---|
| `.gitignore` | 4315 | 2026-09-12 | SI | 157 | otro | - | (no textual) |
| `.pre-commit-config.yaml` | 1940 | 2026-08-28 | NO | 2 | otro | utf-8 | # Pre-commit hooks for Isla Ancestral |
| `AGENTS.md` | 87745 | 2026-09-12 | SI | 888 | otro | utf-8 | # Reglas Globales para la IA — Proyecto Godot (Isla Ancestral) |
| `AUTHORS.md` | 505 | 2026-09-03 | SI | 4 | otro | utf-8 | # juego-isla-ancestral — AUTHORS |
| `CHANGELOG.md` | 68 | 2026-09-04 | SI | 66 | otro | utf-8 | # Changelog |
| `CHECKLIST-GLOBAL.md` | 115831 | 2026-09-12 | SI | 901 | otro | utf-8 | # CHECKLIST-GLOBAL.md — Orquestador Multiagente |
| `CHECKLIST-GLOBAL.md.bak_2026-09-11_23-21-57` | 112330 | 2026-09-11 | NO | 3 | temporal | - | (no textual) |
| `CONTRIBUTING.md` | 1557 | 2026-09-03 | SI | 3 | otro | utf-8 | # Contributing to juego-isla-ancestral |
| `LICENSE` | 1281 | 2026-09-02 | SI | 119 | otro | - | (no textual) |
| `NOTICE.md` | 2059 | 2026-09-02 | SI | 1 | otro | utf-8 | # Isla Ancestral — Notice & Third-Party Attributions |
| `POSTLAUNCH_CHECKLIST.md` | 5137 | 2026-09-02 | SI | 1 | otro | utf-8 | # Isla Ancestral — Post-Lanzamiento Checklist Operacional |
| `README.md` | 27 | 2026-08-26 | SI | 244 | otro | utf-8-sig | # juego-isla-ancestral |
| `_qa_note.py` | 841 | 2026-09-09 | SI | 0 | temporal | utf-8 | #!/usr/bin/env python3 |
| `analizar_logs.py` | 1179 | 2026-09-02 | NO | 1 | utilidad | utf-8 | import os |
| `broken_log_refs.txt` | 1703 | 2026-09-03 | SI | 0 | otro | utf-8-sig | (en blanco) |
| `check_godot.bat` | 215 | 2026-08-29 | NO | 1 | utilidad | utf-8 | @echo off |
| `corregir_logs.py` | 6459 | 2026-09-02 | NO | 1 | utilidad | utf-8 | import os |
| `count_lists.ps1` | 770 | 2026-08-26 | SI | 0 | utilidad | utf-8 | $mods = @('69-Fast-Travel','131-Creditos','104-Analytics','118-CI-CD') |
| `data.drift.json` | 34832 | 2026-09-04 | SI | 1 | otro | utf-8 | { |
| `duplicates_scan.txt` | 2589 | 2026-09-03 | SI | 0 | otro | utf-8-sig | (en blanco) |
| `duplicates_summary.txt` | 1642 | 2026-09-03 | SI | 0 | otro | utf-8-sig | 401: |
| `duplicates_with_dates.txt` | 62931 | 2026-09-03 | SI | 0 | otro | utf-8-sig | (en blanco) |
| `isla-modelo-2.jpg` | 806398 | 2026-08-29 | NO | 0 | recurso | - | (no textual) |
| `isla-modelo-3.jpg` | 831046 | 2026-08-29 | NO | 0 | recurso | - | (no textual) |
| `isla-modelo.jpg` | 3885305 | 2026-08-29 | NO | 2 | recurso | - | (no textual) |
| `log_references_scan.txt` | 68616 | 2026-09-03 | SI | 0 | otro | utf-8-sig | (en blanco) |
| `logs_global_order.txt` | 62929 | 2026-09-03 | SI | 0 | otro | utf-8-sig | (en blanco) |
| `opencode.json` | 548 | 2026-09-05 | SI | 17 | otro | utf-8 | { |
| `paleta-propuesta-isla.png` | 23542 | 2026-08-29 | NO | 0 | recurso | - | (no textual) |
| `postlaunch_checklist.json` | 8492 | 2026-09-02 | NO | 0 | otro | utf-8 | { |
| `renombrar_logs.py` | 2420 | 2026-09-02 | NO | 0 | utilidad | utf-8 | import os |
| `renumber_map.json` | 5245 | 2026-09-03 | SI | 0 | otro | utf-8-sig | { |
| `renumber_map_v2.json` | 5234 | 2026-09-03 | SI | 0 | otro | utf-8-sig | { |
| `renumber_map_v3.json` | 5174 | 2026-09-03 | SI | 0 | otro | utf-8-sig | { |
| `run_m105.ps1` | 623 | 2026-08-29 | NO | 1 | utilidad | utf-8 | $ErrorActionPreference = 'Continue' |
| `sync_actuals.ps1` | 361 | 2026-08-26 | SI | 0 | utilidad | utf-8 | $dirs = @('69-Fast-Travel','131-Creditos','104-Analytics','118-CI-CD') |
| `validate_m13.bat` | 443 | 2026-08-26 | NO | 1 | utilidad | utf-8 | @echo off |
| `validate_m39.bat` | 986 | 2026-08-26 | NO | 1 | utilidad | utf-8 | @echo off |
| `validate_tscn.bat` | 299 | 2026-08-27 | NO | 1 | utilidad | utf-8 | @echo off |

## Resumen

- Sueltos totales: **39**
- Sin versionar: **15**
- Sin versionar **y** sin menciones en la documentación: **5**
- Clasificados como temporales por el nombre: **2**

## Candidatos a mover a `Obsoletos/`

(ninguno)

## Huérfanos que se conservan a propósito

- `isla-modelo-2.jpg` — referencia visual de la isla (insumo del usuario)
- `isla-modelo-3.jpg` — referencia visual de la isla (insumo del usuario)
- `paleta-propuesta-isla.png` — paleta de colores propuesta para la isla
- `postlaunch_checklist.json` — checklist de post-lanzamiento; decidir si se integra a M121 o se descarta
- `renombrar_logs.py` — utilidad reutilizable: la numeracion de Logs/ se rompe seguido (ver BUG-014 en DOCUMENTACION/11-BUGS.md)
