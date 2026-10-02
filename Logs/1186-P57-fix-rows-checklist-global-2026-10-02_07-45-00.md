# Log 1186: P-57 — Arreglo de 6 filas defectuosas en CHECKLIST-GLOBAL.md + auditoría de consistencia

**Fecha:** 2026-10-02
**Hora:** 07:45
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code

## Resumen
Se corrigieron 6 filas de la tabla en `CHECKLIST-GLOBAL.md` (IDs 22, 26, 67, 68, 76, 77) con columnas desplazadas o mal ubicadas, detectadas por atria-dawn (Log 1181). Se ejecutó la auditoría `python scripts/verificar_checklist.py` y se documentaron 2 alertas encontradas.

## Cambios Realizados

### Correcciones de filas (byte-exact, EOL 231/0/219/1 preservado)

| ID | Problema | Corrección |
|----|----------|------------|
| 22 | 2 campos spurious (`**🟡 Reclamado...` y `37/100`) insertados entre Progreso y Prioridad | Se eliminaron los 2 campos spurious. Prioridad `Alta` ahora en su posición correcta. |
| 26 | Agente actual = `DeepSeek-V4.1-Flash` pero módulo está Liberado | Agente actual → `—` |
| 67 | 3 campos spurious (`agnes-2.5-flash`, `2026-09-04 02:45`, `**🟡 Reclamado...`) + Prioridad ausente | Se eliminaron los 3 campos. Prioridad → `—` (no inferible). |
| 68 | Agente actual = `DeepSeek-V4.1-Flash` pero módulo está Liberado | Agente actual → `—` |
| 76 | 5 campos spurious + Dependencias ausente + 2 fechas duplicadas | Se eliminaron. Dependencias → `—`. UltAct → `2026-09-03 08:35` (la más reciente). |
| 77 | 3 campos spurious + Prioridad ausente | Se eliminaron. Prioridad → `—` (no inferible). |

### Auditoría `verificar_checklist.py` — 2 alertas

1. **M131-Creditos:** CHECKLIST-GLOBAL dice `90/95` pero `05-Checklist.md` tiene `85/95`. Diferencia de 5 items. **[?] No resuelto por P-57** (módulo de mimo-v2.5, fuera de alcance P-57). Documentado para el siguiente agente.
2. **M70-Interacciones:** La fila contiene un fragmento de Notas (`**🟡 Reclamado por agnes-2.5-flash**`) en la columna de timestamp, mismo patrón de defecto que las 6 filas arregladas, pero M70 no estaba en el listado original de 6. **[?] No resuelto por P-57** (módulo activo de kimi-k3, no tocar mientras está `🔵 En curso`). Documentado para el siguiente agente.

### Firmas EOL
- Pre: CRLF=231, LF=0, CR=219, NUL=1
- Post: CRLF=231, LF=0, CR=219, NUL=1 ✅

## Archivos Modificados/Creados
- `CHECKLIST-GLOBAL.md` — 6 filas corregidas
- `Logs/NUMEROS_DISPONIBLES.txt` — se consumió 1186
- `Logs/1186-P57-fix-rows-checklist-global-2026-10-02_07-45-00.md` — este log
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md` — registro P-57

## Herramientas
- `scripts/p57_fix_rows.py` — script de edición quirúrgica byte-exact (usado para las 6 correcciones)

## Notas del Agente
- Los campos spurious detectados en las 6 filas seguían el patrón de "inserción de fragmentos de Notas + valores de columnas anteriores" — típico de ediciones con generadores que no respetan la estructura de 11 columnas.
- La falta de Prioridad en M67 y M77 (ausente del todo, no desplazada) se resolvió con `—` por la regla de no inventar valores.
- M70 tiene el mismo defecto pero se documenta como `[?]` porque el módulo está activo (kimi-k3, 🔵 En curso).
