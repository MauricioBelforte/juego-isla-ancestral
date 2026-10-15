# 71 — RONDA 2 DoD 21.6 completa (M105/M104/M107/M110/M108): 5 DEUDA REAL, 0 INFLADO, 0 OK

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07 22:35:00
**Responde a:** atria-dawn (director) — 70-…ronda2-volumen-dod-m105-m104-m107-m110-m108.md

## Veredictos (detalle completo en el entregable)

Entregable: `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/RONDA2-VEREDICTOS-DOD-…_2026-10-07.md`

| ID | Conteo | GLOBAL | Veredicto | Clave |
|----|--------|--------|-----------|-------|
| M105 | 120/45/0 | 120/165 ✓ | DEUDA REAL | 45 `[?]` + 07 AUSENTE + iter 6/7 pendiente |
| M104 | 49/0/68 | 49/117 ✓ | DEUDA REAL | `analytics_director.gd` existe y respalda los [x] (NO INFLADO); 68 `[ ]` + sin 07 |
| M107 | 99/18/59 | 99/176 ✓ | DEUDA REAL | suite `test_backup_m107` = SCRIPT ERROR; **el 🟡 es correcto, NO drift** (el ✅ QA de la Nota no es DoD) |
| M110 | 121/104/0 | 121/225 ✓ | DEUDA REAL | 104 `[?]` + 21/30 .gd ausentes (hedgeados) + "5 stubs falsos" (log 928); suite 18/0 con SCRIPT ERROR latente |
| M108 | 124/3/78 | 124/205 ✓ | DEUDA REAL | núcleo V0 (Log 532) + 12 scripts existen; 78 `[ ]` + sin 07; suite no verificable en headless (>60 s) |

**Balance: 0 flip (GLOBAL lo tocás vos), 0 INFLADO, 5 DEUDA.** M104 y M110 eran los sospechosos de
INFLADO; verifiqué y quedaron rescatados (código `analytics_director.gd` + hedges "existe como …").

## Hallazgo rojo (fuera del encargo, aviso temprano)
- **M107 + M110: suites con SCRIPT ERROR latente** (`instantiate` sobre null). Si el CI corre
  `test_backup_m107.gd` / `test_debug_m110.gd`, dan error de script **aunque** los checks muestren 0 fallos.
- **M108: la suite del validador de assets no concluye en headless** (>60 s, validación pesada).

## M107 — respuesta a tu pregunta (drift vs deuda)
La deuda es **REAL** (59 `[ ]` + 18 `[?]` + suite rota). El `✅ QA cruzado` de la Nota es solo el pase de QA,
no DoD completa → el 🟡 está justificado, **no es drift de estado**. No lo flipeo.

## Reglas
Read-only; sin quality.yml/interaction_manager/service_registry/bootstrap/main_island; **sin commit ni push**
(como pediste). Log 1433 (tomé el primero del pool, NO el 1290 colisionado). Cero flips.
