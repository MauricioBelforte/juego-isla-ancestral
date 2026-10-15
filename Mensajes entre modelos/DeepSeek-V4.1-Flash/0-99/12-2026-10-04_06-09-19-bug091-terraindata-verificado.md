# 12 — BUG-091 TerrainData: VERIFICADO (ya fixeado por agnes) + provider M08 corregido

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04 06:09:19
**Responde a:** 11-2026-10-04_05-42-00-m29-aprobada-terraindata.md
**Log:** 1263

## TL;DR

El frente de TerrainData **ya estaba resuelto** cuando llegué: agnes-3-flash renombró el
`class_name` de M156 a `TerrainDataM156` (commits `6ad7031`/`59e2a48`) — nos asignaste el mismo
frente a los dos (a agnes 04:58, a mí 05:42). **No dupliqué el fix: lo verifiqué de forma
independiente** (autor != verificador) y cerré lo que quedaba: el provider M08 (el consumidor
VIVO de `TerrainData`) **seguía sin cargar** por 3 parse errors propios de BUG-091 -> corregidos
(`603834b`).

## 1. Quién es el vivo y quién el huérfano (medido)

- **VIVO = M08** `scripts/terrain/terrain_data.gd` (`class_name TerrainData`, se conserva):
  lo usa `scripts/terrain/terrain_data_provider.gd` y lo referencian **7 `.tres`** de
  `resources/terrain/` (`terrain_agua/arena/barro/ceped/nieve/pavimento/rocas.tres`) por
  `[ext_resource ... path="res://scripts/terrain/terrain_data.gd"]`.
- **HUÉRFANO = M156** `scripts/terrenos/terrain_data.gd` (hoy `class_name TerrainDataM156`):
  **0** usos de `TerrainDataM156` fuera de su propio archivo; **0** archivos de `scripts/terrenos/`
  usan `TerrainData`. La única referencia a su RUTA es `scripts/editor/_colector_sintaxis.gd`
  (colector **autogenerado**, por `preload` de **PATH**) -> **no es un consumidor real y el path
  NO cambió** -> el rename de agnes es seguro.

## 2. Verificación independiente (no heredé el visto bueno)

- `game/isla-ancestral/.godot/global_script_class_cache.cfg`: **exactamente 1** `"TerrainData"`,
  1 `"TerrainDataM156"`, 1 `"TerrainDataProvider"`.
- `grep -rhoE "^class_name "` sobre `game/**/*.gd`: **0 duplicados** en todo el proyecto.
- `scripts/verificar_funcs_duplicadas.py`: **EXIT 0**.
- Ambos archivos `--check-only`: **EXIT 0**.

## 3. Hallazgo NUEVO: el provider VIVO seguía roto

`scripts/terrain/terrain_data_provider.gd` daba **EXIT 1, parse=3** (L30/36/42):

    The variable type is being inferred from a Variant value...
    var terrain := _terrains.get(terrain_id)   # Dictionary.get() -> Variant

**PREEXISTENTE** (agnes solo tocó `scripts/terrenos/`) y **listado en BUG-091**
("M08 (terrain_data_provider x2 + colisión de class_name TerrainData)"). Es decir: **resolver la
colisión NO basta** — el consumidor vivo seguía sin cargar.

**Fix (3 líneas):** `var terrain := ...` -> `var terrain: TerrainData = _terrains.get(terrain_id)`.
Ahora **`--check-only` EXIT 0, parse=0**, LF preservado. Commit `603834b`.

## 4. M167 (Isla-Raiz) — verificado sin impacto

Leí `DOCUMENTACION/167-Isla-Raiz/README.md` antes de tocar nada, como pediste. M167 es exclusivo
de la Isla Raíz (terreno FIJO + posicionamiento, RECOVERY): **0 refs a `TerrainData`**. La colisión
era M08 (`scripts/terrain/`) vs M156 (`scripts/terrenos/`); M167 es un **tercer** sistema -> el
rename y mi fix no lo tocan.

## 5. Lo que NO hice (honestidad)

- **NO** dupliqué el fix de agnes (verifiqué en su lugar).
- **NO** toqué `quality.yml` (s2 sigue con BUG-091).
- **NO** toqué M167 ni la Isla Raiz.
- **NO** commiteé `CHECKLIST-GLOBAL.md` (cambios ajenos en vuelo).
- **NO** arreglé `tests/unit/terrain/test_terrain_modifiers.gd`: usa `assert_that(x).is_equal_to(y)`,
  que **NO existe en gdUnit4** -> **parsea (EXIT 0) pero muere en runtime**. **No es un parse error
  de BUG-091** -> fuera de alcance. **Reportado** (¿lo escalo como bug propio o lo asignás?).
- **Sin cambio de marcas; NO sello §21.8** (autor != verificador; un fix de colisión no pide sello).

## 6. Trampas nuevas (para el skill)

1. **`is_equal_to` NO existe en gdUnit4** (0 apariciones en `addons/gdUnit4/`): `assert_that(x).is_equal_to(y)`
   **parsea** pero falla en runtime -> suite MUERTA sin parse error. Distinto de
   `assert_that(x).is_instance_of(int)`, que SÍ da parse error ("Builtin type cannot be used as a name").
2. **Fixear una colisión de `class_name` NO arregla a sus consumidores**: hay que verificar el
   consumidor (el provider M08 tenía sus propios parse errors), no solo la declaración.
3. **Doble asignación del mismo frente**: antes de arrancar un frente del director, revisar si otro
   canal lo recibió ya (agnes lo tenía desde 04:58).

## 7. Próximo

Frente cerrado. Quedo a la espera de: (a) confirmación de que el fix del provider M08 cierra el
frente TerrainData; (b) qué hago con `test_terrain_modifiers.gd` (deuda ajena reportada);
(c) próximo frente — ¿sigo con más parse errors de BUG-091, o me pasás M53/M54 (widgets)? Mi
criterio: los widgets (PRIORIDAD 4) son módulos activos con código no conectado, sin tierra sagrada;
si preferís, sigo barriendo BUG-091 que es 100% verificable headless.
