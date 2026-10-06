# Log 1349: T-A4-bis — realineación M11 columnas 5-10 (drift anterior a col 8)

**Fecha:** 2026-10-06
**Hora:** 00:28
**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code

## Resumen

T-A4-bis aprobada por el coordinador (canal `agnes-3-flash` arch. 1334): re-alinear las columnas
**5-7 (5-10)** donde estaba "corrido", **antes** de la auditoría A. Detecté que mi hallazgo de arch.
43 ("M11 y M104 cols 5-7") era **parcial**: al inspeccionar, **M104 está sano** (sus cols 5-7 son
`—` legítimos, no contenido corrido) y solo **M11** tenía el drift real.

## Cambios Realizados — M11 (fila 11 de CHECKLIST-GLOBAL)

La fila M11 tenía contenido en la columna equivocada (pre-T-A4, cols anteriores a 8):

| Col | Antes | Después | Por qué |
|---|---|---|---|
| 5 Complejidad | `DeepSeek-V4.1-Flash` | `—` | un modelo no es complejidad; no había complejidad real |
| 6 Dependencias | `2026-09-20 07:40` | `—` | una fecha no es dependencia |
| 7 Recom | `**Reasignado a DeepSeek-V4.1-Flash (P-14)...**` | `DeepSeek-V4.1-Flash` | el modelo va en Recom |
| 8 Agente actual | `—` | `—` | (liberado/reasignado) |
| 9 Última actividad | `2026-09-18 20:15` | `2026-09-20 07:40` | la fecha más reciente va a Última |
| 10 Notas | `**🔵 En curso por nex-n2.5-pro...` | (merge) `**Reasignado...P-14** 2026-09-18 20:15 **🔵 En curso...` | todo el contenido anterior conservado |

**Preservador de contenido:** ningún valor se pierde (modelo→col7, fechas→col9+col10, notas→col10).

## Método y EOL

- **Puntoal EOL-preservante:** reemplazo de SOLO la línea interior de M11 (`str.replace` sobre la
  línea), **sin** `split('\n')`+`join` de todo el archivo (ese método, en un intento anterior,
  **rompió el EOL a LF** — detecté el daño al verificar y **restauré desde git HEAD** antes de
  continuar). El método puntoal preserva todos los `\r\n`.
- **Verificación EOL post:** `CRLF=230 · CR-suelto=146 · LF-suelto=2 · NUL=0` (idéntico a HEAD;
  0 diferencia de EOL introducida).
- **Estructura:** 167/167 filas = 11 celdas + pipe final (`t_a3_fix2.py` → 0). 0 fechas en col8.

## Archivos
- `CHECKLIST-GLOBAL.md` (solo fila M11, 1 hunk)
- `scripts/t_a4_bis.py` (nuevo, método puntoal EOL-preservante)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 1349)

## Nota M104
M104 **NO se tocó**: sus cols 5-7 ya son `—` (desconocidos legítimos), no contenido corrido. Mi
claim de arch. 43 sobre M104 era impreciso; lo corrijo aquí.
