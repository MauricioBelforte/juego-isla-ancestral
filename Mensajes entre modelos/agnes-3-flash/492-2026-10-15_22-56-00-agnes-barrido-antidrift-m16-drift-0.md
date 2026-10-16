# 492 — Barrido anti-drift M16-Crafting: DRIFT 0 (con nota estructural)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-15 22:56

## M16 — 04-Codigo.md vs. scripts/crafting/

| Ruta citada | Disco | Nota |
|-------------|-------|------|
| crafting_recipe.gd | OK | — |
| crafting_service.gd | OK | autoload, sin class_name (GUIA §9.17) |
| crafting_station.gd | OK | — |
| crafting_ui.gd | OK | — |
| crafting_feedback.gd | OK | — |
| test_m16_crafting_toast.gd | OK | — |
| crafting_types.gd | MISS | §2.1 (diseño) |
| crafting_ui_experiment.gd | MISS | L15 "opcional, dentro de CraftingUI" |

**Análisis de los 2 MISS:**

- **`crafting_types.gd`** — aparece en §2 "Funciones Clave (firmas GDScript)", que es la sección de **diseño/spec** (firmas), NO una afirmación `[x]` de que el archivo existe como tal. El diseño propone un archivo suelto con enums (StationType/RecipeCategory/RecipeSource/CraftError) y clases ligeras (RecipeMaterial/CraftResult/ExperimentResult). **La implementación enlaza esos tipos:** `crafting_recipe.gd` define `enum Categoria`/`Estacion`/`Origen` y `crafting_station.gd` define `enum Tipo` (L13). El contenido funcional EXISTE, solo está inlinado en recipe/station en vez de un archivo suelto. **No es inflación** (ningún `[x]` afirma que `crafting_types.gd` existe como archivo separado).
- **`crafting_ui_experiment.gd`** — L15 lo marca explícitamente **"opcional, dentro de CraftingUI como Control"**. Su ausencia como archivo suelto es el diseño previsto, no drift.

## Veredicto

**DRIFT 0 (funcional).** Los 6 scripts ✅ Implementado existen. `crafting_types.gd` y `crafting_ui_experiment.gd` son artefactos de diseño/inclusiones opcionales, no afirmaciones `[x]` infladas.

**Nota estructural (opcional):** el doc podría actualizar §2.1 para reflejar que los tipos se enlizaron a `crafting_recipe.gd`/`crafting_station.gd` en vez de un `crafting_types.gd` suelto. Recomendado, no bloqueante.
