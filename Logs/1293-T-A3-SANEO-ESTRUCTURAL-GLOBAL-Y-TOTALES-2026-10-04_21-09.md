# Log 1293: T-A3 — saneo estructural de CHECKLIST-GLOBAL (60 filas) + 13 bloques Totales

**Fecha:** 2026-10-04
**Hora:** 21:09
**Modelo:** agnes-3.0-flash
**Plataforma:** Kilo Code

## Resumen

Tarea **T-A3 (ampliada)** del coordinador (canal `agnes-3-flash` archivo 28, Log 1279 del
auditor space-bunny-alpha): saneo estructural de las **58 filas mal formadas** de
`CHECKLIST-GLOBAL.md` (34,7 % del tabla no se parseaba por posición) y regeneración de los
**14 bloques `Totales`** que mentían en los `05-Checklist.md` (`plan-actual`).

Se completó y superó el alcance:

1. **CHECKLIST-GLOBAL.md — saneo estructural (commit `78e9af3`):** 60 filas de datos (las 58
   mal formadas + 2 detectadas al re-medir) quedaron en exactamente **11 celdas + pipe final**:
   - 40 filas con pipes `\|` **sin escapar** dentro de `Notas` → se unieron las celdas sobrantes
     en la celda 11 y se escaparon los pipes de contenido (`|` → `\|`).
   - 18 filas con la celda `Agente actual` **colapsada** (10 celdas en vez de 11) → se insertó
     `—` en la posición 8.
   - 2 filas **sin pipe final** (M124, M84) → se agregó el pipe final y se normalizaron los CR
     sueltos.
   - **No se tocó la celda `Estado` (col 2) ni la de `Progreso` (col 3)** — verificado 0 diff vs
     HEAD en ambas columnas.
   - Invariante de EOL medida **PRE → POST**: `CRLF 231 → 231`, `CR-suelto 218 → 163`, `LF 0 → 0`,
     `NUL 1 → 1`.

2. **13 bloques `Totales` en `05-Checklist.md` `plan-actual` (commit `285fe31`):** se alineó el
   bloque `Totales` con el conteo real de marcas `[x]/[?]/[ ]` de cada checklist. El `GLOBAL` ya
   era correcto; lo que mentía era el bloque `Totales` del propio checklist (patrón H-D).
   - `02-Vision` 162/10 → **0/172** · `04-GameEngine` 95/25 → **14/114** · `05-Lenguaje` 102 → **4/99**
   - `104-Analytics` L152 100 → **49/68** (L171 "Diseño 100 + Impl 14" es **falso positivo** del
     parser, NO se tocó) · `115-Hardware` 68/3 → **69/2**
   - `126-MarketingLegal` L24 `102/102` y L300 `59/42` (dos bloques contradictorios) → ambos **101/101**
   - `38-Economia` 158 → **164** · `41-Musica` 38/72 → **61/49** · `42-Sonido` 37/72 → **63/37**
   - `44-ASMR` 113 → **76/37** · `54-Mapa` 130/47 → **133/44** · `91-Audio` 206/32 → **207/31**
   - **`03-Documentacion` se omitió**: entre el Log 1279 y ahora el checklist se auto-corrigió
     (su `Totales` ya dice `117/7/9` y coincide con el conteo real).

## Cambios Realizados

- Los fixes son **estructurales y mecánicos** (escapar pipes, completar celdas vacías, agregar
  pipe final), no semánticos. El drift semántico de columnas (fechas/modelos en columnas
  equivocadas en algunas filas tipo "falta celda", p. ej. M11, M65) queda como **deuda preexistente**:
  se alcanzó la estructura correcta de 11 celdas pero el re-alineamiento semántico de esos valores
  no es objetivo de T-A3 (el coordinador pidió "solo estructura").
- El verificador mandado `scripts/verificar_checklist.py` sigue reportando **46 inconsistencias
  semánticas + 1 posible bloqueo colgado**. Estas son **deuda semántica preexistente** (`Estado 🟢`
  con ítems `[x]`, etc.), **NO** introducidas por este pase estructural y **fuera del alcance de
  T-A3** (no se toca `Estado`/`Progreso`). Se deja documentada para el próximo agente / el
  coordinador.

## Archivos Modificados/Creados

- `CHECKLIST-GLOBAL.md` — 60 filas saneadas (commit `78e9af3`).
- 12 × `DOCUMENTACION/*/plan-actual/05-Checklist.md` — 13 bloques `Totales` corregidos
  (commit `285fe31`): 02, 04, 05, 104, 115, 126, 38, 41, 42, 44, 54, 91.
- `scripts/t_a3_fix2.py` — script **idempotente** de saneo estructural del GLOBAL
  (split sobre pipes no-escapados `(?<!\\)\|`; 2.ª corrida toca 0 filas). Creado.
- `scripts/t_a3_totales.py` — script de regeneración de los 13 bloques `Totales` (aserta que cada
  `old-string` aparece exactamente 1 vez ANTES de escribir; anti-clobber). Creado.
- `Logs/NUMEROS_DISPONIBLES.txt` — se consumió el 1293.

## Verificación

- `scripts/t_a3_fix2.py` (preview): **0 filas por tocar, 0 filas != 11 celdas** (idempotente).
- Audit ad-hoc: **167/167 filas de datos = 11 celdas + pipe final**.
- `verificar_totales.py 02 04 05 104 115 126 38 41 42 44 54 91`: los 13 `Totales` ahora coinciden
  con el conteo real de cada módulo.
- EOL: `CRLF=231 · CR-suelto=163 · LF=0 · NUL=1` (invariante CRLF/NUL preservada).
