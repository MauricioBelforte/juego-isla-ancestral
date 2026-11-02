# Log 2300 - M110-UI: paneles REALES (D y E), TabBar y handler de senal

- **Fecha:** 2026-11-01 23:15
- **Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Modulo:** M110-Debug-Menu (seccion M110-UI)
- **Rama:** 2 (no habia mensaje nuevo del director: tracker 492 = max NN del canal)
- **Tarea:** item 17 de la COLA ACTIVA ("M110 b2: continuar"), cluster de WIDGETS de los paneles D y E.

## 1. Premisa medida antes de escribir

Medido sobre `DOCUMENTACION/110-Debug-Menu/plan-actual/05-Checklist.md`:

- marcas: **179 [x] / 46 [ ] / 0 [?] = 225**; la linea `**Totales:**` (L311) coincide (179/46/0).
- La COLA ACTIVA del BACKLOG-MASTER tiene **0 items `[ ]`** (12.a vuelta que lo reporto) y **5 `[->]`**.
  De los 5, cuatro estan cerrados o con premisa vencida (35 entregado, 36 y 102 premisa vencida,
  3 esperando decision de semantica del director) -> se tomo el 17, el unico con trabajo propio abierto.
- Los 4 flips que propuse en el informe 497 **no fueron aplicados** (M110 sigue en 179, no en 183).

## 2. Hallazgo central: la capa de UI era DECORATIVA, y son TRES defectos

Antes de esta tanda, `debug_menu_ui.gd` montaba un `TabBar` y un `RichTextLabel` que escribia
"Panel: Mundo". No habia **ni un widget** de los 13 que piden las secciones D y E.

Los tres defectos, cada uno MEDIDO con una sonda antes de tocar codigo:

1. **La escena nunca adjunto su script.** `scenes/debug/debug_menu.tscn` declara
   `[ext_resource type="Script" path="res://scripts/debug/debug_menu_ui.gd" id="1"]` pero el nodo
   raiz `[node name="DebugMenuUI" type="CanvasLayer"]` **no tenia la linea `script = ExtResource("1")`**.
   Medido: `escena.instantiate()` devuelve un `CanvasLayer` sin metodos
   (`SCRIPT ERROR: Nonexistent function 'obtener_tab_bar' in base 'CanvasLayer'`).
   Consecuencia en el juego real: el menu se instanciaba **sin comportamiento** (0 pestanas, 0 consola,
   boton de cerrar sin handler). La suite heredada `test_m110_ui3.gd` no lo cazaba porque solo comprueba
   que el script *carga* y que los nodos *existen*, no que este adjunto.
2. **TabBar con 0 pestanas.** `_configurar_tabs()` hacia `_tab_bar.tooltip_text = " | ".join(tabs)` con
   `tabs` = Array de **DICTIONARIES** del config. Medido: el join produce
   `{ "id": "jugador", ... } | { ... }` y `tab_count == 0` (TabBar nace en 0 y solo crece con `add_tab()`).
   La barra se veia VACIA y los nombres vivian en un tooltip ilegible.
3. **Handler de senal con el tipo equivocado.** Las senales del backend son
   `estacion_solicitada(estacion: int)` y `clima_solicitado(tipo_clima: int)` (debug_menu.gd:46/49) y los
   handlers declaraban `String`. Medido: `ERROR: Cannot convert argument 1 from int to String` y el
   handler **nunca corria** (`llamado` quedaba en 0): la consola no registraba la solicitud.

## 3. Entregado

- `scripts/debug/panels/panel_mundo.gd` (**NUEVO**, 251 lineas): los **8 widgets** de la seccion D
  cableados a la funcion publica del backend:
  Label hora (`hora_actual()`), OptionButton estacion (`set_season`), OptionButton clima (`set_weather`),
  LineEdit seed (`seed_generacion()`), Button Aplicar seed (`aplicar_seed`), SpinBox chunk X y Z +
  Button Regenerar (`regenerar_chunk(cx, cz)`). Catalogos REALES: 4 estaciones de
  `game_clock.gd:26 NOMBRES_ESTACIONES` y 9 climas via `Weather.get_nombre_clima(i)`.
- `scripts/debug/panels/panel_entidades.gd` (**NUEVO**, 240 lineas): los **5 widgets** de la seccion E:
  selector NPC (`VillagerManager.obtener_activos()`), Button Resetear NPC (`reset_npc`),
  Label estado IA (duck-typed `get_ai_state()` / `get_state_machine()` de M64), selector puzzle
  (nodos de la escena con `set_emisor()`, el mismo criterio que `_buscar_puzzle_room()`), Button
  Resetear puzzle (`reset_puzzle`).
- `scripts/debug/debug_menu_ui.gd` (REESCRITO, 189 lineas): `add_tab()` con los nombres del config,
  handlers en `int`, y las pestanas `mundo` / `entidades` montan los paneles reales.
- `scripts/debug/debug_menu.gd` (+39): `aplicar_seed(valor)` **nuevo**. El boton "Aplicar seed" no
  tenia backend (`seed_generacion()` es solo getter).
- `scenes/debug/debug_menu.tscn` (+1): `script = ExtResource("1")` en el nodo raiz.
- `scripts/debug/test_panels_m110.gd` (**NUEVO**, 417 lineas): suite de 10 bloques A-J.

### El detalle que hace honesto `aplicar_seed`

`world_seed` es una **propiedad** (`world_generator.gd:7`) y el generador real se construye en
`_get_island_gen()` (L21), que **cachea** `_island_gen` y solo lo reconstruye si esta nulo o invalido.
Asignar `world_seed` y nada mas cambia lo que devuelve `seed_generacion()` pero **deja el terreno con la
semilla vieja**: el boton "aplicaria" sin aplicar. Por eso `aplicar_seed()` invalida la cache
(`gen.set("_island_gen", null)`), y la respuesta lo declara en `cache_invalidada`. La cache se puede
invalidar sin riesgo porque `_instancia_global` (L18) mantiene la referencia fuerte para los threads de
VoxelTerrain. El bloque E de la suite lo verifica (E4/E5) y el bloque E6 prueba el fail-closed.

## 4. Evidencia medida

- Suite nueva `test_panels_m110.gd`: **53 checks / 0 fallos / EXIT 0 x3 corridas**, `SCRIPT ERROR: 0`.
  Piso `CHECKS_MINIMOS = 53` **MEDIDO** en verde (no estimado). Guard de 3 capas: `_fin(bloque)` en el
  cuerpo de cada bloque, piso de checks, y `_summary` en un `call_deferred` SEPARADO.
- **4 sondas EN ROJO**, cada una con `sha256` restaurado byte-exacto:
  - S1 aborto de **runtime** dentro del bloque C (por intermedio sin tipo): EXIT 1, nombra
    `bloque C NO se ejecuto`, dispara el piso (`50 < 53`) y **termina** (no cuelga).
  - S2 piso 999 > 53: EXIT 1.
  - S3 handler de estacion vuelve a `String` (defecto 2): EXIT 1, `bloque I NO se ejecuto`.
  - S4 TabBar vuelve al tooltip sin `add_tab` (defecto 1): EXIT 1, `H2 TabBar tiene 5 pestanas` en rojo.
  - Control final sin mutar: 53 / 0 / EXIT 0.
- **Regresion: 10 suites de M110 = 392 checks / 0 fallos / EXIT 0 x10**, `SCRIPT ERROR: 0`:
  config 75, control 75, entorno 61, visualizer-real 66, headless 22, iter-atria 27, ui 17, ui2 14,
  ui3 17, debug_m110 18.
- `--check-only` de los 4 `.gd` tocados: **EXIT 0 / 0 errores** cada uno (medido con el exit del
  PROCESO, no del pipe: la 1.a medicion dio "exit=0" siendo el de `head`, trampa 75).

## 5. Dos defectos PROPIOS corregidos en la misma vuelta

1. **E6 probaba mal el fail-closed.** `_inyectar_generador(null)` NO desactiva el descubrimiento:
   `_fuente_generador()` cae a buscar en el arbol y encontraba el `GeneradorFalso` del propio bloque
   -> E6 salio rojo con `ok=true` sobre codigo correcto. Fix: usar un backend **fuera del arbol**
   (`is_inside_tree()` == false devuelve null sin buscar).
2. **J2 probaba mal la ausencia de backend.** `_inyectar_menu(null)` hace que `_ready()` caiga al
   autoload real `/root/DebugMenu` -> el label mostraba "Hora: 08:00". El caso que importa es un backend
   **presente pero sin la funcion**: ahora se inyecta un `Node` pelado y el label dice `n/d`.

## 6. Trampas nuevas

1. **Una escena puede declarar su script y no adjuntarlo.** `[ext_resource type="Script"]` sin
   `script = ExtResource("1")` en el nodo raiz compila, importa, y la escena se instancia **sin
   comportamiento**. Una suite que solo comprueba "el script carga" y "los nodos existen" da verde.
   Chequeo de 2 segundos: `escena.instantiate().get_script() != null` (o llamar un metodo del script).
2. **`String.join()` sobre un Array de Dictionaries no falla: fabrica basura.** Convierte cada
   Dictionary a su `repr` y devuelve un string plausible que se puede asignar a `tooltip_text` sin
   error. El sintoma es un widget VACIO con datos ilegibles al lado.
3. **`_inyectar_X(null)` no siempre significa "sin X".** Si la funcion de descubrimiento tiene un
   fallback al arbol/autoload, inyectar null **activa** el fallback. Para probar el fail-closed hay que
   usar un objeto que no pueda resolver (fuera del arbol) o uno mutilado (sin el metodo).
4. **Windows: `Path.write_bytes()` puede dar `OSError Errno 22` al restaurar una sonda** (lock del
   indexer/AV). Un `finally: write_bytes(orig)` sin reintentos deja el archivo **mutado** -- paso de
   verdad: `debug_menu_ui.gd` quedo con el defecto inyectado y hubo que repararlo a mano. Reintentos
   (12 x 0.3 s) + verificacion de `sha256` en el `finally`, y si no restaura, ABORTAR ruidosamente.

## 7. Flips propuestos (NO aplicados: los aplica el director)

**13 nuevos de esta tanda** (evidencia: bloques A y F de la suite):

- L93 Label de hora actual, L94 Dropdown de estacion, L95 Dropdown de clima, L96 Input de seed,
  L97 Boton "Aplicar seed", L98 Input de chunk X, L99 Input de chunk Z, L100 Boton "Regenerar".
- L107 Selector de NPC, L108 Boton "Resetear" NPC, L109 Label de estado IA actual,
  L110 Selector de puzzle, L111 Boton "Resetear" puzzle.

**16 `[ ]` que ya estaban implementados** (medidos esta vuelta, siguen sin flipar):
L126 y L172 (Depurador3D sobre ImmediateMesh), L194 `show()`, L195 `hide()`, L198 `show_panel`,
L199 `hide_panel`, L200 `toggle_panel`, L226 `debug_menu_toggle`, L227 `debug_menu_close`,
L228 `_input`, L230 Escape, L231 mouse mode, L243 aviso de desarrollo, L244 log de accesos,
L263 FPS overlay, L268 visualizaciones solo si visible, L274 registrar DebugVisualizer.

Si se aplican los 29: **M110 pasaria de 179/46/0 a 208/17/0 = 225**.

**NO propongo flip** de L275 (registrar DiagnosticExporter: el exporter sigue embebido en
`debug_menu.gd`, no hay servicio que registrar) ni de L286-288 (refactor a `debug_commands.gd` /
`diagnostic_exporter.gd` / `panel_*.gd`: los paneles ya estan separados, pero el refactor del
monolito de 1404 lineas no se hizo).

## 8. Pendiente del director

- **Aplicar los 29 flips** (13 nuevos + 16 stale) o decir cual criterio usar para descartarlos.
- **Los 4 flips del informe 497** (L126/L172/L268/L274) siguen sin aplicar; los 16 de arriba los incluyen.
- **GO de commit** de los 6 paths de esta tanda (sin commit no hay push: 0/0 esta vuelta).
- **Decision de cola (13.a vuelta):** la COLA ACTIVA tiene 0 items `[ ]`. Si no repone, mi proxima
  vuelta vuelve a elegir entre los 5 `[->]`.
- **Pool de canal ROTO:** head 423 vs real 497 -> mensaje 498 = max+1, pool **NO tocado** (25.a vuelta).
- **`reservar_log.py --estado`: 12 problemas de numeracion AJENOS** (1878, 1888, 2120...). No se tocan.

## 9. Higiene de bytes

Los 6 archivos tocados: `bom=False`, **LF puro** (`crlf=0`), `fffd=0` (verificado por bytes).
Este log: ASCII puro + CRLF + sin BOM (verificado por bytes, no mirando).
