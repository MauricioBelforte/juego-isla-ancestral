# M110 - Capa de control, input y avisos (M110-UI)

- **Modelo:** DeepSeek-V4.1-Flash
- **Plataforma:** WorkBuddy
- **Fecha:** 2026-10-27 04:03 (GMT-3)
- **Modulo:** M110-Debug-Menu (seccion M110-UI)
- **Rama:** RAMA 1 (acuse del msg 431) + RAMA 2 (item 17 de la COLA, en curso)

## Entrada

El mensaje 431 de la directora agnes-3-flash es un **acuse sin tarea ejecutable**:
ella aplica los 7 flips de la seccion N y sincroniza la fila GLOBAL de M110; los 5 GOs
del fundador siguen con el fundador. Tracker 429 -> **431**.

## Medicion previa (antes de escribir una sola cifra)

M110 `05-Checklist.md`: **179 [x] / 46 [ ] / 0 [?] = 225**. Los 7 flips de la seccion N
ya estan aplicados (172/53 -> 179/46): coincide con lo que declara el msg 431.

De los 46 `[ ]`, el cluster con artefacto posible sin escena de UI es la capa de control:
API de visibilidad y paneles (L194/L195/L198/L199/L200), input por acciones
(L226/L227/L228/L230/L231), gate de visualizaciones (L268) y log de accesos (L244).

## Entregado

### `scripts/debug/debug_menu.gd` (+239 lineas netas)

Seccion nueva **Q. Capa de control, input y avisos**, con el contrato de `03-Diseno.md`
**seccion 2** (API) y **seccion 6** (input):

- `show()` / `hide()` / `toggle()` / `is_visible()` - devuelven `true` si el estado cambio.
  `alternar()` y `esta_visible()` quedan como alias historicos.
- `show_panel(id)` / `hide_panel(id)` / `toggle_panel(id)` - devuelven el estado resultante.
- `_fijar_visible()` como **unico** punto que asigna `visible` (mouse mode + log + refresco
  del overlay). La version anterior de `alternar()` asignaba `visible` directo y se saltaba
  las tres cosas.
- `_registrar_acciones()` + `_asegurar_evento()`: registran `debug_menu_toggle` (F1 +
  Backtick) y `debug_menu_close` (Escape) en **runtime** via `InputMap`. `project.godot`
  NO se toca. Idempotente: la segunda llamada agrega 0 eventos.
- `_input(event)` (no `_unhandled_input`) para que un `Control` con foco no se coma la
  tecla. Escape cierra **solo** si el menu esta abierto: no abre.
- `_aplicar_mouse_mode()` / `mouse_mode_deseado()`: al abrir pide `MOUSE_MODE_VISIBLE`, al
  cerrar restaura el **previo**. En headless solo registra la intencion.
- `visualizacion_activa(id)` / `visualizaciones_activas()`: condicion EFECTIVA de dibujo =
  `visible and toggle_activo(id)`. Overhead cero con el menu cerrado (seccion 7).
- `_registrar_acceso()` / `accesos_registrados()` / `ultimo_acceso()`: log de accesos al
  menu (GameLogger si existe; si no, contador local).
- `aviso_desarrollo()` / `es_build_de_desarrollo()`: texto del aviso obligatorio.
- `fps_overlay_texto(ahora_ms)` / `fps_ultimo_ms()`: overlay con refresco acotado a **500 ms**
  y reloj **inyectable** (suite hermetica).
- F12 se conserva como alias de **LEGADO** en `_unhandled_input`: el fix del 2026-09-02 lo
  cableo ahi y `test_debug_menu_headless.gd:123-128` lo verifica.

### `scripts/debug/test_debug_menu_control_m110.gd` (NUEVA, 8 bloques A-H)

## Evidencia medida

- Suite nueva: **75 checks / 0 fallos / EXIT 0 x3 corridas**, `SCRIPT ERROR` = 0 en las 3.
- Piso `CHECKS_MINIMOS = 75` **MEDIDO** en verde (A 11 + B 13 + C 10 + D 9 + E 5 + F 9 +
  G 7 + H 11). La primera version lo dejo en 71 "por las dudas" y se corrigio al valor real.
- Regresion M110, 7 suites preexistentes: **190 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR**
  (`config` 75, `headless` 22, `debug_m110` 18, `iter_atria` 27, `ui` 17, `ui2` 14, `ui3` 17).
  Con la nueva: **265 checks / 0 fallos**.
- `--check-only` sobre `debug_menu.gd`: EXIT 0.
- Consumidores externos de la API: 0 llamadas reales (`house_manager.gd:24` declara
  `_debug_menu` sin usarlo; `crash_debug_menu.gd:13` solo lo menciona en un comentario).

## Sondas EN ROJO (4/4, sha256 restaurado)

| Sonda | Inyeccion | Resultado |
|---|---|---|
| S1 | aborto de runtime al inicio del bloque D (`_sonda[5]` sobre `Array` vacio) | EXIT 1, nombra `D`, dispara el piso (67 < 75), **no cuelga** |
| S2 | quitar el guard de idempotencia de `_fijar_visible` | EXIT 1, rojo en A4 y A9 |
| S3 | piso 75 -> 99 | EXIT 1, `solo 75 checks ejecutados (minimo medido 99)` |
| S4 | neutralizar la guarda de Escape en `_input` | EXIT 1, rojo en D7 (y D8 por arrastre) |

Restauracion: 4/4 con sha256 identico al de partida, en 1 intento cada una.

## Trampas confirmadas y una nueva

1. **Un aborto de runtime NO salta los bloques siguientes.** Medido en S1: el error en el
   bloque D aborta SOLO esa funcion y el llamador RETOMA, asi que E-H si corren. Lo que
   delata el hueco es (a) el bloque nombrado y (b) el piso. La expectativa inicial de la
   sonda ("E tampoco corre") era FALSA y se corrigio con la medicion.
2. **Tipo inferido con `Node`.** `var x := _menu.metodo()` es PARSE ERROR cuando `_menu` esta
   tipado `Node` (el retorno es Variant). 5 variables hubo que tipar a mano.
3. **NUEVA: el editor deja el archivo en CRLF y el repo es `eol=lf`.** Tras la edicion,
   `git ls-files --eol` paso a `i/lf w/crlf` (1247 CRLF) mientras el resto de la familia
   `scripts/debug/` es `w/lf`. Se normalizo a LF antes de seguir: sin eso, dos aserciones
   estaticas (H2/H3) fallaban porque el archivo tenia `\r\n` y la asercion buscaba `\n`.
   `git diff --numstat` fue identico con y sin `--ignore-cr-at-eol` (514/2), o sea que el
   contenido no estaba mal: solo el EOL.
4. **Una asercion mal planteada tambien es un falso rojo.** E3 pedia "al cerrar, un modo
   distinto de VISIBLE"; en headless el modo previo **ES** VISIBLE, asi que la asercion
   correcta es "restaura el previo". Se corrigio la asercion, no el codigo.

## Estado de las marcas

**0 flips aplicados** (los aplica la directora). Propuestos, con evidencia:

- **12 solidos:** L194, L195, L198, L199, L200, L226, L227, L228, L230, L231, L244, L268.
  Efecto: **179/46 -> 191/34**.
- **2 en su MODELO (no propongo flip):** L243 (texto del aviso; falta el banner visual) y
  L263 (modelo del overlay; falta el `Label`).
- **Siguen abiertos por proteccion:** L233 (`Input Map en Project Settings`) requiere
  `project.godot`, que es NO TOCAR. Las acciones se resuelven en runtime; el item pide el
  archivo.
- **Ya implementados en la vuelta anterior, medibles:** L132/L133/L134/L147/L148/L149
  (filtros de consola: `set_filtros_consola()` + `aplicar_filtros_consola()`) y L139
  (`save_config()` existe; falta el boton de la escena).

## Limites

0 commits, 0 push, 0 archivos protegidos tocados (`CHECKLIST-GLOBAL.md`, `quality.yml`,
`AGENTS.md`, `project.godot` y `05-Checklist.md` intactos). No se toco el runtime de otros
modulos. Pool de Logs: cabeza medida 2216, consumido 2216. Pool de canal: 432 consumido
(ultimo archivo 431 + 1; el 432 estaba en el pool).

## Numeros

- Log: **2216**
- Mensaje: **432**
- Tracker: 429 -> **431**
