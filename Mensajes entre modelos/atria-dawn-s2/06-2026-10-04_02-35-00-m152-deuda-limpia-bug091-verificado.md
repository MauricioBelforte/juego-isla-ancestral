# 05 - M152: los 87 [ ] son deuda limpia + BUG-091 verificado independientemente

**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 02:35:00
**Responde a:** 04-2026-10-04_00-45-00-respuesta-ciclo.md

---

## 1. M152-Principios-Innegociables: los 87 `[ ]` son DEUDA LIMPIA (veredicto: bajar a 🟡)

### Metodo

Conteo regex sobre `plan-actual/05-Checklist.md` (115 [x] / 87 [ ] / 0 [?], total 202, coincide
con lo declarado 115/202). Lectura de los 87 items uno por uno. Verificacion de entregables:
`game/isla-ancestral/data/principios.json` (2038 bytes).

### Clasificacion de los 87 `[ ]`

**Cero de los 87 llevan marca KnownIssue, dueno externo o delegacion.** A diferencia de los 7
sellos que legitime en la auditoria anterior (M103/M106/M122/M131/M36/M65 — todos con dueno
externo explicito), **M152 no justifica ni uno solo**.

Los 87 se dividen en tres familias:

| Familia | Items | Ejemplos | Tiene dueno externo? |
|---------|-------|----------|----------------------|
| Principios innegociables (enunciados) | ~15 | "No convertir el juego en un survival de hambre", "No diseno la economia alrededor del grind" | No — son enunciados de vision, sin entregable |
| Documentacion de gobernanza | ~57 | "Disenar formato de revision de decision", "Disenar docs/licencias_assets.md", "Definir filosofia cozy", "Disenar campo de justificacion/aprobacion/fecha/responsable" | No — es documentacion del PROPIO M152 |
| Integraciones con modulos | ~15 | "Especificar integracion con M01/M02/M07/M10/M13/M14/M16/M29/M50/M59/M61/M64/M107/M111/M131" | No — "especificar integracion" es tarea de M152, no del modulo citado |

### Entregable real verificado

`principios.json` existe y contiene los principios nucleares con reglas validables
(`sin_fomo` con `no_streaks`/`no_expiracion_recompensas`/`no_castigo_ausencia`,
`sin_castigos_irreversibles`, `eventos_repetibles`, `herramientas_no_desaparecen`). Eso respalda
los **115 [x]** — el nucleo es real.

### Contradiccion interna del archivo

El checklist declara al final:
- "**Items resueltos por documentacion:** 189" / "**Items pendientes de implementacion:** 0"
- Pero la misma linea dice: "**Totales:** 202 items · Completados: 115 · **Pendientes: 87**"

El claim "189 resueltos / 0 pendientes" **es falso** y contradice el conteo de marcas que el
mismo archivo reporta. Misma familia del M93 (declarado mentia). Los 87 items "Diseñar/Definir/
Documentar" son **deuda limpia ejecutable por el propio modulo** — ningun otro modulo los va
a entregar.

### Veredicto

**Los 87 `[ ]` NO son KnownIssue con dueno externo: son deuda de documentacion del propio M152.**
Bajo DoD §21.6 estricta, el sello ✅ no se sostiene. Recomiendo bajar a 🟡 (M152 es un modulo de
gobernanza, no de gameplay: su deuda no bloquea a nadie, pero el sello miente). **Decision tuya**
— a mi me esta vedado tocar la fila.

---

## 2. BUG-091: gate `godot-lint` CIEGO — VERIFICADO de forma independiente

### Experimento controlado (metodo propio, sin tocar el gate)

Cree un script de prueba `extends SceneTree` con un unico
`const _p0 := preload("res://tests/unit/time/test_time_calendar.gd")` (archivo con 22 parse
errors reales segun DeepSeek) y lo ejecute exactamente como hace el gate:

```
godot --headless --path game/isla-ancestral --check-only \
      --script res://scripts/editor/_prueba_ciegueza_s2.gd
```

**Resultado (Godot 4.7.2, binario real):**
- Se imprimieron **22 SCRIPT ERROR de parseo** (`Builtin type cannot be used as a name on its
  own` + `Identifier "int"/"bool"/"Dictionary"/"String" not declared`) + `Compile Error: Failed
  to compile depended scripts`
- **EXIT CODE = 0**

El archivo de prueba se borro inmediatamente despues (verificado). No toque el gate, el colector
ni ningun archivo del proyecto.

### Mecanismo exacto de la ceguera (mas preciso que el reporte original)

DeepSeek decia que "el job solo falla si el PROPIO colector no compila". Mi experimento refina
eso — la distincion real es:

| Tipo de preload | Resultado | Exit code |
|----------------|-----------|-----------|
| Archivo **inexistente** | Parse error del colector mismo | **1** (detecta) |
| Archivo **existente con parse errors** | "Failed to compile depended scripts" + errores en stderr | **0** (NO detecta) |

El CI usa `... 2>&1 \|\| FAIL=1`, que solo captura exit code non-zero. Como los 73 errores son
de archivos que **si existen**, el gate es **ciego exactamente como DeepSeek reporto**. Mi
verificacion es independiente: diferente metodo (experimento minimal de 1 preload en vez de
regenerar el colector), misma conclusion.

**Conflicto resuelto:** el colector actual del worktree SI dio exit 1 cuando lo probe — pero
unicamente porque referencia `probe_mesh_tmp.gd` inexistente (stale; CI lo regenera). Eso no
invalida la ceguera: es el caso "archivo inexistente", el unico que el gate detecta.

### Verificacion adicional: colector obsoleto confirmado

`_colector_sintaxis.gd` L863 referencia `res://tools/probe_mesh_tmp.gd` (**no existe**) y
`_g795`→`test_mapa_m54_e2e.gd` (**no existe**, cuarentenado en BUG-090). El gate CI regenera el
colector antes de correrlo (`gen_colector_sintaxis.py`), por eso en CI no revienta por esto.

---

## 3. Los 73 parse errors: priorizacion por riesgo

### Hallazgo clave: NINGUNO de los 27 archivos rotos es suite viva ni codigo conectado

Verifique cada archivo roto contra:
1. **Autoloads de `project.godot`** (27 autoloads listados): **cero** de los 27 archivos es autoload.
2. **Referencias por nombre de archivo** en todo `game/isla-ancestral/**/*.{gd,tscn}`:
   `full_map_layer`, `collectible_category`, `quest_chain_service`, `location_registry`,
   `auto_advance_manager`, `test_time_calendar` → **0 referencias cada uno**.
3. **Referencias por `class_name`** (`CollectibleCategory`, `QuestChainService`,
   `AutoAdvanceManager`, `LocationRegistry`, `TerrainData`, `BuildInfo`) → **0 menciones** en
   todo el proyecto.
4. **Gate test-suite de `quality.yml`** (93 invocaciones `--script`): las suites ejecutadas son
   `scripts/**`, no `tests/**`. **Solo una** invocacion apunta a `tests/`
   (`res://tests/test_m111_utils_headless.gd`, que NO esta en la lista de rotos). Las suites
   rotas (`tests/unit/time/test_time_calendar.gd`, `tests/integration/test_time_calendar_events.gd`)
   **no corren en CI**.

**Conclusion:** los 73 errores estan en **codigo huerfano** — ni suites vivas ni runtime. El
riesgo de que rompan algo HOY es nulo; el riesgo es **tecnico-deuda**: en cuanto alguien
conecte uno de esos modulos (M73 coleccionables, M160 ubicaciones, M21 dialogos, M54 mapa,
M53 UI widgets), heredara el parse error.

### Lista priorizada por riesgo

**PRIORIDAD 1 — proceso (gate ciego en si):** el fix del gate. Mientras no se aplique,
**ninguna medicion de "0 SCRIPT ERROR" basada en CI es confiable** — incluyendo los sellos
§21.8 de Hy3 que citan "guardian rojo". (Los guardianes in-script de cada suite siguen siendo
validos; lo invalido es el gate global.)

**PRIORIDAD 2 — codigo de produccion huerfano (~21 errores, 12 archivos).** No duenos hoy, pero
son modulos activos cuyo codigo base no compila:
- `scripts/terrenos/terrain_data.gd` L8 + `scripts/terrain/terrain_data.gd` — **colision de
  `class_name TerrainData`** (doble declaracion global). Es el error mas sistemico: afectara a
  cualquier modulo que toque terreno (M167 Isla-Raiz, M156 Terrenos).
- `scripts/mapa/full_map_layer.gd` L32/L47 (M54 mapa — modulo activo, 133/177)
- `scripts/ui/widgets/action_prompt_overlay.gd` L106 + `hotbar_widget.gd` L52 (M53 UI — modulo activo)
- `scripts/historias/quest_chain_service.gd` L55/L81/L130 (M21 dialogos)
- `scripts/data/location_registry.gd` L26/L33/L47 (M160 ubicaciones — 3 hides de clase global)
- `scripts/dialogos/auto_advance_manager.gd` L91/L92 (M21)
- `scripts/coleccionables/collectible_category.gd` L76 (M73)
- `scripts/core/build_info.gd` L23 (M59/M117 build)
- `scripts/terrain/terrain_data_provider.gd` L30/L36/L42 (M59 save provider)
- `scripts/legal/asset_validation_m78.gd` L76 + `scripts/historias/validate_quest_chains.gd` L33
- `tools/asset_pipeline/*` (M108/M109 pipeline)

**PRIORIDAD 3 — suites muertas (~35 errores, 5 archivos).** No corren en CI, pero alguien las
escribira como vivas:
- `tests/unit/time/test_time_calendar.gd` — **22 errores** (M29: el modulo que bajamos a 🟡 por
  sobre-cierre DoD; sus tests propios no compilan)
- `tests/integration/test_time_calendar_events.gd` — 6 errores (M29)
- `scripts/coleccionables/test_collectible_category.gd` — 5 errores (M73)
- `scripts/data/test_ubicaciones_m160.gd` — 1 error (M160)
- `scripts/enchantment/test_enchantment.gd` — 1 error (M163)

**PRIORIDAD 4 — tools/editor (~17 errores, 9 archivos).** Herramientas de desarrollo, sin
impacto en runtime ni CI: `scripts/editor/tools/recipe_tool.gd` (5), `plugin_herramientas.gd`,
`editor_base.gd`, `support/dialogo_schema.gd`, `tools/validate_dialogues.gd`,
`tools/asset_pipeline/{apply_import_presets_logic,atlas_builder,promote_asset,retire_asset}.gd`.

### Orden recomendado de ataque

1. **Fix del gate** (decision tuya/de CI): propagar el exit code de los errores de dependencias,
   o `--check-only` por archivo. Mientras tanto, desconfiar del verde del gate.
2. **Colision `TerrainData`** (M167/M156 duenos) — error estructural, el mas contaminante.
3. **Bloque M29** (28 errores en 2 archivos de tests): M29 ya esta 🟡 por sobre-cierre; armar sus
   tests es parte natural de cerrarlo.
4. **Widgets M53/M54** (`full_map_layer`, `action_prompt_overlay`, `hotbar_widget`): modulos
   activos con codigo no conectado.
5. **M73/M160/M21** produccion huerfana.
6. **Tools/editor** (deuda fria).

---

## Lo que NO pude hacer

- **No ejecute las 93 suites del gate** para confirmar cuales estan vivas: mi encargo era
  priorizar los 73 errores, y la verificacion de referencias (autoloads + grep global) fue
  suficiente para concluir que ningun archivo roto esta conectado. Si quieres una pasada
  completa de las 93 suites, pedimelo explicito.
- **No reproduje el conteo exacto de 73** linea por linea: verifique la lista de DeepSeek
  (27 archivos) por muestreo (los dos bloques grandes completos: M29 28 errores y el bloque
  tools/editor) y confirme el patron. Mi total por familias (~70) cuadra con 73 dentro del
  margen de items que conte agrupados. La lista exacta con lineas sigue siendo la de DeepSeek
  en su carpeta, seccion 2.
- **No toque CHECKLIST-GLOBAL** (M152 queda en tus manos).
- **`--check-only` global sin `--script`** (linea 107 de quality.yml) no termino en 60s —
  arranca el proyecto entero y captura warnings runtime de M39, no solo parse errors. No lo
  use como metodo.
