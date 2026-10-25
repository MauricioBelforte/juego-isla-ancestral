# Log 2183 - M53 UI/UX: tanda 2 de L159 (5 literales) y un punto ciego del propio auditor

**Modulo:** 53-UI-UX
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-25 02:52
**Rama:** RAMA 2 (sin mensaje nuevo del director; se ejecuta la orden pendiente del 396 y el GO vigente del 395)
**Tarea de origen:** BACKLOG-11 D8, bloque `01-Fundamentos-Del-Proyecto` (medido y agotado en cubo-A) + punto 4 del mensaje 395 (GO scopeado de los 27 literales token-dup)

---

## 1. Lo que habia pedido el director

| Mensaje | Orden | Estado |
|---|---|---|
| 395 (punto 3) | `pantalla_carga` a 120, `ui_root` queda en 100 | CERRADO en la vuelta anterior (Log 2181) |
| 395 (punto 4) | GO scopeado: reemplazo mecanico SOLO por `ThemeUx.COLOR_*`, los 27 token-dup, en tandas por modulo, reportando cada tanda | Tanda 1 cerrada en 2181 (9 sitios); **tanda 2 cerrada en este log (5 sitios)** |
| 396 | "Toma el SIGUIENTE bloque del D8 (produce-first cubo-A). Si el D8 se agoto o el siguiente bloque depende de un dueno externo, avisame y te asigno otro riel" | **Medido: agotado en cubo-A. Se reporta y se pide riel** (seccion 3) |

---

## 2. Premisa medida antes de tocar nada

Medido con el binario real y con el auditor, no de memoria:

| Medicion | Valor |
|---|---|
| `.gd` en `scripts/` | 1216 |
| `literales_duplican_token` | 18 |
| `archivos_con_token` | 21 |
| `archivos_con_literal` | 92 |
| `literales_fuera_paleta` | 280 |
| `violaciones_duras` | 20 |
| `--selftest` del auditor | 18 checks / 0 fallos / piso 18 |

Los 18 duplicados, por archivo: `player.gd` 5, `w_reloj.gd` 3, `fast_travel_effect.gd` 2, y 1 en `crafting_ui`, `dialogue_ui`, `main_island`, `map_canvas`, `shop_ui`, `pantalla_carga`, `block_catalog`, `minimap_widget`.

La tanda 2 toma **solo** los tres modulos libres propuestos en el reporte 397: `clock/` (3), `shops/` (1), `crafting/` (1) = 5 sitios. Quedan afuera a proposito `dialogue_ui.gd` (M21, NO TOCAR), `pantalla_carga.gd` (M63, NO TOCAR) y `minimap_widget.gd` (su literal NO es igual al token, dist 0.03: unificarlo es decision de diseno, y el archivo lo reclama M54).

---

## 3. Hallazgo que define la vuelta: el cubo-A de mi bloque D8 esta agotado

El 396 manda tomar el bloque siguiente del D8. Antes de elegir, medi los siete bloques que quedan en `BACKLOG-11-PAQUETE-D8-DETALLE.md`:

| Bloque | Items `[ ]` en el D8 | Ultima escritura de su `plan-actual` | Dueno medido | Veredicto |
|---|---|---|---|---|
| 01-Fundamentos-Del-Proyecto | 126 | 2026-10-24 22:18 | **DeepSeek-V4.1-Flash (yo)** | **es mio: se toma** |
| 75-Postgame | 101 | 2026-10-24 23:03 | glm-5.3-flash | NO TOCAR |
| 67-Vehiculos | 93 | 2026-10-25 00:45 | G-5.3-Flash-Agente (activo hace 2 h) | ajeno |
| 48-Animacion | 78 | 2026-10-25 01:30 | step-5-kilocode / agnes | NO TOCAR |
| 28-Viajes | 77 | 2026-10-25 02:39 | glm-5.3-flash (activo hace 13 min) | ajeno |
| 17-Construccion | 48 | 2026-10-24 20:21 | minimax-m3-1-flash (P3 en curso) | ajeno |
| 76-Multijugador | 1 | 2026-10-23 18:31 | Step-5-WorkBuddy (129/130) | ajeno |

De los siete, el unico libre y mio es **01-Fundamentos-Del-Proyecto**. Se tomo ese.

**Y ahi aparece el problema, medido.** El bloque 01 tiene hoy **152 items, 122 `[x]` y 30 `[ ]`** (contado por prefijo `^\s*- \[([ x?>])\]`). Cruzando esos 30 con la etiqueta de cubo que el propio BACKLOG-11 les asigna:

| Cubo | Items | Que manda el D8 |
|---|---|---|
| A-FORMULA / A-FORMULA-DOC | **2** (M29 Reloj en Tiempo Real, M43 ASMR y Feedback) | producir spec o formula |
| C-PIPELINE | 2 (M03 Game Engine, M28 Tiempo y Calendario) | listar para el director |
| B-EDITOR/ARTE | **26** | "dejar `[ ]` honesto; listar" |

Y los 2 del cubo A **dependen de su propio modulo**, no de mi:

| Item de M01 | Modulo | Estado de su checklist | Que lo bloquea |
|---|---|---|---|
| M29 Reloj en Tiempo Real | 30-Reloj-En-Tiempo-Real | 119/120, **1 `[?]`** | icono de estacion: requiere assets de M45/M46 (fase arte) |
| M43 ASMR y Feedback | 44-ASMR-Y-Feedback | 107/113, **6 `[?]`** | las 6 son dependencias externas (M45, M31, M13/M17, M114) |

Conclusion medida: **el cubo-A del bloque 01-Fundamentos se agota con 2 items y los dos estan bloqueados por modulos que no son mios**. No hay bloque D8 con cubo-A libre. Se reporta al director y se pide riel (seccion 11), como el propio 396 autoriza.

No se invento trabajo en el bloque agotado: los 26 de cubo B y los 2 de cubo C tienen como accion asignada "listar", y esa lista ya existe y esta medida en `09-Clasificacion-Pendientes.md` (iter. 9) y `10-Clasificacion-Dependencias.md` (iter. 10/11), con las cinco categorias de bloqueo.

---

## 4. Lo entregado: tanda 2 de L159 (5 sitios)

| Archivo | Linea | Antes | Despues | Token | Dist |
|---|---|---|---|---|---|
| `clock/w_reloj.gd` | 117 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `clock/w_reloj.gd` | 124 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `clock/w_reloj.gd` | 141 | `Color(0.95, 0.93, 0.86)` | `ThemeUxRef.COLOR_TEXT_DARK` | `COLOR_TEXT_DARK` | 0.017 |
| `shops/shop_ui.gd` | 59 | `Color(0.96, 0.92, 0.86, 0.98)` | `Color(ThemeUx.COLOR_TEXT_DARK, 0.98)` | `COLOR_TEXT_DARK` | 0.022 |
| `crafting/crafting_ui.gd` | 58 | `Color(0.96, 0.92, 0.86, 0.98)` | `Color(ThemeUx.COLOR_TEXT_DARK, 0.98)` | `COLOR_TEXT_DARK` | 0.022 |

**El alpha se pasa explicito donde el literal lo tenia.** `COLOR_TEXT_DARK` vale `Color(0.94, 0.92, 0.85)`, o sea alpha 1.0; los dos paneles usaban **0.98**. El token pelado habria cambiado la transparencia de los dos paneles, asi que va `Color(token, 0.98)`. En los tres sitios del reloj el literal era opaco y el token tambien: ahi va el token directo, sin envoltorio.

---

## 5. E-30: por que `ThemeUxRef` y no `ThemeUx` en el reloj

`w_reloj.gd` no usaba ningun simbolo del tema, y **es precargado por suites `--script` headless**:

- `scripts/clock/caso_reloj_tests.gd` L18: `const WRELOJ := preload("res://scripts/clock/w_reloj.gd")`
- `scripts/clock/test_reloj_localizacion.gd` L54: `load("res://scripts/clock/w_reloj.gd").new()`

En modo `--script` los `class_name` globales no resuelven (E-30, GUIA-GODOT/06). Si se usaba `ThemeUx.COLOR_TEXT_DARK` a secas, el riesgo era un SCRIPT ERROR en esas dos suites. Se agrego:

```gdscript
const ThemeUxRef := preload("res://scripts/ui/theme/theme_ux.gd")
```

que es el mismo patron que ya usa `scripts/ui/feedback_accion_m53.gd` L27. Los otros dos archivos (`shop_ui.gd`, `crafting_ui.gd`) ya referenciaban `ThemeUx` de forma global y no se les cambio el estilo.

**Verificado en runtime, no en sintaxis:** las dos suites del reloj corrieron con el binario real y dieron `SCRIPT ERROR: 0`. Si el preload no hubiera resuelto, el error habria aparecido ahi.

---

## 6. Punto ciego del auditor, encontrado al medir

Despues de la tanda, `archivos_con_token` subio **21 -> 23**, pero habia **tres** archivos nuevos con token. La diferencia delata un defecto de conteo.

Causa: el auditor marcaba "archivo con token" con `re.search(r"ThemeUx\.COLOR_[A-Z0-9_]+", txt)`. Esa forma no matchea el patron con alias, porque en `ThemeUxRef.COLOR_TEXT_DARK` el caracter que sigue a `ThemeUx` es `R`, no un punto. Consecuencia: un **subconteo preexistente** de 1 archivo (`feedback_accion_m53.gd`, que ya usaba el alias desde la vuelta anterior).

Corregido a `(?:ThemeUx|ThemeUxRef)\.COLOR_[A-Z0-9_]+` y **cubierto con fixture**, porque un arreglo sin test vuelve a romperse:

- corpus sintetico limpio: se agrego `reloj_alias.gd` (token por preload con alias).
- check nuevo: `archivos_con_token == 2` en ese corpus (uno por `ThemeUx.`, uno por `ThemeUxRef.`).
- piso de checks **18 -> 19, MEDIDO** en verde (no estimado), `--selftest` **19/0 x3**, exit real 0 en las tres.

**Prueba EN ROJO** (`sonda_alias.py`, descartable, en `.workbuddy-ai/tmp/`):

| Paso | Resultado |
|---|---|
| sha256 antes | `e4e659c3f2c865766412237acaea376870c40a892b4f03b80c1a679d85e59711` |
| control en verde | `19 checks, 0 fallo(s)`, EXIT 0 |
| inyeccion: se revierte el regex a la forma vieja | `19 checks, 1 fallo(s)`, **EXIT 1**, linea: "cuenta el token por class_name Y por preload con alias (medido=1)" |
| restauracion de bytes | sha256 **identico**, `bytes identicos: True` |
| control final | `19 checks, 0 fallo(s)`, EXIT 0 |

La sonda escribe en el repo, asi que lleva **reintentos** (12 x 0.4 s) y **control post-restauracion por sha256**, que es la leccion del `Errno 22` de la vuelta anterior.

---

## 7. Medido antes -> despues

| Metrica | Antes | Despues | Delta |
|---|---|---|---|
| `.gd` escaneados | 1216 | 1216 | 0 |
| `literales_duplican_token` | 18 | **13** | **-5** |
| `archivos_con_token` | 21 | **25** | +4 (+3 de la tanda, +1 que el subconteo ocultaba) |
| `archivos_con_literal` | 92 | 92 | 0 |
| `literales_fuera_paleta` | 280 | 280 | 0 (fuera de alcance a proposito) |
| `violaciones_duras` | 20 | **15** | **-5** |
| colisiones de capa | 0 | 0 | 0 |
| `orden_carga.layer` | 120 | 120 | 0 |

Las 15 duras = los 13 literales restantes + las 2 de L138 (`colocacion` y `compra` sin feedback, preexistentes). El delta es exactamente el tamano de la tanda, que es la unica forma de saber que no se movio nada mas.

**Los 13 que quedan:**

| Archivo | Sitios | Modulo / nota |
|---|---|---|
| `player/player.gd` | 5 | M11, el bloque mas grande |
| `fasttravel/fast_travel_effect.gd` | 2 | M68 |
| `dialogos/ui/dialogue_ui.gd` | 1 | M21, NO TOCAR |
| `main_island.gd` | 1 | escena raiz |
| `mapa/map_canvas.gd` | 1 | M54 |
| `stream/pantalla_carga.gd` | 1 | M63, NO TOCAR |
| `world/block_catalog.gd` | 1 | M08 |
| `ui/widgets/minimap_widget.gd` | 1 | M54, literal NO igual al token |

---

## 8. Regresion ejecutada con binario real

Godot `4.7.2.stable.official.ed1daf0bf`, `--headless --path game/isla-ancestral`.

| Suite | Resultado | SCRIPT ERROR |
|---|---|---|
| `--check-only` clock/w_reloj.gd | EXIT 0, 0 errores | 0 |
| `--check-only` shops/shop_ui.gd | EXIT 0, 0 errores | 0 |
| `--check-only` crafting/crafting_ui.gd | EXIT 0, 0 errores | 0 |
| `clock/test_reloj_localizacion.gd` | 6 checks, 0 fallos, EXIT 0 | 0 |
| `crafting/qa_m16_ui_cerrada.gd` | RESULTADO=OK, EXIT 0 | 0 |
| `crafting/qa_m16_panel_mejora.gd` | RESULTADO=OK, EXIT 0 | 0 |
| `ui/test_m53_capas.gd` | 14 checks, 0 fallos, EXIT 0 | 0 |
| `ui/test_m53_no_redundancia.gd` | 7 checks, 0 fallos, EXIT 0 | 0 |
| `ui/test_m53_extremos.gd` | 9 checks, 0 fallos, EXIT 0 | 0 |
| `ui/test_m53_lista_larga.gd` | 7 checks, 0 fallos, EXIT 0 | 0 |
| `ui/test_feedback_accion_m53.gd` | 64 checks, 0 fallos, piso 64, EXIT 0 | 0 |
| `ui/test_m53_wcag.gd` | 17 checks, 0 fallos, EXIT 0 | 0 |

Total de las suites de UI: **118 checks, 0 fallos, 0 SCRIPT ERROR**.

---

## 9. Rojo ajeno que aparece en la regresion y NO es de esta tanda

`clock/caso_reloj_tests.gd` sale **29 checks, 1 fallo, EXIT 1**. El fallo es:

```
[VIOLA] res://scripts/rendimiento/memoria/sesion_m62_30min.gd -> Time.get_datetime_string_from_system
[VIOLA] ... (5 archivos mas de scripts/rendimiento/memoria/)
[FALLO] C56/E89/E90: 0 lecturas de reloj-SO en gameplay (1216 archivos escaneados)
```

Prueba de que es preexistente y ajeno:

1. Los 6 archivos que lo disparan son de **M62** (`sesion_m62_*.gd`, `test_m62_chunks_presupuesto.gd`) y estan en HEAD desde **`2dfed83`, 2026-10-19**; el scan se toco por ultima vez el **2026-10-16** (`4582b67`). O sea: el scan es anterior a los archivos.
2. Los 3 archivos que toque tienen **0** ocurrencias de las APIs del scan (`grep -c "Time.get_\|OS.get_"` = 0 en los tres).
3. El scan es textual sobre contenido de archivos: quitar literales de color no puede cambiar su resultado.

Causa tecnica: la whitelist del scan tiene `res://scripts/performance/` pero los archivos viven en `res://scripts/rendimiento/`. **No se toco**: agregar la entrada es decision de M30 (dueno del scan) y cambiar los timestamps es de M62. Queda reportado.

---

## 10. Estado del checklist y de la documentacion

- `DOCUMENTACION/53-UI-UX/plan-actual/03-Diseno.md`: seccion **8.10 nueva** (+5537 B, de 32957 a 38494). LF puro, sin BOM, 122 secuencias de mojibake preexistentes **sin tocar** (no se agrego ninguna).
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md`: nota de evidencia agregada a la linea L159, **0 flips**. Medido despues: **148 `[x]` / 14 `[ ]` / 1 `[->]` / 2 `[?]` = 165**, coherente con la linea `**Totales:**` del archivo. Los flips los aplica el director.
- `scripts/ui/auditar_ui_m53.py`: regex de conteo corregido + fixture + check nuevo, piso 19 medido, sonda roja valida.

---

## 11. Limites de esta vuelta

- **0 commits, 0 push, 0 flips, 0 auto-sellos 21.8.** Nada sale del worktree sin autorizacion.
- **No se toco** `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, ningun `05-Checklist` ajeno, ni los modulos de la lista NO TOCAR.
- **No se toco** el rojo de `caso_reloj_tests` (M62/M30): se mide, se prueba que es ajeno y se reporta.
- **`minimap_widget.gd` sigue afuera** hasta que el director de GO explicito y confirme dueno.
- **Verificacion visual M154 pendiente** del orden de capa 120/100 (declarada pendiente, no verificada).

## 12. Proximo

1. **Pedido al director: otro riel.** El D8 no tiene bloque con cubo-A libre (seccion 3, medido). Los 26 items de cubo B del bloque 01 tienen como accion "listar" y esa lista ya existe y esta medida.
2. **Pedido: GO para la tanda 3 de L159.** Candidato natural `player/player.gd` (5 sitios, M11). Los otros 8 quedan fuera: 2 en NO TOCAR, 1 pendiente de GO (`minimap_widget`), 5 de un sitio cada uno.
3. **Pedido: commit** de los paths de esta vuelta y de la anterior (ver reporte).
4. **Derivacion sugerida:** el rojo C56 de `caso_reloj_tests` (whitelist `scripts/rendimiento/` vs `scripts/performance/`) a M30, y los timestamps a M62.
