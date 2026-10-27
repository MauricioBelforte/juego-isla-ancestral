# Log 2214 - M110 Debug Menu - Persistencia de estado (seccion N)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-27 02:47 (GMT-3)
**Modulo:** M110-Debug-Menu
**Rama:** RAMA 1 procesada (msg 429 = acuse sin tarea nueva) + RAMA 2 (tanda propia)

## 1. Entrada

- Tracker previo: 427. Mensaje nuevo del canal: **429** de agnes-3-flash
  (acuse del 428: M48 re-elegible, M60 honesto, fila 48 aplicada, 3 GOs del
  fundador pendientes). **Sin tarea ejecutable**: los 5 pedidos restantes son
  GO del fundador (commits M48/M55, cableado de `quality.yml`, 5 flips M55) y
  el gate-2 runtime es de Hy3. Tracker -> **429**.
- Sin instruccion nueva -> RAMA 2 sobre la COLA ACTIVA.

## 2. Premisa medida antes de elegir la tanda

Conteo por prefijo `^\s*- \[([ x?])\]` sobre `plan-actual/05-Checklist.md` de
los 167 modulos: **39 modulos con `[ ]`**. Los items de la cola con premisa
VENCIDA (0 pendientes reales) medidos hoy: M123 (108/0/0), M118, M62, M124,
M69, M99, M64, M14, M30, M32, M93, M52. NO ejecutables.

Item elegido: **17 - "M110 b2: continuar (integracion con telemetria M105)"**.
Medido: M110 = **172 `[x]` / 53 `[ ]` / 0 `[?]` = 225**. La premisa
"integracion con telemetria M105" NO existe como pendiente en el checklist
(grep de `telemetr` en los 53 `[ ]` = 0); lo que si hay es un cluster coherente
de **7 items de la seccion N (Configuracion y persistencia)** sin artefacto:

- `save_config()`, `reset_config()`
- guardar posicion y tamano
- guardar visibilidad de paneles
- guardar estado de toggles
- guardar filtros de consola
- guardar configuracion al cerrar

Antes de tocar: `git status --porcelain` de `scripts/debug/` vacio y
`git ls-files --eol` = `w/crlf`, `attr/text=auto eol=lf` -> sin trabajo ajeno
en vuelo; EOL respetado (archivo final 1008 CRLF, 0 LF suelto, sin BOM).

## 3. Entregado (codigo)

`game/isla-ancestral/scripts/debug/debug_menu.gd` (+152 lineas netas):

- Constantes `RUTA_ESTADO = "user://debug_menu_estado.json"` y
  `VERSION_ESTADO = 1`. El estado de sesion va a `user://` porque el build
  exportado es de solo lectura; el config de pestanas/comandos sigue en
  `res://` y NO se toca.
- `estado_actual()` = unica fuente de verdad de lo que se serializa (lo que se
  guarda y lo que se lee no pueden divergir).
- `save_config()` con escritura temporal + rename y fallback a escritura
  directa (Windows con lock); `_escribir_archivo()` es el unico punto de I/O.
- `reset_config()`: vuelve a defaults, borra el archivo y deja el estado limpio.
- `_cargar_estado()` fail-closed: sin archivo, JSON invalido o VERSION distinta
  -> defaults y NO se pisa el archivo. `_aplicar_estado()` valida campo por
  campo (un valor corrupto cae al default de ESE campo).
- `set_geometria()`/`get_geometria()`, `set_panel_visible()`/`panel_visible()`/
  `paneles_visibles()`, `toggle_activo(id)`.
- `set_filtros_consola()`/`filtros_consola()`/`aplicar_filtros_consola()`:
  `nivel`/`categoria` = -1 significa todos; `busqueda` case-insensitive;
  `autoscroll` es preferencia (no filtra).
- `_console_entradas: Array[Dictionary]` paralela a `_console_lines`, para que
  los filtros puedan discriminar por nivel/categoria sin romper el contrato
  previo de `console_get_lines()` (devuelve TODAS).
- `_notification(EXIT_TREE | WM_CLOSE_REQUEST)` -> `save_config()` SOLO si
  `_estado_sucio`. Un arranque sin cambios no genera escrituras.
- Los 6 `toggle_*` marcan sucio (defecto detectado por la propia suite: sin
  `_marcar_sucio()` el item "guardar estado de toggles" quedaba muerto).

`game/isla-ancestral/scripts/debug/test_debug_menu_config_m110.gd` (NUEVO, 339
lineas, LF, sin BOM): 7 bloques A-G. Guardia de 3 capas: `_fin()` al FINAL del
cuerpo de cada bloque, `CHECKS_MINIMOS` **medido en verde**, `_summary()` en un
`call_deferred` separado. La suite NO agrega el menu al arbol (no dispara
`_ready`); el cableado de `_ready`/`_notification` se verifica de forma
estatica (bloque G) para que la persistencia no sea codigo muerto.

## 4. Evidencia medida

- Suite nueva: **75 checks / 0 fallos / EXIT 0 x3** (A 14, B 9, C 18, D 9,
  E 11, F 7, G 7). Piso `CHECKS_MINIMOS = 75` MEDIDO, no estimado.
- Guardian probado EN ROJO x3 (restauracion con reintentos + sha256 verificado):
  1. aborto de RUNTIME en el bloque C -> EXIT 1 en 1 corrida, nombra
     `el bloque C NO se ejecuto`, dispara el piso (58 < 75) y **termina**
     (no cuelga). sha suite restaurado `bf3fd7a9...`.
  2. quitar `_marcar_sucio()` de `toggle_chunks` -> `[FALLO] F7
     WM_CLOSE_REQUEST tambien guarda`, EXIT 1. sha impl restaurado
     `ca8e2d79...`.
  3. `CHECKS_MINIMOS = 99` -> `solo 75 checks ejecutados (minimo medido 99)`,
     EXIT 1.
- Control final post-sondas: 75/0/EXIT 0 y **sha256 de los 2 archivos identico
  al original** (nada quedo inyectado).
- Regresion M110 (6 suites, 115 checks): `test_debug_m110` 18/0,
  `test_debug_menu_headless` 22/0, `test_m110_iter_atria` 27/0,
  `test_m110_ui` 17/0, `test_m110_ui2` 14/0, `test_m110_ui3` 17/0. Todas
  EXIT 0, 0 SCRIPT ERROR.
- `--check-only` EXIT 0 en los 2 archivos.
- EOL/BOM: `debug_menu.gd` 1008 CRLF / 1008 LF / 0 CR suelto / sin BOM
  (w/crlf preservado); suite nueva LF puro, sin BOM.

## 5. Hallazgos para la directora

1. **La cola esta mayormente VENCIDA**: 12 de los items medidos ya no tienen
   pendientes reales (M123 108/0/0, M118, M62, M124, M69, M99, M64, M14, M30,
   M32, M93, M52). Conviene reponer con conteo medido, no con el numero que
   figura en el titulo del item.
2. **El item 17 no es de telemetria**: no hay ningun pendiente de integracion
   con M105 en M110. El cluster real de M110 es UI (M110-UI) + persistencia (N).
3. **Los 53 `[ ]` de M110 son casi todos de M110-UI** (widgets: labels,
   dropdowns, inputs, botones, filtros visuales de consola). Con esta tanda,
   el backend ya tiene TODO lo que la UI necesita para persistir su estado:
   `get_geometria()`, `paneles_visibles()`, `toggle_activo()`,
   `filtros_consola()`.
4. **`_console_lines` no guardaba nivel/categoria** (se descartaban en
   `_on_logger_line`): sin `_console_entradas` el item "guardar filtros de
   consola" habria sido un flip inflado, porque no habia nada que filtrar.

## 6. Marcas

- **0 flips aplicados.** No toque `05-Checklist.md` (archivo protegido sin
  orden escrita). Propuestos para que los aplique la directora:
  N: `save_config()` -> `[x]`, `reset_config()` -> `[x]`, "Guardar posicion y
  tamano" -> `[x]`, "Guardar visibilidad de paneles" -> `[x]`, "Guardar estado
  de toggles" -> `[x]`, "Guardar filtros de consola" -> `[x]`, "Guardar
  configuracion al cerrar" -> `[x]` (7 items). M110 pasaria de 172/53/225 a
  **179/46/225**.
- Backlog: item 17 marcado `[->]` con la evidencia (no `[x]`: la capa UI de
  M110 sigue abierta).

## 7. Numeracion

- Log **2214** reservado con `scripts/reservar_log.py --reservar` (cabeza
  medida justo antes: primero libre 2214).
- Canal **430** = ultimo archivo (429) + 1; 430 consumido del pool.
  El pool trae lineas stale (su primera linea dice 423) - trampa conocida.

## 8. Limites

0 commits / 0 push / 0 flips / 0 auto-sellos 21.8 / 0 archivos protegidos
tocados (`CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`,
`05-Checklist.md`).
