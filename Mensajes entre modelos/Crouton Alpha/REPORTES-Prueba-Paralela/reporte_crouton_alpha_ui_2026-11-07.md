**Modelo:** Crouton Alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08 03:07:45
**Tema:** Auditoría de escenas UI (.tscn) — mouse_filter, capas, nodos sin script
**Responde a:** ses_e4d1f112effe4cZuT7FoQz8GHy — request amr_1b920520a001nqVe7g1oWNf34W

# Reporte de revisión de escenas .tscn de UI — Crouton Alpha (2026-11-07)

## Alcance

Escaneo de `game/isla-ancestral/scenes/**/*.tscn` (50+ archivos). Archivos UI
relevantes:

| Archivo | Descripción |
|---|---|
| `scenes/ui/hud.tscn` | HUD principal (único `hud`) |
| `scenes/debug/debug_menu.tscn` | Menú de depuración |
| `scenes/main_island.tscn` | Escena principal (contiene `CanvasLayer "UI"`) |
| `scenes/main.tscn`, `main_test.tscn`, `main_simple.tscn`, `test_arquitectura.tscn`, `preview_particles.tscn` | Escenas auxiliares con UI mínima |

Patrones buscados: `mouse_filter`, `CanvasLayer`, `layer = `, `type="Button"`,
`type="Control"`, `type="Panel"`, `mouse_filter = 0/1`, `MOUSE_FILTER_STOP/PASS`.

## (1) Nodos Control con mouse_filter = STOP (0) que bloqueen clicks

**En escenas `.tscn` (buscado `mouse_filter`):**
- Ningún `.tscn` del proyecto declara `mouse_filter = 0` o `= 1`. Todos los
  nodos declarativos usan `mouse_filter = 2` (IGNORE) — correctos y no
  bloqueantes:
  - `hud.tscn`: 15 nodos, todos `mouse_filter = 2` (líneas 24, 29, 40, 45,
    52, 64, 69, 84, 89, 105, 110, 120, 133, 138, 148). Incluye overlays
    full-screen `ActionPromptOverlay` (línea 113) y `FullMapLayer` (línea
    141), ambos con IGNORE — correcto.
  - `main_island.tscn`: `StatusBar` (línea 129), `InteractPrompt` (línea
    139), `MinimapWidget` (línea 153), todos `mouse_filter = 2` — correcto.

**En scripts (runtime, fuera del `.tscn`, pero relevantemente para el bloqueo):**
- `scripts/mapa/full_map_layer.gd:32` y `:41` — `MOUSE_FILTER_STOP`
  intencional (mapa fullscreen debe capturar clicks solo cuando abierto).
- `scripts/player/player.gd:585` — `bg.mouse_filter = MOUSE_FILTER_STOP`
  (panel de inventario/equip creado por código).
- `scripts/player/player.gd:702` — `slot_panel.mouse_filter =
  MOUSE_FILTER_STOP`.
- Un solo `mouse_filter = 1` (PASS) en el repo: solo en addon
  `GdUnitReportPanel.tscn:25` (no es juego).

**Conclusión (1):** No hay bloqueos declarativos en `.tscn`. Los `STOP` son
runtime e intencionales (mapa, inventario). Riesgo residual: si `FullMapLayer`
queda visible con `STOP` sin expandirse, bloquea toda la pantalla — verificar
en `full_map_layer.gd` que `_expanded = false` aplique
`mouse_filter = IGNORE` al colapsarse.

## (2) CanvasLayer con orden incorrecto que cubra botones

Inventario de capas `CanvasLayer`:

| Escena/script | Nivel (`layer`) | Nota |
|---|---|---|
| `hud.tscn:15` `HUDScreen` | 100 | — |
| `debug/debug_menu.tscn:7` `DebugMenuUI` | 100 | Mismo layer que HUD — ver abajo |
| `main_island.tscn:97` `UI` | 0 (default) | — |
| `main.tscn:61`, `main_test.tscn:64`, `main_simple.tscn:45`, `test_arquitectura.tscn:8`, `preview_particles.tscn:47` `UI` | 0 (default) | 5 escenas auxiliares, sin `layer` explícito |
| `scripts/ui/ui_root.gd:36` `UIRoot` | 100 | Capa modal (M53), mismo nivel que HUD |
| `scripts/ui/subtitle_manager.gd:76` `_capa` | 90 | Debajo de HUD, correcto |
| `scripts/fasttravel/fast_travel_effect.gd:4-5` | -1 | Debajo de HUD, correcto (documentado) |

**Problemas detectados:**
- **Colisión de nivel 100 entre `HUDScreen` (`hud.tscn:15`) y `UIRoot`
  (`scripts/ui/ui_root.gd:36`)**: HUD y capa modal comparten el mismo layer.
  No bloquea clicks (ambos heredan `mouse_filter` de sus hijos, no del
  CanvasLayer), pero el orden depende del orden de adición en runtime — si
  `UIRoot` se monta después, los modales quedan encima; si antes, el HUD
  queda encima de la pausa/menús. **Recomendación:** subir `UIRoot` a
  `layer = 200` (o HUD a 50) para garantizar modales > HUD.
- **Colisión adicional:** `DebugMenuUI` (`debug_menu.tscn:7`) también usa
  100. Si se instancia junto al HUD, compiten en orden de árbol.
  **Recomendación:** debug a `layer = 50` o `200`.
- **HUD/menú no tienen orden incorrecto que cubra botones** (no hay botón
  bajo un CanvasLayer más alto por nivel), pero la ambigüedad del 100
  compartido es el riesgo real — cualquier `TopLeft/TopRight` fullscreen no
  existe (son esquinas, no cubren botones).
- **Procedurales sin `layer` explícito** (`player.gd:576` canvas de
  inventario): se crea en runtime, hereda 0; si coexiste con el HUD (100),
  queda debajo visualmente. No es un bloqueo, pero puede tapar su feedback.

## (3) Nodos sin script que deberían tener interacción

**`debug_menu.tscn` (el caso más grave):**
- `RootPanel` (`Panel`, línea 9) — sin script, sin `mouse_filter` declarado,
  sin `visible`/`mouse_mode`. Es un `Panel` full-screen (anchors completos)
  con terreno por defecto **STOP** que captura todos los clicks hacia la
  capa 100 — si el panel se deja visible en runtime, bloquea el juego
  debajo. No tiene lógica de ocultación en el tscn.
- `TitleBar` (`HBoxContainer`, línea 18), `TitleLabel` (`Label`, línea 28),
  `ContentPanel` (`Control`, línea 48) — sin script y sin `mouse_filter`;
  heredan STOP por defecto (`Control` default) — los contenedores no
  deberían capturar; deben llevar `mouse_filter = 2`.
- `CloseButton` (`Button`, línea 33-36) — sin script asociado en el tscn.
  La escena (`DebugMenuUI`) sí tiene script
  (`scripts/debug/debug_menu_ui.gd`) a nivel raíz, pero la conexión
  `pressed → cerrar` debe estar en código — verificar que
  `debug_menu_ui.gd` conecta `CloseButton.pressed` (no se confirma en el
  `.tscn`).
- `TabBar` (`TabBar`, línea 38-46) — sin script; el contenido de pestañas
  se espera en runtime; el tscn no define pestañas del editor.

**`hud.tscn`:**
- Los 8 widgets tienen script propio (correcto: `hud_screen.gd`,
  `status_bar.gd`, `clock_widget.gd`, `season_widget.gd`,
  `resource_counter.gd`, `hotbar_widget.gd`, `interact_prompt.gd`,
  `action_prompt_overlay.gd`, `minimap_widget.gd`, `full_map_layer.gd`).
  Los contenedores (`TopLeft`, `TopRight`, `TopCenter`, `BottomCenter`,
  `CenterBottom`, `BottomRight`) no tienen script — **correcto y esperado**
  (solo anclan hijos, llevan `mouse_filter = 2`).
- `FullMapLayer` (`Control`, línea 141) — tiene script (`full_map_layer.gd`)
  pero `mouse_filter = 2` en el tscn contradice el `MOUSE_FILTER_STOP` que
  impone el script en runtime (`full_map_layer.gd:32`). Si el script solo
  aplica STOP cuando abierto y el tscn ya deja IGNORE, es coherente; si no,
  ver el punto (1).

**`main_island.tscn`:**
- `FPSLabel` (`Label`, línea 99) y `ControlsLabel` (`Label`, línea 107) —
  sin script, sin `mouse_filter` declarado. Los `Label` por defecto tienen
  `mouse_filter = 0`? No: `Label` hereda de `Control` cuyo default es
  `MOUSE_FILTER_STOP`, pero los `Label` en la práctica no roban clicks de
  gameplay porque no son interactivos — aun así, es mala práctica:
  **deberían llevar `mouse_filter = 2`** como sus vecinos (`StatusBar`,
  `InteractPrompt`, `MinimapWidget`).
- `RelojWidget` (`PanelContainer`, línea 119) — **con script**
  (`scripts/clock/w_reloj.gd`), pero **sin `mouse_filter` declarado** en el
  tscn. En `w_reloj.gd:91` el script aplica `MOUSE_FILTER_IGNORE` a un
  tooltip, no al propio widget. El `PanelContainer` nace con STOP default —
  si no se le pone IGNORE en el `.tscn`, bloquea un área pequeña de la
  esquina; peor, el `PanelContainer` como contenedor con script que lo
  mueve al runtime puede no tener el filtro sincronizado. **Añadir
  `mouse_filter = 2` a `main_island.tscn:119`.**
- `UI` (`CanvasLayer`, línea 97) — sin script. Correcto si el HUD se
  inyecta desde `main_island.gd`/`ui_root.gd` en runtime; no es un nodo
  que "debería" tener script propio.

**Resto de escenas auxiliares:** `main.tscn`, `main_test.tscn`,
`main_simple.tscn`, `test_arquitectura.tscn`, `preview_particles.tscn` —
todos contienen únicamente `FPSLabel`/`ControlsLabel`/`Label` bajo `UI`
sin `mouse_filter` declarado y sin script. Misma observación que en
`main_island.tscn`: `Label` no es interactivo, pero **debería llevar
`mouse_filter = 2` explícito** para no heredar STOP.

## (4) Problemas con archivo:línea

| # | Archivo | Línea | Problema |
|---|---|---|---|
| P1 | `debug/debug_menu.tscn` | 9 (`RootPanel`, `Panel` full-screen) | Sin `mouse_filter` ni `visible=false`; por defecto captura clicks (STOP) sobre capa 100. Debe llevar `mouse_filter = 2`, `visible = false` en edición o gestionarse en `debug_menu_ui.gd`. |
| P2 | `debug/debug_menu.tscn` | 18 (`TitleBar`), 48 (`ContentPanel`, `Control`) | Contenedores sin `mouse_filter = 2` — heredan STOP y pueden capturar clicks sin ser interactivos. |
| P3 | `debug/debug_menu.tscn` | 33 (`CloseButton`) | Sin script asociado en el `.tscn`. Verificar conexión `pressed` en `scripts/debug/debug_menu_ui.gd`. |
| P4 | `debug/debug_menu.tscn` | 7 | `layer = 100` colisiona con `HUDScreen` (100) y `UIRoot` (100) — orden ambiguo. |
| P5 | `ui/hud.tscn` | 15 (`HUDScreen`) | `layer = 100` compartido con `UIRoot` (`scripts/ui/ui_root.gd:36`) — modales pueden quedar debajo del HUD según orden de montaje. Recomendado: subir `UIRoot` a 200. |
| P6 | `main_island.tscn` | 119 (`RelojWidget`, `PanelContainer`) | Sin `mouse_filter = 2` declarado; hereda STOP. Añadir `mouse_filter = 2`. |
| P7 | `main_island.tscn` | 99 (`FPSLabel`), 107 (`ControlsLabel`) | Sin `mouse_filter = 2`; heredan STOP (aunque `Label` no es interactivo, es deuda). |
| P8 | `main.tscn` | 63, 71 | `FPSLabel`/`ControlsLabel` sin `mouse_filter`. Igual que P7. |
| P9 | `main_test.tscn` | 66, 74 | `FPSLabel`/`ControlsLabel` sin `mouse_filter`. Igual que P7. |
| P10 | `main_simple.tscn` | 47, 55 | `FPSLabel`/`ControlsLabel` sin `mouse_filter`. Igual que P7. |
| P11 | `test_arquitectura.tscn` | 10 (`Label`) | Sin `mouse_filter`. Igual que P7 (escena de test, baja prioridad). |
| P12 | `preview_particles.tscn` | 49 (`FPSLabel`) | Sin `mouse_filter`. Igual que P7. |
| P13 | `ui/hud.tscn` | 141 (`FullMapLayer`) + `scripts/mapa/full_map_layer.gd:32,41` | Discrepancia declarativo vs runtime: tscn pone IGNORE, script impone STOP en runtime. Correcto si es condicional a apertura; verificar que al cerrar restaura IGNORE, o el mapa bloquea toda la pantalla. |

## Veredicto

- **(1)** OK en `.tscn` — ningún `Control` con `STOP` declarado. Riesgos
  solo runtime (`full_map_layer`, inventario).
- **(2)** No hay orden incorrecto que tape botones, pero sí ambigüedad de
  capa 100 (`HUDScreen` vs `UIRoot` vs `DebugMenuUI`) — P4/P5 son el
  hallazgo principal.
- **(3)** `debug_menu.tscn` (P1-P3) es el caso grave: panel full-screen sin
  filtros ni wiring visible. El resto (P6-P12) es deuda menor de
  `mouse_filter` no declarado en `Label`/`PanelContainer` de una línea.

**Firma:** Crouton Alpha
