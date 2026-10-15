# 12 — Frente tools/editor CERRADO (22→0 parse errors) + 3 suites cableadas + QA M38 sellada

**Modelo:** atria-dawn-s2 (analista)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 07:10:00
**Responde a:** 09-2026-10-04_05-42-00-gate-aprobado-commit-tools.md

---

## (E) QA §21.8 M38 — APROBADA y SELLADA (resumen; detalle en Log 1267)

agnes entregó el re-fix v3 (`c60b068`). Verifiqué los 3 cambios por código + binario real:

- **3 suites:** `test_bug047_sell_only.gd` 6/0 (nueva), `test_m38_economia_smoke.gd` 7/0,
  `test_iter5_jkl.gd` 33/0. 0 SCRIPT ERROR.
- **Sonda ROJO→VERDE empírica:** hice `git checkout 8ed9c60 -- price_manager.gd` (falso fix v1)
  → **6/6 FAIL** (actual=0); restauré HEAD → **6/0 OK** (75/200/60/55/40). La regla del
  test-que-falla-contra-el-pre-fix **se cumple**.
- **Preocupaciones del director, todas despejadas:**
  - Cambio #3 (clamp `if tope > 0`): NO desactiva el clamp para items normales (compra>0 sigue
    clampado; `madera_roble == 6` OK).
  - Cambio #2: `TOPE_VENTA_SOBRE_COMPRA` **sigue usándose** en la rama compra>0 (grep: solo en
    `price_manager.gd`, no quedó huérfana).
  - Assert anti-arbitraje ahora **no-trivial**: `precio_venta_vigente('pico_cobre') == 60`
    (verificado), así que `60 < 78` reemplaza al `0 < 78` trivial.
- **Extra:** BUG-028 también verificado resuelto (`test_loop_economico.gd` EXIT 0,
  `[OK] precio compra definido`, item OBJ-PLA-002 existe).

**Sellos aplicados (autorizados por el director):**
- `11-BUGS.md`: BUG-047 `[!] RE-ABIERTO` → `[x] RESUELTO 2026-10-04` + entrada en sección 7.
- `CHECKLIST-GLOBAL.md` fila 38: `🟡 158/164 agnes-3-flash` → `✅ 164/164 —` (byte-exact,
  11 pipes preservados) con sello `✅ QA por atria-dawn-s2 (Log 1267)`.
- `05-Checklist.md` M38: 6 `[?]` → `[x]` con nota de resolución → **164/164, 0 [?]**.
- `python scripts/verificar_checklist.py` → **✅ SIN ALERTAS** para 38-Economia.

Commits: `00841a3` (sellos + coordinación), `2398ac8` (huella §4.3). Push `e2ff0fa..2398ac8`.

---

## (5) Frente tools/editor — CERRADO: 22 parse errors → 0

**Descubrimiento metodológico importante:** el colector `_colector_sintaxis.gd` estaba **stale**
(864 líneas, referenciaba `probe_mesh_tmp.gd` y `test_mapa_m54_e2e.gd` ya borrados). Con el
colector stale solo aparecían 4 errores (todos del propio colector). Regeneré con
`tools/quality/gen_colector_sintaxis.py` (hay que correrlo DESDE `game/isla-ancestral/`, usa
`os.getcwd()`) → 918 preloads → **77 SCRIPT ERROR reales**, de los cuales **22 eran de mi frente**.
El director estimó ~17; el número real era 22.

**Ninguno de los 9 archivos es huérfano** (verifiqué referencias; `plugin_herramientas.gd` es
EditorPlugin cargado por `project.godot`). Fixes aplicados:

| archivo | errores | fix |
|---|---|---|
| `recipe_tool.gd` | 7 | `load()` de JSON → `FileAccess`+`JSON.parse_string`; `string2num()` inexistente → `.to_float()`/`.to_int()` por campo; bloque backup con scopes rotos (`bak`/`old` locales a un `if`) reescrito; `FileAccess.store_json()` estática inexistente → `open()`+`JSON.stringify()` |
| `editor_base.gd` | 2 | 2 líneas muertas ofuscadas eliminadas (`get_node("" if false else "")`); `for campo: String in _campos`; `var res: String` |
| `plugin_herramientas.gd` | 1 | `DOCK_SLOT_BOTTOM_LEFT` (Godot 3) → `DOCK_SLOT_BOTTOM` |
| `dialogo_schema.gd` | 1 | `var nid: String = pila.pop_back()` |
| `validate_dialogues.gd` | 1 | `var data: Variant = json.data` |
| `apply_import_presets_logic.gd` | 4 | tipos explícitos (`Dictionary`/`Variant`) |
| `atlas_builder.gd` | 1 | `var recurso: Variant` (el `Node is String` es imposible) |
| `promote_asset.gd` | 3 | estrechamiento `if recurso is Resource:` con `ruta: String` |
| `retire_asset.gd` | 3 | idem |

**Notas:**
- En `recipe_tool.gd` corregí además un **bug lógico** que no era de parseo: la guardia
  `if errores.is_empty(): return "⚠️ Receta inválida..."` estaba **invertida** (guardaba recetas
  inválidas y rechazaba las válidas). Y agregué `_recetas[id] = receta` antes de persistir para
  que la UI vea la nueva receta sin recargar.
- **Trampa de API cazada:** mi primer fix de `plugin_herramientas.gd` usó
  `DOCK_SLOT_BOTTOM_BL`, que **no existe en Godot 4.7**. Enumeré las constantes reales con
  `ClassDB.class_get_integer_constant_list("EditorPlugin")`: Godot 4.7 simplificó las docks
  inferiores a solo `DOCK_SLOT_BOTTOM` (sin sufijos de esquina UL/BL/UR/BR en bottom).
- **El edit de `DOCK_SLOT` se perdió una vez** entre turnos (probablemente lo apliqué antes de
  la interrupción y no persistió); lo re-apliquí y verifiqué. Lección: re-verificar con el
  binario después de cada interrupción.

### Verificación

- Colector fresco + binario real 4.7.2: **0 SCRIPT ERROR en los 9 archivos** (antes 22).
- Total del proyecto: **77 → 44** (mi 22 + 11 de otros agentes en paralelo).
- `python scripts/validar_workflows.py`: EXIT 0, quality.yml ✅.

---

## (5b) 3 suites cableadas en `test-suite` (gate duro)

| suite | resultado | origen |
|---|---|---|
| `tests/unit/time/test_time_calendar.gd` | 74/0 | M29 iter.2 (DeepSeek, Log 1257) |
| `tests/integration/test_time_calendar_events.gd` | 51/0 | M29 iter.2 |
| `scripts/transporte/test_transporte_m68_iter3.gd` | 108/0 | M68 iter.3 (Log 1251) |

Las 3 dan **EXIT 0** (verificado con el binario real antes de cablearlas — no rompen el CI).
Cableadas con `|| FAIL=1` (gate duro, como las M59/lore/stream), justo antes del
`echo "All validation tests completed"`.

Los SCRIPT ERROR colaterales que imprimen (service_registry, settings_audio_layer = BUG-048) no
son fallos de las suites: `Resumen: 74 checks, 0 fallos`.

**EOL:** CRLF=903 / LF-sueltos=0 (preservado). YAML válido, 12 jobs.

---

## Huellas

- Push `e2ff0fa..2398ac8`: sellos M38 + coordinación (commit `00841a3`) + huella (`2398ac8`).
- Push `2398ac8..3ba9f42`: frente tools/editor + cableado (commit `3ba9f42`).

## Lo que NO pude hacer

- **No fixeé los 44 SCRIPT ERROR restantes** (deuda de otros frentes: 12 en
  `test_collectible_category.gd`, 5 en `quest_chain_service.gd`, etc.). No son de mi frente
  asignado; varios son código de gameplay (vedado para mí).
- **No re-emití la QA de M91** (encargo del addendum 1, si existía) — el archivo 09 menciona
  "QA de M91" como posible próximo contacto pero no vino encargo formal en el addendum 2.
- **No actualicé el índice de canales** tras el cierre: `indice_canales.py --update` respondió
  "SIN NOVEDADES" antes de la QA; no lo re-corrí después.
