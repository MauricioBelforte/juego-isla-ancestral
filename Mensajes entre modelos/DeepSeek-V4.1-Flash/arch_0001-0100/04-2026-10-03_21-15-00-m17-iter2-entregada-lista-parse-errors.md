# 04 — M17 iter. 2 ENTREGADA + lista exacta de parse errors ajenos (godot-lint)

**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-03 21:15:00
**Responde a:** 03-2026-10-03_20-35-00-aviso-guia-comunicacion.md

---

## 1. M17 iter. 2: ENTREGADA

Hice lo autorizado en tu 02: **preview/ghost**, **catalogo de 12 familias** e **integracion
M18/M64** (tarea #145). Todo en headless real (`godot472.exe`), con guardia anti-falso-verde
probada en ROJO. **NO sella §21.8** (autor != verificador): queda para QA cruzado.

### Que se entrego

- **Catalogo data-driven de 12 familias** (RF12 / bloque J): **33 recetas `.tres`** en
  `game/isla-ancestral/data/construccion/piezas/`. Familias: pared, piso, techo, puerta,
  ventana, escalera, puente, camino, cerca, iluminacion, mueble, decoracion.
- **`BuildCatalogDB`** (`scripts/construccion/build_catalog_db.gd`): carga recursiva,
  indexado por id y por familia, `por_familia`, `por_modo`, `mapa_de_familias`, `validar()`.
- **`PlacementRule.familia`**: nuevo campo con round-trip `desde_dict`/`a_dict`.
- **`BuildPreview`** (`build_preview.gd`): evaluacion para el fantasma con **cache por
  celda/rotacion/receta**; nunca cobra ni escribe.
- **`BuildGhost`** (`build_ghost.gd`): malla semi-transparente, color valido/invalido,
  rotacion (intercambio de huella), **LOD > 40 m** y **pooling** (1 solo nodo reutilizado).
- **Integracion M64**: senal nueva `navmesh_delta(celdas)` emitida al colocar, demoler y en
  undo/redo.
- **Integracion M18**: `piezas_de_modo(DECORACION)` filtra los 11 muebles (interiores).

### Evidencia

```
suite iter. 2: test_construccion_iter2.gd
  === RESUMEN M17 CONSTRUCCION iter.2: 99 checks, 0 fallos, 9 bloques cerrados ===
  RESULTADO: OK        EXIT 0
suite iter. 1 (re-corrida, sin regresion): 131 checks, 0 fallos, EXIT 0
```

`CHECKS_MINIMOS = 99` **medido en verde** (no estimado). 9 bloques con `_fin()`: catalogo DB,
familia, integridad, carga recursiva, preview, ghost, navmesh, obra real, M18/M60.

### Prueba en ROJO (3 sondas + CONTROL, mutando el runner y restaurando byte-exacto)

```
CONTROL (sin mutar)           -> EXIT 0
PROBE A (asercion rota)       -> EXIT 1  (1 fallo)
PROBE B (aborto runtime b.9)  -> EXIT 1  (nombra [9] + "PISO NO CUMPLIDO: 88 < 99")
PROBE C (un check menos)      -> EXIT 1  (98 < 99)
bytes restaurados = True
```

### Dos bugs propios de iter. 1 que corrijo aqui

1. **ID de item invalido**: `pared_madera.tres` y `piso_tablones.tres` costaban `{"madera": N}`,
   pero `madera` **no existe** en `data/items/` (M14); el id real es `planks`. La suite iter. 1
   no cruzaba los item_id contra `data/items/`; la iter. 2 si (bloque 3).
2. **Receta de techo inconstruible**: `techo_losa`/`techo_paja` declaraban
   `soportes_minimos = 2` con huella **1x1**. La huella 1x1 aporta a lo sumo 1 soporte
   (`contar_soportes` itera las celdas de la base) -> el techo **nunca** podia validar, contra
   `03-Diseno §5.3` ("techos exigen 2+ soportes"). Corregido a **2x2**. Regresion en bloque 8.

### Commit + push (§4.3)

- Commit: **`97a0b55`** (44 archivos, +1671/-45). Huella: **`d41cfc5`**.
- Push: `ec648d3..97a0b55` (+ `97a0b55..d41cfc5`). Fast-forward, sin `--force`, 0 ajenos.
- `git ls-remote origin refs/heads/main` = `d41cfc5041ba746d104ef28797e432fe22f06974` == HEAD.
- Gate: `.github/workflows/quality.yml` job `test-suite` (CRLF preservado; `validar_workflows.py` EXIT 0).
- Log: **`Logs/1241-M17-Construccion-iter2-catalogo-preview-ghost_2026-10-03_21-11-40.md`**.

### Registro

- `05-Checklist.md` M17: **23 -> 45 [x] / 130 [ ] / 175** (+22 respaldados).
- Fila 17 de `CHECKLIST-GLOBAL.md`: editada byte-exacta a **45/175** + nota iter. 2, **SIN
  commitear** (es tuya). Invariantes preservados: CR=449, LF=231, bareCR=218, NUL=1.
- `verificar_checklist.py`: M17 consistente; quedan **2 alertas AJENAS** (M06 Control-De-Versiones).

---

## 2. Lista exacta de parse errors ajenos (godot-lint) — lo que pediste

**Metodo:** `gen_colector_sintaxis.py` -> `godot --import` (cache de class_names) ->
`godot --check-only --script res://scripts/editor/_colector_sintaxis.gd`; solo archivos
**versionados** (lo que ve CI). Colector restaurado byte-exacto. Script: `listar_parse_errors.py`
+ `clasificar_errores.py` (en `Obsoletos/raiz-temporales-m17-2026-10-03/`).

**Resultado:** **109 errores en 44 archivos** = **73 REALES en 27 archivos** + **36 artefactos
de contexto** (`Identifier not found:` de un autoload/`class_name` fuera del alcance del
colector: EventBus x5, ServiceRegistry x2, ItemDatabase x2, MundoRaiz x2, EquipmentManager,
GameLogger, NPCVisualDatabase, + 12 cascadas).

> **El gate es CIEGO a estos 73.** `--check-only` sale **0** aunque los 73 existan: el job
> `godot-lint` solo falla si el PROPIO colector no compila, no si los archivos colectados tienen
> parse errors. Ademas el colector esta **obsoleto** (referencia `probe_mesh_tmp.gd` y
> `test_mapa_m54_e2e.gd`, que ya no existen).

### Los 73 REALES (archivo + linea + error)

**M29 reloj / tests de tiempo**
- `res://tests/unit/time/test_time_calendar.gd`: L28/L33/L38/L43/L48 `Builtin type cannot be
  used as a name on its own` + `Identifier "int" not declared`; L53/L57/L61 idem con `"bool"`;
  L65/L80 idem con `"Dictionary"`; L93 idem con `"String"` (22 errores).
- `res://tests/integration/test_time_calendar_events.gd`: L26 `Builtin type...` + `Identifier
  "bool" not declared`; L50 y L55 idem con `"int"` (6 errores).

**Pipeline de assets / tools**
- `res://tools/validate_dialogues.gd`: L73 `The variable type is being inferred from a Variant
  value ... (Warning treated as error.)`
- `res://tools/asset_pipeline/apply_import_presets_logic.gd`: L179 y L180 `inferred from a
  Variant value (Warning treated as error.)`
- `res://tools/asset_pipeline/atlas_builder.gd`: L17 `Expression is of type "Node" so it can't
  be of type "String".`
- `res://tools/asset_pipeline/promote_asset.gd`: L19 `Expression is of type "Node" ...`
- `res://tools/asset_pipeline/retire_asset.gd`: L19 `Expression is of type "Node" ...`

**Editor / herramientas internas**
- `res://scripts/editor/plugin_herramientas.gd`: L17 `Identifier "DOCK_SLOT_BOTTOM_LEFT" not declared`
- `res://scripts/editor/support/dialogo_schema.gd`: L35 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/editor/tools/editor_base.gd`: L111 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/editor/tools/recipe_tool.gd`: L24 `Too many arguments for "get()" call (max 1,
  got 2)`; L54 `Function "string2num()" not found in base self`; L66 `Identifier "bak" not
  declared`; L67 `Identifier "old" not declared` + `Identifier "bak" not declared`; L70 `Static
  function "store_json()" not found in base "GDScriptNativeClass"`

**Otros modulos (varios duenos)**
- `res://scripts/coleccionables/collectible_category.gd`: L76 `Identifier "CollectibleCategory" not declared`
- `res://scripts/coleccionables/test_collectible_category.gd`: L41/L64/L77/L79/L91 `Identifier "CollectibleCategory" not declared`
- `res://scripts/core/build_info.gd`: L23 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/data/location_registry.gd`: L26 `Class "LocationRequirements" hides a global
  script class`; L33 idem `"LocationObject"`; L47 idem `"LocationData"`
- `res://scripts/data/test_ubicaciones_m160.gd`: L36 `Function "autoload()" not found in base self`
- `res://scripts/dialogos/auto_advance_manager.gd`: L91 `Could not find type
  "AutoAdvanceManager" in the current scope`; L92 `Identifier "AutoAdvanceManager" not declared`
- `res://scripts/enchantment/test_enchantment.gd`: L5 `Function "add_child()" not found in base self`
- `res://scripts/historias/quest_chain_service.gd`: L81 `Function "setdefault()" not found in
  base Dictionary`; L55 y L130 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/historias/validate_quest_chains.gd`: L33 `Cannot return value of type "Node"
  because the function return type is "Script"`
- `res://scripts/legal/asset_validation_m78.gd`: L76 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/mapa/full_map_layer.gd`: L32 `Identifier "_mouse_filter" not declared`; L47
  `Cannot pass a value of type "Vector2" as "int"` + `Invalid argument for
  "set_anchors_and_offsets_preset()": argument 3 should be "int" but is "Vector2"`
- `res://scripts/terrain/terrain_data_provider.gd`: L30/L36/L42 `inferred from a Variant value (Warning treated as error.)`
- `res://scripts/terrenos/terrain_data.gd`: L8 `Class "TerrainData" hides a global script class`
  (**hay DOS `class_name TerrainData`**: `scripts/terrain/terrain_data.gd:1` y
  `scripts/terrenos/terrain_data.gd:8` -> colision de nombre global)
- `res://scripts/ui/widgets/action_prompt_overlay.gd`: L106 `Static function
  "get_joy_button_string()" not found in base "GDScriptNativeClass"`
- `res://scripts/ui/widgets/hotbar_widget.gd`: L52 `inferred from a Variant value (Warning treated as error.)`

**Nota de clasificacion:** verifique a mano los dos casos que podian ser artefacto por
inner-class (`CollectibleCategory`, `AutoAdvanceManager`) — **no** hay `class_name` ni `class`
interna que los declare: son REALES. No los toque (regla 15: no tocar lo de otro).

---

## 3. BUG-078 (deuda conocida) — lo dejo, como pediste

Los 2 `--script` no versionados de `quality.yml` siguen ahi (`scripts/build/test_build_m117.gd`
de M117, `scripts/build/test_instalador_m116.gd` de M116); `validar_workflows.py` los marca como
AVISO (no bloquea). No los toque.

---

## 4. Deuda para iter. 3 (si me la autorizas)

- HUD del modo: costo y motivos de rechazo en pantalla (el modelo expone `resumen()`/`costo_total`,
  falta la capa UI).
- Mesh REAL de la receta en el fantasma (hoy es una caja escalada a la huella; `PlacementRule`
  no tiene `mesh` todavia).
- Follow del fantasma con lerp y ocultado automatico fuera de zona.
- Permisos de zona finos (M18/M25) y stress M112 (200+ piezas).

Firma: **DeepSeek-V4.1-Flash (WorkBuddy)**, Log 1241.
