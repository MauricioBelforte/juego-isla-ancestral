# Log 507: Saneamiento masivo de codificación UTF-8 (corrección de mojibake)

**Fecha:** 2026-09-02
**Hora:** 01:47
**Modelo:** hy3
**Plataforma:** Kilo Code

## Resumen
Se corrigió la codificación de los archivos de texto del proyecto que presentaban corrupción por doble-codificación cp1252→UTF-8 (mojibake tipo `Ã¡`, `â€`, `Â`, `ð`, flechas `â†’`, etc.). La tarea se apoyó en un script de saneamiento (`scripts/fix_encoding.py`) con detección y conversión segura línea por línea y por tramos.

## Cambios Realizados
- Se creó `scripts/fix_encoding.py`: detecta archivos UTF-8 válidos pero con mojibake, y archivos cp1252 puro; revierte la doble-codificación por tramos (runs de caracteres codificables a cp1252 con fallback latin-1) preservando emojis (🟢🔵🟡✅⚠️) y símbolos fuera de cp1252.
- Se corrigieron **27 archivos** de documentación y código fuente (CHECKLIST-GLOBAL.md, DOCUMENTACION/* módulos 08/14/64/70/73/74/115/166, Mensajes entre modelos/ESTADO-PARALELO.md, referencias de `.claude/skills/`).
- Se excluyeron deliberadamente: `AGENTS.md` (contiene ejemplos intencionales de mojibake en la §28), `.venv/`, `scripts/` (scripts del otro agente con literales `Ã`), `Logs/` y binarios.
- Se generaron respaldos automáticos en `Obsoletos/encoding-backup-20260902_014555/`.

## Verificación
- Post-saneamiento: 0 archivos de documentación/código con marcadores de mojibake (salvo `AGENTS.md` intencional y `tools/mcp/.venv/` de terceros, fuera de alcance).
- Los acentos, `¿`/`¡`, `→`, `—`, comillas y elipsis fueron restaurados correctamente; los emojis se conservaron.

## Limitación importante (honestidad)
Se detectaron **8 archivos con el carácter de reemplazo U+FFFD** (irreversible): 6 docs del proyecto (`DOCUMENTACION/115-Hardware/plan-actual/02-Analisis.md`, `03-Diseno.md`; `DOCUMENTACION/14-Inventario/plan-actual/03-Diseno.md`, `04-Codigo.md`, `05-Checklist.md`; `Mensajes entre modelos/ESTADO-PARALELO.md`) y 2 de `.venv`. Este daño proviene de una conversión cp1252 previa (de otro agente) que usó `replace`, perdiendo los bytes originales. **No es recuperable** automáticamente; requeriría re-generar esos fragmentos desde la fuente original.

## Archivos Modificados/Creados
- `scripts/fix_encoding.py` (nuevo)
- 27 archivos de documentación/código corregidos (ver lista en salida del script)
- `Obsoletos/encoding-backup-20260902_014555/` (respaldos)
- `Logs/507-SANEAMIENTO-UTF8-MOJIBAKE_2026-09-02_01-47-21.md` (este log)
