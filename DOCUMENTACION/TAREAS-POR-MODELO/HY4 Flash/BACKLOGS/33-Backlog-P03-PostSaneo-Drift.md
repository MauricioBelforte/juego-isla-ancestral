# Backlog 33 — P-03 Verificación post-saneo de drift (M4/M13/M15 + GLOBAL M29/M30)

**Agente:** hy4-flash
**Origen:** director 068 (P-03 aprobada, "cuando quieras")
**Fecha:** 2026-11-19
**Estado:** CERRADO — verificación; SIN flips, SIN ediciones

## Método

- Recount anclado por línea con
  `^\s*(?:\d+\.|[-*])\s+\[([ x?→>-])\]` sobre los 5 `05-Checklist.md` de
  `plan-actual/`.
- Cotejo independiente con `grep -cE '^[[:space:]]*(|-|\*)[[:space:]]+\[x\]'`
  y `grep -cF -- '- [?]'`; cuando discrepaban se abría la línea para decidir
  si era casilla real o mención inline.
- Lectura de las líneas `Totales:` y de la fila correspondiente en
  `CHECKLIST-GLOBAL.md` (raíz del repo), con número de línea exacto.
- Cero ediciones: verificador ≠ autor.

## Recount medido

| Módulo | [x] | [ ] | [?] | Total | Totales local (L) | GLOBAL (L) |
|---|---:|---:|---:|---:|---|---|
| M4 | 128 | 0 | 0 | 128 | L170 = 128/126/2/0 | L28 = 126/128 |
| M13 | 119 | 1 | 0 | 120 | L174 = 120/84/34/2 | L71 = 119/120 |
| M15 | 215 | 0 | 4 | 219 | L385 = 219/205/4/10 | L96 = 215/219 |
| M29 | 195 | 0 | 0 | 195 | L143 = 195/195/0/0 | L132 = 193/195 |
| M30 | 120 | 0 | 0 | 120 | L252 = 120/120/0/0 | L133 = 119/120 |

## Líneas que siguen STALE (6 de 10)

1. `DOCUMENTACION/04-Game-Engine/plan-actual/05-Checklist.md:170` —
   dice 126 completados / 2 pendientes; medido 128 / 0.
2. `CHECKLIST-GLOBAL.md:28` — fila `04-Game-Engine` dice 126/128;
   medido 128/128.
3. `DOCUMENTACION/13-Herramientas/plan-actual/05-Checklist.md:174` —
   dice 84/34/2; medido 119/1/0 (el texto entre paréntesis "todos con
   dueño externo" ya no describe las 34 casillas).
4. `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md:385` —
   dice 205/4/10; medido 215/0/4.
5. `CHECKLIST-GLOBAL.md:132` — fila `29-Tiempo-Y-Calendario` dice
   193/195; medido 195/195.
6. `CHECKLIST-GLOBAL.md:133` — fila `30-Reloj-En-Tiempo-Real` dice
   119/120; medido 120/120.

Las 5 líneas prioritarias del encargo (M4, M13, M15 Totales + M29, M30
GLOBAL) están **5/5 stale**: el saneo pedido por Hy3 en TANDA 22nov NO fue
aplicado en ninguna de ellas.

Líneas que SÍ coinciden (4/10): M13 GLOBAL L71, M15 GLOBAL L96,
M29 Totales L143, M30 Totales L252.

## Trampa medida en esta pasada

`grep -cF -- '- [?]'` sobre M29 devuelve **1**, pero el recount anclado da
**0**. La ocurrencia está en la línea 315, prosa de auditoría:
`- La leyenda de estados ... decia "[ ] cumplido - [ ] pendiente - [?] no ...`.
Es una mención inline, no una casilla. Contarla como casilla inflaría M29
a 196 y produciría un falso "GLOBAL 193/195 correcto". Anchoring manda.

## Límites

- No apliqué flips ni edité Totales/GLOBAL: son archivos protegidos sin GO.
- No re-ejecuté suites: P-03 es solo cotejo documental; las suites ya fueron
  medidas en P-01 y siguen RED por el regres global.
- Los números son del estado en disco al 2026-11-19 06:11.

**Firma:** hy4-flash
