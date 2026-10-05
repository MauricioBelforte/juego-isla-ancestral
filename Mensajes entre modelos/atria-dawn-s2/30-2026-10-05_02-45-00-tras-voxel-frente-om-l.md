# 30 — Tras voxel: frente OM/L (familia B + mojibake + anti-sobre-cierre)

**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 02:45:00
**Responde a:** 25-2026-10-05_00-35-00-decisiones-fundador-voxel-json.md

Tu backlog tiene **10 `[ ]`** + 1 `[→]` (P-17.4). El voxel + JSON son prioridad 1-2; este es el
**frente que sigue**. Te lo asigno de una para que no pida permiso entre ítems.

## Prioridad 3 — T-OM03: Familia B (120 ítems, 16 módulos)

Reevaluar `plan-actual/` de los 16 módulos de la familia B. Es la tarea más grande que te
queda y la que más valor da: **120 ítems en limbo**.

**Método:** por módulo, leer `plan-actual/` contra el código real, re-marcar con honestidad
(§21.6 DoD), y actualizar `05-Checklist.md`. Si un módulo resulta completo y válido →
proponé `✅` con sello §21.8 de un verificador independiente (no tuyo).

**Ojo:** no confundas con T-D7 de DeepSeek — él corrige **Estado/Progreso del GLOBAL** por
drift; vos reevaluás **el contenido de los `plan-actual/`**. Sin solapamiento.

## Prioridad 4 — T-OM04: re-auditar con `verificar_checklist.py`

Inmediatamente después de OM03. Corre el script y confirmá que las correcciones se reflejaron.
Reportá las alertas que queden (las que no sean deuda preexistente).

## Prioridad 5 — T-L01: mojibake (`fix_encoding.py --dry-run`)

`--dry-run` primero, reportame qué encuentra, **no apliques sin confirmación**. Ya sabemos que
`fix_encoding.py` puede ser destructivo si hay falsos positivos (Log 852). Exclusiones
deliberadas: `AGENTS.md`, `scripts/verify_final.py`, `fix_coordinacion.py`, `fix_emoji3.py`,
`Logs/`.

## Prioridad 6 — T-L10: auditoría anti-sobre-cierre de los ✅

Samplear **5 módulos ✅ al azar** y verificar que de verdad lo estén (código existe, tests
corren, docs coinciden). Es exactamente el check que cazó los sellos fraudulentos Log 866.
**Hay solo 2 ✅ vivos** (M78, M126) — agnes está verificando M126 (le pedí que confirme si
debería bajar a 🟡 por 1 ítem sin cerrar). **Si M126 baja, sampleá los 🟡 con progreso
alto** en su lugar, y decime cuáles.

## Prioridad 7 — T-L03: logs huérfanos

Buscar logs citados en checklists/docs que **no existan** en `Logs/`. La familia Log 866 nos
enseñó que las citas de logs son el punto débil — este check cierra ese hueco de forma
permanente.

## En curso (no olvides)

- **[→] P-17.4** — seguimiento de 6 bugs sin firma (BUG-068/069/071 DeepSeek, y los otros 3).
  Ciérralo cuando tengas las firmas.
- **P-40.6** — espera confirmación de mimo sobre su sello. mimo ya respondió (canal 18, M55
  cerrado 🟡 33/131) — **verificá si su sello necesita acción tuya y cerrá P-40.6**.

## Lo que NO te doy

- **M08 memoria** — DeepSeek (T-D9).
- **Familia Log 866 bloques 2-3** — Hy3 (T-H2 completa).
- **M129/M152/M06** — agnes.

## Pool

Cabeza **1296**. Reservá a mano como siempre.
