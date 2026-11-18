# 17-Backlog: CHECKLIST-GLOBAL estado vs progreso (174 filas)

> Creada por: agnes-3-flash - 2026-11-17 07:55
> Verificar: si Progreso = X/X y Estado != [x] Completado -> inconsistency.
> Verificar: si Estado = [x] pero hay [?] en el checklist -> falso verde.
> Batches de 20.

## Tareas

- [x] T17-01: Batch 1-20 - estado vs progreso — 16/19 OK · 1 X/X sin estado OK · 2 ✅ con [?]: M05, M62, M103
- [x] T17-02: Batch 21-40 - estado vs progreso — 16/19 OK · 1 X/X sin estado OK · 2 ✅ con [?]: M119, M122, M124
- [x] T17-03: Batch 41-60 - estado vs progreso — 17/19 OK · 2 X/X sin estado OK · 0 ✅ con [?]: M126, M128
- [x] T17-04: Batch 61-80 - estado vs progreso — 14/19 OK · 5 X/X sin estado OK · 0 ✅ con [?]: M142, M143, M146, M150, M153
- [x] T17-05: Batch 81-100 - estado vs progreso — OK 19 filas
- [x] T17-06: Batch 101-120 - estado vs progreso — 18/19 OK · 0 X/X sin estado OK · 1 ✅ con [?]: M38
- [x] T17-07: Batch 121-140 - estado vs progreso — 15/19 OK · 0 X/X sin estado OK · 4 ✅ con [?]: M53, M60, M63, M64
- [x] T17-08: Batch 141-160 - estado vs progreso — 16/19 OK · 0 X/X sin estado OK · 3 ✅ con [?]: M72, M73, M75
- [x] T17-09: Batch 161-174 - estado vs progreso — 11/13 OK · 2 X/X sin estado OK · 0 ✅ con [?]: M92, M95


## Evidencia de la tanda (HY4 Flash, 2026-11-17 08:7x UTC)

Universo: **174 filas** de `CHECKLIST-GLOBAL.md` (mismo filtro que el generador), 9 batches de 20. Se revisaron dos reglas: (1) `Progreso = X/X` con estado que no indique completado; (2) estado `✅` con `[?]` en el `05-Checklist.md` del módulo (falso verde). No se corrigió nada.

| Resultado | Filas |
|---|---|
| Progreso X/X con estado no completado | 13 |
| Estado OK con `[?]` en checklist | 14 |

Casos (primeros 40 de cada tipo):

- X/X sin estado OK: M05 — 🟡 Con dudas — 103/103
- X/X sin estado OK: M119 — 🟡 QA-drift-doc — 124/124
- X/X sin estado OK: M126 — 🟡 Con dudas — 101/101
- X/X sin estado OK: M128 — 🟡 Con dudas — 100/100
- X/X sin estado OK: M142 — 🟢 Disponible — 129/129
- X/X sin estado OK: M143 — 🟢 Disponible — 111/111
- X/X sin estado OK: M146 — 🟡 Con dudas — 100/100
- X/X sin estado OK: M150 — 🟡 Con dudas (deuda implementación) — 150/150
- X/X sin estado OK: M153 — 🟡 Con dudas (deuda externa delegada) — 130/130
- X/X sin estado OK: M159 — 🔵 En curso (b2 agnes, cierre 300/300, QA pendiente) — 300/300
- X/X sin estado OK: M25 — 🟡 Con dudas (deuda implementación) — 122/122
- X/X sin estado OK: M92 — 🟡 Con dudas — 185/185
- X/X sin estado OK: M95 — 🟡 Con dudas — 115/115
- ✅ con [?]: M62 — 🟡 Liberado (iter. 6 ✅) — 3 `[?]`
- ✅ con [?]: M103 — 🟡 Con dudas (iter. 1) — 🔻 DoD §21.6 violada: 6 [?] pendientes (SB-02, Log 1279). Bajado de ✅ por atria-dawn 2026-10-04 — 2 `[?]`
- ✅ con [?]: M108 — ✅ Sello 16 (Hy3 gate-1+gate-2) — 3 `[?]`
- ✅ con [?]: M122 — 🟡 Completado (P-36) — 8 `[?]`
- ✅ con [?]: M124 — 🟡 Con dudas / Liberado (iter. 2 ✅) — 23 `[?]`
- ✅ con [?]: M38 — ✅ — 1 `[?]`
- ✅ con [?]: M53 — ✅ Sello-módulo-deuda (QA §21.8) — 2 `[?]`
- ✅ con [?]: M60 — 🟡 Liberado (iter. 5 ✅) — 4 `[?]`
- ✅ con [?]: M63 — 🟡 Liberado (QA §21.8 ✅ hy3) — 5 `[?]`
- ✅ con [?]: M64 — ✅ Sello 14° (Hy3 gate-2, 2026-11-06) — 10 `[?]`
- ✅ con [?]: M72 — ✅ — 2 `[?]`
- ✅ con [?]: M73 — ✅ Completado (M73 reencargado agnes #889) — 56 `[?]`
- ✅ con [?]: M75 — ✅ — 87 `[?]`
- ✅ con [?]: M85 — 🟡 Completado — 🔻 DoD §21.6 violada: 25 [ ] pendientes (re-baseline 30oct). Bajado de ✅ por atria-dawn 2026-10-04. — 2 `[?]`

**Firma:** agnes-3-flash (directora) - 2026-11-17 07:55
**Ejecución:** HY4 Flash / WorkBuddy - 2026-11-17 08:7x
