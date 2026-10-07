# Log 1435: Auditoría de las 12 inconsistencias 🟢 — M121 y M97 con deuda real, resto consistente con naturaleza documental

**Fecha:** 2026-10-07
**Hora:** 19:54
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Audité las 12 inconsistencias 🟢 detectadas por `verificar_checklist.py` (módulos con Estado
global 🟢 Disponible pero `[x]` en el plan-actual). **Son módulos documentales** (marketing,
store page, fases de hito, soporte post-lanzamiento) — no de código gameplay. **0 "Implementar"
[x]** en 11 de 12; el único caso (M139) está respaldado. **M121 y M97 tienen deuda real.**

## Barrido general

| Módulo | [x] | Implementar [x] | Naturaleza | 04-Codigo |
|---|---|---|---|---|
| 121-Soporte-Post-Lanzamiento | 123 | 0 | Soporte (parcialmente código) | 5 scripts + faq.json |
| 97-Steam-Store-Page | 129 | 0 | Marketing/documentación | 6 entregables .md |
| 98-Trailer | 4 | 0 | Documentación | — |
| 99-Marketing | 7 | 0 | Documentación | — |
| 137-Prototipo | 10 | 0 | Hito/fase | — |
| 138-Vertical-Slice | 11 | 0 | Hito/fase | — |
| 139-Pre-Alpha | 12 | 1 | Hito/fase | — |
| 140-Alpha | 14 | 0 | Hito/fase | — |
| 141-Beta | 15 | 0 | Hito/fase | — |
| 142-Release-Candidate | 23 | 0 | Hito/fase | — |
| 143-Lanzamiento | 18 | 0 | Hito/fase | — |
| 144-Después-Del-Lanzamiento | 4 | 0 | Hito/fase | — |

## M121-Soporte-Post-Lanzamiento — DEUDA REAL

- `support_manager.gd` ✓ **existe**; `faq.json` ✓ **existe** (1).
- **FALTAN 4 de 5 scripts** del 04-Codigo: `faq_manager.gd`, `ticket_manager.gd`,
  `hotfix_manager.gd`, `patch_manager.gd` (búsqueda recursiva en todo el repo, worktrees
  excluidos).
- **[x] FALSO en L13**: *"Test headless de soporte post-lanzamiento [M]"* — **0 archivos**
  `*support*`/`*soporte*` en `game/isla-ancestral/tests/`. Además el 04-Codigo dice
  "06/07-Testings: NO APLICA", contradictorio con un [x] de test headless.

**Veredicto:** implementación parcial real (1 de 5 scripts + datos), con un [x] de test falso.
**Recomiendo 🟡** con nota de deuda, o dejar 🟢 pero corregir el [x] del test a [ ].

## M97-Steam-Store-Page — DEUDA REAL (entregables faltantes)

- El 04-Codigo lista **6 entregables .md**: `plantilla-descripcion.md`, `lista-capturas.md`,
  `guion-trailer.md`, `requisitos-sistema.md`, `keywords-tags.md`, `assets-store.md`.
- **Solo 1 existe**: `guion-trailer.md` — y está en `docs/marketing/`, que el AGENTS.md
  atribuye a **M98-Trailer**, no a M97. Los otros **5 faltan globalmente**.
- Los 129 [x] son en su mayoría registros documentales válidos (24 son
  "Registrar/Confirmar/Documentar" — entregas internas del plan, legítimas). El problema no son
  los [x] individuales, sino que **los entregables físicos del módulo no existen**.

**Veredicto:** documentación interna completa pero entregables externos ausentes (5/6).
**Recomiendo 🟡** con nota de deuda, o 🟢 con los entregables marcados como pendientes.

## M139-Pre-Alpha — único "Implementar" [x], RESPALDADO

L60: *"Implementar anti-stuck con teleport a waypoint previo (M66)"*. Verifiqué en disco:
`m65_animal_ai.gd` y `test_m65.gd` contienen `anti_stuck`; `transport_route_waypoints.gd`,
`player.gd` y otros contienen `waypoint`/`teleport`. **[x] legítimo.**

## M98, M99, M137-M138, M140-M144 — consistentes

Módulos puramente documentales (trailer, marketing, fases de hito). Sus [x] son
"Registrar/Definir/Documentar/Disenar" — entregas internas de planificación, legítimas por la
naturaleza del módulo. **Sin claims falsos detectados en el barrido.** No requieren
implementación de código.

**Veredicto:** el estado 🟢 es discutible (tienen trabajo [x] hecho, no "disponible sin
iniciar"), pero no hay falsedad — es una **convención de tablero**: ¿un módulo documental
completo debe ser 🟢 o 🟡? Decisión de gobernanza.

## Recomendación al director

| Módulo | Acción recomendada |
|---|---|
| **M121** | 🟡 o corregir [x] del test headless → [ ] (test inexistente) + nota 4/5 scripts |
| **M97** | 🟡 o marcar 5 entregables .md faltantes como pendientes |
| **M139** | Sin acción (✅ [x] respaldado) |
| **M98, M99, M137-138, M140-144** | Definir convención para módulos documentales (🟢 vs 🟡) |

No toqué el GLOBAL ni código — todas las decisiones son de gobernanza del director.

## Archivos Modificados/Creados

- `Logs/1435-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1435 consumido: 1566 → 1565 líneas)
