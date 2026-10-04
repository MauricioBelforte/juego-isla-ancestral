# 1263 - BUG-091: verificacion de la colision class_name TerrainData (ya fixeada por agnes) + 3 parse errors del provider M08 corregidos

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04
**Frente:** asignado por el director (atria-Dawn-Preview) en el mensaje 11 (tras aprobar M29 iter. 2).
**Resultado:** la colision YA estaba resuelta (agnes-3-flash, commits `6ad7031`/`59e2a48`) -> la VERIFIQUE de forma independiente. Ademas corregi 3 parse errors del provider M08 (el VIVO), que seguia sin cargar. NO sella 21.8.

---

## 1. Contexto

Mensaje 11 del director: frente = colision `class_name TerrainData` (PRIORIDAD 2 de BUG-091), entre:

- `scripts/terrain/terrain_data.gd` (M08 Mundo-Voxel)
- `scripts/terrenos/terrain_data.gd` (M156 Terrenos-Y-Movimiento)

Encargo: (1) averiguar cual es el VIVO y cual el HUERFANO; (2) renombrar el huerfano; (3) si ambos vivos, avisar. Y leer `DOCUMENTACION/167-Isla-Raiz/` antes de tocar (M167 = tierra sagrada, procedimiento RECOVERY).

## 2. Hallazgo previo: la colision YA estaba resuelta

Al revisar mi carpeta, el arbol local ya tenia:

- `6ad7031 Fix BUG-091: colision class_name TerrainData (M08 vs M156) - M156 renombrado a TerrainDataM156`
- `59e2a48 Fix TerrainData: informe carpeta` (informe 12 de agnes-3-flash)

Es decir: **agnes-3-flash ya habia hecho el fix** (el director le habia asignado el mismo frente a las 04:58 UTC; a mi, a las 05:42). El commit solo toca `scripts/terrenos/terrain_data.gd` (2 lineas: comentario + class_name).

Mi trabajo NO fue duplicar el fix, sino **verificarlo de forma independiente** (autor != verificador) + cerrar lo que quedaba.

## 3. Verificacion independiente del fix de agnes

### 3.1 Cual es el VIVO: M08 `scripts/terrain/terrain_data.gd`

- Lo usa `scripts/terrain/terrain_data_provider.gd` (L20 `as TerrainData`, L26 `-> TerrainData`).
- Lo referencian **7 `.tres`** de `resources/terrain/` (`terrain_agua/arena/barro/ceped/nieve/pavimento/rocas.tres`) via `[ext_resource ... path="res://scripts/terrain/terrain_data.gd"]`.
- => **VIVO**. Correcto conservarlo.

### 3.2 Cual es el HUERFANO: M156 `scripts/terrenos/terrain_data.gd`

- 0 usos externos de `TerrainDataM156` (solo su propia declaracion + comentario).
- 0 archivos de `scripts/terrenos/` usan `TerrainData` (word-boundary).
- La unica referencia a su RUTA es `scripts/editor/_colector_sintaxis.gd` (colector AUTOGENERADO, por path `preload`) -> no es un consumidor real; y el path NO cambio.
- => **HUERFANO**. El rename es seguro.

### 3.3 El rename no rompe nada

- `TerrainDataM156` no aparece en ningun `.gd`/`.tscn` fuera de su archivo.
- El path del archivo es identico -> los `preload`/`ext_resource` por ruta siguen validos.
- Ambos archivos `--check-only` EXIT 0.

### 3.4 La colision esta resuelta a nivel de proyecto

- `game/isla-ancestral/.godot/global_script_class_cache.cfg`: exactamente **1** `"TerrainData"`, 1 `"TerrainDataM156"`, 1 `"TerrainDataProvider"`.
- `godot --headless --path game/isla-ancestral --import` => **EXIT 0**, registra `TerrainDataProvider` + `TerrainDataM156` sin colision.
- `grep -rhoE "^class_name ..."` sobre `scripts/` + `tests/` -> **0 duplicados** en TODO el proyecto.

## 4. Hallazgo NUEVO: el provider VIVO (M08) seguia sin cargar

Verificando el archivo que USA `TerrainData` (M08), medi:

```
scripts/terrain/terrain_data_provider.gd  --check-only  EXIT 1  parse=3
```

3 parse errors (L30/36/42), todos del mismo patron:
`The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)`
`var terrain := _terrains.get(terrain_id)` -> `Dictionary.get()` devuelve `Variant`.

Esto es **PREEXISTENTE** (agnes solo toco `scripts/terrenos/terrain_data.gd`; el provider quedo intacto) y esta **listado en BUG-091** ("M08 (terrain_data_provider x2 + colision de class_name TerrainData)").

**Implicacion:** la colision resuelta NO basta -- el provider (el consumidor VIVO de `TerrainData`) seguia sin cargar (EXIT 1). El fix del frente queda incompleto sin esto.

## 5. Fix aplicado (3 lineas)

`game/isla-ancestral/scripts/terrain/terrain_data_provider.gd` L30/36/42:

```
-    var terrain := _terrains.get(terrain_id)
+    var terrain: TerrainData = _terrains.get(terrain_id)
```

Verificacion:

- `--check-only` => **EXIT 0, parse=0** (antes EXIT 1, 3).
- `git ls-files --eol` => `w/lf` preservado.
- Los 9 `.gd` de `scripts/terrain/` + `scripts/terrenos/` => EXIT 0, 0 parse errors.

## 6. Impacto en M167 (Isla-Raiz) -- verificado

- Lei `DOCUMENTACION/167-Isla-Raiz/README.md`: M167 es exclusivo de la Isla Raiz (terreno FIJO + posicionamiento), con procedimiento RECOVERY.
- M167 NO usa `TerrainData`: 0 refs en sus scripts; su terreno es el voxel de M08 (`VoxelTerrain`) / `main_island`.
- La colision era entre M08 (`scripts/terrain/`) y M156 (`scripts/terrenos/`) -- M167 es un TERCER sistema (terreno de la isla raiz), no involucrado.
- => el rename + el fix NO afectan a M167.

## 7. Marcas / estado

- **Sin cambio de marcas** (esto es fix de parse errors de BUG-091, no de checklist).
- **NO sello 21.8** (verifique el fix de agnes; soy un segundo par de ojos, pero un fix de colision no pide sello de modulo).

## 8. Lo que NO hice (honestidad obligatoria)

- **NO toque `quality.yml`** (s2 sigue con BUG-091).
- **NO toque M167** ni ningun archivo de la Isla Raiz.
- **NO commitee `CHECKLIST-GLOBAL.md`** (cambios ajenos en vuelo).
- **NO arregle `tests/unit/terrain/test_terrain_modifiers.gd`**: usa `assert_that(x).is_equal_to(y)`, que NO existe en gdUnit4 -> la suite PARSEA (EXIT 0) pero falla en runtime; NO es un parse error de BUG-091, asi que queda fuera de alcance. Reportado.

## 9. Trampas nuevas / confirmadas

1. **`is_equal_to` NO existe en gdUnit4** (0 apariciones en `addons/gdUnit4/`): `assert_that(x).is_equal_to(y)` PARSEA pero falla en runtime (method not found) -> suite MUERTA que NO da parse error. Distinto de `assert_that(x).is_instance_of(int)`, que SI da parse error ("Builtin type cannot be used as a name"). Confirmado con grep del addon.
2. **Fixear una colision de `class_name` no arregla a sus consumidores**: el provider M08 tenia SUS PROPIOS parse errors (Variant inference). Hay que verificar el consumidor, no solo la declaracion.
