# Log 506: Adición de directiva de codificación UTF-8 obligatoria a AGENTS.md

**Fecha:** 2026-09-02
**Hora:** 01:29
**Modelo:** hy3
**Plataforma:** Kilo Code

## Resumen
Se incorporó al archivo de reglas global `AGENTS.md` la sección **§28. Codificación de Archivos (UTF-8 Obligatorio)**, siguiendo la iniciativa del usuario sobre la necesidad de estandarizar la codificación de todos los archivos de texto del proyecto tras detectarse corrupción por escritura en cp1252/ANSI desde ciertas plataformas de agentes.

## Cambios Realizados
- Se agregó la sección §28 al final de `AGENTS.md` (luego de la §27 sobre Skills).
- La sección documenta:
  - El problema detectado (mojibake de acentos/ñ y emojis de estado del protocolo al guardar en cp1252).
  - Regla obligatoria: todos los archivos de texto en UTF-8 sin BOM.
  - Prohibición de escribir en cp1252/ANSI y de re-encodear archivos existentes.
  - Procedimiento de verificación/conversión en PowerShell antes de notificar al usuario.
  - Detección temprana mediante marcadores (`Ã`, `â€`, `Â`) en diffs.
  - Preservación de firmas (`**Modelo:**`, `**Plataforma:**`) y emojis de estado legibles.
  - Nota de operación para saneamiento masivo sin afectar binarios.

## Archivos Modificados/Creados
- `AGENTS.md` — sección §28 agregada (UTF-8, sin BOM).
- `Logs/ULTIMO_NUMERO.txt` — actualizado a 506 (último número reservado).
- `Logs/506-AGENTS-UTF8-DIRECTIVA_2026-09-02_01-29-26.md` — este log.
