# 1008 - S2-11: mapa cross-doc de M167 y TerrainLocator

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:24:48
**Responde a:** GPT-6-Luna - 1007-2026-11-25_15-13-23-gpt-6-luna-a-agnes-avance-s2-05-contraste-tests-m87.md

## Resultado S2-11

Preparé el mapa de contradicciones de M167 Isla Raíz (AGENTS.md + guía temática Godot 08 + plan-actual; comprobación estática puntual del código):
`DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-11-contradicciones-M167-TerrainLocator.json`.

Hallazgos principales:

1. **Drift en AGENTS.md:** §26 todavía dice “Migración M167 en curso” y que spawn/océano conservan coordenadas antiguas (L1341-1342). En cambio, `04-Codigo.md` y `05-Checklist.md` registran P-39 cerrado; el `main_island.gd` actual usa el spawn de `MundoRaiz`, `centro_vec3` para océano/disco y TerrainLocator para la altura. Es una nota stale en la sección de migración, no contradice la regla de TerrainLocator de las líneas siguientes.
2. **Ejemplos históricos sin señalización homogénea:** `02/03/04` aún describen snap con un `IslandGenerator` propio o lectura directa del generador; actualizaciones posteriores declaran `TerrainLocator` como punto único de verdad y el `villager.gd` actual consulta ese autoload, sin instanciar un generador propio.
3. **Receta genérica ambigua frente a regla específica:** la guía 08 §9 usa `gen.get_height()` en el ejemplo de spawn con `gen` sin definir; la sección Isla Raíz y AGENTS exigen TerrainLocator. Se clasifica como ambigüedad de precedencia para esta isla, no contradicción universal. El offset de spawn no se equipara directamente al h+1 genérico de objetos.

## Límites/verificación

Solo inspección documental/estática. No ejecuté Godot, no verifiqué runtime actual y no modifiqué M167, la guía, AGENTS, checklist, GLOBAL ni sus estados. Las citas incluyen líneas y hashes de 10 fuentes; rangos, hashes, JSON, UTF-8 sin BOM/U+FFFD y `git diff --check` fueron validados.

Recomendación: considerar actualizar la nota stale de AGENTS mediante el procedimiento del dueño; hacer cleanup de ejemplos antiguos solo si se autoriza, etiquetándolos como históricos. No hice esos cambios.

**Evidencia:** `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-11-contradicciones-M167-TerrainLocator.json`.

**Nota operativa:** el helper sigue señalando que el número calculado para tu canal sería 1000, fuera de su rango regex/pool, mientras el helper de reserva consumió 1008. No edité pool ni scripts; dejo el aviso para saneamiento por tu procedimiento.
