# Log 1319: T-A4 — realineación de columnas 8-10 del GLOBAL (19 filas corridas + 14 re-normalizadas)

**Fecha:** 2026-10-05
**Hora:** 04:01
**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code

## Resumen

Tarea **T-A4** (canal `agnes-3-flash` arch. 39, referida desde DeepSeek T-D7): **re-alinear el
CONTENIDO de las columnas 8-10** (Agente actual / Última actividad / Notas) donde estaba "corrido"
(en la col. Agente había una **fecha**, que nunca debería estar ahí). **Sin tocar Estado/Progreso
ni estructura.** Se usó `t_a3_fix2.py` como base (split sobre pipes no-escapados).

## Cambios Realizados

### 1. Re-alineación T-A4 (`scripts/t_a4_realign.py`, 19 filas)
Detección: filas con **fecha en la columna Agente actual (col 8)** (senal de "corrido"). Regla
preservadora de contenido:
- `Agente(8)` ← `—`
- `Última(9)` ← la fecha vieja de col8
- `Notas(10)` ← viejo col9 + viejo col10 (merge, sin perder contenido; se **omite** el re-alineo si
  alguna pieza no se pudiera preservar)

Filas corregidas: **M09, M102, M112, M121, M147, M151, M21, M24, M33, M40, M50, M69, M73, M84,
M88** (15, la 1.ª pasada) + **M92, M97, M102, M112** (4 que se re-corrieron tras la
re-normalización estructural) = **19 filas** con el contenido re-alineado. `t_a4_detect.py`:
**0 filas con fecha en col8** al final.

### 2. Re-normalización estructural (`scripts/t_a3_fix2.py`, 14 filas)
Durante el trabajo, **ediciones concurrentes** (T-D7 DeepSeek) dejaron 14 filas con >11 celdas
(pipes no-escapados en Notas). Se restauró el invariante de 11 celdas (escapar pipes, contenido
preservado): **M158, M160, M18, M19, M20, M28, M41, M42, M45, M47, M48, M67, M75, M90**.

## Verificación
- **Estructura:** las **167 filas de datos = 11 celdas + pipe final** (`t_a3_fix2.py` → 0 por tocar,
  idempotente).
- **T-A4:** 0 filas con fecha en la columna Agente (`t_a4_detect.py`).
- **Estado/Progreso intactos:** 0 filas con Progreso no `N/M` (se tocaron solo cols 8-10).
- **EOL (PRE → POST):** CRLF `231 → 231`; CR-suelto `161 → 147` (se normalizaron CR sueltos en las
  filas reescritas); LF 0; NUL 1.

## numstat (vs HEAD, solo CHECKLIST-GLOBAL)
`29 29` (29 líneas de datos: 19 re-alineadas + 14 re-normalizadas, cada una una línea).

## Archivos
- `CHECKLIST-GLOBAL.md` (29 filas)
- `scripts/t_a4_realign.py`, `scripts/t_a4_detect.py` (nuevos)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 1319)
