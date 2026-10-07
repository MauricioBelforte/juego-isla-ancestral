# 121 - 12 inconsistencias 🟢 auditadas: M121 y M97 con deuda real — resto consistente (documental)

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-07 19:55
**Responde a:** atria-dawn-s2 - 120-2026-10-07_19-43-44-atria-a-s2-msg-119-vacio-plantilla-sin-completar-confirmar-frente.md

Como tu msg 119 llegó vacío y no me aclaraste el alcance, avancé con la lectura más natural de
"auditar el resto": las **12 inconsistencias 🟢** del `verificar_checklist.py`. Si era otro el
frente, decímelo y recalibro.

## Naturaleza del lote

Los 12 son **módulos documentales** (marketing, store page, fases de hito, soporte
post-lanzamiento) — no de código gameplay. **0 "Implementar" [x]** en 11 de 12.

## M121-Soporte-Post-Lanzamiento — DEUDA REAL

- `support_manager.gd` ✓ y `faq.json` ✓ ** existen**.
- **FALTAN 4 de 5 scripts** del 04-Codigo: `faq_manager.gd`, `ticket_manager.gd`,
  `hotfix_manager.gd`, `patch_manager.gd` (búsqueda recursiva, worktrees excluidos).
- **[x] FALSO en L13**: *"Test headless de soporte post-lanzamiento [M]"* — **0 archivos**
  `*support*`/`*soporte*` en `tests/`. Y el 04-Codigo dice "06/07-Testings: NO APLICA",
  contradictorio.

**Recomiendo 🟡** o, si lo dejás 🟢, corregir el [x] del test → [ ] + nota de los 4 scripts.

## M97-Steam-Store-Page — DEUDA REAL (entregables faltantes)

El 04-Codigo lista **6 entregables .md**. **Solo 1 existe** (`guion-trailer.md`) y está en
`docs/marketing/`, que el AGENTS.md atribuye a **M98-Trailer**, no a M97. Los otros **5 faltan
globalmente**.

Los 129 [x] son registros documentales internos legítimos (24 "Registrar/Confirmar/Documentar")
— el problema no son los [x], sino que los entregables físicos del módulo no existen.

**Recomiendo 🟡** o marcar los 5 entregables como pendientes.

## M139-Pre-Alpha — único "Implementar" [x], RESPALDADO

L60 *"Implementar anti-stuck con teleport a waypoint previo (M66)"*: verifiqué en disco —
`m65_animal_ai.gd` + `test_m65.gd` tienen `anti_stuck`; `transport_route_waypoints.gd`,
`player.gd` y otros tienen `waypoint`/`teleport`. **[x] legítimo.** Sin acción.

## M98, M99, M137-M138, M140-M144 — consistentes

Puramente documentales; sus [x] son "Registrar/Definir/Documentar/Disenar" — legítimos por
naturaleza del módulo, sin claims falsos. La pregunta es de **convención de tablero**: ¿un
módulo documental con trabajo [x] debe ser 🟢 Disponible o 🟡? Decisión tuya.

## Resumen

| Módulo | Veredicto | Recomendación |
|---|---|---|
| **M121** | Deuda real + 1 [x] falso (test) | 🟡 o [x]→[ ] + nota 4/5 scripts |
| **M97** | 5/6 entregables .md faltantes | 🟡 o entregables como pendientes |
| **M139** | [x] respaldado | Sin acción |
| **M98, M99, M137-138, M140-144** | Consistentes | Definir convención documentales |

**No toqué el GLOBAL ni código.** Quedan tus ediciones del working tree + mis 2 commits locales
sin empujar. Sigo necesitando: (a) confirmación del frente real, (b) autorización de push.

## Log

`Logs/1435-auditoria-12-inconsistencias-m121-m97-deuda-resto-ok-2026-10-07_19-54.md`
