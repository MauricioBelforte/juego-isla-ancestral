# Log 2193 - M53 UI/UX: L159 flip-candidato (coherencia visual de los 5 widgets del HUD)

**Agente:** DeepSeek-V4.1-Flash
**Modulo:** M53-UI/UX
**Fecha:** 2026-10-25
**Origen:** RAMA 1 - mensajes 402 y 403 de la directora agnes-3-flash (ack de mi 401 + nudge por 93 min idle)
**Commits propios:** 0. El Cron C ya commiteo los 5 widgets en `a756e3a` (verificado con `git show HEAD:<ruta>`, no con el worktree).

## 1. Pedido

- Msg 402 item 2: "L159 coherencia visual: con token-dup resuelto, L159 pasa a ser flip-candidato [x] (si queda evidencia de coherencia). Lo mides y me propones el flip con cita".
- Msg 403: seguir M53 si quedan `[ ]` propios; los 6 token-dup restantes NO se tocan (3 dueno externo + 3 decision de diseno).

## 2. Defecto medido (antes de escribir la cifra)

Los 5 widgets del HUD declaraban el color de texto con el literal de la paleta CLARA anterior a D102:

```
const COLOR_TEXT := Color(0.25, 0.18, 0.12)
```

Ese literal se aplica como `add_theme_color_override("font_color", ...)` sobre el panel noche del tema
(`COLOR_BG_ARENA = Color(0.14, 0.16, 0.24, 0.94)`). Contraste WCAG medido:

| Color de texto | vs panel noche | AA normal (4.5) | AAA (7.0) |
|---|---|---|---|
| literal `(0.25,0.18,0.12)` | **1.12:1** | NO | NO |
| `COLOR_TEXT_DARK` `(0.94,0.92,0.85)` | **12.04:1** | SI | SI |

1.12:1 es texto practicamente invisible: el widget dibujaba su fondo noche y escribia marron oscuro encima.
El test WCAG no lo veia porque solo media las constantes de `theme_ux.gd` y las capas de servicio, nunca
las constantes propias de los widgets.

## 3. Fix aplicado

Patron `ThemeUxRef` (preload explicito), NO `ThemeUx` global: estos scripts se precargan desde suites
`--script` y los `class_name` globales no resuelven ahi (E-30, mismo precedente que `clock/w_reloj.gd` L117,
Log 2182).

```
const ThemeUxRef := preload("res://scripts/ui/theme/theme_ux.gd")
const COLOR_TEXT := ThemeUxRef.COLOR_TEXT_DARK
```

Archivos (5):

| Archivo | Cambio |
|---|---|
| `scripts/ui/widgets/clock_widget.gd` | `COLOR_TEXT` literal -> `ThemeUxRef.COLOR_TEXT_DARK` |
| `scripts/ui/widgets/season_widget.gd` | idem |
| `scripts/ui/widgets/resource_counter.gd` | idem |
| `scripts/ui/widgets/interact_prompt.gd` | idem (su `COLOR_BG` ya usaba `ThemeUx.COLOR_BG_ARENA`) |
| `scripts/ui/widgets/action_prompt_overlay.gd` | idem (su `COLOR_KEY_BG` ya usaba token) |

`--check-only` de los 5: EXIT 0, 0 errores de parseo/compilacion.

## 4. Evidencia de coherencia (medida, no estimada)

Auditor `scripts/ui/auditar_ui_m53.py`, acotado a `scripts/ui` (72 .gd):

| Metrica | Antes | Despues | Delta |
|---|---|---|---|
| literales fuera de paleta | 54 | **49** | **-5** (exactamente los 5 COLOR_TEXT) |
| literales que duplican token | 1 | 1 | 0 |
| literales no-producto | 11 | 11 | 0 |
| archivos con token | 16 | **19** | +3 |
| archivos con literal | 21 | 20 | -1 |

Nota: `interact_prompt` y `action_prompt_overlay` ya contaban como "con token" por su color de fondo;
por eso el delta de archivos con token es +3 y no +5. El delta de literales fuera de paleta (-5) es el
que mide el fix, y coincide exacto con los 5 sitios tocados.

## 5. Red de seguridad nueva: bloque `_test_widgets_hud()`

`scripts/ui/test_m53_wcag.gd`: 17 -> **23 checks**. El bloque tiene 2 capas:

1. Para cada uno de los 5 widgets: lee `COLOR_TEXT` del `get_script_constant_map()` y exige ratio >= 4.5
   contra `COLOR_BG_ARENA` (5 checks). Una constante correcta que no se aplica tambien es un defecto.
2. Runtime: instancia `clock_widget`, lee el `font_color` REAL del label y exige AA (1 check).

`CHECKS_MINIMOS` = **23 MEDIDO en verde** (no estimado).

## 6. Dos defectos del propio guardian, encontrados midiendo y corregidos

### 6.a La capa de nombres por bloque estaba CIEGA

`_fin("widgets")` vivia en `_run()`, DESPUES de la llamada al bloque. En Godot 4 un `SCRIPT ERROR`
aborta **solo la funcion donde ocurre**; el llamador **RETOMA**. Por lo tanto `_fin()` se ejecutaba igual
y el bloque abortado quedaba marcado como "visto": la capa que debe NOMBRAR el bloque faltante no podia
nombrar nada.

Medido en rojo antes del arreglo (sonda B): el reporte decia `18 checks, 1 fallo` y **no nombraba
'widgets'**; solo lo salvaba el piso. Fix: `_fin(<bloque>)` al **final del cuerpo** de cada bloque.

### 6.b El mensaje del piso publicaba un numero inflado

`_summary()` hacia `_checks += 1` antes de imprimir, asi que informaba "solo 18 checks ejecutados"
cuando en realidad habian corrido 17. Fix: informar el valor **previo** al incremento (`var corridos`).

## 7. Sonda EN ROJO (guardian probado, no asumido)

Script `.workbuddy-ai/tmp/sonda_l159.py`, restauracion byte-exacta por `sha256` despues de cada mutacion.

| Caso | Mutacion | Esperado | Medido |
|---|---|---|---|
| A | reinyectar el literal en `season_widget.gd` | EXIT 1, 1 fallo, nombra el widget, ratio 1.12:1 | EXIT 1 / 23 checks 1 fallo / nombra `season_widget` / `1.12:1` |
| B | aborto de RUNTIME al inicio de `_test_widgets_hud()` (asignacion `Array` -> `Dictionary` con valor dinamico) | EXIT 1, nombra el bloque + dispara piso | EXIT 1 / 19 checks 2 fallos / `bloque 'widgets' NO se ejecuto` + piso |
| C | control sin mutar | EXIT 0, 23/0 | EXIT 0 / 23 checks 0 fallos |

Resultado final: **0 fallos de sonda**. La primera corrida de la sonda dio 2 fallos en el caso B: eso es
lo que descubrio el defecto 6.a (la sonda estaba bien escrita; el guardian estaba mal).

La inyeccion usa valores DINAMICOS (no literales) para que sea un error de RUNTIME y no un PARSE ERROR
estatico: un literal mal tipado no compila el script entero y no prueba el guardian.

## 8. Regresion

| Suite | Resultado |
|---|---|
| `test_m53_wcag.gd` x3 | 23 checks / 0 fallos / EXIT 0 |
| `test_m53_capas.gd` | 14 / 0 / EXIT 0 |
| `test_m53_extremos.gd` | 9 / 0 / EXIT 0 |
| `test_m53_lista_larga.gd` | 7 / 0 / EXIT 0 |
| `test_m53_no_redundancia.gd` | 7 / 0 / EXIT 0 |
| `test_ui_framework.gd` | EXIT 0, 0 SCRIPT ERROR |
| `test_ui_i18n_m53.gd` | **EXIT 124 (cuelga)** - defecto AJENO, ver 9 |

## 9. Hallazgo AJENO no tocado: la suite i18n de M53 cuelga

`scripts/ui/test_ui_i18n_m53.gd` L183 llama `loc.get_locale_actual()`. Ese metodo **no existe** en
`scripts/localizacion/localization_manager.gd` (API real: `get_texto`, `get_plural`, `set_idioma`,
`idiomas_disponibles`, `cantidad_cadenas`, `set_cadena`). `grep -rn get_locale_actual` en los 1.431 .gd
del proyecto devuelve **un solo sitio: la llamada de la suite**.

Consecuencia: `SCRIPT ERROR` -> `_run()` aborta -> `_resumen()` nunca corre -> el proceso **no sale** y
hay que matarlo (medido: EXIT 124 con `timeout 240`). No publica "0 fallos": cuelga. Es el peor caso de
la familia falso-verde, porque un runner de CI que no impone timeout se queda esperando.

El archivo NO esta modificado por mi (`git diff HEAD -- ...test_ui_i18n_m53.gd` vacio) y el literal que
yo cambie no tiene relacion causal con una API de locale. **No lo arreglo sin orden** (la suite es de M53
pero el drift de API es de M87/M88). Consecuencia honesta: **cualquier sello que se haya apoyado en esta
suite no tiene evidencia medida**.

## 10. Propuesta de flip (NO aplicado: los aplica la directora)

**L159 "Verificar coherencia visual entre todas las capas (un solo lenguaje)" -> `[x]`.**

Cita propuesta para el 05-Checklist (tanda 4, 2026-10-25, Log 2193):

> TANDA 4 2026-10-25 (DeepSeek-V4.1-Flash, Log 2193): los 5 widgets del HUD (`clock_widget`,
> `season_widget`, `resource_counter`, `interact_prompt`, `action_prompt_overlay`) escribian el texto con
> el literal de la paleta CLARA pre-D102 `Color(0.25,0.18,0.12)` sobre el panel noche del tema:
> contraste medido **1.12:1** (por debajo de AA 4.5 y de 3.0). Pasados a `ThemeUxRef.COLOR_TEXT_DARK`
> (patron preload por E-30): **12.04:1 AAA**. Auditor acotado a `scripts/ui`: literales fuera de paleta
> **54 -> 49** (delta -5 = los 5 sitios), archivos con token 16 -> 19. Red nueva: bloque
> `_test_widgets_hud()` en `test_m53_wcag.gd` (17 -> **23 checks**, piso 23 MEDIDO en verde) que verifica
> la constante Y que llega al label en runtime. Guardian probado EN ROJO: defecto reinyectado -> EXIT 1
> nombrando `season_widget` a 1.12:1; aborto de runtime -> nombra el bloque `widgets` + dispara el piso;
> control 23/0. **Dos defectos del guardian corregidos**: `_fin()` vivia en `_run()` y un SCRIPT ERROR
> (que solo aborta la funcion, no el llamador) lo marcaba igual como visto -> capa de nombres ciega;
> y el mensaje del piso publicaba el contador ya incrementado.

Alcance de lo que este flip NO cubre (para que la marca sea honesta): sigue pendiente la alineacion de
la paleta UI con la paleta de marca M128 (dueno M45/M46) y la verificacion visual por M154. El flip
cubre la coherencia MEDIBLE por contraste y fuente unica de color, no la comparacion visual humana.

## 11. Pendientes de M53 tras esta tanda

`05-Checklist.md` de M53: **157 [x] / 5 [ ] / 1 [->] / 0 [?] = 163** (el conteo previo de la fila
GLOBAL dice 144/165: esa fila la sincroniza la directora, no yo).

Los 5 `[ ]`:

1. L178 toast visual de eventos auditivos [M]
2. L187 prompts dinamicos por dispositivo [M] (drift documentado: `action_prompt_overlay.gd` no tiene
   mapeo por dispositivo)
3. L210 ratios 16:9 y 16:10 en todas las pantallas [M]
4. L221 canvas merge por capa para minimizar draw calls [M] (requiere medicion con Profiler M61)
5. L229 font subsetting por idioma [M] (dueno M88)

Y el `[->]` L138 (feedback visual de colocacion/cosecha/compra, Tween 120 ms).

## 12. Limites respetados

0 commits, 0 push, 0 flips aplicados, 0 auto-sellos 21.8, 0 ediciones a `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot` ni a ningun `05-Checklist` de otro modulo.
