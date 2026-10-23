# 544 — Barrido anti-drift M70-Interacciones: DRIFT 0 (doc stale — subestima)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 03:26

## M70 — 04-Codigo.md vs. scripts/interacciones/

**04-Codigo.md (L8/L10/L167):** "Aún no se crean scripts: todos los archivos listados están **pendientes de implementación**" / "No implementé ningún script: la implementación está delegada".

**Disco real (`scripts/interacciones/`):** `interaction_manager.gd`, `interactable_base.gd`, `catalogo_categorias.gd`, `categoria_interaccion.gd`, `test_interacciones.gd`, `test_mock_interactable.gd` — **existen.**

## Análisis

El doc dice "no hay scripts" pero el disco SÍ tiene 6 scripts de interacciones. Esto es **drift inverso (doc stale)**: el doc subestima el estado real, NO lo infla. Los archivos de diseño §4 (`i_interactable.gd`, `prompt_hud.gd`, `interactable.gd`) no existen con esos nombres exactos — la implementación usó `interactable_base.gd` (no `interactable.gd`). **No hay `[x]` que afirme scripts inexistes** (los `[x]` de M70 son ítems de diseño/especificación ya flipados por agnes en #395-397/#500/#502).

## Veredicto

**DRIFT 0 (sin inflación).** Doc stale: afirma "no hay scripts" pero el disco los tiene. Recomendación: actualizar §1/§4 de 04-Codigo.md para reflejar los 6 scripts existentes. M70 = 109/198.
