# Log 2301 - M110 Debug Menu - consola con filtros, overlay FPS y aviso de desarrollo

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy AI
**Fecha:** 2026-11-01 23:33 (GMT-3) / 2026-11-02 02:33 UTC
**Modulo:** M110-Debug-Menu
**Tanda:** b2 (item 17 de la COLA ACTIVA: "M110 b2: continuar")
**Canal:** 499 (reporte)
**Rama de metodologia:** RAMA 2 (tracker en 492, sin mensajes nuevos del director)

---

## 1. Punto de partida (medido antes de escribir una sola linea)

- Tracker `.ultima-revision-deepseek.txt` = **492**. El canal tiene como maximo el **498**
  (mis propios reportes 493-498). **No hay mensaje del director con NN > 492** -> RAMA 2.
- `BACKLOG-MASTER.md`: **0 items `[ ]`** en la COLA ACTIVA (lineas 1-425) y **5 `[->]`**
  (items 3, 17, 35, 36, 102). Es la **14.a vuelta** que reporto la cola sin `[ ]`.
- De los 5 `[->]`: el 3 espera decision de semantica de flips, el 35 esta entregado con
  escalados, el 36 y el 38 tienen **premisa vencida** (M90 mide **249/0/0**), y el 102
  no cierra el gate de M61 por depender de un contexto de render real. Se toma el **17**.
- **Hallazgo sobre el titulo del item 17**: dice "integracion con telemetria M105", pero
  `grep -rn "M105\|telemetr" DOCUMENTACION/110-Debug-Menu/plan-actual/*.md` = **0**.
  El titulo no tiene respaldo en los documentos del modulo; el trabajo real del item es
  "continuar M110", y eso es lo que se hizo.
- `05-Checklist.md` de M110: **179 `[x]` / 46 `[ ]` / 0 `[?]` = 225**. Los 46 pendientes
  se clasificaron por linea: 13 cubiertos por la tanda del 2026-11-01 (Log 2300),
  15 son flips stale ya implementados, 9 son de esta tanda y **9 quedan** (L114, L139,
  L142, L176, L233, L275, L286, L287, L288).
- Suites M110 antes de tocar: `test_panels_m110` **53/0**, `test_m110_ui` **17/0**,
  `test_m110_ui2` **14/0**, `test_m110_ui3` **17/0**, `test_debug_m110` **18/0**,
  todas EXIT 0 y **0 SCRIPT ERROR**. 119 checks de piso.

## 2. Defectos medidos y corregidos (no eran items del checklist: los encontro la medicion)

### 2.1 La consola NUNCA recibia lineas vivas

`debug_console.gd:37` hacia:

```gdscript
if _debug_menu.has_signal("console_line_added"):
    _debug_menu.connect("console_line_added", _on_console_line)
```

**Medido:** `grep -n "^signal" debug_menu.gd` devuelve 3 senales (`toggle_visual_cambiado`,
`estacion_solicitada`, `clima_solicitado`) y **ninguna** se llama `console_line_added`.
El guard `has_signal()` daba siempre `false`, asi que el `connect` **nunca corria** y
`_on_console_line` era **codigo muerto**. Consecuencia: la consola mostraba el **snapshot**
de `console_get_lines()` al arrancar y despues **solo** lo que el usuario tecleaba; el log
del juego no aparecia en vivo.

Fix: suscribirse a `GameLogger.line_emitted(level: int, category: int, line: String)`,
que es la senal que el backend **si** usa (`debug_menu.gd:1323`). El handler declara
`(int, int, String)` exactamente: con un tipo equivocado Godot imprime
`Cannot convert argument 1 from int to String` y el handler no corre (defecto ya medido
en `debug_menu_ui.gd` el 2026-11-01).

### 2.2 La consola se usaba como CARTEL de pestana

`debug_menu_ui.gd:122-128` hacia `_console.set_text("[b]Panel: Jugador[/b]...")` en cada
cambio de pestana. La consola es el log in-game: escribir ahi **pisa** las lineas reales.
El `_refrescar_vista()` siguiente las recuperaba, pero el cartel volvia a imponerse en cada
cambio de pestana.

Fix: un `Label` placeholder aparte para las pestanas sin panel propio, y la consola visible
**solo** en la pestana `sistema` (que es donde sec G la ubica). El render de la consola pasa a
ser siempre el log real.

### 2.3 La UI nunca escribia la preferencia de filtros

sec N tiene `[x] Guardar filtros de consola` porque el **backend** persiste
`_filtros_consola` (en `set_filtros_consola()` + `_cargar_config()`). Pero **ningun widget**
llamaba a `set_filtros_consola()`: la preferencia se guardaba siempre con el default. Ahora
cada cambio en la barra de filtros empuja el estado al backend.

## 3. Implementacion

### 3.1 `scripts/debug/debug_console.gd` (3.223 B -> 13.104 B; 103 -> 379 lineas)

- **Barra de filtros** (`HBoxContainer` "Filtros") con los 4 widgets que pide el checklist:
  - `OptionButton` "FiltroNivel" (sec G L132 / sec H L147), indice 0 = "Todos" -> valor -1.
  - `OptionButton` "FiltroCategoria" (sec G L133 / sec H L148), indice 0 = "Todas" -> -1.
  - `LineEdit` "FiltroBusqueda" (sec G L134 / sec H L149), case-insensitive y con `strip_edges()`.
  - `CheckBox` "FiltroAutoScroll" (sec G L135), mueve `RichTextLabel.scroll_following`.
- **Nombres de nivel/categoria**: constantes `NIVELES` y `CATEGORIAS` con la **fuente citada**
  (`scripts/logging/logger.gd:36` y `:39`). La suite las **cruza** contra
  `get_script_constant_map()` del logger: si alguien agrega un nivel o una categoria, la
  suite se pone roja en vez de quedar desactualizada.
- **Entradas con metadato**: `_entradas: Array[Dictionary]` con `{nivel, categoria, linea}`.
  Una linea sin metadato (snapshot del backend, eco de comandos) lleva `-1/-1` y **no pasa**
  un filtro de nivel/categoria: no se le inventa un nivel.
- **Filtrado**: `_pasa()` + `_refrescar_vista()`; `lineas_visibles()` expone el resultado.
- **Persistencia**: `_sincronizar_backend()` llama `set_filtros_consola()`; al arrancar,
  `_restaurar_filtros()` lee `filtros_consola()` y reconstruye el estado de los widgets.
- **Contrato previo intacto**: `obtener_lineas()`, `tamano()`, `limpiar()`,
  `agregar_linea_publica()`, `set_text()`, `backend_conectado()` y el tope de 100 lineas
  siguen funcionando (las 3 suites heredadas que los usan dan verde sin cambios).
- Ganchos de test: `widgets_filtros()`, `filtros_ui()`, `aplicar_filtros()`,
  `texto_renderizado()`, `conectado_al_logger()`, `motivo_sin_vivas()`,
  `_inyectar_backend()`, `_inyectar_logger()`.

### 3.2 `scripts/debug/debug_menu_ui.gd` (6.857 B -> 10.724 B; 189 -> 296 lineas)

- `_placeholder: Label` ("Placeholder") para las pestanas sin panel propio; la consola deja
  de usarse como cartel.
- **Overlay de FPS** (sec O L263): `Label` "FpsOverlay" + `Timer` "TimerFps" con
  `wait_time = 0.5` (`FPS_INTERVALO`). `_actualizar_fps()` lee
  `Engine.get_frames_per_second()` y se muestra **solo** si `toggle_activo("fps")` del
  backend esta activo.
- **Aviso de desarrollo** (sec M L243): `Label` "AvisoDesarrollo" en la barra de titulo con
  "SOLO PARA DESARROLLO - no distribuir" y el estado real de `OS.is_debug_build()` en el
  tooltip.
- `_inyectar_menu()` para tests (el backend se inyecta antes de entrar al arbol).

## 4. Suite nueva `scripts/debug/test_consola_m110.gd` (16.204 B, 368 lineas)

`extends SceneTree`, **10 bloques A-J**, guardian de 3 capas:

1. `_fin(bloque)` al **final del cuerpo** de cada bloque (un `SCRIPT ERROR` aborta la
   funcion y el llamador RETOMA: un `_fin()` en el llamador seria ciego).
2. `CHECKS_MINIMOS := 55` **MEDIDO en verde** (primer corrida: 55 checks; el piso se fijo
   despues de medir, no antes).
3. `_summary()` en un `call_deferred` **separado** de `_run()`: si `_run()` aborta, el
   resumen corre igual y nombra los bloques faltantes (si no, el arbol se cuelga).

Cobertura por bloque:

| Bloque | Que ejercita | Checks |
|---|---|---|
| A | los 4 widgets existen + cruce de NIVELES/CATEGORIAS con el enum real del logger | 7 |
| B | filtro por nivel (incluye "linea sin metadato no pasa") | 4 |
| C | filtro por categoria + combinacion + reset | 4 |
| D | busqueda: minusculas, `strip_edges()`, sin coincidencias, vacia | 4 |
| E | auto-scroll contra `RichTextLabel.scroll_following` | 4 |
| F | **equivalencia con el filtro REAL del backend** (`aplicar_filtros_consola()`) en 6 combinaciones | 7 |
| G | persistencia: `set_filtros_consola()` recibe las 4 claves + restauracion al arrancar | 5 |
| H | lineas vivas: `GameLogger.line_emitted` -> consola -> filtro por el nivel recibido | 5 |
| I | overlay de FPS (visible/oculto por toggle, texto, `wait_time == 0.5`) + aviso dev | 8 |
| J | placeholder vs consola: en "jugador" cartel, en "sistema" consola con el log real | 7 |

**El bloque F es el que impide que las dos implementaciones deriven**: el widget filtra
localmente y el backend tiene su propio `aplicar_filtros_consola()`; la suite los corre
sobre los mismos 6 datos y exige identidad linea por linea.

**Resultado: 55 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR, x3 corridas consecutivas.**

## 5. Sondas EN ROJO (5/5), con restauracion byte-exacta por sha256

Cada sonda muta el archivo real, corre la suite, exige el fallo esperado y restaura
verificando sha256 (con reintentos: Windows puede dar `OSError 22` por lock del indexer).

| Sonda | Mutacion | Resultado medido |
|---|---|---|
| Control previo | ninguna | EXIT 0 / 55 checks / 0 fallos / 0 SCRIPT ERROR |
| P1 | `_pasa()` ignora el nivel (`if false and ...`) | **EXIT 1**, 55 checks, **6 fallos**, nombra `[FAIL] B1` y `[FAIL] B2` |
| P2 | `CHECKS_MINIMOS := 999` | **EXIT 1**, 55 checks, **1 fallo**, imprime "minimo 999" |
| P3 | aborto de RUNTIME al inicio del bloque D (`var _d: Dictionary = _boom`) | **EXIT 1**, **15 checks**, **8 fallos**: nombra D, E, F, G, H, I, J + el piso. **No se cuelga** |
| P4 | se quita el `connect` a `line_emitted` | **EXIT 1**, **3 fallos**: `[FAIL] H1`, `H3`, `H4` |
| P5 | se reinyecta el cartel en la consola (`set_text("Panel: ...")`) | **EXIT 1**, **1 fallo**: `[FAIL] J6` |
| Control final | ninguna | EXIT 0 / 55 checks / 0 fallos |

**P5 encontro un defecto en MI PROPIA suite.** La primera version del check J6 buscaba el
literal viejo `"Panel: Sistema"`; el defecto reinyectado escribe el **id** en minusculas
(`"Panel: sistema"`), asi que el check **pasaba en verde con el defecto vivo**. Se cambio
por una **afirmacion positiva**: el render tiene que contener la linea real que agrego la
suite **y** no contener `"panel:"` (case-insensitive). Re-medido: P5 -> EXIT 1, `[FAIL] J6`.
*Un check que busca el literal exacto del defecto no lo detecta si el literal varia; el
check positivo es el que discrimina.*

## 6. Regresion

**11 suites de M110**, todas EXIT 0 y **0 SCRIPT ERROR**:

```
test_consola_m110             55/0      test_debug_menu_config_m110    75/0
test_panels_m110              53/0      test_debug_menu_control_m110   75/0
test_m110_ui                  17/0      test_debug_menu_entorno_m110   61/0
test_m110_ui2                 14/0      test_debug_visualizer_real_m110 66/0
test_m110_ui3                 17/0      test_m110_iter_atria           27/0
test_debug_m110               18/0
```

**Total: 478 checks / 0 fallos / 11 suites / EXIT 0.** Antes de la tanda eran 119 checks
en 5 suites; las 6 restantes se sumaron al barrido para no heredar verdes sin medir.

## 7. Flips propuestos (NO aplicados: los aplica el director)

**9 nuevos, todos con artefacto en disco y ejercitados por ruta real:**

| Linea | Item | Evidencia |
|---|---|---|
| L132 | Consola: filtro por nivel | `_opt_nivel` + bloque B (4 checks) + P1 en rojo |
| L133 | Consola: filtro por categoria | `_opt_categoria` + bloque C (4 checks) |
| L134 | Consola: campo de busqueda | `_txt_busqueda` + bloque D (4 checks) |
| L135 | Consola: checkbox "Auto-scroll" | `_chk_autoscroll` + bloque E (4 checks) |
| L147 | (H) Filtro por nivel | mismo widget; bloque B |
| L148 | (H) Filtro por categoria | mismo widget; bloque C |
| L149 | (H) Busqueda de texto | mismo widget; bloque D |
| L263 | FPS overlay cada 0.5s | `FpsOverlay` + `TimerFps` (0.5) + bloque I |
| L243 | Advertencia "Solo para desarrollo" | `AvisoDesarrollo` + bloque I (I7/I8) |

**Correccion de mi reporte anterior (498):** propuse L243 y L263 como "flips stale ya
implementados". **Estaba mal**: los dos items decian literalmente "sin UI" y "sin overlay"
y **no habia artefacto**. Esta tanda los implementa de verdad, asi que el flip vale, pero
por esta razon y no por la que escribi. El conjunto stale real es de **15**, no 17.

Aritmetica medida del modulo (no de memoria):

```
179 [x] + 13 (tanda 2026-11-01) + 15 (stale reales) + 9 (esta tanda) = 216 [x]
46 [ ] - 13 - 15 - 9 = 9 [ ]   ->  216 / 9 / 0 = 225
```

Los **9 que quedan** son: L114 (M64), L139 (boton Guardar Configuracion), L142 y L176 y
L275 (refactor DiagnosticExporter), L233 (Input Map en Project Settings), L286, L287 y L288
(archivos del refactor).

## 8. Hallazgos NO tocados (ajenos o fuera de alcance)

1. **`test_m110_ui2.gd` y `test_m110_ui3.gd` tienen un piso que no falla.** Declaran
   `CHECKS_MINIMOS` (12 y 15) pero el resumen solo imprime
   `WARNING: solo %d checks (minimo %d)` **sin** `_fallos += 1`. Medido: una corrida
   recortada seguiria dando EXIT 0. Es el defecto que la trampa 122 describe; no lo toco
   porque son suites heredadas y el arreglo es de una linea que el director puede preferir
   aplicar junto con los flips.
2. **L288 pide `scripts/debug/panel_*.gd`, pero los paneles viven en
   `scripts/debug/panels/panel_*.gd`** (subcarpeta). El item no se puede cerrar con la ruta
   que declara: o se corrige la ruta en el checklist o se mueven los archivos. Decision del
   director (el checklist es ajeno).
3. **12 colisiones de numeracion de logs ajenas** (1290, 1468, 1547, 1559, 1585, 1645, 1698,
   1726, 1876, 1878, 1888, 2120): sin cambios, se reportan.
4. **Pool de numeracion del canal roto**: head **423** vs maximo real **498**. Sin tocar;
   el mensaje 499 se numera como `max + 1`.

## 9. Trampas de esta vuelta (para el skill)

1. **Un guard `has_signal("X")` sobre una senal que no existe es codigo muerto que se ve
   como robustez.** El `if` protege de un crash, pero el efecto es que la feature no
   funciona **nunca** y no hay error. Deteccion: `grep -n "^signal" <backend>` y comparar
   con el nombre que el guard consulta.
2. **Un check que busca el literal exacto del defecto no lo detecta si el literal varia.**
   `"Panel: Sistema"` (del codigo viejo) vs `"Panel: sistema"` (del defecto reinyectado):
   el check pasaba en verde. La sonda P5 lo encontro. La forma correcta es **afirmar lo
   positivo** (el render contiene el log real) ademas de lo negativo.
3. **Una suite puede estar verde en la primera corrida y ser correcta**: lo que lo prueba no
   es el verde, son las 5 sondas en rojo. Sin P1-P5, 55/0 no distingue "funciona" de
   "no mide nada".
4. **Dos implementaciones del mismo filtro (widget y backend) derivan en silencio.** El
   bloque F las corre sobre los mismos datos y exige identidad: es mas barato que confiar en
   que alguien las mantenga sincronizadas a mano.

## 10. Lo que NO hice

- **0 commits y 0 push**: el trabajo queda en el worktree; el commit lo autoriza el director.
- **0 flips aplicados** y **0 auto-sellos sec 21.8**: los 9 flips se proponen, no se aplican.
- **0 archivos ajenos tocados**: ni `CHECKLIST-GLOBAL.md`, ni `quality.yml`, ni `AGENTS.md`,
  ni `project.godot`, ni el `05-Checklist.md` de M110.
- **0 numeros del pool de mensajes tocados**: el mensaje va como `max + 1` (499).
