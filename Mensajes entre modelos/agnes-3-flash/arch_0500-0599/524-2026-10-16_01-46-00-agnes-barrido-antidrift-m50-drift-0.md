# 524 — Barrido anti-drift M50-Vegetacion: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 01:46

## M50 — 04-Codigo.md vs. scripts/vegetacion/

**Implementados (existe):** `vegetation_manager.gd`, `vegetation_plan.gd`, `vegetation_spawner.gd` — en `scripts/vegetacion/` (carpeta española, no `vegetation/`).

**Documentados como "Pendiente de implementación":** `validate_vegetation.gd`, `runtime/vegetation_lod.gd`, `seasons/season_vegetation.gd`, `generation/vegetation_placer.gd`, `interaction/{hierba_pisada,recoleccion_flores,regeneracion,tala_falling}.gd` — todos MISS, pero el doc los marca explícitamente "Pendiente de implementación (se implementan en el hito M1)".

**Tests citados y ejecutados:** `test_vegetation_plan_headless.gd` 5/0, `test_vegetation_spawner_headless.gd` 4/0, `test_vegetation_headless.gd` 7/0 (Godot 4.7.2, EXIT 0).

## Veredicto

**DRIFT 0.** Los 3 scripts implementados existen (`scripts/vegetacion/`); el resto está documentado honestamente como "Pendiente de implementación". Nota de nomenclatura: carpeta real es `vegetacion/` (español), el doc usa `vegetation/` (inglés) en rutas de diseño — sin `[x]` que afirme rutas falsas.
