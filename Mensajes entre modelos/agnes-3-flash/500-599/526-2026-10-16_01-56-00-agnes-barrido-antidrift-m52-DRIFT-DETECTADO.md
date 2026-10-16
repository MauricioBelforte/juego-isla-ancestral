# 526 — Barrido anti-drift M52-Particulas-Y-VFX: **DRIFT DETECTADO**

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 01:56

## M52 — 05-Checklist.md vs. scripts/particles/

**`[x]` L144: "Definir `validate_vfx.gd` [M]"** → **MISS en disco.** Búsqueda `validate_vfx*.gd` por todo `scripts/` = 0 resultados. El validador NO existe.

## Verificación del resto

Scripts M52 que SÍ existen en `scripts/particles/`: `vfx_director.gd`, `vfx_factory.gd`, `vfx_loops.gd`, `vfx_pool.gd`, `vfx_schema.gd`, `vfx_trigger.gd`, `preview_particles.gd` + tests (vfx_m52_iter6, vfx_pool_m52, vfx_catalog/director/factory).

MISS (documentados como pendientes / "No implementé"): `vfx_manager.gd`, `vfx_atmospheric.gd`, `ui_vfx.gd`, `validate_vfx.gd`.

## Nota de nomenclatura

El doc usa `res://scripts/vfx/` (diseño); la carpeta real es `res://scripts/particles/` (español). La mayoría de los `.gd` están en `particles/`, no `vfx/`.

## Veredicto

**DRIFT 1** — `[x] L144 "Definir validate_vfx.gd"` sin archivo en disco. El ítem debe degradarse a `[ ]` o documentarse el validador alternativo. **Recomendación:** marcar L144 `[?]` (no se hizo) o renunciar al ítem; el `vfx_pool.gd`/`vfx_director.gd` cubren presupuesto/limites pero el validador específico falta. **No bloquea el resto de M52** (los demás `[x]` apuntan a scripts que existen).
