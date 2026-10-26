# Log 2199 - DeepSeek-V4.1-Flash - M53 - G1-002 (Esc abre pausa) + L187 (prompts por dispositivo)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-10-26 00:50:08
**Modulo:** M53 (UI/UX)
**Iteracion:** 24
**Entrada:** mensajes 410 y 411 de la directora agnes-3-flash (RAMA 1)
**Reserva:** Log 2199 (pool global v3) | mensaje de canal 412

## 1. Encargo

410: riel nuevo -> trabajar M53 hacia SELLABLE (157/5/2): cerrar los `[ ]` propios, documentar los
`[?]` de dueno externo sin flipearlos, evidencia de suite + flip propuesto, e investigar G1-002
(Escape no abre el menu de pausa, hallazgo Nemotron). L98/L99 son deuda externa, no tocar.
411: nudge del mismo riel (idle 75 min) con la secuencia M53 primero -> M75-5-[ ] despues.

## 2. G1-002 - diagnostico medido (es un defecto REAL de M53)

Cuatro causas, todas medidas leyendo el codigo, no inferidas:

1. `scripts/ui/core/ui_manager.gd::_unhandled_input` atendia la accion `pausa` con UNA sola rama:
   `close_top()`. **Nunca abria nada.** La accion existe y esta bien bindeada (project.godot L283:
   `pausa` -> keycode 4194305 = KEY_ESCAPE), asi que el problema no era el binding.
2. En gameplay no hay capa visible -> el "tope" calculado caia en la ULTIMA capa REGISTRADA y
   OCULTA (tipicamente PauseLayer) y `close_top()` la DES-REGISTRABA de `_stack`. Consecuencia
   doble: Esc no abria el menu y, si algo lo abria despues, `_actualizar_pausa_mundo()` ya no la
   veia (itera `_stack`) -> el mundo NO se congelaba.
3. `scripts/player/player.gd::_physics_process` togleaba `Input.mouse_mode` en CADA Esc. Eso es
   exactamente lo que el jugador ve: `scenes/main_island.tscn:116` dice "Escape - Liberar mouse".
   Aun abriendo la pausa, ese toggle invertia el modo de raton justo despues (unhandled_input
   corre antes que physics_process) y dejaba el menu sin puntero.
4. `if _stack.is_empty(): return` cortaba el handler ANTES de la rama de pausa: sin capas montadas,
   Esc no podia abrir nada (lo destapo la propia suite nueva, ver bloque D).

## 3. Fix aplicado

- `UIManager._capa_visible()` (privada) + `hay_capa_visible()` (publica, la consume M11).
- `UIManager.abrir_pausa()`: resuelve PauseLayer, la RE-REGISTRA si una vuelta anterior la saco de
  la pila, la abre, fija `_current_modal_full` (`open()` no lo toca: solo `push_layer`) y llama
  `_actualizar_pausa_mundo()`.
- `_unhandled_input`: la accion `pausa` se atiende ANTES del guard de pila vacia. Capa visible ->
  `close_top()` (historico); sin capa visible -> `abrir_pausa()`.
- `PauseLayer`: `on_layer_opened()` libera el raton y guarda el modo previo en `_mouse_previo`;
  `on_layer_closed()` lo restaura (no captura a ciegas).
- `player.gd` (M11): el toggle de raton por Esc se salta si `hay_capa_visible()`. Cambio quirurgico
  y documentado: sin el, el fix de M53 quedaba anulado por el toggle de M11 un frame despues.
- `main_island.tscn`: la etiqueta decia "Escape - Liberar mouse" y "F - Hablar con NPC"; el InputMap
  declara `interactuar` en physical_keycode 69 (**E**). Corregido a
  "Escape - Pausa / Liberar mouse" y "E - Hablar con NPC".

## 4. L187 - prompts dinamicos por dispositivo (implementado)

El `DEVICE_MAP` por dispositivo YA existia en `action_prompt_overlay.gd`, pero era INALCANZABLE:
el diagnostico de 2026-10-12 (26 lineas, "sin mapeo por dispositivo") quedo STALE. Tres defectos
medidos:

1. Se consultaba el InputMap con la CLAVE DE PROMPT (`interact`) en vez de la ACCION REAL
   (`interactuar`) -> `action_get_events()` devolvia `[]` siempre. Y el fallback tampoco salvaba:
   `device_map.get(action, "?")` usaba la accion cruda, que NO es clave del mapa -> **"?"** siempre.
   El fallback estaba roto por partida doble.
2. Aun consultando bien, se tomaba `eventos[0]` sin mirar el dispositivo. El InputMap del proyecto
   declara UN solo evento por accion y es de TECLADO (verificado: `interactuar` = physical 69,
   `inventario` = 66, `pausa` = 4194305, los tres InputEventKey) -> con gamepad se veia
   "E"/"B"/"Escape".
3. `_on_device_changed` mapeaba solo `teclado`/`xbox`/`playstation`. `ControlInput` (M57) emite
   ademas `raton` y `generico` (control_input.gd L22-26); `"generico"` -el modo de Switch/Steam
   Deck/pad no reconocido- caia a `_` -> teclado. Se agrego `gamepad_generic` al DEVICE_MAP y
   `"raton"` se mapea explicito a keyboard. `_detect_device()` manda los pads no identificados a
   `gamepad_generic` (antes los mandaba a `gamepad_xbox`).

Cuarto defecto, encontrado al medir: las teclas se leian con `evento.keycode`, que en este InputMap
es **0** (todas las acciones usan `physical_keycode`): el prompt salia VACIO. Ahora cae a
`physical_keycode`.

## 5. Evidencia medida

Suite nueva `scripts/ui/test_m53_pausa_prompts.gd` (bloques A-G):

| corrida | checks | fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 35 | 0 | 0 | 0 |
| 2 | 35 | 0 | 0 | 0 |
| 3 | 35 | 0 | 0 | 0 |

- Piso `CHECKS_MINIMOS = 35` MEDIDO en verde (no estimado).
- Guardian de 3 capas probado EN ROJO, 2 modos:
  - aborto de RUNTIME al inicio del bloque D (via intermedio `Variant`, no parse error):
    `EXIT 1` + `[FAIL] el bloque D NO se ejecuto (posible SCRIPT ERROR)` +
    `[FAIL] solo 31 checks ejecutados (minimo 35)` + 3 fallos.
  - asercion falsa: `36 checks, 1 fallo`, `EXIT 1`.
  - sondas borradas en la misma invocacion; `git status` del directorio sin residuo de sondas;
    `sha256` del archivo identico antes y despues (`f7856ff0afebac6e`).
- Regresiones (8 suites de UI, TODAS EXIT 0 y 0 SCRIPT ERROR): test_m53_capas 14/0,
  test_ui_framework 0 fallos, test_layer_type_m53 0 fallos, test_m89_menus 48/0,
  test_m53_no_redundancia 7/0, test_m53_extremos 9/0, test_m53_lista_larga 7/0, test_m53_wcag 23/0.
- `--check-only` sobre los 4 .gd tocados: rc=0, 0 errores (medido con el exit del PROCESO, no del
  pipe: trampa 75).
- Carga de proyecto (`--quit`): 0 SCRIPT ERROR / 0 Parse Error tras el cambio de escena.

## 6. L210 (ratios 16:9 / 16:10) - MEDIDO Y NO SE CUMPLE

El proyecto usa `window/stretch/mode="canvas_items"` + `aspect="expand"` (project.godot L140-141).
Con `root.size` en 1920x1080 y 1680x1050, `get_visible_rect()` da **1152x648** (16:9) y
**1152x720** (16:10): el lienzo de UI crece en alto, no en ancho.

Instanciando las 10 capas de `scripts/ui/layers/` y midiendo el mayor hijo Control, TRES desbordan
el lienzo 16:9:

| capa | medida | desborde |
|---|---|---|
| inventory_layer | 1469x588 | +317 px de ancho |
| diary_layer | 874x765 | +117 px de alto |
| settings_audio_layer | 508x689 | +41 px de alto |

Las otras 7 caben: confirm_popup 356x129, credits 715x186, dialog 139x234, equipment 516x547,
loading 400x179, menus 320x346, pause 328x364.

El item queda `[ ]`: el desborde es de LAYOUT de esas 3 pantallas (falta scroll o reflow), no de
M53-core. La tabla de arriba es la linea base para re-medir tras el fix.

## 7. Hallazgos cruzados (NO tocados)

- **M57 / InputMap:** `interactuar` y `equipamiento` comparten `physical_keycode = 69` (**E**).
  El prompt de "interactuar" muestra E, la misma tecla que abre el panel de equipamiento. Es de M57
  (dueno del InputMap). Medido, no corregido.
- **`test_ui_i18n_m53.gd`** sigue colgando (EXIT 124) por `get_locale_actual()` inexistente: suite
  muerta, no cuenta como evidencia (ya reportado en la vuelta anterior).
- Fila 53 de `CHECKLIST-GLOBAL.md`: no se toco (limite duro).

## 8. Marcas

`05-Checklist.md` de M53: **157 [x] / 5 [ ] / 2 [?] = 164** (SIN CAMBIOS: no aplique flips).
Se anadieron 7 notas de evidencia (L137, L178, L187, L210, L221, L224, L229). Invariante de bytes
verificado tras escribir: `bom=False`, `crlf=341`, `lf_solo=0`, `fffd=0`.

**Flips PROPUESTOS (los aplica la directora):**
- **L187** "Prompts dinamicos por dispositivo" `[ ]` -> `[x]`: implementado y verificado (bloques F y
  G de la suite). Cita: `04-Codigo.md` seccion "Iter. 24".

**Items que quedan `[ ]` con causa medida:** L210 (desborde de layout en 3 pantallas, tabla del
punto 6), L178 (falta el PRODUCTOR de audio: M91), L221 (requiere Profiler de M61), L229 (dueno M88,
que ya tiene el subsetter).

**`[?]` honestos, sin flipear:** L137 (SFX por canal de audio separado, M91/FeedbackDirector) y
L224 (minimapa: `_draw()` procedural, no hay textura cache que verificar).

## 9. Numeracion e higiene

- Log 2199: pool global v3 (`reservar_log.py --reservar`). ASCII puro verificado por bytes
  (`[^ -~]` = 0), CRLF, sin BOM.
- Canal: pool con cabeza 410 y archivos 410/411 ya escritos por la directora (patron conocido: deja
  su numero en mi pool). `ultimo` = 409 -> `ultimo+1` = 410 == cabeza, sin discrepancia que obligue a
  abortar; como 410 y 411 estan USADOS, se tomo `max(archivos)+1` = **412**.
- 0 commits / 0 push. Worktree compartido: no se uso `git add -A` ni `--amend`.

## 10. Trampas de la vuelta

1. **El guard de "pila vacia" anulaba el fix que estaba escribiendo.** Mi primera version puso la
   rama de pausa DESPUES de `if _stack.is_empty(): return`; el bloque D de la suite lo cazo (Esc
   seguia sin abrir nada cuando la pausa era la unica capa registrada y habia salido de la pila).
   Sin ese bloque, el fix habria quedado verde y roto en el caso borde.
2. **Un diagnostico de auditoria puede quedar STALE y hacerte "arreglar" algo que ya existe.**
   La nota de 2026-10-12 describia un archivo de 26 lineas sin mapeo por dispositivo; el archivo
   real tiene 210 lineas y un DEVICE_MAP completo. El defecto era otro (el mapa era inalcanzable).
   Medir el archivo antes de implementar lo que la nota pide.
3. **El fallback de un mapa se puede romper por dos lados a la vez** (clave equivocada en la
   consulta Y clave equivocada en el `get`): el sintoma es un "?" que parece "no implementado".
4. **Un `keycode` en 0 no es "sin tecla":** el proyecto bindea por `physical_keycode`. Un prompt
   vacio es el sintoma, no un dato faltante.
5. **`EXIT=$?` despues de un pipe mide el pipe** (trampa 75, reincidente): la primera medicion de
   `--check-only` dio EXIT 0 leyendo el exit de `head`. Re-medido con redireccion a archivo y `rc`
   del proceso.
