# Log 1554: M107 — restore_backup.ps1 reescrito (UTF-8, 0 parse errors)

**Fecha:** 2026-10-10
**Hora:** 02:30
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Reescrito `scripts/backup/restore_backup.ps1` limpio: UTF-8 sin BOM, sin mojibake, llaves cerradas. Verificado con `[System.Management.Automation.Language.Parser]::ParseFile` → **0 errores de parseo**.

## Problemas corregidos
| Problema | Causa | Fix |
|---|---|---|
| 3 parse errors (L43, L90, L146) | Llave `}` faltante + catch incompleto | Reescritura completa con try/catch correcto |
| Mojibake (â"€â"€, VerificaciÃ³n) | Archivo guardado en cp1252 | Reescritura en UTF-8 sin BOM, sin acentos |
| Acentos en strings | cp1252 encoding | Eliminados (restauracion, raiz, exito, etc.) |

## Verificación
- `[Parser]::ParseFile` → **0 errores** ✓
- Estructura: `param` → `try { ... exit 0 } catch { ... exit 1 }` ✓
- UTF-8 sin BOM ✓
- Sin mojibake ✓

## Reglas
- M107 es mi módulo ✓
- No toco `data_store.gd` (M60) ✓
- Sin commits ✓
