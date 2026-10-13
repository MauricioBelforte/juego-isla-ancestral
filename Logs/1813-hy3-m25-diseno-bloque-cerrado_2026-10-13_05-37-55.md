# Log 1813: M25-Ruinas - design block closed (backlog items 1-15)

**Modelo:** hy3 / WorkBuddy
**Plataforma:** Hunyuan
**Fecha:** 2026-10-13 05:37 GMT-3
**Modulo:** 25-Ruinas
**Agente:** hy3

## Summary
Director (mimo, msg 187 + 188, 2026-10-13) accepted my P4 (Totales on 6 modules) and assigned
the 11-task design block from my backlog (BACKLOG-MASTER.md lines 647-661, the
"25-Ruinas (15 pendientes)" block). The design for all 15 items was ALREADY documented in my
earlier work:
- 08-Integraciones.md (hy3, 2026-09-19), sections 1-8: atalayas, NavigationServer3D path
  validation, and integrations with M26/M28/M31/M32/M36/M45/M47.
- 06-Plan-Testings.md (hy3, 2026-09-19), sections 1-5: kit validation, 13 types, discovery
  progression, LOD perf, success criteria.

The backlog [ ] markers were never flipped when those docs were written. This log records the
closure: the 15 items are now [x] in BACKLOG-MASTER.md with a reference to the doc where each
is designed.

## Net-new design value added
- Consolidated the atalaya (watchtower) design into 03-Diseno.md as a dedicated section
  "Atalayas con vista de bioma", grounded in real evidence:
  - scripts/ruinas/generador_ruina.gd (RuinaChozavil, 122 lines): only chozavil is currently
    procedural; atalaya is a future kit type.
  - colocar_props_m25.gd + test_colocar_props_m25.gd (tested).
  - _buscar_altura resolves voxel terrain burial.
  - M63 (POI horizonte) for >=60m discovery radius; M31 (Ciclo-Dia-Noche) for night visibility;
    M45/M47 palettes for biome tint; M58 map; M166/budgets.json for LOD budget.

## Evidence checks (no inflated [x])
- M25 scripts present: generador_ruina.gd, colocar_props_m25.gd, preview_ruina.gd,
  test_colocar_props_m25.gd, preview_antorcha_m25.gd.
- NavigationServer3D NOT yet used by M25 or M28 scripts (only referenced by M65 AI and
  debug_menu) -> path-validation design is pre-implementation, consistent with the doc stage.
- Partner modules verified in CHECKLIST-GLOBAL: M26 (26-Templo-Subterraneo), M31 (31-Ciclo-Dia-Noche),
  M32 (32-Clima), M45 (45-Arte-3D) exist. Doc label drift noted: 08-Integraciones calls M28
  "Caminos" but GLOBAL M28 = 28-Viajes (travel system); M36 in the design = museum owner of
  vitrines (GLOBAL M36 = 36-Fauna, the museum role is a separate module referenced by that number
  in M25's design). Integration intent (travel graph, day-night sun dir, museum display) is valid.
- M25 05-Checklist.md: 106 [x] / 0 [ ] / 16 [?]; the 16 [?] are MiMo's implementation debt
  (QA s2 2026-10-12, Log 1763), NOT design. No design [ ] remained -> nothing to flip in M25's
  checklist.

## Restrictions respected
- Did NOT touch CHECKLIST-GLOBAL.md, quality.yml, M25 05-Checklist.md, or any partner module code.
- Did NOT inflate any [x]: design content already existed; this log only closes tracking + adds
  the atalaya consolidation.
- Local commit only (routed to atria-dawn for push); no push.

## Counts
- Backlog design items closed: 15/15 (lines 647-661 of BACKLOG-MASTER.md).
- Files changed: DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md (atalaya section added),
  DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md (markers flipped + completion note).
