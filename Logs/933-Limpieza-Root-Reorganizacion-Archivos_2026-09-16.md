# Log 933: Limpieza de raíz y reorganización de archivos sueltos

**Fecha:** 2026-09-16
**Hora:** 18:15
**Modelo:** mimo-v2.5
**Plataforma:** OpenCode

## Resumen

Revisión completa de los archivos en la raíz del proyecto. Se analizaron 25+ archivos sueltos, se reorganizaron en carpetas apropiadas y se creó la carpeta `PAPELERA/` para archivos obsoletos.

## Archivos movidos a `scripts/` (8 archivos útiles)

| Archivo original | Destino | Función |
|-----------------|---------|---------|
| `_qa_note.py` | `scripts/qa_add_note.py` | Helper para agregar notas a CHECKLIST-GLOBAL |
| `analizar_logs.py` | `scripts/analizar_logs.py` | Analiza duplicados y gaps en Logs/ |
| `check_godot.bat` | `scripts/check_godot.bat` | Verifica errores de compilación Godot headless |
| `count_lists.ps1` | `scripts/count_lists.ps1` | Cuenta items de checklist (regla ≥100) |
| `sync_actuals.ps1` | `scripts/sync_actuals.ps1` | Sincroniza plan-inicial → plan-actual |
| `validate_m13.bat` | `scripts/validate_m13.bat` | Valida módulo M13 (Herramientas) |
| `validate_m39.bat` | `scripts/validate_m39.bat` | Valida módulo M39 (Tiendas) |
| `validate_tscn.bat` | `scripts/validate_tscn.bat` | Valida carga de escenas .tscn |

## Archivos movidos a `tools/` (1 archivo)

| Archivo | Destino | Función |
|---------|---------|---------|
| `data.drift.json` | `tools/data.drift.json` | Hashes MD5 de data/ para detectar cambios |

## Archivos movidos a `DOCUMENTACION/` (6 archivos de referencia)

| Archivo | Destino | Función |
|---------|---------|---------|
| `isla-modelo.jpg` | `DOCUMENTACION/00-PLAN-INICIAL/referencias-visuales/` | Referencia visual: isla tropical |
| `isla-modelo-2.jpg` | `DOCUMENTACION/00-PLAN-INICIAL/referencias-visuales/` | Referencia visual: isla tropical |
| `isla-modelo-3.jpg` | `DOCUMENTACION/00-PLAN-INICIAL/referencias-visuales/` | Referencia visual: isla tropical |
| `paleta-propuesta-isla.png` | `DOCUMENTACION/167-Isla-Raiz/` | Paleta de colores del terreno |
| `postlaunch_checklist.json` | `DOCUMENTACION/M97-Marketing/plan-actual/` | Checklist post-lanzamiento (JSON) |
| `POSTLAUNCH_CHECKLIST.md` | `DOCUMENTACION/M97-Marketing/plan-actual/` | Checklist post-lanzamiento (Markdown) |

## Archivos movidos a `PAPELERA/` (14 archivos obsoletos)

| Archivo | Razón |
|---------|-------|
| `broken_log_refs.txt` | Output de diagnóstico ya completado |
| `CHECKLIST-GLOBAL.md.bak_2026-09-11_23-21-57` | Backup antiguo, ya no se necesita |
| `corregir_logs.py` | Script one-shot de renumeración, completado |
| `duplicates_scan.txt` | Output de diagnóstico de duplicados, completado |
| `duplicates_summary.txt` | Resumen de duplicados, completado |
| `duplicates_with_dates.txt` | Inventario de logs, completado |
| `log_references_scan.txt` | Escaneo de referencias rotas, completado |
| `logs_global_order.txt` | Inventario de logs, completado |
| `renombrar_logs.py` | Script one-shot de renombrado, completado |
| `renumber_map.json` | Mapping de renumeración v1, obsoleto |
| `renumber_map_v2.json` | Mapping de renumeración v2, obsoleto |
| `renumber_map_v3.json` | Mapping de renumeración v3, obsoleto |
| `run_m105.ps1` | Test one-shot de M105, completado |
| `out/` | Outputs de testing de sesiones anteriores |

## Archivos que se DEJARON en la raíz (correctamente ubicados)

| Archivo | Razón |
|---------|-------|
| `opencode.json` | Configuración MCP crítica de OpenCode, debe estar en raíz |
| `AGENTS.md` | Documentación principal del protocolo |
| `CHECKLIST-GLOBAL.md` | Tablero de seguimiento central |
| `CHECKLIST-QA-SEALS.md` | Checklist de QA de sellos |
| `README.md`, `LICENSE`, `NOTICE.md`, `AUTHORS.md`, `CONTRIBUTING.md`, `CHANGELOG.md` | Archivos estándar de proyecto |
| `ASSETS-LICENSE.md`, `THIRD-PARTY-NOTICES.md` | Licencias de assets |
| `.gitattributes`, `.gitignore`, `.pre-commit-config.yaml` | Configuración Git |
| `build/` | Builds exportados (web) |
| `installer/` | Sistema de empaquetado/distribución |

## Estado final de la raíz

**Antes:** 65 entradas (archivos sueltos, scripts, outputs, backups, imágenes)
**Después:** 37 entradas (solo carpetas del proyecto + archivos estándar + opencode.json)

La raíz quedó limpia y organizada. Los scripts útiles están en `scripts/`, los obsoletos en `PAPELERA/`, y las referencias visuales en `DOCUMENTACION/`.
