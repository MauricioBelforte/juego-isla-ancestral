# 1266 - M53/M54 widgets: 3 parse errors de BUG-091 corregidos (hotbar_widget, action_prompt_overlay, full_map_layer)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-04
**Frente:** asignado por el director (atria-Dawn-Preview) en el mensaje 13 (parte c).
**Resultado:** 3 widgets con parse error de BUG-091 (los 3 referenciados por `hud.tscn`!) -> corregidos. `--check-only` EXIT 0 x3; `hud.tscn` carga OK. Marcados en los 05-Checklist de M53/M54. **NO sella 21.8.**

---

## 1. Contexto

Mensaje 13 (c): tomar los 3 widgets (PRIORIDAD 4). **Excepcion:** NO tocar el menu de settings de audio de M53 (frente de mimo-v2.6-flash-free).

Rutas del encargo (una estaba mal):
- `scripts/ui/widgets/full_map_layer.gd` -> **real: `scripts/mapa/full_map_layer.gd`** (M54).
- `scripts/ui/widgets/action_prompt_overlay.gd` (M53).
- `scripts/ui/widgets/hotbar_widget.gd` (M53).

## 2. Los parse errors (antes)

| Archivo | Linea | Error |
|---|---|---|
| `scripts/mapa/full_map_layer.gd` (M54) | L32 | `Identifier "_mouse_filter" not declared in the current scope` |
| `scripts/mapa/full_map_layer.gd` (M54) | L47 | `argument 3 should be "int" but is "Vector2"` (`set_anchors_and_offsets_preset`) |
| `scripts/ui/widgets/action_prompt_overlay.gd` (M53) | L106 | `Static function "get_joy_button_string()" not found in base "GDScriptNativeClass"` |
| `scripts/ui/widgets/hotbar_widget.gd` (M53) | L52 | `variable type is being inferred from a Variant value` |

## 3. Hallazgo: NO eran "codigo no conectado"

Los 3 scripts estan referenciados como `[ext_resource]` en **`scenes/ui/hud.tscn`** (ids `6_hotbar`, `8_action`, `10_fullmap`), y `hud_screen.gd` usa `%HotbarWidget`/`%ActionPromptOverlay`. Es decir: el HUD tenia 3 scripts que NO parseaban -> cargar la escena HUD emitia parse errors. El encargo decia "codigo no conectado": no era exacto (el fix es mas valioso de lo previsto).

## 4. Fixes (minimos, con tipo explicito)

**`full_map_layer.gd` L32:** `_mouse_filter = ...` -> `mouse_filter = ...` (la propiedad real de `Control` es `mouse_filter`; `_mouse_filter` no existe).

**`full_map_layer.gd` L47:** `set_anchors_and_offsets_preset(PRESET_CENTER, PRESET_MODE_MINSIZE, Vector2(600,500))` -> el 3er arg es `margin: int`, no un tamano. Se conserva la intencion (panel 600x500 centrado):
```
panel.custom_minimum_size = Vector2(600, 500)
panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
```
(se retiro el `panel.position -= Vector2(300,250)`, que compensaba el arg invalido y descentraba el panel).

**`action_prompt_overlay.gd` L106:** `Input.get_joy_button_string(btn)` **NO existe en Godot 4.7.2** (verificado con `Input.get_method_list()`: no hay ningun `get_joy_*_string`). Se agrega un mapa manual `JOY_BUTTON_NAMES` (enum `JoyButton` -> texto) y se reemplaza la llamada.

**`hotbar_widget.gd` L52:** `var slot_data := _read_hotbar_slot(inv, i)` (la funcion declara `-> Variant`) -> `var slot_data: Variant = _read_hotbar_slot(inv, i)`.

## 5. Verificacion

- `--check-only` **EXIT 0** en los 3 archivos (antes: EXIT 1).
- Sonda de carga: `hud.tscn` + los 3 scripts -> `load()` **OK x4** (antes el hud.tscn habria emitido parse errors).
- EOL **LF preservado** en los 3 `.gd`; checklists M53/M54 editados byte-exact preservando **CRLF** (262/248 CRLF, 0 bare LF).

## 6. Marcas

- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md`: notas de evidencia en "Crear HotbarWidget..." (L44) y "Crear ActionPromptOverlay..." (L46).
- `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md`: nota en "Crear FullMapLayer..." (L38).
- Los 3 items ya estaban `[x]` **pese al parse error** (sobre-cierre de BUG-091: "creado" no es "compila"). Ahora el `[x]` queda respaldado. **Sin cambio de estado** (solo nota).

## 7. Lo que NO hice (honestidad)

- **NO** toque el menu de settings de audio de M53 (frente de mimo-v2.6-flash-free).
- **NO** toque `quality.yml`.
- **NO** sello 21.8 (autor != verificador).

## 8. Trampas nuevas

1. **`Input.get_joy_button_string()` NO existe en Godot 4.7.2** (ni `get_joy_axis_string`). Verificado con `Input.get_method_list()`. Para nombrar botones de gamepad hay que mapear el enum `JoyButton` a mano.
2. **Ruta del encargo desactualizada:** `full_map_layer.gd` esta en `scripts/mapa/`, no en `scripts/ui/widgets/`. Medir la ruta antes de interpretar "File not found -> EXIT 1".
3. **Un `[x]` en checklist NO implica que el script compile:** los 3 items estaban `[x]` con parse errors vivos (familia de BUG-090/091).
